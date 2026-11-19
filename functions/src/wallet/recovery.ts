import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { onSchedule } from "firebase-functions/scheduler";
import { PAYU_SECRETS } from "../payments/payu";
import { REFUNDS } from "../payments/refunds";
import { db } from "../shared/firebase";
import type { Actor } from "../shared/roles";
import { RETURNS } from "../returns/model";
import { countReturnRefund, sendToReview } from "../returns/settle";
import { type ApprovalPlan, finishApproval } from "./claims";
import { ORDER_ISSUES } from "./model";

/**
 * Payouts interrupted half-way (the function died between moving money and
 * closing the claim) would leave a claim "resolving" or a return "running"
 * for ever. Every 30 minutes, anything stuck for 15 minutes is either
 * finished from what was already paid, or reopened when nothing was —
 * never paid twice.
 */
export const STUCK_AFTER_MS = 15 * 60 * 1000;
const RECOVERY_ACTOR: Actor = { uid: "system:recovery", role: "ops", email: null };

export type ClaimRecovery = "finish" | "reopen";

/**
 * What to do with a claim stuck in "resolving": finish when the money (or
 * the replacement) went out, reopen for ops when nothing moved.
 */
export function claimRecovery(input: {
  kind: string | null;
  plan: ApprovalPlan | null;
  refundFound: boolean;
  replacementFound: boolean;
}): ClaimRecovery {
  if (input.kind === "replacement") return input.replacementFound ? "finish" : "reopen";
  if (!input.plan) return "reopen"; // stopped before deciding the amounts
  if (input.plan.refundPaise > 0 && !input.refundFound) return "reopen"; // refund never recorded; wallet pays in step 2
  return "finish";
}

async function recoverClaims(cutoff: Timestamp): Promise<number> {
  const stuck = await db.collection(ORDER_ISSUES).where("status", "==", "resolving").where("updatedAt", "<=", cutoff).limit(50).get();
  for (const doc of stuck.docs) {
    const issue = doc.data();
    const kind = (issue.resolvingKind as string | undefined) ?? null;
    const plan = (issue.resolvingPlan as ApprovalPlan | null | undefined) ?? null;
    try {
      const [refund, replacement] = await Promise.all([
        db.collection(REFUNDS).where("issueId", "==", doc.id).limit(1).get(),
        db.collection("orders").where("issueId", "==", doc.id).where("replacementOf", "==", issue.orderId).limit(1).get(),
      ]);
      const action = claimRecovery({ kind, plan, refundFound: !refund.empty, replacementFound: !replacement.empty });
      if (action === "finish") {
        const finalPlan: ApprovalPlan = plan ?? { resolution: "replacement", walletPaise: 0, refundPaise: 0, note: "", sellerAtFault: false };
        await finishApproval(RECOVERY_ACTOR, doc.id, issue, finalPlan, {
          refundId: refund.docs[0]?.id ?? null,
          replacementOrderId: replacement.docs[0]?.id ?? null,
        });
        if (finalPlan.sellerAtFault) {
          await doc.ref.update({ sellerDebitError: "Approval was finished automatically: charge the seller from Orders → Return / damage." });
        }
      } else {
        await db.runTransaction(async (tx) => {
          const current = await tx.get(doc.ref);
          if (current.get("status") !== "resolving") return;
          tx.update(doc.ref, {
            status: "open",
            resolvingPlan: null,
            lastError: "Approval was interrupted before anything was paid. Approve it again.",
            updatedAt: FieldValue.serverTimestamp(),
          });
          tx.update(db.collection("orders").doc(issue.orderId as string), { "opsAlerts.claim": FieldValue.serverTimestamp() });
        });
      }
      logger.warn("Recovered a stuck claim", { issueId: doc.id, action });
    } catch (error) {
      logger.error("Claim recovery failed", { issueId: doc.id, error: String(error) });
    }
  }
  return stuck.size;
}

async function recoverReturns(cutoff: Timestamp): Promise<number> {
  const stuck = await db.collection(RETURNS).where("settle.state", "==", "running").where("settle.startedAt", "<=", cutoff).limit(50).get();
  for (const doc of stuck.docs) {
    try {
      // A refund that went out but wasn't counted yet is counted now, so
      // ops doesn't pay it again from the Claims queue.
      if (!doc.get("settle.refundId")) {
        const refund = await db.collection(REFUNDS).where("returnId", "==", doc.id).limit(1).get();
        if (!refund.empty) {
          await countReturnRefund(doc.id, doc.get("issueId") as string, refund.docs[0].id, (refund.docs[0].get("amountPaise") as number) ?? 0);
        }
      }
      const issueId = doc.get("issueId") as string;
      const replacement = await db.collection("orders").where("issueId", "==", issueId).where("replacementOf", "==", doc.get("orderId")).limit(1).get();
      await doc.ref.update({ "settle.state": "failed", "settle.error": "Interrupted: check what was paid before paying more." });
      await sendToReview(
        issueId,
        replacement.empty
          ? "Automatic refund was interrupted: check what was already paid (Payments, wallet)."
          : `Automatic return was interrupted after replacement order ${replacement.docs[0].id.slice(0, 8).toUpperCase()} was placed: don't pay it again.`,
      );
      logger.warn("Recovered a stuck return", { returnId: doc.id });
    } catch (error) {
      logger.error("Return recovery failed", { returnId: doc.id, error: String(error) });
    }
  }
  return stuck.size;
}

export const recoverStuckPayouts = onSchedule(
  { schedule: "every 30 minutes", secrets: PAYU_SECRETS, timeoutSeconds: 300 },
  async () => {
    const cutoff = Timestamp.fromMillis(Date.now() - STUCK_AFTER_MS);
    const [claims, returns] = await Promise.all([recoverClaims(cutoff), recoverReturns(cutoff)]);
    if (claims || returns) logger.info("recoverStuckPayouts", { claims, returns });
  },
);
