import { type DocumentSnapshot, FieldValue, type Transaction } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { pushOrderCustomer } from "../push";
import { creditRiderDelivery } from "./effects";
import { deliveryEarning } from "./earnings";
import { CANNOT_DELIVER_REASONS, MAX_CODE_ATTEMPTS, type Point, type RiderStage, distanceM, isPoint } from "./model";
import { notifySeller } from "../marketplace/seller_notify";
import { type PickupStop, STORE_GEOFENCE_M, allStopsPicked, stopReady } from "./pickups";
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
export async function onMyOrder<T>(
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

export function event(tx: Transaction, order: DocumentSnapshot, status: string, by: string, note?: string) {
  tx.create(order.ref.collection("events").doc(), {
    status,
    createdAt: FieldValue.serverTimestamp(),
    by,
    ...(note ? { note } : {}),
  });
}

/** Stores still to visit (an order can be filled from several). */
export function storesOf(d: Record<string, unknown>): string[] {
  if (Array.isArray(d.pickupOrder) && d.pickupOrder.length) return d.pickupOrder as string[];
  const allocations = (d.allocations as { storeId?: string }[] | undefined) ?? [];
  return [...new Set(allocations.map((a) => a.storeId).filter((s): s is string => !!s))];
}

type Stops = Record<string, Partial<PickupStop> & { pickedAt?: unknown; reachedAt?: unknown }>;

function storeIdFor(data: Record<string, unknown>, raw: unknown): string {
  const stores = storesOf(data);
  const storeId = typeof raw === "string" ? raw : stores[0];
  if (stores.length && !stores.includes(storeId)) throw new HttpsError("invalid-argument", "Invalid store");
  return storeId ?? "store";
}

/** The rider's position from their last accepted ping, if recent enough. */
function freshPosition(rider: DocumentSnapshot, maxAgeMs: number): Point | null {
  const p = (rider.get("presence") ?? {}) as Record<string, unknown>;
  const at = p.at as { toMillis?: () => number } | undefined;
  const fresh = typeof at?.toMillis === "function" && Date.now() - at.toMillis() <= maxAgeMs;
  return fresh && isPoint({ lat: p.lat, lng: p.lng }) ? { lat: p.lat as number, lng: p.lng as number } : null;
}

const POSITION_MAX_AGE_MS = 3 * 60_000;

/**
 * Request: {orderId, storeId?}. At a marketplace seller's shop the rider
 * must really be there (last ping within 150 m, mocked locations are
 * already refused by riderPing); the seller is told the rider arrived.
 */
export const riderReachedStore = onCall(async (request) => {
  const rider = await requireRider(request);
  const res = await onMyOrder(rider.id, request.data?.orderId, async (tx, { order, data, rider: r }) => {
    if (!["accepted", "at_store"].includes(stageOf(data))) throw new HttpsError("failed-precondition", "WRONG_STEP");
    const storeId = storeIdFor(data, request.data?.storeId);
    const stop = ((data.pickups ?? {}) as Stops)[storeId];
    if (stop?.otpRequired) {
      const here = freshPosition(r, POSITION_MAX_AGE_MS);
      if (!here) throw new HttpsError("failed-precondition", "LOCATION_NEEDED");
      const shop = isPoint({ lat: stop.lat, lng: stop.lng }) ? { lat: stop.lat as number, lng: stop.lng as number } : null;
      if (shop && distanceM(here, shop) > STORE_GEOFENCE_M) {
        throw new HttpsError("failed-precondition", "NOT_AT_STORE", { distanceM: Math.round(distanceM(here, shop)) });
      }
    }
    tx.update(order.ref, {
      riderStage: "at_store",
      [`pickups.${storeId}.reachedAt`]: FieldValue.serverTimestamp(),
    });
    return { ok: true, sellerId: stop?.otpRequired ? (stop.sellerId ?? null) : null, orderId: order.id };
  });
  if (res.sellerId) await notifySeller(res.sellerId, res.orderId, "rider_arrived");
  return { ok: true };
});

/**
 * Marks a stop collected inside a transaction and, after the last one,
 * sends the order out for delivery. Shared by riderPickUp (Zyppi stores)
 * and storeConfirmPickup (sellers' shops, after the pickup code).
 */
export function completePickup(
  tx: Transaction,
  order: DocumentSnapshot,
  data: Record<string, unknown>,
  storeId: string,
  by: string,
): { outForDelivery: boolean; remainingStores: string[] } {
  const stores = storesOf(data);
  const pickups = (data.pickups ?? {}) as Stops;
  const done = new Set(Object.entries(pickups).filter(([, v]) => v?.pickedAt).map(([k]) => k));
  done.add(storeId);
  const allDone = allStopsPicked(stores, done);
  tx.update(order.ref, {
    [`pickups.${storeId}.pickedAt`]: FieldValue.serverTimestamp(),
    ...(pickups[storeId] ? { [`pickups.${storeId}.status`]: "picked" } : {}),
    ...(allDone
      ? {
          status: "out_for_delivery",
          outForDeliveryAt: FieldValue.serverTimestamp(),
          riderStage: "picked_up",
          updatedAt: FieldValue.serverTimestamp(),
        }
      : { riderStage: "at_store" }),
  });
  if (allDone) event(tx, order, "out_for_delivery", by);
  return { outForDelivery: allDone, remainingStores: stores.filter((s) => !done.has(s)) };
}

/**
 * Request: {orderId, storeId?}. A Zyppi store's stop, once ops packed the
 * order. A seller's shop is confirmed by the seller entering the rider's
 * pickup code (storeConfirmPickup), never by the rider alone.
 */
export const riderPickUp = onCall(async (request) => {
  const rider = await requireRider(request);
  return onMyOrder(rider.id, request.data?.orderId, async (tx, { order, data }) => {
    if (!["accepted", "at_store"].includes(stageOf(data))) throw new HttpsError("failed-precondition", "WRONG_STEP");
    const storeId = storeIdFor(data, request.data?.storeId);
    const stop = ((data.pickups ?? {}) as Stops)[storeId];
    if (stop?.otpRequired) throw new HttpsError("failed-precondition", "PICKUP_CODE_REQUIRED");
    if (!stopReady(stop, data.status as string)) throw new HttpsError("failed-precondition", "NOT_PACKED_YET");
    return { ok: true, ...completePickup(tx, order, data, storeId, rider.id) };
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
