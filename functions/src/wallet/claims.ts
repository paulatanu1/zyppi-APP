import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/https";
import { ZYPPI_SELLER_ID, OFFERS } from "../marketplace/model";
import { returnSellerItem } from "../marketplace/settlement";
import { OrderError, placeOrderInTx } from "../orders/quote";
import { PAYU_SECRETS, type PayURefunds, payURefunds } from "../payments/payu";
import { createRefund } from "../payments/refunds";
import { pushOrderCustomer } from "../push";
import { addToInbox } from "../notifications/inbox";
import { writeAudit } from "../shared/audit";
import { requireString, requireUid } from "../shared/callable";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import { writeWalletEntry } from "./ledger";
import { CLAIMS_CONFIG_DOC, autoReturnDecision, claimsConfigFrom } from "../returns/model";
import { readReturnPlan, writeReturnPlan } from "../returns/plan";
import { ownChatId, tellChat } from "../returns/notify";
import {
  type ClaimLine,
  MAX_CLAIM_PHOTOS,
  MAX_STAFF_CREDIT_PAISE,
  decodeClaimPhoto,
  ORDER_ISSUES,
  onlineRefundable,
  orderRemaining,
  replacementCandidates,
  splitClaimPayout,
  validateClaim,
} from "./model";
import { rateLimit } from "../shared/rate_limit";

/**
 * "Report a problem" on a delivered order (docs/WALLET.md).
 *
 *   orderIssues/{issueId}  the claim: lines, photos, what the customer
 *                          wants, status open → resolving → approved | rejected
 *   orders/{id}            openIssueId, claimedQty.{line}, claimWalletPaise
 *
 * The customer reports within 2 hours of delivery; ops approves or rejects
 * every claim. Approving pays it one way: wallet credit, back to the online
 * payment, or a free replacement order; and, when the seller is at fault,
 * takes their credit for those units back (marketplace/settlement.ts).
 */

const rupees = (p: number) => `₹${(p / 100).toFixed(p % 100 === 0 ? 0 : 2)}`;

const issueRef = (id: string) => db.collection(ORDER_ISSUES).doc(id);

/** Storage folder of one order's claim photos (written only by this function). */
export const claimPhotoPrefix = (uid: string, orderId: string) => `users/${uid}/claims/${orderId}/`;

/**
 * Customer: report missing / wrong / damaged / expired items.
 * Photos come in the request (base64, compressed on the phone) and are
 * stored by the server, which checks each really is an image.
 * Request: {orderId, lines: [{index, quantity, kind}], photos: [base64],
 *           note?, resolution: "wallet" | "original" | "replacement", chatId?}
 * Response: {issueId, autoReturn}
 *
 * Wrong / damaged / expired items within the automatic limits
 * (config/claims) skip ops: a return pickup is created per store at once
 * (returns/returns.ts) and the refund goes out when the store receives
 * the items. Everything else waits for ops, as before.
 */
export const reportOrderIssue = onCall(async (request) => {
  const uid = requireUid(request);
  rateLimit("reportOrderIssue", uid);
  const orderId = requireString(request.data?.orderId, "orderId");
  if (!/^[\w-]{1,64}$/.test(orderId)) throw new HttpsError("invalid-argument", "Invalid order");
  const orderRef = db.collection("orders").doc(orderId);
  const ref = db.collection(ORDER_ISSUES).doc();

  const rawPhotos = Array.isArray(request.data?.photos) ? (request.data.photos as unknown[]) : [];
  if (rawPhotos.length > MAX_CLAIM_PHOTOS) throw new HttpsError("failed-precondition", "TOO_MANY_PHOTOS");
  const photos = rawPhotos.map(decodeClaimPhoto);
  if (photos.some((p) => p === null)) throw new HttpsError("failed-precondition", "INVALID_PHOTO");
  const prefix = claimPhotoPrefix(uid, orderId);
  const paths = photos.map((p, i) => `${prefix}${ref.id}_${i}.${p!.ext}`);
  const check = (order: Record<string, unknown>) => {
    const v = validateClaim({
      order,
      uid,
      nowMs: Date.now(),
      lines: request.data?.lines,
      photos: paths,
      note: request.data?.note,
      resolution: request.data?.resolution,
      photoPrefix: prefix,
    });
    if (!v.ok) throw new HttpsError("failed-precondition", v.code);
    return v;
  };

  // Checked before uploading, so a refused claim stores nothing; checked
  // again in the transaction below.
  const before = await orderRef.get();
  if (!before.exists) throw new HttpsError("not-found", "NOT_YOUR_ORDER");
  check(before.data()!);
  // For the automatic check: this customer's claims in the last 30 days and
  // the limits. Read outside the transaction (a count isn't transactional);
  // being one claim off at the edge is harmless.
  const [recent, claimsConfig] = await Promise.all([
    db
      .collection(ORDER_ISSUES)
      .where("userId", "==", uid)
      .where("createdAt", ">=", Timestamp.fromMillis(Date.now() - 30 * 86_400_000))
      .count()
      .get(),
    db.doc(CLAIMS_CONFIG_DOC).get(),
  ]);
  const claims30d = recent.data().count + 1;
  const chatId = await ownChatId(uid, request.data?.chatId);
  const bucket = getStorage().bucket();
  await Promise.all(
    photos.map((p, i) =>
      bucket.file(paths[i]).save(p!.bytes, { contentType: p!.contentType, resumable: false, metadata: { cacheControl: "private, max-age=0" } }),
    ),
  );

  let autoReturn = false;
  try {
    await db.runTransaction(async (tx) => {
      const order = await tx.get(orderRef);
      if (!order.exists) throw new HttpsError("not-found", "NOT_YOUR_ORDER");
      const v = check(order.data()!);
      const decision = autoReturnDecision({
        kinds: v.lines.map((l) => l.kind),
        amountPaise: v.amountPaise,
        claims30d,
        config: claimsConfigFrom(claimsConfig.data()),
      });
      // Reads for the returns happen here, before the first write.
      const plan = decision.auto
        ? await readReturnPlan(tx, { issueId: ref.id, orderId, order: order.data()!, lines: v.lines, resolution: v.resolution })
        : null;
      autoReturn = !!plan;
      tx.create(ref, {
        orderId,
        userId: uid,
        status: plan ? "returning" : "open",
        autoReturn: !!plan,
        reviewReason: plan ? null : decision.auto ? "No store found on the order" : decision.reason,
        returnIds: plan ? plan.map((r) => r.ref.id) : [],
        returnPaidPaise: 0,
        chatId,
        lines: v.lines,
        photos: v.photos,
        note: v.note,
        resolutionWanted: v.resolution,
        amountPaise: v.amountPaise,
        paymentMethod: order.get("paymentMethod") ?? null,
        serviceAreaId: order.get("serviceAreaId") ?? null,
        deliveredAt: order.get("deliveredAt") ?? null,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      const update: Record<string, unknown> = {
        openIssueId: ref.id,
        issueStatus: plan ? "returning" : "open",
        // Ops alert (admin Claims queue); automatic returns don't need one.
        ...(plan ? {} : { "opsAlerts.claim": FieldValue.serverTimestamp() }),
      };
      if (plan) writeReturnPlan(tx, plan);
      for (const l of v.lines) update[`claimedQty.${l.index}`] = FieldValue.increment(l.quantity);
      tx.update(orderRef, update);
      // Shown to ops next to every claim (repeat claimers stand out).
      tx.set(
        db.collection("users").doc(uid),
        { claimStats: { count: FieldValue.increment(1), lastAt: FieldValue.serverTimestamp() } },
        { merge: true },
      );
    });
  } catch (error) {
    await Promise.all(paths.map((p) => bucket.file(p).delete().catch(() => undefined)));
    throw error;
  }
  if (chatId) {
    await tellChat(chatId, autoReturn ? "claimAutoReturn" : "claimForReview").catch((e) =>
      logger.warn("Claim chat message failed", { issueId: ref.id, error: String(e) }),
    );
  }
  return { issueId: ref.id, autoReturn };
});

/**
 * Ops / finance: approve a claim.
 * Request: {issueId, resolution: "wallet" | "original" | "replacement",
 *           amountPaise? (money only; default and maximum: the claim's value),
 *           sellerAtFault?: boolean, note?}
 * Response: {walletPaise, refundPaise, replacementOrderId, sellerDebitPaise}
 */
export const adminResolveIssue = onCall({ secrets: PAYU_SECRETS }, async (request) => {
  const actor = requireRole(request, ["ops", "finance"]);
  return resolveIssue(actor, request.data ?? {});
});

export async function resolveIssue(
  actor: Actor,
  data: Record<string, unknown>,
  payu: PayURefunds = payURefunds,
) {
  const issueId = requireString(data.issueId, "issueId");
  const resolution = data.resolution;
  if (resolution !== "wallet" && resolution !== "original" && resolution !== "replacement") {
    throw new HttpsError("invalid-argument", "Choose wallet, original payment or replacement");
  }
  const note = typeof data.note === "string" ? data.note.trim().slice(0, 300) : "";
  const sellerAtFault = data.sellerAtFault === true;

  // 1. Lock the claim, so two staff can't pay it twice.
  const locked = await db.runTransaction(async (tx) => {
    const snap = await tx.get(issueRef(issueId));
    if (!snap.exists) throw new HttpsError("not-found", "Claim not found");
    if (snap.get("status") !== "open") throw new HttpsError("failed-precondition", "This claim is already handled");
    const order = await tx.get(db.collection("orders").doc(snap.get("orderId") as string));
    if (!order.exists) throw new HttpsError("not-found", "Order not found");
    tx.update(snap.ref, {
      status: "resolving",
      resolvingBy: actor.uid,
      resolvingKind: resolution,
      resolvingPlan: null,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { issue: snap.data()!, order: order.data()! };
  });
  const { issue, order } = locked;
  const orderId = issue.orderId as string;
  const uid = issue.userId as string;
  // Automatic returns may already have paid part of it (returns/settle.ts).
  const claimPaise = Math.max(0, ((issue.amountPaise as number) ?? 0) - ((issue.returnPaidPaise as number) ?? 0));
  const unlock = (error: string) =>
    issueRef(issueId).update({ status: "open", lastError: error.slice(0, 300), updatedAt: FieldValue.serverTimestamp() });

  let refundPaise = 0;
  let walletPaise = 0;
  let refundId: string | null = null;
  let replacementOrderId: string | null = null;
  try {
    if (resolution === "replacement") {
      replacementOrderId = await placeReplacement(issueId, uid, orderId, order, issue.lines as ClaimLine[], claimPaise);
    } else {
      const asked = data.amountPaise == null ? claimPaise : Number(data.amountPaise);
      if (!Number.isInteger(asked) || asked <= 0 || asked > claimPaise) {
        throw new HttpsError("invalid-argument", `Enter an amount up to ${rupees(claimPaise)}`);
      }
      if (resolution === "original" && onlineRefundable(order) <= 0) {
        throw new HttpsError("failed-precondition", "This order wasn't paid online: use the wallet");
      }
      const split = splitClaimPayout({
        amountPaise: asked,
        resolution,
        onlineRefundablePaise: onlineRefundable(order),
        orderRemainingPaise: orderRemaining(order),
      });
      if (split.onlinePaise + split.walletPaise <= 0) {
        throw new HttpsError("failed-precondition", "Everything on this order has already been given back");
      }
      // Written before any money moves: if this function dies after the
      // refund, recoverStuckPayouts finishes the approval from it.
      const plan: ApprovalPlan = { resolution, walletPaise: split.walletPaise, refundPaise: split.onlinePaise, note, sellerAtFault };
      await issueRef(issueId).update({ resolvingPlan: plan, updatedAt: FieldValue.serverTimestamp() });
      if (split.onlinePaise > 0) {
        const r = await createRefund(actor, { orderId }, {
          amountPaise: split.onlinePaise,
          reason: `Claim ${issueId.slice(0, 8)}: ${note || "item problem"}`,
          link: { issueId },
        }, payu);
        refundId = r.refundId;
        refundPaise = split.onlinePaise;
      }
      walletPaise = split.walletPaise;
    }
  } catch (error) {
    await unlock(error instanceof Error ? error.message : String(error));
    if (error instanceof OrderError) {
      throw new HttpsError("failed-precondition", `REPLACEMENT_UNAVAILABLE: ${error.message}`);
    }
    throw error;
  }

  await finishApproval(actor, issueId, issue, {
    resolution,
    walletPaise,
    refundPaise,
    note,
    sellerAtFault,
  }, { refundId, replacementOrderId });
  return { walletPaise, refundPaise, replacementOrderId, sellerDebitPaise: await chargeSeller(actor, issueId, issue, sellerAtFault, note) };
}

/** What an approval pays, fixed before any money moves (orderIssues.resolvingPlan). */
export interface ApprovalPlan {
  resolution: "wallet" | "original" | "replacement";
  walletPaise: number;
  refundPaise: number;
  note: string;
  sellerAtFault: boolean;
}

/**
 * Step 2 of an approval: the wallet credit (fixed entry id, so it can't be
 * paid twice) and the claim marked approved, then the customer told. Only
 * while the claim is still "resolving", so the normal path and
 * recoverStuckPayouts can't both finish it.
 */
export async function finishApproval(
  actor: Actor,
  issueId: string,
  issue: Record<string, unknown>,
  plan: ApprovalPlan,
  done: { refundId: string | null; replacementOrderId: string | null },
): Promise<boolean> {
  const orderId = issue.orderId as string;
  const uid = issue.userId as string;
  const finished = await db.runTransaction(async (tx) => {
    const current = await tx.get(issueRef(issueId));
    if (current.get("status") !== "resolving") return false;
    const orderRef = db.collection("orders").doc(orderId);
    if (plan.walletPaise > 0) {
      writeWalletEntry(tx, uid, `claim_${issueId}`, {
        type: "claim",
        amountPaise: plan.walletPaise,
        reason: `Refund for a problem with your order`,
        orderId,
        issueId,
        by: actor.uid,
      });
    }
    tx.update(orderRef, {
      openIssueId: null,
      issueStatus: "approved",
      ...(plan.walletPaise > 0 ? { claimWalletPaise: FieldValue.increment(plan.walletPaise) } : {}),
    });
    tx.update(issueRef(issueId), {
      status: "approved",
      resolution: {
        type: plan.resolution,
        walletPaise: plan.walletPaise,
        refundPaise: plan.refundPaise,
        refundId: done.refundId,
        replacementOrderId: done.replacementOrderId,
        sellerAtFault: plan.sellerAtFault,
        note: plan.note,
        by: actor.uid,
        at: FieldValue.serverTimestamp(),
      },
      lastError: null,
      updatedAt: FieldValue.serverTimestamp(),
    });
    writeAudit(
      actor,
      {
        action: "claim.approve",
        target: `${ORDER_ISSUES}/${issueId}`,
        after: { resolution: plan.resolution, walletPaise: plan.walletPaise, refundPaise: plan.refundPaise, replacementOrderId: done.replacementOrderId, sellerAtFault: plan.sellerAtFault },
      },
      tx,
    );
    return true;
  });
  if (!finished) return false;
  const body =
    plan.resolution === "replacement"
      ? "A free replacement is on its way."
      : [plan.walletPaise > 0 ? `${rupees(plan.walletPaise)} added to your Zyppi wallet.` : "", plan.refundPaise > 0 ? `${rupees(plan.refundPaise)} refunded to your original payment (5–7 days).` : ""]
          .filter(Boolean)
          .join(" ");
  await pushOrderCustomer(orderId, { title: "We've sorted your problem", body }, { issueId }).catch((e) =>
    logger.warn("Claim push failed", { issueId, error: String(e) }),
  );
  return true;
}

/** Step 3: the seller pays for their own mistake (wrong, damaged, expired item). */
async function chargeSeller(actor: Actor, issueId: string, issue: Record<string, unknown>, sellerAtFault: boolean, note: string): Promise<number> {
  let sellerDebitPaise = 0;
  if (!sellerAtFault) return 0;
  const orderId = issue.orderId as string;
  for (const l of (issue.lines as ClaimLine[]).filter((x) => x.sellerId && x.sellerId !== ZYPPI_SELLER_ID)) {
    try {
      const r = await returnSellerItem(actor, {
        orderId,
        index: l.index,
        quantity: l.quantity,
        sellerAtFault: true,
        reason: `Customer claim (${l.kind}) ${note}`.trim(),
      });
      sellerDebitPaise += r.debitPaise;
    } catch (error) {
      // The claim stays approved; ops can charge it from Orders → Return / damage.
      logger.warn("Claim: seller debit failed", { issueId, line: l.index, error: String(error) });
      await issueRef(issueId).update({ sellerDebitError: String(error).slice(0, 300) });
    }
  }
  if (sellerDebitPaise) await issueRef(issueId).update({ "resolution.sellerDebitPaise": sellerDebitPaise });
  return sellerDebitPaise;
}

/**
 * A free order for the claimed units, from the best offer in stock (the
 * same seller first). Tries up to three choices of seller per line before
 * giving up (ops then picks the wallet).
 */
export async function placeReplacement(
  issueId: string,
  uid: string,
  orderId: string,
  order: Record<string, unknown>,
  lines: ClaimLine[],
  claimPaise: number,
): Promise<string> {
  const areaId = order.serviceAreaId as string;
  const choices = await Promise.all(
    lines.map(async (l) => {
      const snap = await db.collection(OFFERS).where("variantId", "==", l.variantId).where("serviceAreaId", "==", areaId).get();
      const ids = replacementCandidates(
        snap.docs.map((d) => ({
          id: d.id,
          sellerId: (d.get("sellerId") as string) ?? "",
          inStock: d.get("inStock") === true,
          isActive: d.get("isActive") === true,
          rankScore: (d.get("rankScore") as number) ?? 0,
        })),
        l.sellerId,
      );
      // Orders from before offers: Zyppi's own stock (legacy cart row).
      return ids.length ? ids : l.sellerId === ZYPPI_SELLER_ID ? [null] : [];
    }),
  );
  if (choices.some((c) => c.length === 0)) throw new OrderError("Out of stock everywhere");
  let lastError: unknown = null;
  for (let attempt = 0; attempt < 3; attempt++) {
    if (attempt > 0 && choices.every((c) => c.length <= attempt)) break;
    try {
      return await db.runTransaction((tx) =>
        placeOrderInTx(
          tx,
          {
            uid,
            openAt: new Date(),
            addressId: order.addressId as string,
            deliverySlotId: order.deliverySlotId as string,
            tipPaise: 0,
            paymentMethod: "Replacement",
            replacement: {
              lines: lines.map((l, i) => ({
                productId: l.productId,
                variantId: l.variantId,
                offerId: choices[i][Math.min(attempt, choices[i].length - 1)],
                quantity: l.quantity,
              })),
            },
          },
          { status: "succeeded", providerReference: null },
          undefined,
          { replacement: { orderId, issueId, claimAmountPaise: claimPaise } },
        ),
      );
    } catch (error) {
      if (!(error instanceof OrderError)) throw error;
      lastError = error;
    }
  }
  throw lastError ?? new OrderError("Out of stock everywhere");
}

/**
 * Ops / support: reject a claim with a reason the customer sees. The
 * units can be claimed again (e.g. with a clearer photo) while the
 * 2-hour window is open.
 * Request: {issueId, reason}
 */
export const adminRejectIssue = onCall(async (request) => {
  const actor = requireRole(request, ["ops", "support", "finance"]);
  const issueId = requireString(request.data?.issueId, "issueId");
  const reason = typeof request.data?.reason === "string" ? request.data.reason.trim().slice(0, 300) : "";
  if (reason.length < 3) throw new HttpsError("invalid-argument", "Give a reason (the customer sees it)");
  const orderId = await db.runTransaction(async (tx) => {
    const snap = await tx.get(issueRef(issueId));
    if (!snap.exists) throw new HttpsError("not-found", "Claim not found");
    if (snap.get("status") !== "open") throw new HttpsError("failed-precondition", "This claim is already handled");
    const orderId = snap.get("orderId") as string;
    const update: Record<string, unknown> = { openIssueId: null, issueStatus: "rejected" };
    for (const l of (snap.get("lines") as ClaimLine[]) ?? []) {
      update[`claimedQty.${l.index}`] = FieldValue.increment(-l.quantity);
    }
    tx.update(db.collection("orders").doc(orderId), update);
    tx.update(snap.ref, {
      status: "rejected",
      rejectReason: reason,
      resolution: { type: "rejected", by: actor.uid, at: FieldValue.serverTimestamp() },
      updatedAt: FieldValue.serverTimestamp(),
    });
    writeAudit(actor, { action: "claim.reject", target: snap.ref.path, after: { reason } }, tx);
    return orderId;
  });
  await pushOrderCustomer(orderId, { title: "About your reported problem", body: reason }, { issueId }).catch(() => undefined);
  return { ok: true };
});

/**
 * Finance: credit a customer's wallet (goodwill, a problem found after the
 * 2 hours, a cash order paid back). `requestId` is generated by the admin
 * panel per click, so a double click or retry can't credit twice.
 * Request: {uid, amountPaise, reason, requestId, orderId?}
 */
export const adminCreditWallet = onCall(async (request) => {
  const actor = requireRole(request, ["finance"]);
  const uid = requireString(request.data?.uid, "uid");
  const requestId = requireString(request.data?.requestId, "requestId");
  if (!/^[\w-]{8,64}$/.test(requestId)) throw new HttpsError("invalid-argument", "Invalid request");
  const amountPaise = Number(request.data?.amountPaise);
  if (!Number.isInteger(amountPaise) || amountPaise <= 0 || amountPaise > MAX_STAFF_CREDIT_PAISE) {
    throw new HttpsError("invalid-argument", `Enter an amount up to ${rupees(MAX_STAFF_CREDIT_PAISE)}`);
  }
  const reason = typeof request.data?.reason === "string" ? request.data.reason.trim().slice(0, 300) : "";
  if (reason.length < 3) throw new HttpsError("invalid-argument", "Give a reason (the customer sees it)");
  const orderId = typeof request.data?.orderId === "string" && request.data.orderId ? (request.data.orderId as string) : null;
  const userRef = db.collection("users").doc(uid);
  await db.runTransaction(async (tx) => {
    const user = await tx.get(userRef);
    if (!user.exists) throw new HttpsError("not-found", "Customer not found");
    const existing = await tx.get(userRef.collection("wallet").doc(`admin_${requestId}`));
    if (existing.exists) return;
    writeWalletEntry(tx, uid, `admin_${requestId}`, {
      type: "credit",
      amountPaise,
      reason,
      orderId,
      by: actor.uid,
    });
    writeAudit(actor, { action: "wallet.credit", target: userRef.path, after: { amountPaise, reason, orderId } }, tx);
  });
  await addToInbox(uid, {
    kind: "account",
    title: `${rupees(amountPaise)} added to your wallet`,
    body: reason,
    data: { screen: "wallet" },
  }).catch(() => undefined);
  return { ok: true };
});
