import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { requireString, requireUid, toHttpsError } from "../shared/callable";
import { ONLINE_METHODS, quoteOrder } from "../orders/quote";
import {
  PHONEPE_MERCHANT_ID,
  PHONEPE_SECRETS,
  getPhonePeAccessToken,
  paymentModeConfig,
  phonePeBase,
} from "./phonepe";
import { placePaidOrder } from "./place_paid_order";

/**
 * Creates a PhonePe order for the caller's server cart. The amount is never
 * taken from the client: quoteOrder validates address, slot, stock and
 * coupon and prices it from the live catalog, so an order that can't be
 * placed is rejected before the customer pays.
 *
 * Request: {paymentMethod: "UPI" | "Credit or debit card", addressId,
 *           deliverySlotId, couponCode?, tipPaise?}
 * Response: {merchantOrderId, orderId, token, merchantId, amountPaise}
 */
export const createPhonePeOrder = onCall({ secrets: PHONEPE_SECRETS }, async (request) => {
  const uid = requireUid(request);
  const data = (request.data ?? {}) as Record<string, unknown>;

  const paymentMethod = typeof data.paymentMethod === "string" ? data.paymentMethod : "UPI";
  if (!ONLINE_METHODS.includes(paymentMethod)) {
    throw new HttpsError("invalid-argument", "Invalid request");
  }
  const params = {
    uid,
    addressId: requireString(data.addressId, "addressId"),
    deliverySlotId: requireString(data.deliverySlotId, "deliverySlotId"),
    couponCode: typeof data.couponCode === "string" ? data.couponCode : null,
    tipPaise: Math.trunc(Number(data.tipPaise ?? 0)),
    paymentMethod,
  };

  let amountPaise: number;
  try {
    const quote = await db.runTransaction((tx) => quoteOrder(tx, params), { readOnly: true });
    amountPaise = quote.totalPaise;
  } catch (error) {
    toHttpsError(error);
  }

  const merchantOrderId = `zyppi-${crypto.randomUUID()}`;
  const intentRef = db.collection("paymentIntents").doc(merchantOrderId);
  await intentRef.create({
    userId: uid,
    amountPaise,
    paymentMethod,
    addressId: params.addressId,
    deliverySlotId: params.deliverySlotId,
    couponCode: params.couponCode,
    tipPaise: params.tipPaise,
    status: "created",
    transactionId: null,
    orderId: null,
    failureReason: null,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  });

  const accessToken = await getPhonePeAccessToken().catch((error) => {
    throw new HttpsError("unavailable", String(error));
  });
  const response = await fetch(`${phonePeBase()}/checkout/v2/sdk/order`, {
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: `O-Bearer ${accessToken}` },
    body: JSON.stringify({
      merchantOrderId,
      amount: amountPaise,
      paymentFlow: { type: "PG_CHECKOUT", paymentModeConfig: paymentModeConfig(paymentMethod) },
    }),
  });
  const result = (await response.json()) as { orderId?: string; token?: string };
  if (!response.ok || !result.orderId || !result.token) {
    await intentRef.update({
      status: "failed",
      failureReason: JSON.stringify(result),
      updatedAt: FieldValue.serverTimestamp(),
    });
    throw new HttpsError("unavailable", "Payment could not be started");
  }

  return {
    merchantOrderId,
    orderId: result.orderId,
    token: result.token,
    merchantId: PHONEPE_MERCHANT_ID.value(),
    amountPaise,
  };
});

/**
 * Confirms a PhonePe payment server-side and, once COMPLETED for the
 * quoted amount, creates the order. Safe to call repeatedly.
 *
 * Request: {merchantOrderId}
 * Response: {verified, pending, orderId, needsReview}
 */
export const verifyPhonePePayment = onCall({ secrets: PHONEPE_SECRETS }, async (request) => {
  const uid = requireUid(request);
  const merchantOrderId = requireString(request.data?.merchantOrderId, "merchantOrderId");

  // Only the payer may check (and complete) their own payment.
  const intent = (await db.collection("paymentIntents").doc(merchantOrderId).get()).data();
  if (!intent || intent.userId !== uid) {
    throw new HttpsError("not-found", "Unknown payment");
  }
  if (intent.orderId) {
    return { verified: true, pending: false, orderId: intent.orderId, needsReview: false };
  }
  if (intent.status === "needs_review") {
    return { verified: true, pending: false, orderId: null, needsReview: true };
  }

  const accessToken = await getPhonePeAccessToken().catch((error) => {
    throw new HttpsError("unavailable", String(error));
  });
  const response = await fetch(
    `${phonePeBase()}/checkout/v2/order/${encodeURIComponent(merchantOrderId)}/status?details=true`,
    { headers: { Authorization: `O-Bearer ${accessToken}` } },
  );
  const status = (await response.json()) as {
    state?: string;
    amount?: number;
    paymentDetails?: { transactionId?: string }[];
  };
  if (!response.ok) throw new HttpsError("unavailable", "Could not check payment");

  if (status.state === "PENDING") {
    return { verified: false, pending: true, orderId: null, needsReview: false };
  }
  if (status.state !== "COMPLETED") {
    await db.runTransaction(async (tx) => {
      const ref = db.collection("paymentIntents").doc(merchantOrderId);
      const snap = await tx.get(ref);
      if (snap.get("status") !== "created") return;
      tx.update(ref, {
        status: "failed",
        failureReason: status.state ?? "UNKNOWN",
        updatedAt: FieldValue.serverTimestamp(),
      });
    });
    return { verified: false, pending: false, orderId: null, needsReview: false };
  }

  // COMPLETED can briefly come back without its transaction details.
  const transactionId = status.paymentDetails?.[0]?.transactionId;
  if (!transactionId || typeof status.amount !== "number") {
    return { verified: false, pending: true, orderId: null, needsReview: false };
  }

  const orderId = await placePaidOrder(merchantOrderId, transactionId, status.amount);
  return orderId
    ? { verified: true, pending: false, orderId, needsReview: false }
    : { verified: true, pending: false, orderId: null, needsReview: true };
});
