import { type DocumentSnapshot, FieldValue, type Transaction } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { pushOrderCustomer } from "../push";
import { creditRiderDelivery } from "./effects";
import { deliveryEarning } from "./earnings";
import { CANNOT_DELIVER_REASONS, MAX_CODE_ATTEMPTS, type RiderStage } from "./model";
import { requireRider } from "./rider_auth";

/**
 * The rider's steps on their active order:
 * accepted → (reached store → picked up, per store) → out for delivery →
 * arrived → delivered (code + cash) — or "can't deliver" → ops decides.
 * Status changes write an order event like ops' changes, so the customer
 * gets the same pushes and tracking timeline.
 */

const ORDERS = "orders";

interface Ctx {
  order: DocumentSnapshot;
  data: Record<string, unknown>;
  rider: DocumentSnapshot;
}

function orderIdOf(raw: unknown): string {
  if (typeof raw !== "string" || !/^[\w-]{1,64}$/.test(raw)) {
    throw new HttpsError("invalid-argument", "Invalid orderId");
  }
  return raw;
}

/** Runs `step` in a transaction on the rider's own, still-open order. */
async function onMyOrder<T>(
  riderId: string,
  orderIdRaw: unknown,
  step: (tx: Transaction, c: Ctx) => Promise<T>,
): Promise<T> {
  const orderRef = db.collection(ORDERS).doc(orderIdOf(orderIdRaw));
  return db.runTransaction(async (tx) => {
    const [order, rider] = await Promise.all([tx.get(orderRef), tx.get(db.collection("riders").doc(riderId))]);
    if (!order.exists || order.get("riderId") !== riderId) {
      throw new HttpsError("permission-denied", "NOT_YOUR_ORDER");
    }
    const status = order.get("status") as string;
    if (status === "cancelled") throw new HttpsError("failed-precondition", "ORDER_CANCELLED");
    if (status === "delivered") throw new HttpsError("failed-precondition", "ALREADY_DELIVERED");
    return step(tx, { order, data: order.data()!, rider });
  });
}

const stageOf = (d: Record<string, unknown>) => (d.riderStage as RiderStage | undefined) ?? "accepted";

function event(tx: Transaction, order: DocumentSnapshot, status: string, by: string, note?: string) {
  tx.create(order.ref.collection("events").doc(), {
    status,
    createdAt: FieldValue.serverTimestamp(),
    by,
    ...(note ? { note } : {}),
  });
}

/** Stores still to visit (an order can be filled from several). */
function storesOf(d: Record<string, unknown>): string[] {
  const allocations = (d.allocations as { storeId?: string }[] | undefined) ?? [];
  return [...new Set(allocations.map((a) => a.storeId).filter((s): s is string => !!s))];
}

/** Request: {orderId, storeId?}. */
export const riderReachedStore = onCall(async (request) => {
  const rider = await requireRider(request);
  return onMyOrder(rider.id, request.data?.orderId, async (tx, { order, data }) => {
    if (!["accepted", "at_store"].includes(stageOf(data))) throw new HttpsError("failed-precondition", "WRONG_STEP");
    const stores = storesOf(data);
    const storeId = typeof request.data?.storeId === "string" ? request.data.storeId : stores[0];
    if (stores.length && !stores.includes(storeId)) throw new HttpsError("invalid-argument", "Invalid store");
    tx.update(order.ref, {
      riderStage: "at_store",
      [`pickups.${storeId ?? "store"}.reachedAt`]: FieldValue.serverTimestamp(),
    });
    return { ok: true };
  });
});

/**
 * Request: {orderId, storeId?}. Allowed once the store marked the order
 * packed; when the last store is picked up the order goes out for delivery.
 */
export const riderPickUp = onCall(async (request) => {
  const rider = await requireRider(request);
  return onMyOrder(rider.id, request.data?.orderId, async (tx, { order, data }) => {
    if (!["accepted", "at_store"].includes(stageOf(data))) throw new HttpsError("failed-precondition", "WRONG_STEP");
    if (data.status !== "packed") throw new HttpsError("failed-precondition", "NOT_PACKED_YET");
    const stores = storesOf(data);
    const storeId = typeof request.data?.storeId === "string" ? request.data.storeId : stores[0];
    if (stores.length && !stores.includes(storeId)) throw new HttpsError("invalid-argument", "Invalid store");
    const pickups = (data.pickups ?? {}) as Record<string, { pickedAt?: unknown }>;
    const done = new Set(Object.entries(pickups).filter(([, v]) => v?.pickedAt).map(([k]) => k));
    done.add(storeId ?? "store");
    const allDone = stores.every((s) => done.has(s));
    tx.update(order.ref, {
      [`pickups.${storeId ?? "store"}.pickedAt`]: FieldValue.serverTimestamp(),
      ...(allDone
        ? {
            status: "out_for_delivery",
            outForDeliveryAt: FieldValue.serverTimestamp(),
            riderStage: "picked_up",
            updatedAt: FieldValue.serverTimestamp(),
          }
        : { riderStage: "at_store" }),
    });
    if (allDone) event(tx, order, "out_for_delivery", rider.id);
    return { ok: true, outForDelivery: allDone, remainingStores: stores.filter((s) => !done.has(s)) };
  });
});

/** Request: {orderId}. Tells the customer their rider is outside. */
export const riderArrived = onCall(async (request) => {
  const rider = await requireRider(request);
  const res = await onMyOrder(rider.id, request.data?.orderId, async (tx, { order, data }) => {
    if (data.status !== "out_for_delivery") throw new HttpsError("failed-precondition", "WRONG_STEP");
    const first = stageOf(data) !== "at_customer";
    tx.update(order.ref, {
      riderStage: "at_customer",
      ...(first ? { riderArrivedAt: FieldValue.serverTimestamp() } : {}),
    });
    return { ok: true, first, orderId: order.id };
  });
  if (res.first) {
    await pushOrderCustomer(
      res.orderId,
      { title: "Your rider is here", body: "Your Zyppi order is at your door. Keep your delivery code ready." },
      { status: "rider_arrived" },
    );
  }
  return { ok: true };
});

/**
 * Request: {orderId, code, cashCollected}. The customer's 4-digit code
 * (orders/{id}/private/handover) must match; cash orders must confirm the
 * cash. Delivers the order and credits the rider (counters, cash, pay, tip).
 */
export const riderDeliver = onCall(async (request) => {
  const rider = await requireRider(request);
  const code = typeof request.data?.code === "string" ? request.data.code.trim() : "";
  if (!/^\d{4}$/.test(code)) throw new HttpsError("invalid-argument", "WRONG_CODE");
  const outcome = await onMyOrder(rider.id, request.data?.orderId, async (tx, { order, data, rider: r }) => {
    if (data.status !== "out_for_delivery") throw new HttpsError("failed-precondition", "WRONG_STEP");
    const handoverRef = order.ref.collection("private").doc("handover");
    const handover = await tx.get(handoverRef);
    const attempts = (handover.get("attempts") as number | undefined) ?? 0;
    if (attempts >= MAX_CODE_ATTEMPTS) throw new HttpsError("failed-precondition", "CODE_LOCKED");
    // Orders placed before codes existed have none: delivered without one.
    const expected = handover.get("code") as string | undefined;
    if (expected && expected !== code) {
      tx.set(handoverRef, { attempts: FieldValue.increment(1) }, { merge: true });
      return { wrong: true, left: MAX_CODE_ATTEMPTS - attempts - 1 };
    }
    const cod = (data.payment as { method?: string } | undefined)?.method === "Cash on delivery";
    if (cod && request.data?.cashCollected !== true) throw new HttpsError("failed-precondition", "COLLECT_CASH");
    const extra = await deliveryEarning(tx, order.ref, data, r);
    tx.update(order.ref, {
      status: "delivered",
      deliveredAt: FieldValue.serverTimestamp(),
      riderStage: "delivered",
      updatedAt: FieldValue.serverTimestamp(),
      ...(cod ? { "payment.status": "succeeded" } : {}),
    });
    creditRiderDelivery(tx, order.ref, data, r, rider.id, extra);
    event(tx, order, "delivered", rider.id);
    return { wrong: false, left: MAX_CODE_ATTEMPTS };
  });
  if (outcome.wrong) {
    // Not an exception: the attempt counter must be saved.
    throw new HttpsError("invalid-argument", outcome.left > 0 ? "WRONG_CODE" : "CODE_LOCKED", { left: outcome.left });
  }
  return { ok: true };
});

/**
 * Request: {orderId, reason, note?}. The rider can't complete the drop;
 * ops sees it on the Dispatch board and cancels, reschedules or reassigns.
 */
export const riderCannotDeliver = onCall(async (request) => {
  const rider = await requireRider(request);
  const reason = request.data?.reason;
  if (!(CANNOT_DELIVER_REASONS as readonly string[]).includes(reason)) {
    throw new HttpsError("invalid-argument", "Invalid reason");
  }
  const note = typeof request.data?.note === "string" ? request.data.note.trim().slice(0, 300) : "";
  return onMyOrder(rider.id, request.data?.orderId, async (tx, { order }) => {
    tx.update(order.ref, {
      riderStage: "returning",
      cannotDeliver: { reason, note: note || null, at: FieldValue.serverTimestamp(), riderId: rider.id },
      dispatch: { state: "issue", updatedAt: FieldValue.serverTimestamp() },
    });
    return { ok: true };
  });
});
