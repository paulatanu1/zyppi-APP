import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { returnSellerItem } from "../marketplace/settlement";
import { OrderError } from "../orders/quote";
import { createRefund } from "../payments/refunds";
import { db } from "../shared/firebase";
import type { Actor } from "../shared/roles";
import { placeReplacement } from "../wallet/claims";
import { writeWalletEntry } from "../wallet/ledger";
import { type ClaimLine, ORDER_ISSUES, onlineRefundable, orderRemaining, splitClaimPayout } from "../wallet/model";
import { DONE_STATUSES, RETURNS, type ReturnLine, type ReturnStatus, sellerAtFault } from "./model";
import { rupeesText, tellCustomer } from "./notify";

/**
 * What happens once a store has received a return, with no staff step:
 * the refund (wallet / original payment) or a free replacement, the
 * seller charged for their own mistake, and the claim closed when every
 * return of it is done. Each step runs once: the return's `settle` field
 * says how far it got, and the wallet entry id is fixed per return.
 */

/** Who the audit log and refund records show for automatic steps. */
export const RETURNS_ACTOR: Actor = { uid: "system:returns", role: "ops", email: null };

export async function settleReturn(returnId: string): Promise<void> {
  const ref = db.collection(RETURNS).doc(returnId);
  // Claim the work, so a retried trigger can't pay twice.
  const r = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (snap.get("status") !== "received" || snap.get("settle.state")) return null;
    tx.update(ref, { "settle.state": "running", "settle.startedAt": FieldValue.serverTimestamp() });
    return snap.data()!;
  });
  if (!r) return;
  const issueId = r.issueId as string;
  const orderId = r.orderId as string;
  const uid = r.userId as string;
  const lines = (r.lines as ReturnLine[]) ?? [];
  const amount = (r.amountPaise as number) ?? 0;
  const result: Record<string, unknown> = { walletPaise: 0, refundPaise: 0, replacementOrderId: null, sellerDebitPaise: 0 };

  try {
    let money = r.resolution !== "replacement";
    if (!money) {
      try {
        const order = (await db.collection("orders").doc(orderId).get()).data() ?? {};
        result.replacementOrderId = await placeReplacement(
          issueId,
          uid,
          orderId,
          order,
          lines.map((l) => ({ ...l, offerId: null }) as unknown as ClaimLine),
          amount,
        );
      } catch (error) {
        if (!(error instanceof OrderError)) throw error;
        // Nothing in stock anywhere: the customer gets the money instead.
        logger.info("Return: replacement unavailable, refunding to wallet", { returnId, reason: error.message });
        money = true;
      }
    }
    if (money) {
      const order = (await db.collection("orders").doc(orderId).get()).data() ?? {};
      const split = splitClaimPayout({
        amountPaise: amount,
        resolution: r.resolution === "original" ? "original" : "wallet",
        onlineRefundablePaise: onlineRefundable(order),
        orderRemainingPaise: orderRemaining(order),
      });
      if (split.onlinePaise > 0) {
        await createRefund(RETURNS_ACTOR, { orderId }, { amountPaise: split.onlinePaise, reason: `Return ${returnId.slice(0, 12)}` });
        result.refundPaise = split.onlinePaise;
      }
      if (split.walletPaise > 0) {
        await db.runTransaction(async (tx) => {
          writeWalletEntry(tx, uid, `claim_${returnId}`, {
            type: "claim",
            amountPaise: split.walletPaise,
            reason: "Refund for your return",
            orderId,
            issueId,
            by: RETURNS_ACTOR.uid,
          });
          tx.update(db.collection("orders").doc(orderId), { claimWalletPaise: FieldValue.increment(split.walletPaise) });
        });
        result.walletPaise = split.walletPaise;
      }
      await db.collection(ORDER_ISSUES).doc(issueId).update({
        returnPaidPaise: FieldValue.increment(split.onlinePaise + split.walletPaise),
      });
    }

    // The seller pays for wrong / damaged / expired items they sold.
    if (sellerAtFault(r.sellerId as string, lines)) {
      let debit = 0;
      for (const l of lines) {
        try {
          const d = await returnSellerItem(RETURNS_ACTOR, {
            orderId,
            index: l.index,
            quantity: l.quantity,
            sellerAtFault: true,
            reason: `Customer return (${l.kind})`,
          });
          debit += d.debitPaise;
        } catch (error) {
          logger.warn("Return: seller debit failed", { returnId, line: l.index, error: String(error) });
          result.sellerDebitError = String(error).slice(0, 300);
        }
      }
      result.sellerDebitPaise = debit;
    }
    await ref.update({ settle: { state: "done", ...result, at: FieldValue.serverTimestamp() } });
  } catch (error) {
    // Left for ops (the admin Claims queue shows it); never retried blindly.
    logger.error("Return settlement failed", { returnId, error: String(error) });
    await ref.update({ "settle.state": "failed", "settle.error": String(error).slice(0, 300) });
    await sendToReview(issueId, `Automatic refund failed: ${String(error).slice(0, 200)}`);
    return;
  }

  const issue = { ...r, id: issueId, chatId: (await db.collection(ORDER_ISSUES).doc(issueId).get()).get("chatId") };
  if (result.replacementOrderId) await tellCustomer(issue, "replacementSent");
  else {
    const paid = (result.walletPaise as number) + (result.refundPaise as number);
    if (paid > 0) await tellCustomer(issue, "refunded", { amount: rupeesText(paid) });
  }
  await closeIssueIfDone(issueId);
}

/**
 * A return needs a person (rider says the item doesn't match, or the
 * automatic refund failed): the claim goes back to the ops Claims queue.
 */
export async function sendToReview(issueId: string, reason: string): Promise<void> {
  await db.runTransaction(async (tx) => {
    const ref = db.collection(ORDER_ISSUES).doc(issueId);
    const issue = await tx.get(ref);
    if (!issue.exists || ["approved", "rejected"].includes(issue.get("status") as string)) return;
    tx.update(ref, { status: "open", reviewReason: reason.slice(0, 300), lastError: reason.slice(0, 300), updatedAt: FieldValue.serverTimestamp() });
    tx.update(db.collection("orders").doc(issue.get("orderId") as string), {
      issueStatus: "open",
      "opsAlerts.claim": FieldValue.serverTimestamp(),
    });
  });
}

/**
 * When every return of a claim is over: approved if anything was
 * received, rejected if nothing could be collected. A claim waiting for
 * ops (review) is left to them.
 */
export async function closeIssueIfDone(issueId: string): Promise<void> {
  await db.runTransaction(async (tx) => {
    const ref = db.collection(ORDER_ISSUES).doc(issueId);
    const issue = await tx.get(ref);
    if (!issue.exists || issue.get("status") !== "returning") return;
    const ids = (issue.get("returnIds") as string[] | undefined) ?? [];
    const returns = ids.length ? await tx.getAll(...ids.map((id) => db.collection(RETURNS).doc(id))) : [];
    const statuses = returns.map((s) => s.get("status") as ReturnStatus);
    if (!statuses.every((s) => DONE_STATUSES.includes(s))) return;
    if (returns.some((s) => s.get("status") === "received" && s.get("settle.state") !== "done")) return;
    const received = returns.filter((s) => s.get("status") === "received");
    const orderRef = db.collection("orders").doc(issue.get("orderId") as string);
    const approved = received.length > 0;
    const update: Record<string, unknown> = { openIssueId: null, issueStatus: approved ? "approved" : "rejected" };
    // Units that were never collected can be claimed again (window permitting).
    for (const s of returns.filter((x) => x.get("status") !== "received")) {
      for (const l of (s.get("lines") as ReturnLine[] | undefined) ?? []) {
        update[`claimedQty.${l.index}`] = FieldValue.increment(-l.quantity);
      }
    }
    tx.update(orderRef, update);
    const sum = (k: string) => received.reduce((a, s) => a + ((s.get(`settle.${k}`) as number | undefined) ?? 0), 0);
    tx.update(ref, {
      status: approved ? "approved" : "rejected",
      ...(approved
        ? {
            resolution: {
              type: issue.get("resolutionWanted"),
              walletPaise: sum("walletPaise"),
              refundPaise: sum("refundPaise"),
              replacementOrderId: (received.find((s) => s.get("settle.replacementOrderId"))?.get("settle.replacementOrderId") as string | undefined) ?? null,
              sellerAtFault: received.some((s) => ((s.get("settle.sellerDebitPaise") as number | undefined) ?? 0) > 0),
              sellerDebitPaise: sum("sellerDebitPaise"),
              note: "Automatic return",
              by: RETURNS_ACTOR.uid,
              at: FieldValue.serverTimestamp(),
            },
          }
        : {
            rejectReason: returns.some((s) => s.get("status") === "failed")
              ? "We couldn't collect the item because nobody was available."
              : "The return was cancelled by Zyppi support.",
            resolution: { type: "rejected", by: RETURNS_ACTOR.uid, at: FieldValue.serverTimestamp() },
          }),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}
