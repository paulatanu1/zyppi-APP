import { createHash } from "node:crypto";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { onSchedule } from "firebase-functions/scheduler";
import { onTaskDispatched } from "firebase-functions/tasks";
import { enqueueSafely, taskId } from "../shared/tasks";
import { completePickup, event } from "../dispatch/delivery";
import { MAX_CODE_ATTEMPTS } from "../dispatch/model";
import { PICKUP_CODES, type PickupStop, sellerOnlyOrderReady } from "../dispatch/pickups";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import { MARKETPLACE_CONFIG_DOC, SELLERS } from "./model";
import { notifySeller } from "./seller_notify";
import { requireSeller } from "./sellers";
import { updateOrderStatus } from "../admin/orders";
import { PAYU_SECRETS } from "../payments/payu";
import { logger } from "firebase-functions";
import { marketplaceConfigFrom } from "./ranking";

/**
 * A marketplace seller's side of an order (docs/MARKETPLACE.md → Seller
 * app): accept or say they can't fulfil it (before accepting; the order is
 * cancelled and refunded), mark ready, hand
 * over to the rider by entering the rider's pickup code, report an item
 * problem. Sellers never read orders/{id} (it holds the customer's
 * details): they get a projection at sellers/{id}/orders/{orderId}.
 */

const ORDERS = "orders";

type Stops = Record<string, Partial<PickupStop> & { reachedAt?: unknown; pickedAt?: unknown }>;

function orderIdOf(raw: unknown): string {
  if (typeof raw !== "string" || !/^[\w-]{1,64}$/.test(raw)) throw new HttpsError("invalid-argument", "Invalid orderId");
  return raw;
}

/** This seller's stops in the order. */
export function myStops(pickups: Stops, sellerId: string): string[] {
  return Object.entries(pickups)
    .filter(([, s]) => s?.otpRequired && s.sellerId === sellerId)
    .map(([id]) => id);
}

/** Request: {orderId}. Idempotent; an accepted order can't be cancelled by the seller. */
export const sellerAcceptOrder = onCall(async (request) => {
  const me = await requireSeller(request);
  const ref = db.collection(ORDERS).doc(orderIdOf(request.data?.orderId));
  return db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    const status = (order.get("sellerStatus") ?? {}) as Record<string, string>;
    if (!order.exists || !(me.sellerId in status)) throw new HttpsError("permission-denied", "NOT_YOUR_ORDER");
    if (order.get("status") === "cancelled") throw new HttpsError("failed-precondition", "ORDER_CANCELLED");
    if (status[me.sellerId] !== "pending") return { ok: true, status: status[me.sellerId] };
    const stops = myStops((order.get("pickups") ?? {}) as Stops, me.sellerId);
    const stillPending = Object.entries(status).some(([id, s]) => id !== me.sellerId && s === "pending");
    tx.update(ref, {
      [`sellerStatus.${me.sellerId}`]: "accepted",
      [`sellerAcceptedAt.${me.sellerId}`]: FieldValue.serverTimestamp(),
      ...Object.fromEntries(stops.map((s) => [`pickups.${s}.status`, "accepted"])),
      ...(stillPending ? {} : { sellersPending: false }),
    });
    return { ok: true, status: "accepted" };
  });
});

/** Why a seller can't take an order (seller app). */
export const SELLER_REJECT_REASONS = ["out_of_stock", "shop_closing", "too_busy", "other"] as const;

/** Identity for cancels the seller or the accept deadline caused (audit, cancelledBy). */
export const SELLER_CANCEL_ACTOR: Actor = { uid: "system:seller", role: "ops", email: null };

/**
 * Request: {orderId, reason}. Before accepting, the seller can't fulfil
 * the order: it is cancelled like an ops cancel (stock back, wallet /
 * online refund, customer told), and counts against the seller
 * (sellerIssues → stats.cancelled, ranking). Lines aren't moved to another
 * seller: the customer can order again.
 */
export const sellerRejectOrder = onCall({ secrets: PAYU_SECRETS }, async (request) => {
  const me = await requireSeller(request);
  const orderId = orderIdOf(request.data?.orderId);
  const reason = request.data?.reason;
  if (!(SELLER_REJECT_REASONS as readonly unknown[]).includes(reason)) throw new HttpsError("invalid-argument", "Pick a reason");
  const label = String(reason).replace(/_/g, " ");
  const res = await updateOrderStatus(
    { ...SELLER_CANCEL_ACTOR, uid: `seller:${me.sellerId}` },
    { orderId, status: "cancelled", reason: `Seller can't fulfil: ${label}` },
    undefined,
    (d) => {
      const status = (d.sellerStatus ?? {}) as Record<string, string>;
      if (!(me.sellerId in status)) throw new HttpsError("permission-denied", "NOT_YOUR_ORDER");
      if (d.status === "cancelled") throw new HttpsError("failed-precondition", "ORDER_CANCELLED");
      if (status[me.sellerId] !== "pending") throw new HttpsError("failed-precondition", "ALREADY_ACCEPTED");
    },
    () => ({
      [`sellerStatus.${me.sellerId}`]: "rejected",
      [`sellerIssues.${me.sellerId}`]: { note: `Rejected: ${label}`, at: FieldValue.serverTimestamp(), by: me.uid },
      sellersPending: false,
      sellerAcceptDeadline: null,
    }),
  );
  return { ok: true, refund: res.refund ?? null };
});

/**
 * Request: {orderId}. Packed and ready for the rider. When every stop of a
 * seller-only order is ready, the order becomes `packed` (the customer is
 * told, and dispatch set to "assign when packed" starts).
 */
export const sellerMarkReady = onCall(async (request) => {
  const me = await requireSeller(request);
  const ref = db.collection(ORDERS).doc(orderIdOf(request.data?.orderId));
  return db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    const status = (order.get("sellerStatus") ?? {}) as Record<string, string>;
    if (!order.exists || !(me.sellerId in status)) throw new HttpsError("permission-denied", "NOT_YOUR_ORDER");
    if (order.get("status") === "cancelled") throw new HttpsError("failed-precondition", "ORDER_CANCELLED");
    if (status[me.sellerId] === "ready") return { ok: true };
    if (status[me.sellerId] !== "accepted") throw new HttpsError("failed-precondition", "ACCEPT_FIRST");
    const pickups = (order.get("pickups") ?? {}) as Stops;
    const stops = myStops(pickups, me.sellerId);
    const after: Stops = { ...pickups };
    for (const s of stops) after[s] = { ...after[s], status: "ready" };
    const packNow = order.get("status") === "placed" && sellerOnlyOrderReady(after);
    tx.update(ref, {
      [`sellerStatus.${me.sellerId}`]: "ready",
      ...Object.fromEntries(stops.map((s) => [`pickups.${s}.status`, "ready"])),
      ...(packNow ? { status: "packed", packedAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() } : {}),
    });
    if (packNow) event(tx, order, "packed", `seller:${me.sellerId}`);
    return { ok: true, packed: packNow };
  });
});

/**
 * Request: {orderId, code}. The rider shows a 4-digit code at the shop;
 * the seller enters it, which proves the assigned rider was there and got
 * the items. Five wrong codes lock the stop (ops can still force it).
 */
export const storeConfirmPickup = onCall(async (request) => {
  const me = await requireSeller(request);
  const code = typeof request.data?.code === "string" ? request.data.code.trim() : "";
  if (!/^\d{4}$/.test(code)) throw new HttpsError("invalid-argument", "WRONG_CODE");
  const ref = db.collection(ORDERS).doc(orderIdOf(request.data?.orderId));
  const outcome = await db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    if (!order.exists) throw new HttpsError("not-found", "Order not found");
    const data = order.data()!;
    if (data.status === "cancelled") throw new HttpsError("failed-precondition", "ORDER_CANCELLED");
    const pickups = (data.pickups ?? {}) as Stops;
    const storeId = myStops(pickups, me.sellerId).find((s) => !pickups[s]?.pickedAt);
    if (!storeId) throw new HttpsError("failed-precondition", "NOTHING_TO_HAND_OVER");
    const stop = pickups[storeId];
    if (stop.status !== "ready") throw new HttpsError("failed-precondition", "MARK_READY_FIRST");
    if (!data.riderId || !stop.reachedAt) throw new HttpsError("failed-precondition", "RIDER_NOT_HERE");
    const codeRef = ref.collection(PICKUP_CODES).doc(storeId);
    const codeSnap = await tx.get(codeRef);
    const attempts = (codeSnap.get("attempts") as number | undefined) ?? 0;
    if (attempts >= MAX_CODE_ATTEMPTS) throw new HttpsError("failed-precondition", "CODE_LOCKED");
    if (codeSnap.get("code") !== code) {
      tx.set(codeRef, { attempts: FieldValue.increment(1) }, { merge: true });
      return { wrong: true, left: MAX_CODE_ATTEMPTS - attempts - 1 };
    }
    const done = completePickup(tx, order, data, storeId, `seller:${me.sellerId}`);
    tx.update(ref, { [`pickups.${storeId}.handedOverBy`]: me.uid });
    return { wrong: false, ...done };
  });
  if (outcome.wrong) {
    throw new HttpsError("invalid-argument", outcome.left! > 0 ? "WRONG_CODE" : "CODE_LOCKED", { left: outcome.left });
  }
  return { ok: true };
});

/**
 * Request: {orderId, note}. An accepted item turned out missing / damaged:
 * the seller can't cancel, so ops sees the issue on the Dispatch board and
 * substitutes or part-refunds (opsAlerts.sellerIssue).
 */
export const sellerReportIssue = onCall(async (request) => {
  const me = await requireSeller(request);
  const note = typeof request.data?.note === "string" ? request.data.note.trim().slice(0, 300) : "";
  if (note.length < 3) throw new HttpsError("invalid-argument", "Say what's wrong");
  const ref = db.collection(ORDERS).doc(orderIdOf(request.data?.orderId));
  return db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    if (!order.exists || !(me.sellerId in ((order.get("sellerStatus") ?? {}) as object))) {
      throw new HttpsError("permission-denied", "NOT_YOUR_ORDER");
    }
    tx.update(ref, {
      [`sellerIssues.${me.sellerId}`]: { note, at: FieldValue.serverTimestamp(), by: me.uid },
      // Ops alert (admin Dispatch board). Not dispatch.state: that would stop
      // the rider assignment.
      "opsAlerts.sellerIssue": FieldValue.serverTimestamp(),
    });
    tx.set(db.collection(SELLERS).doc(me.sellerId), { stats: { itemIssues: FieldValue.increment(1) } }, { merge: true });
    return { ok: true };
  });
});

/** Request: {token, platform?}. One doc per device, keyed by a hash of the FCM token. */
export const sellerRegisterDevice = onCall(async (request) => {
  const me = await requireSeller(request);
  const token = typeof request.data?.token === "string" ? request.data.token.trim() : "";
  if (token.length < 20 || token.length > 4096) throw new HttpsError("invalid-argument", "Invalid token");
  const id = createHash("sha256").update(token).digest("hex").slice(0, 40);
  await db.collection(SELLERS).doc(me.sellerId).collection("devices").doc(id).set({
    token,
    uid: me.uid,
    platform: typeof request.data?.platform === "string" ? request.data.platform.slice(0, 20) : null,
    at: FieldValue.serverTimestamp(),
  });
  return { ok: true };
});

/**
 * What a seller may see of an order: their own items, payout and stop,
 * the order's progress and the rider — no customer name, phone or address.
 */
export function sellerOrderView(order: Record<string, unknown>, sellerId: string): Record<string, unknown> {
  const items = ((order.items ?? []) as Record<string, unknown>[]).filter((i) => i.sellerId === sellerId);
  const pickups = (order.pickups ?? {}) as Stops;
  const stops = myStops(pickups, sellerId);
  const stop = stops.length ? pickups[stops[0]] : null;
  return {
    status: order.status ?? null,
    sellerStatus: ((order.sellerStatus ?? {}) as Record<string, string>)[sellerId] ?? null,
    placedAt: order.placedAt ?? null,
    acceptBy: order.sellerAcceptDeadline ?? null,
    items: items.map((i) => ({
      productId: i.productId,
      variantId: i.variantId,
      name: i.name,
      unit: i.unit,
      image: i.image ?? null,
      quantity: i.quantity,
      payoutPaise: i.payoutPaise ?? 0,
    })),
    payoutPaise: items.reduce((a, i) => a + Number(i.payoutPaise ?? 0) * Number(i.quantity ?? 0), 0),
    stop: stop
      ? {
          storeId: stops[0],
          status: stop.status ?? null,
          riderAtStore: !!stop.reachedAt,
          pickedAt: stop.pickedAt ?? null,
        }
      : null,
    riderName: order.riderName ?? null,
    riderPhone: order.riderPhone ?? null,
    late: !!((order.sellerLate ?? {}) as Record<string, unknown>)[sellerId],
    paymentMethod: order.paymentMethod ?? null,
  };
}

/**
 * Keeps sellers/{id}/orders/{orderId} in step with the order and tells the
 * seller about new and cancelled orders.
 */
export const onOrderForSellers = onDocumentWritten(`${ORDERS}/{orderId}`, async (e) => {
  const before = e.data?.before?.data();
  const after = e.data?.after?.data();
  const ids = new Set<string>([
    ...((after?.sellerIds ?? []) as string[]),
    ...((before?.sellerIds ?? []) as string[]),
  ]);
  if (!ids.size) return;
  const orderId = e.params.orderId;
  const deadline = after?.sellerAcceptDeadline as Timestamp | null | undefined;
  if (!before && after?.sellersPending === true && deadline) {
    await enqueueSafely(
      ACCEPT_TASK,
      { orderId },
      { id: taskId("seller-accept", orderId), scheduleTime: new Date(deadline.toMillis() + 2_000) },
    );
  }
  await Promise.all(
    [...ids].map(async (sellerId) => {
      const ref = db.collection(SELLERS).doc(sellerId).collection("orders").doc(orderId);
      if (!after) {
        await ref.delete();
        return;
      }
      const view = sellerOrderView(after, sellerId);
      const prev = before ? sellerOrderView(before, sellerId) : null;
      if (JSON.stringify(view) !== JSON.stringify(prev)) {
        await ref.set({ ...view, updatedAt: FieldValue.serverTimestamp() });
      }
      const acceptsHere = view.sellerStatus != null;
      if (!before && acceptsHere) await notifySeller(sellerId, orderId, "new_order");
      if (before?.status !== "cancelled" && after.status === "cancelled" && acceptsHere) {
        await notifySeller(sellerId, orderId, "cancelled");
      }
    }),
  );
});

const ACCEPT_TASK = "checkSellerAccept";

/**
 * The accept deadline passed: sellers still "pending" get an ops alert
 * (opsAlerts.sellerLate), their app rings again, and it counts as a late
 * accept (ranking: reliability). Does nothing if they all accepted, the
 * order was cancelled, or this already ran (at-least-once tasks).
 */
export async function escalateLate(orderId: string): Promise<string[]> {
  const ref = db.collection(ORDERS).doc(orderId);
  const late = await db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    if (!order.exists || order.get("sellersPending") !== true) return [];
    const deadline = order.get("sellerAcceptDeadline") as Timestamp | null | undefined;
    if (!deadline || deadline.toMillis() > Date.now() + 5_000) return [];
    if (order.get("status") === "cancelled") {
      tx.update(ref, { sellerAcceptDeadline: null, sellersPending: false });
      return [];
    }
    const status = (order.get("sellerStatus") ?? {}) as Record<string, string>;
    const pending = Object.entries(status).filter(([, s]) => s === "pending").map(([id]) => id);
    tx.update(ref, {
      sellerAcceptDeadline: null,
      ...Object.fromEntries(pending.map((id) => [`sellerLate.${id}`, true])),
      ...(pending.length ? { "opsAlerts.sellerLate": FieldValue.serverTimestamp() } : { sellersPending: false }),
    });
    for (const id of pending) {
      tx.set(db.collection(SELLERS).doc(id), { stats: { lateAccepts: FieldValue.increment(1) } }, { merge: true });
    }
    return pending;
  });
  await Promise.all(late.map((id) => notifySeller(id, orderId, "escalate")));
  return late;
}

/** Queued at placement for the order's accept deadline (onOrderForSellers). */
export const checkSellerAccept = onTaskDispatched<{ orderId: string }>(
  { retryConfig: { maxAttempts: 5, minBackoffSeconds: 15 }, rateLimits: { maxConcurrentDispatches: 10 } },
  async (req) => {
    const orderId = req.data?.orderId;
    if (typeof orderId === "string" && /^[\w-]{1,64}$/.test(orderId)) await escalateLate(orderId);
  },
);

/**
 * Safety net, not the timer (checkSellerAccept is): deadlines whose task
 * never ran, e.g. Cloud Tasks was briefly unavailable at placement. Also,
 * when config/marketplace.autoCancelLateMinutes is set, cancels (and
 * refunds) orders a seller still hasn't accepted that long after the
 * alert, so the customer isn't left waiting.
 */
export const escalateLateSellers = onSchedule(
  { schedule: "every 5 minutes", timeZone: "Asia/Kolkata", secrets: PAYU_SECRETS },
  async () => {
    const due = await db
      .collection(ORDERS)
      .where("sellersPending", "==", true)
      .where("sellerAcceptDeadline", "<=", Timestamp.fromMillis(Date.now() - 60_000))
      .limit(100)
      .get();
    for (const o of due.docs) await escalateLate(o.id);
    await cancelLateOrders();
  },
);

/** True when an order a seller is late on should now be cancelled. */
export function lateCancelDue(alertedAtMs: number | null, autoCancelMinutes: number, nowMs: number): boolean {
  return autoCancelMinutes > 0 && alertedAtMs != null && nowMs - alertedAtMs >= autoCancelMinutes * 60_000;
}

async function cancelLateOrders(nowMs = Date.now()): Promise<void> {
  const cfg = marketplaceConfigFrom((await db.doc(MARKETPLACE_CONFIG_DOC).get()).data());
  if (cfg.autoCancelLateMinutes <= 0) return;
  const late = await db
    .collection(ORDERS)
    .where("sellersPending", "==", true)
    .where("opsAlerts.sellerLate", "<=", Timestamp.fromMillis(nowMs - cfg.autoCancelLateMinutes * 60_000))
    .limit(50)
    .get();
  for (const o of late.docs) {
    try {
      await updateOrderStatus(
        SELLER_CANCEL_ACTOR,
        { orderId: o.id, status: "cancelled", reason: "Seller didn't accept in time" },
        undefined,
        (d) => {
          const alerted = (d.opsAlerts as { sellerLate?: Timestamp } | undefined)?.sellerLate?.toMillis() ?? null;
          if (d.status !== "placed" || d.sellersPending !== true || !lateCancelDue(alerted, cfg.autoCancelLateMinutes, Date.now())) {
            throw new HttpsError("failed-precondition", "NOT_LATE");
          }
        },
        (d) => {
          const status = (d.sellerStatus ?? {}) as Record<string, string>;
          const pending = Object.keys(status).filter((id) => status[id] === "pending");
          return {
            sellersPending: false,
            ...Object.fromEntries(pending.map((id) => [`sellerStatus.${id}`, "expired"])),
            ...Object.fromEntries(
              pending.map((id) => [`sellerIssues.${id}`, { note: "Didn't accept in time", at: FieldValue.serverTimestamp(), by: "system" }]),
            ),
          };
        },
      );
    } catch (e) {
      if (!(e instanceof HttpsError && e.message === "NOT_LATE")) logger.warn("late seller cancel failed", { orderId: o.id, e });
    }
  }
}

/**
 * Admin → Dispatch: ops marks a stop collected when the code can't be used
 * (locked after wrong tries, seller's phone dead). Needs a reason; audited.
 * Request: {orderId, storeId, reason}.
 */
export const adminForcePickup = onCall(async (request) => {
  const actor = requireRole(request, ["ops"]);
  const reason = typeof request.data?.reason === "string" ? request.data.reason.trim().slice(0, 300) : "";
  if (reason.length < 3) throw new HttpsError("invalid-argument", "Give a reason");
  const storeId = typeof request.data?.storeId === "string" ? request.data.storeId : "";
  const ref = db.collection(ORDERS).doc(orderIdOf(request.data?.orderId));
  return db.runTransaction(async (tx) => {
    const order = await tx.get(ref);
    if (!order.exists) throw new HttpsError("not-found", "Order not found");
    const data = order.data()!;
    const stop = ((data.pickups ?? {}) as Stops)[storeId];
    if (!stop) throw new HttpsError("invalid-argument", "Invalid store");
    if (stop.pickedAt) return { ok: true, already: true };
    if (!data.riderId) throw new HttpsError("failed-precondition", "Assign a rider first");
    if (["cancelled", "delivered"].includes(data.status as string)) throw new HttpsError("failed-precondition", "Order is closed");
    const done = completePickup(tx, order, data, storeId, actor.uid);
    tx.update(ref, { [`pickups.${storeId}.forcedBy`]: { uid: actor.uid, reason } });
    writeAudit(actor, { action: "order.forcePickup", target: ref.path, after: { storeId, reason } }, tx);
    return { ok: true, ...done };
  });
});
