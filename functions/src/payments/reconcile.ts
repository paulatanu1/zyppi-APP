import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { onSchedule } from "firebase-functions/scheduler";
import { db } from "../shared/firebase";
import { PAYU_SECRETS, PayUOutcome, verifyPayUTxn } from "./payu";
import { settleIntent } from "./settle";

/** Leave fresh intents to the app's own checks while checkout is open. */
export const RECONCILE_MIN_AGE_MS = 5 * 60 * 1000;
/** After this, an intent PayU still can't settle is closed as expired. */
export const RECONCILE_MAX_AGE_MS = 48 * 60 * 60 * 1000;
/** Intents per run; the rest wait for the next run. */
export const RECONCILE_BATCH = 100;

/** What the reconciler does with an open intent of [ageMs]. */
export function reconcileAction(ageMs: number): "skip" | "settle" | "expire" {
  if (ageMs < RECONCILE_MIN_AGE_MS) return "skip";
  if (ageMs > RECONCILE_MAX_AGE_MS) return "expire";
  return "settle";
}

export interface ReconcileSummary {
  settled: Record<string, number>;
  expired: number;
  errors: number;
}

/**
 * Settles PayU payments the app never confirmed (app killed, network
 * lost, bank captured late): every open intent between 5 minutes and 48
 * hours old is checked with PayU; older ones are expired. A late
 * capture for an expired intent still lands (see settleIntent).
 */
export async function reconcileOpenIntents(
  now: number = Date.now(),
  verify: (txnid: string) => Promise<PayUOutcome> = verifyPayUTxn,
): Promise<ReconcileSummary> {
  const snap = await db
    .collection("paymentIntents")
    .where("status", "==", "created")
    .where("createdAt", "<=", Timestamp.fromMillis(now - RECONCILE_MIN_AGE_MS))
    .orderBy("createdAt")
    .limit(RECONCILE_BATCH)
    .get();

  const summary: ReconcileSummary = { settled: {}, expired: 0, errors: 0 };
  for (const doc of snap.docs) {
    const createdAt = doc.get("createdAt") as Timestamp | undefined;
    const action = reconcileAction(createdAt ? now - createdAt.toMillis() : Infinity);
    try {
      if (action === "skip") continue;
      if (action === "settle") {
        const { state } = await settleIntent(doc.id, verify);
        summary.settled[state] = (summary.settled[state] ?? 0) + 1;
        continue;
      }
      // One last look before closing it, so a capture isn't missed.
      const { state } = await settleIntent(doc.id, verify);
      if (state !== "pending") {
        summary.settled[state] = (summary.settled[state] ?? 0) + 1;
        continue;
      }
      await db.runTransaction(async (tx) => {
        const current = await tx.get(doc.ref);
        if (current.get("status") !== "created") return;
        tx.update(doc.ref, {
          status: "expired",
          failureReason: "Not settled by PayU within 48 hours",
          updatedAt: FieldValue.serverTimestamp(),
        });
      });
      summary.expired += 1;
    } catch (error) {
      summary.errors += 1;
      logger.warn("PayU reconcile failed", { txnid: doc.id, error: String(error) });
    }
  }
  return summary;
}

export const reconcilePayUIntents = onSchedule(
  { schedule: "every 10 minutes", secrets: PAYU_SECRETS, timeoutSeconds: 300 },
  async () => {
    const summary = await reconcileOpenIntents();
    logger.info("PayU reconcile", summary);
  },
);
