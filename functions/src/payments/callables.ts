import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { requireString, requireUid, toHttpsError } from "../shared/callable";
import { ONLINE_METHODS, quoteOrder } from "../orders/quote";
import {
  PAYU_MERCHANT_KEY,
  PAYU_SALT,
  PAYU_SECRETS,
  amountString,
  classifyHash,
  newTxnId,
  payUSdkEnvironment,
  signHash,
  verifyPayUTxn,
} from "./payu";
import { placePaidOrder } from "./place_paid_order";

const PRODUCT_INFO = "Zyppi order";

/** PayU wants a plain first name, a valid-looking email and 10 digits. */
function payerDetails(user: Record<string, unknown>, authPhone: string | undefined) {
  const name = String(user.fullName ?? "")
    .replace(/[^A-Za-z ]/g, "")
    .trim()
    .split(/\s+/)[0];
  const email = String(user.email ?? "").trim();
  const digits = String(user.phone ?? authPhone ?? "").replace(/\D/g, "").slice(-10);
  return {
    firstName: name || "Customer",
    email: /^[^\s@|]+@[^\s@|]+\.[^\s@|]+$/.test(email) ? email : "orders@zyppi.one",
    phone: digits.length === 10 ? digits : "9999999999",
  };
}

/**
 * Starts a PayU payment for the caller's server cart. The amount is never
 * taken from the client: quoteOrder validates address, slot, stock and
 * coupon and prices it from the live catalog, so an order that can't be
 * placed is rejected before the customer pays.
 *
 * Request: {paymentMethod: "UPI" | "Credit or debit card", addressId,
 *           deliverySlotId, couponCode?, tipPaise?}
 * Response: {txnid, key, amount, productInfo, firstName, email, phone,
 *            environment, amountPaise}
 */
export const createPayUOrder = onCall({ secrets: PAYU_SECRETS }, async (request) => {
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

  const user = (await db.collection("users").doc(uid).get()).data() ?? {};
  const payer = payerDetails(user, request.auth?.token.phone_number);

  const txnid = newTxnId();
  await db.collection("paymentIntents").doc(txnid).create({
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

  return {
    txnid,
    key: PAYU_MERCHANT_KEY.value(),
    amount: amountString(amountPaise),
    productInfo: PRODUCT_INFO,
    ...payer,
    environment: payUSdkEnvironment(),
    amountPaise,
  };
});

// A payment hash is only signed for an intent created recently.
const SIGNABLE_INTENT_AGE_MS = 60 * 60 * 1000;

/**
 * Signs a hash CheckoutPro asks for (its `generateHash` callback). The
 * salt stays here, and only safe strings are signed: allow-listed
 * read-only commands, or a payment for one of the caller's own open
 * intents at exactly the quoted amount.
 *
 * Request: {hashName, hashString, hashType?, postSalt?}
 * Response: {[hashName]: hash}
 */
export const signPayUHash = onCall({ secrets: PAYU_SECRETS }, async (request) => {
  const uid = requireUid(request);
  const data = (request.data ?? {}) as Record<string, unknown>;
  const hashRequest = {
    hashName: requireString(data.hashName, "hashName"),
    hashString: requireString(data.hashString, "hashString"),
    hashType: typeof data.hashType === "string" ? data.hashType : null,
    postSalt: typeof data.postSalt === "string" ? data.postSalt : null,
  };

  const decision = classifyHash(hashRequest, PAYU_MERCHANT_KEY.value());
  const refuse = (reason: string): never => {
    logger.warn("Refused PayU hash", { uid, hashName: hashRequest.hashName, reason });
    throw new HttpsError("permission-denied", "Hash not allowed");
  };

  const ownOpenIntent = async (txnid: string) => {
    const intent = (await db.collection("paymentIntents").doc(txnid).get()).data();
    if (!intent || intent.userId !== uid || intent.status !== "created") return null;
    const createdAt = intent.createdAt as Timestamp | undefined;
    if (!createdAt || Date.now() - createdAt.toMillis() > SIGNABLE_INTENT_AGE_MS) return null;
    return intent;
  };

  switch (decision.kind) {
    case "reject":
      return refuse(decision.reason);
    case "payment": {
      const intent = await ownOpenIntent(decision.txnid);
      if (!intent) return refuse("unknown txnid");
      if (intent.amountPaise !== decision.amountPaise) return refuse("amount differs");
      break;
    }
    case "v2": {
      const intents = await Promise.all(decision.txnids.map(ownOpenIntent));
      if (!intents.some(Boolean)) return refuse("unknown txnid");
      break;
    }
    case "command":
      break;
  }

  return { [hashRequest.hashName]: signHash(hashRequest, PAYU_SALT.value()) };
});

/**
 * Confirms a PayU payment server-side (verify_payment) and, once captured
 * for the quoted amount, creates the order. Safe to call repeatedly.
 *
 * Request: {txnid}
 * Response: {verified, pending, orderId, needsReview}
 */
export const verifyPayUPayment = onCall({ secrets: PAYU_SECRETS }, async (request) => {
  const uid = requireUid(request);
  const txnid = requireString(request.data?.txnid, "txnid");

  // Only the payer may check (and complete) their own payment.
  const intentRef = db.collection("paymentIntents").doc(txnid);
  const intent = (await intentRef.get()).data();
  if (!intent || intent.userId !== uid) {
    throw new HttpsError("not-found", "Unknown payment");
  }
  if (intent.orderId) {
    return { verified: true, pending: false, orderId: intent.orderId, needsReview: false };
  }
  if (intent.status === "needs_review") {
    return { verified: true, pending: false, orderId: null, needsReview: true };
  }

  const outcome = await verifyPayUTxn(txnid).catch((error) => {
    logger.error("PayU verify failed", { txnid, error: String(error) });
    throw new HttpsError("unavailable", "Could not check payment");
  });

  if (outcome.state === "pending") {
    return { verified: false, pending: true, orderId: null, needsReview: false };
  }
  if (outcome.state === "failed") {
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(intentRef);
      if (snap.get("status") !== "created") return;
      tx.update(intentRef, {
        status: "failed",
        failureReason: outcome.reason,
        updatedAt: FieldValue.serverTimestamp(),
      });
    });
    return { verified: false, pending: false, orderId: null, needsReview: false };
  }

  const orderId = await placePaidOrder(txnid, outcome.mihpayid, outcome.amountPaise);
  return orderId
    ? { verified: true, pending: false, orderId, needsReview: false }
    : { verified: true, pending: false, orderId: null, needsReview: true };
});
