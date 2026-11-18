import { FieldValue } from "firebase-admin/firestore";
import { onDocumentUpdated } from "firebase-functions/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { MAX_CODE_ATTEMPTS, RIDER_CONFIG_DOC } from "../dispatch/model";
import { inventoryIdFor } from "../marketplace/model";
import { requireSeller } from "../marketplace/sellers";
import { PAYU_SECRETS } from "../payments/payu";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { requireRole } from "../shared/roles";
import { earningRef, payReturnRider, releaseReturnRider, returnIdOf } from "./dispatch";
import { DONE_STATUSES, RETURNS, RETURN_OFFERS, type ReturnLine, type ReturnStatus, restockPlan } from "./model";
import { closeIssueIfDone, sendToReview, settleReturn } from "./settle";

/**
 * Seller app → "Receive return" (dark-store staff use it too, signed in as
 * Zyppi staff). The rider shows a 4-digit code; the store types it, says
 * what goes back on the shelf, and the rest happens on its own (settle.ts).
 *
 * Request: {returnId, code, restock?: {[lineIndex]: "shelf" | "write_off"}}
 */
export const storeReceiveReturn = onCall(async (request) => {
  const me = await requireSeller(request);
  const returnId = returnIdOf(request.data?.returnId);
  const code = typeof request.data?.code === "string" ? request.data.code.trim() : "";
  if (!/^\d{4}$/.test(code)) throw new HttpsError("invalid-argument", "WRONG_CODE");
  const ref = db.collection(RETURNS).doc(returnId);
  const out = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const r = snap.data();
    if (!r || r.sellerId !== me.sellerId) throw new HttpsError("permission-denied", "NOT_YOUR_RETURN");
    if (!["picked_up", "at_store"].includes(r.status as string)) throw new HttpsError("failed-precondition", "RIDER_NOT_HERE");
    const codeRef = ref.collection("private").doc("store");
    const lines = (r.lines as ReturnLine[]) ?? [];
    const riderId = r.riderId as string;
    const [c, rider, config, earned] = [
      await tx.get(codeRef),
      await tx.get(db.collection("riders").doc(riderId)),
      await tx.get(db.doc(RIDER_CONFIG_DOC)),
      await tx.get(earningRef(riderId, returnId)),
    ];
    const attempts = (c.get("attempts") as number | undefined) ?? 0;
    if (attempts >= MAX_CODE_ATTEMPTS) throw new HttpsError("failed-precondition", "CODE_LOCKED");
    if (c.get("code") !== code) {
      tx.set(codeRef, { attempts: FieldValue.increment(1) }, { merge: true });
      return { wrong: true, left: MAX_CODE_ATTEMPTS - attempts - 1 };
    }
    const plan = restockPlan(lines, request.data?.restock);
    const now = FieldValue.serverTimestamp();
    // Stock: good items back on the shelf; the rest recorded as written off.
    for (const l of lines) {
      const shelf = plan[String(l.index)] === "shelf";
      const sellerId = l.sellerId === "zyppi" ? null : l.sellerId;
      const invRef = db.collection("inventory").doc(inventoryIdFor(r.storeId as string, sellerId, l.variantId));
      if (shelf) tx.set(invRef, { quantity: FieldValue.increment(l.quantity), updatedAt: now }, { merge: true });
      tx.create(db.collection("inventoryMovements").doc(), {
        storeId: r.storeId,
        sellerId,
        productId: l.productId,
        variantId: l.variantId,
        delta: shelf ? l.quantity : 0,
        reason: shelf ? "return" : l.kind === "expired" ? "expired" : "damage",
        note: `Customer return ${returnId.slice(0, 12)}${shelf ? "" : ` (${l.quantity} written off)`}`,
        orderId: r.orderId,
        actorUid: me.uid,
        actorEmail: null,
        at: now,
      });
    }
    if (rider.exists) {
      payReturnRider(tx, rider, returnId, r, config.data(), earned);
      releaseReturnRider(tx, riderId);
    }
    tx.update(ref, {
      status: "received",
      receivedAt: now,
      receivedBy: me.uid,
      restock: plan,
      updatedAt: now,
    });
    return { wrong: false, left: MAX_CODE_ATTEMPTS };
  });
  if (out.wrong) {
    throw new HttpsError("invalid-argument", out.left > 0 ? "WRONG_CODE" : "CODE_LOCKED", { left: out.left });
  }
  return { ok: true };
});

/** Received → refund / replacement, seller charge, claim closed. A trigger, so a crash is retried. */
export const onReturnReceived = onDocumentUpdated({ document: `${RETURNS}/{returnId}`, secrets: PAYU_SECRETS }, async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (after?.status === "received" && before?.status !== "received") await settleReturn(event.params.returnId);
});

/**
 * Ops: cancel a return (customer changed their mind, wrong address…) or
 * send it to the Claims queue for a decision by hand.
 * Request: {returnId, action: "cancel" | "review", reason}
 */
export const adminUpdateReturn = onCall(async (request) => {
  const actor = requireRole(request, ["ops"]);
  const returnId = returnIdOf(request.data?.returnId);
  const action = request.data?.action;
  const reason = typeof request.data?.reason === "string" ? request.data.reason.trim().slice(0, 300) : "";
  if (action !== "cancel" && action !== "review") throw new HttpsError("invalid-argument", "Choose cancel or review");
  if (reason.length < 3) throw new HttpsError("invalid-argument", "Give a reason");
  const ref = db.collection(RETURNS).doc(returnId);
  const r = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const r = snap.data();
    if (!r) throw new HttpsError("not-found", "Return not found");
    if (DONE_STATUSES.includes(r.status as ReturnStatus)) throw new HttpsError("failed-precondition", "This return is closed");
    const offered = (r.offer as { riderId?: string } | undefined)?.riderId;
    if (offered) {
      tx.set(db.collection("riders").doc(offered), { presence: { offerReturnId: null } }, { merge: true });
      tx.delete(db.collection("riders").doc(offered).collection(RETURN_OFFERS).doc(returnId));
    }
    if (r.riderId) releaseReturnRider(tx, r.riderId as string);
    tx.update(ref, {
      status: action === "cancel" ? "cancelled" : "review",
      opsNote: reason,
      offer: FieldValue.delete(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    writeAudit(actor, { action: `return.${action}`, target: ref.path, before: { status: r.status }, after: { reason } }, tx);
    return r;
  });
  if (action === "review") await sendToReview(r.issueId as string, `Ops: ${reason}`);
  else await closeIssueIfDone(r.issueId as string);
  return { ok: true };
});
