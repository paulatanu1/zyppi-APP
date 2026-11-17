import { type DocumentReference, FieldValue, Timestamp, type Transaction } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { onSchedule } from "firebase-functions/scheduler";
import { istDayAndWeek } from "../dispatch/earnings";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import { MARKETPLACE_CONFIG_DOC, SELLERS, ZYPPI_SELLER_ID } from "./model";
import { PERIODS, openPeriod, readPlan } from "./periods";
import { notifySeller } from "./seller_notify";
import { requireSeller } from "./sellers";
import {
  type Period,
  type SettlementConfig,
  applyFeePayment,
  payoutSplit,
  remindersDue,
  returnDebit,
  sellerCredit,
  settlementConfigFrom,
  subscriptionStatus,
} from "./settlement_model";

/**
 * Seller settlement and subscriptions (docs/MARKETPLACE.md). Ledger:
 * sellers/{id}/earnings/{id} with `ledger: "seller"` (riders' ledgers share
 * the collection name). Payouts: sellers/{id}/payouts. Subscription
 * periods: sellers/{id}/subscriptions. Money is only recorded here — it is
 * paid by bank / UPI outside the app, like rider payouts.
 */

const EARNINGS = "earnings";
const PAYOUTS = "payouts";

async function config(tx?: Transaction): Promise<SettlementConfig> {
  const ref = db.doc(MARKETPLACE_CONFIG_DOC);
  return settlementConfigFrom((tx ? await tx.get(ref) : await ref.get()).data());
}

// ------------------------------------------------------------ order credits

/**
 * Delivered → each seller's net (payout − TCS − TDS) is held for the return
 * window. Cancelled after that → a reversal. Idempotent: deterministic ids.
 */
export const onOrderSettleSellers = onDocumentWritten("orders/{orderId}", async (e) => {
  const before = e.data?.before?.data();
  const after = e.data?.after?.data();
  if (!after) return;
  const delivered = after.status === "delivered" && before?.status !== "delivered";
  const cancelled = after.status === "cancelled" && before?.status !== "cancelled";
  if (!delivered && !cancelled) return;
  const totals = (after.sellerTotals ?? {}) as Record<string, { itemTotalPaise?: number; payoutPaise?: number }>;
  const issues = (after.sellerIssues ?? {}) as Record<string, unknown>;
  const orderId = e.params.orderId;
  for (const sellerId of Object.keys(totals)) {
    if (delivered) await creditSeller(sellerId, orderId, totals[sellerId]);
    else await reverseSeller(sellerId, orderId, !!issues[sellerId]);
  }
});

async function creditSeller(sellerId: string, orderId: string, totals: { itemTotalPaise?: number; payoutPaise?: number }) {
  const seller = db.collection(SELLERS).doc(sellerId);
  const row = seller.collection(EARNINGS).doc(`${orderId}_order`);
  await db.runTransaction(async (tx) => {
    const [cfg, existing, s] = [await config(tx), await tx.get(row), await tx.get(seller)];
    if (existing.exists || !s.exists) return;
    const c = sellerCredit(totals, !!s.get("gstin"), cfg);
    const now = new Date();
    const { day, week } = istDayAndWeek(now);
    tx.create(row, {
      ledger: "seller",
      type: "order",
      orderId,
      ...c,
      amountPaise: c.netPaise,
      status: "held",
      releaseAt: Timestamp.fromMillis(now.getTime() + cfg.holdDays * 86_400_000),
      day,
      week,
      at: FieldValue.serverTimestamp(),
    });
    tx.update(seller, {
      heldPaise: FieldValue.increment(c.netPaise),
      earnedTotalPaise: FieldValue.increment(c.netPaise),
      "stats.orders": FieldValue.increment(1),
      "taxTotals.tcsPaise": FieldValue.increment(c.tcsPaise),
      "taxTotals.tdsPaise": FieldValue.increment(c.tdsPaise),
    });
  });
}

async function reverseSeller(sellerId: string, orderId: string, sellerAtFault: boolean) {
  const seller = db.collection(SELLERS).doc(sellerId);
  const credit = seller.collection(EARNINGS).doc(`${orderId}_order`);
  const reversal = seller.collection(EARNINGS).doc(`${orderId}_reversal`);
  await db.runTransaction(async (tx) => {
    const [c, r, s] = [await tx.get(credit), await tx.get(reversal), await tx.get(seller)];
    if (!s.exists) return;
    if (sellerAtFault) tx.update(seller, { "stats.cancelled": FieldValue.increment(1) });
    if (!c.exists || r.exists) return;
    // Units already returned were taken back by their own rows.
    const share = 1 - ((c.get("returnedPaise") as number) ?? 0) / Math.max(1, (c.get("amountPaise") as number) ?? 0);
    const net = ((c.get("amountPaise") as number) ?? 0) - ((c.get("returnedPaise") as number) ?? 0);
    const wasHeld = c.get("status") === "held";
    const { day, week } = istDayAndWeek(new Date());
    tx.create(reversal, {
      ledger: "seller",
      type: "reversal",
      orderId,
      amountPaise: -net,
      grossPaise: -Math.round(((c.get("grossPaise") as number) ?? 0) * share),
      payoutPaise: -Math.round(((c.get("payoutPaise") as number) ?? 0) * share),
      tcsPaise: -Math.round(((c.get("tcsPaise") as number) ?? 0) * share),
      tdsPaise: -Math.round(((c.get("tdsPaise") as number) ?? 0) * share),
      status: "applied",
      day,
      week,
      at: FieldValue.serverTimestamp(),
    });
    // A held credit is simply never released; a released one comes off the balance.
    if (wasHeld) tx.update(credit, { status: "reversed" });
    tx.update(seller, {
      ...(wasHeld ? { heldPaise: FieldValue.increment(-net) } : { earningsBalancePaise: FieldValue.increment(-net) }),
      earnedTotalPaise: FieldValue.increment(-net),
      "taxTotals.tcsPaise": FieldValue.increment(-Math.round(((c.get("tcsPaise") as number) ?? 0) * share)),
      "taxTotals.tdsPaise": FieldValue.increment(-Math.round(((c.get("tdsPaise") as number) ?? 0) * share)),
    });
  });
}

// ------------------------------------------------------------ subscriptions

/**
 * Admin → seller → plan (finance). Starts the subscription now if there is
 * none; otherwise the new plan applies from the next period.
 * Request: {sellerId, planId}.
 */
export const adminSetSellerPlan = onCall(async (request) => {
  const actor = requireRole(request, ["finance"]);
  const sellerId = String(request.data?.sellerId ?? "");
  const planId = String(request.data?.planId ?? "");
  const ref = db.collection(SELLERS).doc(sellerId);
  return db.runTransaction(async (tx) => {
    const [s, plan] = [await tx.get(ref), await readPlan(tx, planId)];
    if (!s.exists || s.get("model") !== "subscription") throw new HttpsError("failed-precondition", "Not a subscription seller");
    const started = !!s.get("subscription.periodEnd");
    if (started) tx.update(ref, { "subscription.nextPlanId": plan.id });
    else openPeriod(tx, ref, plan, Date.now());
    writeAudit(actor, { action: "seller.plan", target: ref.path, after: { planId, from: started ? "next period" : "now" } }, tx);
    return { ok: true, startsNow: !started };
  });
});

/** Oldest unpaid period start (ms), from the open periods. */
async function openPeriods(tx: Transaction, seller: DocumentReference): Promise<(Period & { ref: DocumentReference })[]> {
  const snap = await tx.get(seller.collection(PERIODS).where("open", "==", true));
  return snap.docs.map((d) => ({
    id: d.id,
    ref: d.ref,
    feePaise: d.get("feePaise") as number,
    paidPaise: (d.get("paidPaise") as number) ?? 0,
    startMs: (d.get("start") as Timestamp).toMillis(),
  }));
}

/** Marks `amount` of fees paid, oldest period first (inside a transaction, after reads). */
function payFees(tx: Transaction, periods: (Period & { ref: DocumentReference })[], amountPaise: number) {
  const { paid } = applyFeePayment(periods, amountPaise);
  for (const p of periods) {
    if (paid[p.id] == null) continue;
    tx.update(p.ref, { paidPaise: paid[p.id], open: paid[p.id] < p.feePaise });
  }
  const stillOpen = periods.filter((p) => (paid[p.id] ?? p.paidPaise) < p.feePaise);
  return stillOpen.length ? Math.min(...stillOpen.map((p) => p.startMs)) : null;
}

// ------------------------------------------------------------ payouts & fees

/** Seller app → "Request payout" (owner). Dues come off first. */
export const sellerRequestPayout = onCall(async (request) => {
  const me = await requireSeller(request, ["owner"]);
  const ref = db.collection(SELLERS).doc(me.sellerId);
  return db.runTransaction(async (tx) => {
    const [cfg, s, open] = [
      await config(tx),
      await tx.get(ref),
      await tx.get(ref.collection(PAYOUTS).where("status", "==", "requested").limit(1)),
    ];
    if (!open.empty) throw new HttpsError("failed-precondition", "A payout request is already open");
    const split = payoutSplit(
      (s.get("earningsBalancePaise") as number) ?? 0,
      (s.get("duesPaise") as number) ?? 0,
      cfg.minPayoutPaise,
    );
    if (!split) throw new HttpsError("failed-precondition", `MIN_PAYOUT:${cfg.minPayoutPaise}`);
    const payout = ref.collection(PAYOUTS).doc();
    tx.create(payout, {
      status: "requested",
      ...split,
      requestedBy: me.uid,
      requestedAt: FieldValue.serverTimestamp(),
    });
    return { payoutId: payout.id, ...split };
  });
});

/**
 * Finance records a seller payout made by bank / UPI (UTR). Dues deducted
 * with it are marked paid. Request: {sellerId, payoutId?, amountPaise,
 * duesDeductedPaise?, method: upi|bank, reference}.
 */
export async function recordSellerPayout(actor: Actor, d: Record<string, unknown>) {
  const sellerId = String(d.sellerId ?? "");
  const amount = Number(d.amountPaise);
  const dues = Number(d.duesDeductedPaise ?? 0);
  const method = d.method === "upi" || d.method === "bank" ? d.method : null;
  const reference = typeof d.reference === "string" ? d.reference.trim().slice(0, 60) : "";
  if (!Number.isInteger(amount) || amount < 0 || !Number.isInteger(dues) || dues < 0 || amount + dues <= 0) {
    throw new HttpsError("invalid-argument", "Enter the amount paid");
  }
  if (!method || reference.length < 4) throw new HttpsError("invalid-argument", "Method and UTR / reference are required");
  const ref = db.collection(SELLERS).doc(sellerId);
  return db.runTransaction(async (tx) => {
    const s = await tx.get(ref);
    if (!s.exists) throw new HttpsError("not-found", "Seller not found");
    const payoutRef = typeof d.payoutId === "string" && d.payoutId ? ref.collection(PAYOUTS).doc(d.payoutId) : ref.collection(PAYOUTS).doc();
    const [payout, periods] = [await tx.get(payoutRef), await openPeriods(tx, ref)];
    if (payout.exists && payout.get("status") !== "requested") throw new HttpsError("failed-precondition", "Already recorded");
    const balance = (s.get("earningsBalancePaise") as number) ?? 0;
    if (amount + dues > balance) throw new HttpsError("failed-precondition", `The seller's balance is ₹${(balance / 100).toFixed(2)}`);
    if (dues > ((s.get("duesPaise") as number) ?? 0)) throw new HttpsError("failed-precondition", "More than the dues");
    const oldestUnpaid = dues ? payFees(tx, periods, dues) : undefined;
    tx.set(payoutRef, {
      status: "paid",
      payablePaise: amount,
      duesDeductedPaise: dues,
      method,
      reference,
      paidBy: actor.uid,
      paidAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    const { day, week } = istDayAndWeek(new Date());
    tx.create(ref.collection(EARNINGS).doc(`payout_${payoutRef.id}`), {
      ledger: "seller",
      type: "payout",
      payoutId: payoutRef.id,
      amountPaise: -(amount + dues),
      duesPaise: dues,
      status: "applied",
      day,
      week,
      at: FieldValue.serverTimestamp(),
    });
    tx.update(ref, {
      earningsBalancePaise: FieldValue.increment(-(amount + dues)),
      paidOutTotalPaise: FieldValue.increment(amount),
      ...(dues ? { duesPaise: FieldValue.increment(-dues) } : {}),
      ...(oldestUnpaid === null ? { "subscription.status": "active" } : {}),
    });
    writeAudit(actor, { action: "seller.payout", target: payoutRef.path, after: { amount, dues, method, reference } }, tx);
    return { ok: true, payoutId: payoutRef.id };
  });
}

export const adminRecordSellerPayout = onCall(async (request) =>
  recordSellerPayout(requireRole(request, ["finance"]), request.data ?? {}),
);

/** Finance records a subscription fee paid offline. Request: {sellerId, amountPaise, method, reference}. */
export const adminRecordSellerFee = onCall(async (request) => {
  const actor = requireRole(request, ["finance"]);
  const d = request.data ?? {};
  const amount = Number(d.amountPaise);
  const reference = typeof d.reference === "string" ? d.reference.trim().slice(0, 60) : "";
  if (!Number.isInteger(amount) || amount <= 0) throw new HttpsError("invalid-argument", "Enter the amount received");
  if (!["upi", "bank", "cash"].includes(d.method) || reference.length < 2) {
    throw new HttpsError("invalid-argument", "Method and reference are required");
  }
  const ref = db.collection(SELLERS).doc(String(d.sellerId ?? ""));
  return db.runTransaction(async (tx) => {
    const [s, periods] = [await tx.get(ref), await openPeriods(tx, ref)];
    if (!s.exists) throw new HttpsError("not-found", "Seller not found");
    const dues = (s.get("duesPaise") as number) ?? 0;
    if (amount > dues) throw new HttpsError("failed-precondition", `Only ₹${(dues / 100).toFixed(2)} is due`);
    const oldestUnpaid = payFees(tx, periods, amount);
    tx.create(ref.collection("feePayments").doc(), {
      amountPaise: amount,
      method: d.method,
      reference,
      by: actor.uid,
      at: FieldValue.serverTimestamp(),
    });
    tx.update(ref, {
      duesPaise: FieldValue.increment(-amount),
      ...(oldestUnpaid === null ? { "subscription.status": "active" } : {}),
    });
    writeAudit(actor, { action: "seller.fee", target: ref.path, after: { amount, method: d.method, reference } }, tx);
    return { ok: true };
  });
});

/** Finance: signed correction with a reason (damage charge, goodwill…). Request: {sellerId, amountPaise, reason}. */
export const adminAdjustSellerEarnings = onCall(async (request) => {
  const actor = requireRole(request, ["finance"]);
  const amount = Number(request.data?.amountPaise);
  const reason = typeof request.data?.reason === "string" ? request.data.reason.trim().slice(0, 300) : "";
  if (!Number.isInteger(amount) || amount === 0 || Math.abs(amount) > 10_000_000) {
    throw new HttpsError("invalid-argument", "Enter a non-zero amount");
  }
  if (reason.length < 3) throw new HttpsError("invalid-argument", "Give a reason (the seller sees it)");
  const ref = db.collection(SELLERS).doc(String(request.data?.sellerId ?? ""));
  return db.runTransaction(async (tx) => {
    const s = await tx.get(ref);
    if (!s.exists) throw new HttpsError("not-found", "Seller not found");
    const { day, week } = istDayAndWeek(new Date());
    const row = ref.collection(EARNINGS).doc();
    tx.create(row, { ledger: "seller", type: "adjustment", amountPaise: amount, reason, by: actor.uid, status: "applied", day, week, at: FieldValue.serverTimestamp() });
    tx.update(ref, { earningsBalancePaise: FieldValue.increment(amount), earnedTotalPaise: FieldValue.increment(amount) });
    writeAudit(actor, { action: "seller.adjust", target: row.path, after: { amount, reason } }, tx);
    return { ok: true };
  });
});

/**
 * Orders → Return / damage (ops, finance): units of a delivered line came
 * back or were damaged. When the seller is at fault (wrong, damaged or
 * expired item) their credit for those units is taken back, from held
 * money first, else the balance; otherwise Zyppi absorbs it. Refunding
 * the customer is the separate Refund action. Request: {orderId, index,
 * quantity, sellerAtFault, reason}.
 */
export const adminReturnSellerItem = onCall(async (request) => {
  const actor = requireRole(request, ["ops", "finance"]);
  const orderId = typeof request.data?.orderId === "string" ? request.data.orderId : "";
  const index = Number(request.data?.index);
  const quantity = Number(request.data?.quantity);
  const atFault = request.data?.sellerAtFault === true;
  const reason = typeof request.data?.reason === "string" ? request.data.reason.trim().slice(0, 300) : "";
  if (!/^[\w-]{1,64}$/.test(orderId)) throw new HttpsError("invalid-argument", "Invalid order");
  if (!Number.isInteger(index) || index < 0) throw new HttpsError("invalid-argument", "Invalid line");
  if (!Number.isInteger(quantity) || quantity < 1) throw new HttpsError("invalid-argument", "Enter how many units");
  if (reason.length < 3) throw new HttpsError("invalid-argument", "Give a reason (the seller sees it)");
  const orderRef = db.collection("orders").doc(orderId);
  return db.runTransaction(async (tx) => {
    const order = await tx.get(orderRef);
    if (!order.exists) throw new HttpsError("not-found", "Order not found");
    if (order.get("status") !== "delivered") throw new HttpsError("failed-precondition", "Only delivered orders");
    const items = (order.get("items") ?? []) as { sellerId?: string; pricePaise?: number; payoutPaise?: number; quantity?: number; name?: string }[];
    const line = items[index];
    if (!line?.sellerId || line.sellerId === ZYPPI_SELLER_ID) {
      throw new HttpsError("failed-precondition", "Not a marketplace seller's item");
    }
    const returned = ((order.get("returns") ?? {}) as Record<string, number>)[String(index)] ?? 0;
    if (returned + quantity > (line.quantity ?? 0)) {
      throw new HttpsError("failed-precondition", `Only ${(line.quantity ?? 0) - returned} left to return`);
    }
    const seller = db.collection(SELLERS).doc(line.sellerId);
    const credit = seller.collection(EARNINGS).doc(`${orderId}_order`);
    const [cfg, s, c] = [await config(tx), await tx.get(seller), await tx.get(credit)];
    let debitPaise = 0;
    if (atFault && s.exists && c.exists && c.get("status") !== "reversed") {
      const d = returnDebit(line, quantity, !!s.get("gstin"), cfg);
      debitPaise = d.netPaise;
      const { day, week } = istDayAndWeek(new Date());
      tx.create(seller.collection(EARNINGS).doc(`${orderId}_return_${index}_${returned + quantity}`), {
        ledger: "seller",
        type: "return",
        orderId,
        amountPaise: -d.netPaise,
        grossPaise: -d.grossPaise,
        payoutPaise: -d.payoutPaise,
        tcsPaise: -d.tcsPaise,
        tdsPaise: -d.tdsPaise,
        reason: `${quantity} × ${line.name ?? "item"}: ${reason}`,
        by: actor.uid,
        status: "applied",
        day,
        week,
        at: FieldValue.serverTimestamp(),
      });
      const held = c.get("status") === "held";
      tx.update(seller, {
        ...(held ? { heldPaise: FieldValue.increment(-d.netPaise) } : { earningsBalancePaise: FieldValue.increment(-d.netPaise) }),
        earnedTotalPaise: FieldValue.increment(-d.netPaise),
        "taxTotals.tcsPaise": FieldValue.increment(-d.tcsPaise),
        "taxTotals.tdsPaise": FieldValue.increment(-d.tdsPaise),
        "stats.returns": FieldValue.increment(1),
      });
      // Taken back already: the credit releases (or reverses) only the rest.
      tx.update(credit, { returnedPaise: FieldValue.increment(d.netPaise) });
    }
    tx.update(orderRef, { [`returns.${index}`]: returned + quantity });
    writeAudit(actor, { action: "order.returnItem", target: orderRef.path, after: { index, quantity, atFault, debitPaise, reason } }, tx);
    return { debitPaise };
  });
});

// ------------------------------------------------------------ daily job

/**
 * 00:30 India time, once a day: releases held earnings, renews
 * subscriptions and updates their status, sends renewal reminders, and
 * pauses sellers whose FSSAI licence expired.
 */
export const sellerDaily = onSchedule(
  { schedule: "30 0 * * *", timeZone: "Asia/Kolkata", timeoutSeconds: 540 },
  async () => {
    await releaseHeld();
    await subscriptionsAndLicences();
  },
);

export async function releaseHeld(now = Timestamp.now()): Promise<number> {
  const due = await db
    .collectionGroup(EARNINGS)
    .where("ledger", "==", "seller")
    .where("status", "==", "held")
    .where("releaseAt", "<=", now)
    .limit(500)
    .get();
  for (const row of due.docs) {
    await db.runTransaction(async (tx) => {
      const r = await tx.get(row.ref);
      if (r.get("status") !== "held") return;
      // Returns already came off the held money (adminReturnSellerItem).
      const net = ((r.get("amountPaise") as number) ?? 0) - ((r.get("returnedPaise") as number) ?? 0);
      tx.update(row.ref, { status: "available", releasedAt: FieldValue.serverTimestamp() });
      tx.update(row.ref.parent.parent!, {
        heldPaise: FieldValue.increment(-net),
        earningsBalancePaise: FieldValue.increment(net),
      });
    });
  }
  return due.size;
}

async function subscriptionsAndLicences(nowMs = Date.now()): Promise<void> {
  const cfg = await config();
  const sellers = await db.collection(SELLERS).where("status", "==", "approved").get();
  const today = new Date(nowMs + 330 * 60_000).toISOString().slice(0, 10);
  for (const s of sellers.docs) {
    // FSSAI: expired licences pause the seller's offers (sellerCanSell).
    const expiry = s.get("fssaiExpiry") as string | undefined;
    const expired = !!expiry && expiry < today;
    if (expired !== (s.get("compliance.fssaiExpired") === true)) {
      await s.ref.update({ "compliance.fssaiExpired": expired });
      if (expired) await notifySeller(s.id, "", "licence_expired");
    }
    if (s.get("model") !== "subscription" || !s.get("subscription.periodEnd")) continue;
    const reminders: number[] = [];
    const statusBefore = s.get("subscription.status") as string | undefined;
    let statusAfter = statusBefore;
    await db.runTransaction(async (tx) => {
      reminders.length = 0;
      const seller = await tx.get(s.ref);
      const sub = (seller.get("subscription") ?? {}) as Record<string, unknown>;
      let endMs = (sub.periodEnd as Timestamp).toMillis();
      const planId = (sub.nextPlanId as string | undefined) ?? (sub.planId as string);
      const renew = nowMs >= endMs && sub.cancelAtEnd !== true;
      const plan = renew ? await readPlan(tx, planId) : null;
      const periods = await openPeriods(tx, s.ref);
      let oldest = periods.length ? Math.min(...periods.map((p) => p.startMs)) : null;
      if (renew && plan) {
        const startMs = endMs;
        endMs = openPeriod(tx, s.ref, plan, startMs);
        if (plan.feePaise > 0 && oldest == null) oldest = startMs;
        tx.update(s.ref, { "subscription.nextPlanId": FieldValue.delete() });
      }
      const status = sub.cancelAtEnd === true && nowMs >= endMs ? "expired" : subscriptionStatus(oldest, nowMs, cfg.graceDays);
      const sent = renew ? [] : ((sub.remindersSent as number[] | undefined) ?? []);
      reminders.push(...remindersDue(endMs, nowMs, sent));
      statusAfter = status;
      tx.update(s.ref, {
        "subscription.status": status,
        "subscription.remindersSent": [...sent, ...reminders],
      });
    });
    if (reminders.length) await notifySeller(s.id, "", "subscription_reminder");
    if (statusAfter === "expired" && statusBefore !== "expired") await notifySeller(s.id, "", "subscription_expired");
  }
}
