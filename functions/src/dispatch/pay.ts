import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { onSchedule } from "firebase-functions/scheduler";
import { logger } from "firebase-functions";
import { writeAudit } from "../shared/audit";
import { requireString } from "../shared/callable";
import { db } from "../shared/firebase";
import { requireRole } from "../shared/roles";
import { RIDERS } from "../riders/model";
import { EARNINGS, istDayAndWeek } from "./earnings";
import { requireRider } from "./rider_auth";

/**
 * Pocket: payouts (requested by the rider, paid by finance outside the app
 * via UPI / bank, recorded here), manual adjustments, and incentive
 * campaigns (riderOffers) settled every night.
 */

export const PAYOUTS = "payouts";
export const RIDER_OFFERS = "riderOffers";
export const MIN_PAYOUT_PAISE = 10000;

function int(v: unknown, what: string, min: number, max: number): number {
  if (typeof v !== "number" || !Number.isInteger(v) || v < min || v > max) {
    throw new HttpsError("invalid-argument", `Invalid ${what}`);
  }
  return v;
}

/** What can be paid out: unpaid earnings minus cash the rider still holds. */
export function payable(earningsBalancePaise: number, codBalancePaise: number): number {
  return Math.max(0, earningsBalancePaise - Math.max(0, codBalancePaise));
}

/** Request: {}. Asks finance to pay the whole payable balance. */
export const riderRequestPayout = onCall(async (request) => {
  const rider = await requireRider(request);
  const ref = rider.ref.collection(PAYOUTS);
  return db.runTransaction(async (tx) => {
    const r = await tx.get(rider.ref);
    const open = await tx.get(ref.where("status", "==", "requested").limit(1));
    if (!open.empty) throw new HttpsError("failed-precondition", "PAYOUT_PENDING");
    const amount = payable((r.get("earningsBalancePaise") as number) ?? 0, (r.get("codBalancePaise") as number) ?? 0);
    if (amount < MIN_PAYOUT_PAISE) throw new HttpsError("failed-precondition", "PAYOUT_TOO_SMALL");
    const doc = ref.doc();
    tx.create(doc, {
      status: "requested",
      amountPaise: amount,
      riderId: rider.id,
      riderName: r.get("fullName") ?? null,
      requestedAt: FieldValue.serverTimestamp(),
    });
    return { id: doc.id, amountPaise: amount };
  });
});

/**
 * Request: {riderId, amountPaise, method: upi|bank|cash, reference, payoutId?}.
 * Finance records money sent; the rider's balance goes down by it.
 */
export const adminRecordPayout = onCall(async (request) => {
  const actor = requireRole(request, ["finance"]);
  const riderId = requireString(request.data?.riderId, "riderId");
  const amount = int(request.data?.amountPaise, "amount", 100, 10_000_000);
  const method = ["upi", "bank", "cash"].includes(request.data?.method) ? request.data.method : null;
  if (!method) throw new HttpsError("invalid-argument", "Invalid method");
  const reference = typeof request.data?.reference === "string" ? request.data.reference.trim().slice(0, 80) : "";
  if (method !== "cash" && reference.length < 4) throw new HttpsError("invalid-argument", "Add the UTR / reference");
  const riderRef = db.collection(RIDERS).doc(riderId);
  const payoutId = typeof request.data?.payoutId === "string" ? request.data.payoutId : null;
  await db.runTransaction(async (tx) => {
    const rider = await tx.get(riderRef);
    if (!rider.exists) throw new HttpsError("not-found", "Rider not found");
    const balance = (rider.get("earningsBalancePaise") as number) ?? 0;
    if (amount > balance) throw new HttpsError("failed-precondition", "More than the rider's unpaid earnings");
    const doc = payoutId ? riderRef.collection(PAYOUTS).doc(payoutId) : riderRef.collection(PAYOUTS).doc();
    if (payoutId) {
      const existing = await tx.get(doc);
      if (existing.get("status") !== "requested") throw new HttpsError("failed-precondition", "Already handled");
    }
    tx.set(
      doc,
      {
        status: "paid",
        amountPaise: amount,
        method,
        reference: reference || null,
        riderId,
        riderName: rider.get("fullName") ?? null,
        paidBy: actor.uid,
        paidAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    tx.update(riderRef, {
      earningsBalancePaise: FieldValue.increment(-amount),
      paidOutTotalPaise: FieldValue.increment(amount),
    });
    writeAudit(actor, { action: "rider.payout", target: doc.path, after: { amount, method, reference } }, tx);
  });
  return { ok: true };
});

/** Request: {riderId, amountPaise (+/-), reason}. Manual credit or deduction. */
export const adminAdjustEarnings = onCall(async (request) => {
  const actor = requireRole(request, ["finance", "ops"]);
  const riderId = requireString(request.data?.riderId, "riderId");
  const amount = int(request.data?.amountPaise, "amount", -1_000_000, 1_000_000);
  if (amount === 0) throw new HttpsError("invalid-argument", "Amount can't be zero");
  const reason = typeof request.data?.reason === "string" ? request.data.reason.trim().slice(0, 200) : "";
  if (reason.length < 3) throw new HttpsError("invalid-argument", "Give a reason");
  const riderRef = db.collection(RIDERS).doc(riderId);
  const { day, week } = istDayAndWeek(new Date());
  await db.runTransaction(async (tx) => {
    if (!(await tx.get(riderRef)).exists) throw new HttpsError("not-found", "Rider not found");
    const row = riderRef.collection(EARNINGS).doc();
    tx.create(row, { type: "adjustment", amountPaise: amount, reason, by: actor.uid, day, week, at: FieldValue.serverTimestamp() });
    tx.update(riderRef, {
      earningsBalancePaise: FieldValue.increment(amount),
      earnedTotalPaise: FieldValue.increment(amount),
    });
    writeAudit(actor, { action: "rider.adjust", target: row.path, after: { amount, reason } }, tx);
  });
  return { ok: true };
});

// ------------------------------------------------------------ incentives

export type OfferKind = "daily_target" | "weekly_target";

export interface RiderOffer {
  title: string;
  description: string;
  kind: OfferKind;
  /** Deliveries needed in the day / week. */
  target: number;
  rewardPaise: number;
  /** Empty = every area. */
  serviceAreaIds: string[];
  /** yyyy-mm-dd, India time, inclusive. */
  startDate: string;
  endDate: string;
  active: boolean;
}

const DATE = /^\d{4}-\d{2}-\d{2}$/;

export function validateRiderOffer(raw: unknown): RiderOffer {
  const d = (raw ?? {}) as Record<string, unknown>;
  const title = typeof d.title === "string" ? d.title.trim() : "";
  if (title.length < 3 || title.length > 60) throw new HttpsError("invalid-argument", "Title: 3–60 characters");
  const kind = d.kind === "weekly_target" ? "weekly_target" : d.kind === "daily_target" ? "daily_target" : null;
  if (!kind) throw new HttpsError("invalid-argument", "Invalid kind");
  const startDate = String(d.startDate ?? "");
  const endDate = String(d.endDate ?? "");
  if (!DATE.test(startDate) || !DATE.test(endDate) || endDate < startDate) {
    throw new HttpsError("invalid-argument", "Pick a start and end date");
  }
  return {
    title,
    description: typeof d.description === "string" ? d.description.trim().slice(0, 200) : "",
    kind,
    target: int(d.target, "target", 1, 500),
    rewardPaise: int(d.rewardPaise, "reward", 100, 1_000_000),
    serviceAreaIds: Array.isArray(d.serviceAreaIds)
      ? d.serviceAreaIds.filter((x): x is string => typeof x === "string").slice(0, 20)
      : [],
    startDate,
    endDate,
    active: d.active !== false,
  };
}

/** Request: {id?, ...RiderOffer}. */
export const adminSaveRiderOffer = onCall(async (request) => {
  const actor = requireRole(request, ["ops"]);
  const offer = validateRiderOffer(request.data);
  const id = typeof request.data?.id === "string" && /^[\w-]{1,64}$/.test(request.data.id) ? request.data.id : null;
  const ref = id ? db.collection(RIDER_OFFERS).doc(id) : db.collection(RIDER_OFFERS).doc();
  await ref.set({ ...offer, updatedAt: FieldValue.serverTimestamp(), updatedBy: actor.uid }, { merge: true });
  await writeAudit(actor, { action: "riderOffer.save", target: ref.path, after: offer });
  return { id: ref.id };
});

/** The day (daily) or week-start (weekly) periods of `offer` that ended by `today`. */
export function endedPeriod(offer: Pick<RiderOffer, "kind" | "startDate" | "endDate">, today: string, weekOfToday: string): string | null {
  // Settle yesterday's day / last week, if it was inside the offer.
  const yesterday = new Date(Date.parse(`${today}T00:00:00Z`) - 86_400_000).toISOString().slice(0, 10);
  if (offer.kind === "daily_target") {
    return yesterday >= offer.startDate && yesterday <= offer.endDate ? yesterday : null;
  }
  if (today !== weekOfToday) return null; // weeks settle on Monday
  const lastWeek = new Date(Date.parse(`${weekOfToday}T00:00:00Z`) - 7 * 86_400_000).toISOString().slice(0, 10);
  const lastSunday = new Date(Date.parse(`${weekOfToday}T00:00:00Z`) - 86_400_000).toISOString().slice(0, 10);
  return lastSunday >= offer.startDate && lastWeek <= offer.endDate ? lastWeek : null;
}

/**
 * 00:15 India time: pays every rider who hit an incentive target in the
 * period that just ended. Idempotent (one ledger row per offer, period
 * and rider).
 */
export const settleIncentives = onSchedule(
  { schedule: "15 0 * * *", timeZone: "Asia/Kolkata", timeoutSeconds: 300 },
  async () => {
    const { day: today, week } = istDayAndWeek(new Date());
    const offers = await db.collection(RIDER_OFFERS).where("active", "==", true).get();
    for (const o of offers.docs) {
      const offer = o.data() as RiderOffer;
      const period = endedPeriod(offer, today, week);
      if (!period) continue;
      const field = offer.kind === "daily_target" ? "day" : "week";
      const rows = await db
        .collectionGroup(EARNINGS)
        .where("type", "==", "order")
        .where(field, "==", period)
        .get();
      const counts = new Map<string, number>();
      for (const r of rows.docs) {
        const riderId = r.ref.parent.parent!.id;
        counts.set(riderId, (counts.get(riderId) ?? 0) + 1);
      }
      for (const [riderId, n] of counts) {
        if (n < offer.target) continue;
        const riderRef = db.collection(RIDERS).doc(riderId);
        const rider = await riderRef.get();
        if (offer.serviceAreaIds.length && !offer.serviceAreaIds.includes(rider.get("serviceAreaId"))) continue;
        const row = riderRef.collection(EARNINGS).doc(`incentive_${o.id}_${period}`);
        try {
          await db.runTransaction(async (tx) => {
            if ((await tx.get(row)).exists) return;
            const { day: d, week: w } = istDayAndWeek(new Date());
            tx.create(row, {
              type: "incentive",
              offerId: o.id,
              title: offer.title,
              period,
              amountPaise: offer.rewardPaise,
              day: d,
              week: w,
              at: FieldValue.serverTimestamp(),
            });
            tx.update(riderRef, {
              earningsBalancePaise: FieldValue.increment(offer.rewardPaise),
              earnedTotalPaise: FieldValue.increment(offer.rewardPaise),
            });
          });
        } catch (e) {
          logger.error("incentive credit failed", { offer: o.id, riderId, e });
        }
      }
    }
  },
);
