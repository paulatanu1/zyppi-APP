import { type DocumentReference, FieldValue, Timestamp, type Transaction } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { SELLER_PLANS } from "./model";
import { addMonths } from "./settlement_model";

/** Subscription billing periods: sellers/{id}/subscriptions/{start_planId}. */
export const PERIODS = "subscriptions";

/** Opens a billing period (fee due now) and points the seller at it. */
export function openPeriod(
  tx: Transaction,
  seller: DocumentReference,
  plan: { id: string; months: number; feePaise: number },
  startMs: number,
): number {
  const endMs = addMonths(startMs, plan.months);
  const period = seller.collection(PERIODS).doc(`${new Date(startMs).toISOString().slice(0, 10)}_${plan.id}`);
  tx.set(period, {
    planId: plan.id,
    months: plan.months,
    feePaise: plan.feePaise,
    paidPaise: 0,
    open: plan.feePaise > 0,
    start: Timestamp.fromMillis(startMs),
    end: Timestamp.fromMillis(endMs),
    createdAt: FieldValue.serverTimestamp(),
  });
  tx.set(
    seller,
    {
      subscription: {
        planId: plan.id,
        periodStart: Timestamp.fromMillis(startMs),
        periodEnd: Timestamp.fromMillis(endMs),
        remindersSent: [],
        // Unpaid at the start: grace until paid or graceDays pass (sellerDaily).
        status: plan.feePaise > 0 ? "grace" : "active",
      },
      ...(plan.feePaise > 0 ? { duesPaise: FieldValue.increment(plan.feePaise) } : {}),
    },
    { merge: true },
  );
  return endMs;
}

export async function readPlan(tx: Transaction, planId: string) {
  const plan = await tx.get(db.collection(SELLER_PLANS).doc(planId));
  if (!plan.exists) throw new HttpsError("not-found", "Plan not found");
  return { id: plan.id, months: plan.get("months") as number, feePaise: plan.get("feePaise") as number };
}

