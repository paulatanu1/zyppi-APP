import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";
import { logger } from "firebase-functions";
import { restock } from "../admin/orders";
import { COUPONS } from "../coupons/model";
import { event } from "../dispatch/delivery";
import { type PickupStop, sellerOnlyOrderReady } from "../dispatch/pickups";
import { SELLERS } from "../marketplace/model";
import { type PayURefunds, payURefunds } from "../payments/payu";
import { queueRefundInTx, sendRefund } from "../payments/refunds";
import { pushOrderCustomer } from "../push";
import { RESERVED_STORES, reservedStoresOf } from "../catalog/reservations";
import { db } from "../shared/firebase";
import { logLifecycle } from "../shared/log";
import type { Actor } from "../shared/roles";
import { writeWalletEntry } from "../wallet/ledger";
import { COD, ONLINE_METHODS, sellerSummary } from "./quote";

/**
 * Audit S5: one seller who can't fulfil (rejects, or never accepts) no
 * longer cancels the whole order. Their lines are dropped and refunded;
 * the rest of the order goes on. When nothing would be left, the caller
 * cancels the whole order as before ([planSellerDrop] returns null).
 *
 * Money: the dropped lines' price minus their share of the coupon
 * discount comes back; the delivery / handling fee and tip stay (the
 * order is still delivered). Paid online → PayU refund first, any rest
 * to the wallet; cash on delivery → less cash to collect, any rest
 * (paid from the wallet) to the wallet; wallet-paid → the wallet.
 */

interface Item {
  productId: string;
  variantId: string;
  name?: string;
  quantity: number;
  pricePaise: number;
  sellerId: string;
  sellerName?: string;
  payoutPaise: number;
  marginPaise: number;
}

interface Allocation {
  storeId: string;
  sellerId?: string | null;
  productId: string;
  variantId: string;
  quantity: number;
}

type Stops = Record<string, Partial<PickupStop>>;

export interface DropPlan {
  dropped: Item[];
  kept: Item[];
  droppedAllocations: Allocation[];
  keptAllocations: Allocation[];
  /** Pickup stops (store ids) that go away. */
  droppedStops: string[];
  itemPaise: number;
  discountSharePaise: number;
  /** What the customer gets back: itemPaise − discountSharePaise. */
  valuePaise: number;
  /** Of valuePaise: refunded through PayU. */
  refundPaise: number;
  /** Of valuePaise: less cash to collect at the door. */
  cashCutPaise: number;
  /** Of valuePaise: credited to the wallet. */
  walletPaise: number;
}

/**
 * The drop of `sellerIds`' lines from `order`, or null when it can't be a
 * partial drop (nothing would be left, nothing of theirs is in it, or an
 * old order without allocations): cancel the whole order then. Pure.
 */
export function planSellerDrop(order: Record<string, unknown>, sellerIds: readonly string[]): DropPlan | null {
  const drop = new Set(sellerIds);
  const items = (order.items ?? []) as Item[];
  const dropped = items.filter((i) => drop.has(i.sellerId));
  const kept = items.filter((i) => !drop.has(i.sellerId));
  const allocations = (order.allocations ?? []) as Allocation[];
  const droppedAllocations = allocations.filter((a) => a.sellerId != null && drop.has(a.sellerId));
  if (!dropped.length || !kept.length || !droppedAllocations.length) return null;
  if (typeof order.replacementOf === "string") return null; // a claim paid it: keep it simple

  const pickups = (order.pickups ?? {}) as Stops;
  const droppedStops = Object.entries(pickups)
    .filter(([, s]) => s?.sellerId != null && drop.has(s.sellerId))
    .map(([id]) => id);

  const itemTotal = (order.itemTotalPaise as number | undefined) ?? items.reduce((a, i) => a + i.pricePaise * i.quantity, 0);
  const itemPaise = dropped.reduce((a, i) => a + i.pricePaise * i.quantity, 0);
  const discount = (order.discountPaise as number | undefined) ?? 0;
  const discountSharePaise = itemTotal > 0 ? Math.floor((discount * itemPaise) / itemTotal) : 0;
  const valuePaise = Math.max(0, itemPaise - discountSharePaise);

  const payment = (order.payment ?? {}) as Record<string, unknown>;
  const method = (payment.method ?? order.paymentMethod) as string | undefined;
  const walletLeft = Math.max(0, ((order.walletPaise as number | undefined) ?? 0) - ((order.walletRefundedPaise as number | undefined) ?? 0));
  let refundPaise = 0;
  let cashCutPaise = 0;
  if (method && ONLINE_METHODS.includes(method) && payment.status === "succeeded") {
    const onlineLeft = Math.max(0, ((payment.amountPaise as number | undefined) ?? 0) - ((order.refundedPaise as number | undefined) ?? 0));
    refundPaise = Math.min(valuePaise, onlineLeft);
  } else if (method === COD) {
    cashCutPaise = Math.min(valuePaise, (order.cashToCollectPaise as number | undefined) ?? 0);
  }
  const walletPaise = Math.min(valuePaise - refundPaise - cashCutPaise, walletLeft);

  return {
    dropped,
    kept,
    droppedAllocations,
    keptAllocations: allocations.filter((a) => !(a.sellerId != null && drop.has(a.sellerId))),
    droppedStops,
    itemPaise,
    discountSharePaise,
    valuePaise,
    refundPaise,
    cashCutPaise,
    walletPaise,
  };
}

/** Thrown inside the drop's transaction: cancel the whole order instead. */
export const WHOLE_ORDER = "WHOLE_ORDER";

export interface DropResult {
  valuePaise: number;
  refund: { refundId: string; status: string } | null;
}

/**
 * Drops `sellerIds`' lines (see the file comment) in one transaction:
 * stock back, totals and seller payouts re-worked, money returned, the
 * sellers marked `statusLabel` and counted at fault (stats.cancelled,
 * since the order itself isn't cancelled). Throws HttpsError(WHOLE_ORDER)
 * when nothing would be left: the caller cancels the order instead.
 * `guard` re-checks the order as read in the transaction.
 */
export async function dropSellers(
  actor: Actor,
  orderId: string,
  sellerIds: readonly string[],
  opts: {
    reason: string;
    statusLabel: "rejected" | "expired";
    guard?: (order: Record<string, unknown>) => void;
    issueBy: string;
  },
  payu: PayURefunds = payURefunds,
): Promise<DropResult> {
  const ref = db.collection("orders").doc(orderId);
  let sellerName = "A shop";
  const queued = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError("not-found", "Order not found");
    const d = snap.data()!;
    opts.guard?.(d);
    if (d.status !== "placed") throw new HttpsError("failed-precondition", WHOLE_ORDER);
    const plan = planSellerDrop(d, sellerIds);
    if (!plan) throw new HttpsError("failed-precondition", WHOLE_ORDER);
    sellerName = plan.dropped[0]?.sellerName ?? sellerName;

    // Reads (restock reads the inventory) before any write.
    await restock(tx, orderId, { ...d, allocations: plan.droppedAllocations }, actor);

    const pickups = (d.pickups ?? {}) as Stops;
    const keptStops: Stops = Object.fromEntries(Object.entries(pickups).filter(([id]) => !plan.droppedStops.includes(id)));
    const keptStores = new Set(plan.keptAllocations.map((a) => a.storeId));
    const status = { ...((d.sellerStatus ?? {}) as Record<string, string>) };
    for (const id of sellerIds) status[id] = opts.statusLabel;
    const stillPending = Object.values(status).some((s) => s === "pending");
    const summary = sellerSummary(plan.kept);
    const now = Timestamp.now();

    const update: Record<string, unknown> = {
      items: plan.kept,
      allocations: plan.keptAllocations,
      itemTotalPaise: FieldValue.increment(-plan.itemPaise),
      discountPaise: FieldValue.increment(-plan.discountSharePaise),
      totalPaise: FieldValue.increment(-plan.valuePaise),
      sellerTotals: summary.sellerTotals,
      payoutTotalPaise: summary.payoutTotalPaise,
      marginTotalPaise: summary.marginTotalPaise,
      pickupOrder: ((d.pickupOrder ?? []) as string[]).filter((id) => !plan.droppedStops.includes(id)),
      pickupCount: Object.keys(keptStops).length,
      sellersPending: stillPending,
      ...(stillPending ? {} : { sellerAcceptDeadline: null }),
      removedItems: FieldValue.arrayUnion({
        sellerIds: [...sellerIds],
        sellerName,
        items: plan.dropped.map((i) => ({ productId: i.productId, variantId: i.variantId, name: i.name ?? "", quantity: i.quantity, pricePaise: i.pricePaise })),
        valuePaise: plan.valuePaise,
        refundPaise: plan.refundPaise,
        walletPaise: plan.walletPaise,
        cashCutPaise: plan.cashCutPaise,
        reason: opts.reason.slice(0, 300),
        at: now,
      }),
      updatedAt: FieldValue.serverTimestamp(),
    };
    for (const id of plan.droppedStops) update[`pickups.${id}`] = FieldValue.delete();
    for (const id of sellerIds) {
      update[`sellerStatus.${id}`] = opts.statusLabel;
      update[`sellerIssues.${id}`] = { note: opts.reason.slice(0, 300), at: now, by: opts.issueBy };
      // The order isn't cancelled, so settlement won't count it: count it here.
      tx.set(db.collection(SELLERS).doc(id), { stats: { cancelled: FieldValue.increment(1) } }, { merge: true });
    }
    if (reservedStoresOf(d).length) {
      update[RESERVED_STORES] = reservedStoresOf(d).filter((s) => keptStores.has(s));
    }
    if (plan.cashCutPaise > 0) {
      update.cashToCollectPaise = FieldValue.increment(-plan.cashCutPaise);
      update["payment.amountPaise"] = FieldValue.increment(-plan.cashCutPaise);
    }
    if (d.couponRedeemed === true && typeof d.couponCode === "string" && plan.discountSharePaise > 0) {
      tx.set(db.collection(COUPONS).doc(d.couponCode), { totalDiscountPaise: FieldValue.increment(-plan.discountSharePaise) }, { merge: true });
    }
    if (d.countedForUser === true && typeof d.userId === "string") {
      tx.set(db.collection("users").doc(d.userId), { totalSpentPaise: FieldValue.increment(-plan.valuePaise) }, { merge: true });
    }
    if (plan.walletPaise > 0 && typeof d.userId === "string") {
      writeWalletEntry(tx, d.userId, `drop_${orderId}_${[...sellerIds].sort().join("_")}`.slice(0, 1400), {
        type: "cancel",
        amountPaise: plan.walletPaise,
        reason: "Items removed from your order",
        orderId,
        by: actor.uid,
      });
      update.walletRefundedPaise = FieldValue.increment(plan.walletPaise);
    }
    // The shops left have all packed: the order is packed now.
    const packNow = sellerOnlyOrderReady(keptStops);
    if (packNow) {
      update.status = "packed";
      update.packedAt = FieldValue.serverTimestamp();
      event(tx, snap, "packed", actor.uid);
    }

    let refund: { refundId: string; mihpayid: string; amountPaise: number } | null = null;
    if (plan.refundPaise > 0) {
      const payment = (d.payment ?? {}) as Record<string, unknown>;
      if (!payment.providerReference) {
        logger.error("Dropped lines of an online order with no PayU id; refund left for finance", { orderId });
        update.refundStatus = "pending";
      } else {
        const q = queueRefundInTx(tx, actor, { orderId }, d, {
          amountPaise: plan.refundPaise,
          reason: `Items removed: ${opts.reason}`.slice(0, 300),
        });
        Object.assign(update, q.targetUpdate);
        refund = { refundId: q.refundId, mihpayid: q.mihpayid, amountPaise: q.amountPaise };
      }
    }
    tx.update(ref, update);
    return { refund, valuePaise: plan.valuePaise };
  });

  logLifecycle("order.partial", {
    orderId,
    sellerIds: [...sellerIds],
    by: actor.uid,
    valuePaise: queued.valuePaise,
    refundPaise: queued.refund?.amountPaise ?? 0,
  });
  let refund: DropResult["refund"] = null;
  if (queued.refund) {
    const status = await sendRefund(queued.refund.refundId, queued.refund.mihpayid, queued.refund.amountPaise, payu);
    refund = { refundId: queued.refund.refundId, status };
  }
  try {
    await pushOrderCustomer(orderId, {
      title: "Some items were removed",
      body: `${sellerName} couldn't supply part of your order. ₹${(queued.valuePaise / 100).toFixed(2)} is coming back to you; the rest is on its way.`,
    }, { kind: "items_removed" });
  } catch (error) {
    logger.warn("items-removed push failed", { orderId, error: String(error) });
  }
  return { valuePaise: queued.valuePaise, refund };
}
