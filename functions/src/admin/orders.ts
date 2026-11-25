import { FieldValue, type Transaction } from "firebase-admin/firestore";
import { logLifecycle } from "../shared/log";
import { inventoryIdFor, isZyppiStore } from "../marketplace/model";
import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { requireString } from "../shared/callable";
import { type Actor, requireRole } from "../shared/roles";
import { writeAudit } from "../shared/audit";
import { PAYU_SECRETS, type PayURefunds, payURefunds } from "../payments/payu";
import { queueRefundInTx, sendRefund } from "../payments/refunds";
import { logger } from "firebase-functions";
import { RIDERS } from "../riders/model";
import { releaseRedemption } from "../coupons/usage";
import { bindRider, creditRiderDelivery, releaseRider, withdrawOffer } from "../dispatch/effects";
import { deliveryEarning, prepareCancelledTrip } from "../dispatch/earnings";
import { writeWalletEntry } from "../wallet/ledger";
import { RESERVED_STORES, releaseReservation, reservedStoresOf } from "../catalog/reservations";

export const ORDER_STATUSES = ["placed", "packed", "out_for_delivery", "delivered", "cancelled"];
export type OrderStatus = (typeof ORDER_STATUSES)[number];

/** Allowed moves. Delivered and cancelled are final. */
export const TRANSITIONS: Record<string, string[]> = {
  placed: ["packed", "cancelled"],
  packed: ["out_for_delivery", "cancelled"],
  out_for_delivery: ["delivered", "cancelled"],
  delivered: [],
  cancelled: [],
};

export interface StatusInput {
  orderId?: unknown;
  status?: unknown;
  reason?: unknown;
  riderName?: unknown;
  riderPhone?: unknown;
  /** An approved rider's uid to assign, or null to unassign. */
  riderId?: unknown;
}

interface Allocation {
  storeId: string;
  /** Marketplace orders; absent on older orders = Zyppi's own stock. */
  sellerId?: string | null;
  productId: string;
  variantId: string;
  quantity: number;
}

/**
 * Status change (or just rider details when `status` is unchanged), in one
 * transaction with its event (which pushes the customer and drives live
 * tracking) and an audit row.
 * - Cancelling needs a reason, puts the stock back in the stores it came
 *   from (inventoryMovements "order_cancel"), and refunds an online
 *   payment in full right after.
 * - Delivering a cash order marks the cash as collected.
 * - `riderId` assigns an approved rider (name and phone come from their
 *   profile); on delivery the rider's counters and cash-in-hand go up.
 * Exported for the emulator tests.
 */
export async function updateOrderStatus(
  actor: Actor,
  input: StatusInput,
  payu: PayURefunds = payURefunds,
  /** Extra check on the order as read in the transaction (throws to refuse). */
  guard?: (order: Record<string, unknown>) => void,
  /** More fields for the same order write, from the order as read (e.g. who was at fault). */
  extra?: (order: Record<string, unknown>) => Record<string, unknown>,
): Promise<{ ok: true; refund?: { refundId: string; status: string } }> {
  const orderId = requireString(input.orderId, "orderId");
  const status = requireString(input.status, "status");
  if (!ORDER_STATUSES.includes(status)) {
    throw new HttpsError("invalid-argument", `Invalid status: ${status}`);
  }
  const reason = typeof input.reason === "string" ? input.reason.trim() : "";

  const orderRef = db.collection("orders").doc(orderId);
  let fromStatus: string | null = null;
  const queued = await db.runTransaction(async (tx): Promise<QueuedCancelRefund | null> => {
    const order = await tx.get(orderRef);
    if (!order.exists) throw new HttpsError("not-found", `Order not found: ${orderId}`);
    const d = order.data()!;
    guard?.(d);
    const from = d.status as string;
    fromStatus = from;

    const update: Record<string, unknown> = { updatedAt: FieldValue.serverTimestamp() };
    for (const field of ["riderName", "riderPhone"] as const) {
      const value = input[field];
      if (typeof value === "string") update[field] = value.trim().slice(0, 80) || null;
    }

    // Rider: read before any write (transaction rule).
    let riderId = (d.riderId as string | null | undefined) ?? null;
    let riderSnap = null;
    if (input.riderId !== undefined) {
      if (from === "delivered" || from === "cancelled") {
        throw new HttpsError("failed-precondition", "This order is closed");
      }
      if (input.riderId === null || input.riderId === "") {
        riderId = null;
        update.riderId = null;
      } else if (typeof input.riderId === "string") {
        riderSnap = await tx.get(db.collection(RIDERS).doc(input.riderId));
        if (riderSnap.get("status") !== "approved") {
          throw new HttpsError("failed-precondition", "Only approved riders can be assigned");
        }
        riderId = riderSnap.id;
        update.riderId = riderId;
        update.riderName = riderSnap.get("fullName") ?? null;
        update.riderPhone = riderSnap.get("phone") ?? null;
        update.riderAssignedAt = FieldValue.serverTimestamp();
      }
    }
    if (status === "delivered" && riderId && !riderSnap) {
      riderSnap = await tx.get(db.collection(RIDERS).doc(riderId));
    }

    if (status === from) {
      const prevRider = (d.riderId as string | null | undefined) ?? null;
      const offeredTo = (d.offer as { riderId?: string } | undefined)?.riderId ?? null;
      if (input.riderId !== undefined && riderId !== prevRider) {
        if (offeredTo) {
          withdrawOffer(tx, orderRef.id, offeredTo);
          update.offer = FieldValue.delete();
        }
        if (prevRider) releaseRider(tx, prevRider);
        if (riderId) {
          bindRider(tx, orderRef.id, riderId);
          update.riderStage = "accepted";
          update.dispatch = { state: "manual", updatedAt: FieldValue.serverTimestamp() };
        } else {
          update.riderStage = FieldValue.delete();
          update.dispatch = { state: "unassigned", updatedAt: FieldValue.serverTimestamp() };
        }
      }
      tx.update(orderRef, update);
      return null;
    }
    if (!TRANSITIONS[from]?.includes(status)) {
      throw new HttpsError("failed-precondition", `Can’t move an order from ${label(from)} to ${label(status)}`);
    }
    update.status = status;
    update[`${status === "out_for_delivery" ? "outForDelivery" : status}At`] = FieldValue.serverTimestamp();

    let refund: QueuedCancelRefund | null = null;
    let payTrip: (() => number) | null = null;
    if (status === "cancelled") {
      if (reason.length < 3) throw new HttpsError("invalid-argument", "Give a reason for cancelling");
      update.cancelReason = reason.slice(0, 300);
      update.cancelledBy = actor.uid;
      // Reads first: the rider who already collected the goods is paid for the trip.
      const tripRider = (d.riderId as string | null | undefined) ?? null;
      payTrip = tripRider ? await prepareCancelledTrip(tx, orderRef, d, tripRider) : null;
      await restock(tx, orderRef.id, d, actor);
      if (reservedStoresOf(d).length) update[RESERVED_STORES] = [];
      if (d.couponRedeemed === true && typeof d.couponCode === "string") {
        releaseRedemption(tx, d.couponCode, d.userId as string, (d.discountPaise as number) ?? 0);
      }
      // Orders placed since segments existed carry `countedForUser`.
      if (d.countedForUser === true && typeof d.userId === "string") {
        tx.set(
          db.collection("users").doc(d.userId),
          {
            orderCount: FieldValue.increment(-1),
            totalSpentPaise: FieldValue.increment(-((d.totalPaise as number) ?? 0)),
          },
          { merge: true },
        );
      }
      refund = queueCancelRefund(tx, actor, orderRef.id, d, reason, update);
      // What the wallet paid goes straight back to the wallet, whatever
      // the payment method (cash orders included).
      const userId = d.userId as string | undefined;
      const walletPaid = (d.walletPaise as number | undefined) ?? 0;
      if (userId && walletPaid > 0) {
        writeWalletEntry(tx, userId, `cancel_${orderRef.id}`, {
          type: "cancel",
          amountPaise: walletPaid,
          reason: "Order cancelled",
          orderId: orderRef.id,
          by: actor.uid,
        });
        update.walletRefundedPaise = walletPaid;
      }
      // A cancelled replacement: the claim is paid to the wallet instead
      // (same entry id as a wallet claim, so never both).
      const claimPaise = (d.claimAmountPaise as number | undefined) ?? 0;
      if (userId && typeof d.issueId === "string" && typeof d.replacementOf === "string" && claimPaise > 0) {
        // One entry per replacement order (a claim's returns can each have one).
        writeWalletEntry(tx, userId, `claim_${d.issueId}_r_${orderRef.id}`, {
          type: "claim",
          amountPaise: claimPaise,
          reason: "Replacement cancelled: claim credited",
          orderId: d.replacementOf,
          issueId: d.issueId,
          by: actor.uid,
        });
        tx.update(db.collection("orders").doc(d.replacementOf), {
          claimWalletPaise: FieldValue.increment(claimPaise),
        });
        tx.update(db.collection("orderIssues").doc(d.issueId), {
          "resolution.type": "wallet",
          "resolution.walletPaise": claimPaise,
          "resolution.note": "Replacement cancelled; credited to wallet",
        });
      }
    }
    // Sent out (or delivered) by ops without the stops being marked
    // collected: the goods left the shelves anyway.
    if (status === "out_for_delivery" || status === "delivered") {
      const held = reservedStoresOf(d);
      if (held.length) update[RESERVED_STORES] = releaseReservation(tx, d, held);
    }
    const cod = d.payment?.method === "Cash on delivery";
    if (status === "delivered" && cod) {
      update["payment.status"] = "succeeded";
    }
    if (status === "delivered" && riderSnap?.exists) {
      update.riderStage = "delivered";
      creditRiderDelivery(tx, orderRef, d, riderSnap, actor.uid, await deliveryEarning(tx, orderRef, d, riderSnap));
    }
    // Rider app: whoever holds the order (or an open offer for it) follows
    // ops' change.
    const prevRider = (d.riderId as string | null | undefined) ?? null;
    const offeredTo = (d.offer as { riderId?: string } | undefined)?.riderId ?? null;
    if (offeredTo && (input.riderId !== undefined || status === "cancelled")) {
      withdrawOffer(tx, orderRef.id, offeredTo);
      update.offer = FieldValue.delete();
    }
    if (input.riderId !== undefined && riderId !== prevRider) {
      if (prevRider) releaseRider(tx, prevRider);
      if (riderId) {
        bindRider(tx, orderRef.id, riderId);
        update.riderStage = "accepted";
        update.dispatch = { state: "manual", updatedAt: FieldValue.serverTimestamp() };
      } else {
        update.riderStage = FieldValue.delete();
        update.dispatch = { state: "unassigned", updatedAt: FieldValue.serverTimestamp() };
      }
    }
    if (status === "cancelled" && riderId) releaseRider(tx, riderId);
    if (payTrip) update.riderEarning = { totalPaise: payTrip(), tipPaise: 0, cancelledTrip: true };
    if (extra) Object.assign(update, extra(d));

    tx.update(orderRef, update);
    tx.create(orderRef.collection("events").doc(), {
      status,
      createdAt: FieldValue.serverTimestamp(),
      by: actor.uid,
      ...(reason ? { note: reason.slice(0, 300) } : {}),
    });
    writeAudit(
      actor,
      { action: "order.status", target: orderRef.path, before: { status: from }, after: { status, reason: reason || null } },
      tx,
    );
    return refund;
  });

  logLifecycle("order.status", { orderId, from: fromStatus, to: status, by: actor.uid, reason: reason || null });
  if (queued) {
    // The refund is already recorded with the cancel; if PayU is down this
    // stays "requesting" and reconcileRefunds sends it again.
    const refundStatus = await sendRefund(queued.refundId, queued.mihpayid, queued.amountPaise, payu);
    return { ok: true, refund: { refundId: queued.refundId, status: refundStatus } };
  }
  return { ok: true };
}

interface QueuedCancelRefund {
  refundId: string;
  mihpayid: string;
  amountPaise: number;
}

/**
 * A cancelled order paid online: records the refund of what's left in the
 * cancel's own transaction (merging the reservation into `update`, the
 * order's single write). Without a PayU id on the order the refund can't
 * be sent automatically: it's left "pending" for finance (Payments → Refund).
 */
export function queueCancelRefund(
  tx: Transaction,
  actor: Actor,
  orderId: string,
  d: Record<string, unknown>,
  reason: string,
  update: Record<string, unknown>,
): QueuedCancelRefund | null {
  const payment = (d.payment ?? {}) as Record<string, unknown>;
  const online = ["UPI", "Credit or debit card"].includes(payment.method as string);
  if (!online || payment.status !== "succeeded") return null;
  const due = (payment.amountPaise as number) - ((d.refundedPaise as number) ?? 0);
  if (due <= 0) return null;
  if (!payment.providerReference) {
    logger.error("Cancelled online order has no PayU id; refund left for finance", { orderId });
    update.refundStatus = "pending";
    return null;
  }
  const q = queueRefundInTx(tx, actor, { orderId }, d, {
    amountPaise: due,
    reason: `Order cancelled: ${reason}`.slice(0, 300),
  });
  Object.assign(update, q.targetUpdate);
  return { refundId: q.refundId, mihpayid: q.mihpayid, amountPaise: q.amountPaise };
}

const label = (s: string) => s.replace(/_/g, " ");

/**
 * Puts a cancelled order's stock back. Orders placed before `allocations`
 * existed go back to the first active store of their area.
 */
async function restock(
  tx: Transaction,
  orderId: string,
  order: Record<string, unknown>,
  actor: Actor,
): Promise<void> {
  let allocations = (order.allocations as Allocation[] | undefined) ?? [];
  if (!allocations.length) {
    const stores = await tx.get(
      db.collection("stores")
        .where("serviceAreaId", "==", order.serviceAreaId ?? "")
        .where("isActive", "==", true)
        .limit(1),
    );
    const storeId = stores.docs[0]?.id;
    if (!storeId) return;
    allocations = ((order.items as Allocation[] | undefined) ?? []).map((i) => ({
      storeId,
      productId: i.productId,
      variantId: i.variantId,
      quantity: i.quantity,
    }));
  }
  const refs = allocations.map((a) => db.collection("inventory").doc(inventoryIdFor(a.storeId, a.sellerId, a.variantId)));
  const snaps = refs.length ? await tx.getAll(...refs) : [];
  // Units still on the shelf were held for this order (catalog/reservations.ts):
  // they stop being held as they become sellable again.
  const held = new Set(reservedStoresOf(order));
  allocations.forEach((a, i) => {
    const before = (snaps[i].get("quantity") as number | undefined) ?? 0;
    tx.set(
      refs[i],
      {
        storeId: a.storeId,
        ...(isZyppiStore(a.sellerId) ? {} : { sellerId: a.sellerId }),
        productId: a.productId,
        variantId: a.variantId,
        quantity: before + a.quantity,
        ...(held.has(a.storeId) ? { reserved: FieldValue.increment(-a.quantity) } : {}),
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    tx.create(db.collection("inventoryMovements").doc(), {
      storeId: a.storeId,
      productId: a.productId,
      variantId: a.variantId,
      delta: a.quantity,
      before,
      after: before + a.quantity,
      sellerId: isZyppiStore(a.sellerId) ? null : a.sellerId,
      reason: "order_cancel",
      note: null,
      orderId,
      actorUid: actor.uid,
      actorEmail: actor.email,
      at: FieldValue.serverTimestamp(),
    });
  });
}

/**
 * Orders board → status / rider / cancel (ops).
 * Request: {orderId, status, reason?, riderName?, riderPhone?, riderId?}
 */
export const adminUpdateOrderStatus = onCall({ secrets: PAYU_SECRETS }, async (request) =>
  updateOrderStatus(requireRole(request, ["ops"]), request.data ?? {}),
);
