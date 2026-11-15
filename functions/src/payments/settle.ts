import { FieldValue } from "firebase-admin/firestore";
import { db } from "../shared/firebase";
import { PayUOutcome, verifyPayUTxn } from "./payu";
import { CLOSED_BY_ADMIN, placePaidOrder } from "./place_paid_order";

/** Where a payment intent stands after asking PayU about it. */
export type Settlement =
  | { state: "completed"; orderId: string }
  | { state: "needs_review" }
  | { state: "pending" }
  | { state: "failed" };

/**
 * Settles one payment intent from PayU's own record (verify_payment) —
 * never from anything a client or webhook sent. Captured → the order is
 * created; failed → the intent is marked failed; still in progress →
 * left as is for a later check. Idempotent, so the app, the webhook and
 * the reconciler can all call it for the same txnid.
 *
 * Throws when PayU can't be reached; the intent is unchanged.
 */
export async function settleIntent(
  txnid: string,
  verify: (txnid: string) => Promise<PayUOutcome> = verifyPayUTxn,
): Promise<Settlement> {
  const intentRef = db.collection("paymentIntents").doc(txnid);
  const intent = (await intentRef.get()).data();
  if (!intent) throw new Error("Unknown payment");
  if (intent.orderId) return { state: "completed", orderId: intent.orderId as string };
  // Paid but handled by a person (admin panel): never turned into an order
  // by a late webhook or reconcile.
  if (CLOSED_BY_ADMIN.includes(intent.status)) return { state: "needs_review" };
  // A failed / expired intent is still asked about: PayU can report
  // "not found" before a payment lands, and a late capture must still
  // become an order (or needs_review), never be lost.

  const outcome = await verify(txnid);

  if (outcome.state === "pending") return { state: "pending" };
  if (outcome.state === "failed") {
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(intentRef);
      if (snap.get("status") !== "created" && snap.get("status") !== "expired") return;
      tx.update(intentRef, {
        status: "failed",
        failureReason: outcome.reason,
        updatedAt: FieldValue.serverTimestamp(),
      });
    });
    return { state: "failed" };
  }

  const orderId = await placePaidOrder(txnid, outcome.mihpayid, outcome.amountPaise);
  return orderId ? { state: "completed", orderId } : { state: "needs_review" };
}
