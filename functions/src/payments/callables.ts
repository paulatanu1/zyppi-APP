import { assertNotBlocked } from "../admin/customers";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { requireString, requireUid, toHttpsError } from "../shared/callable";
import { assertCanOrder, getFeatures } from "../shared/features";
import { ONLINE_METHODS, quoteOrder } from "../orders/quote";
import {
  PAYU_SECRETS,
  amountString,
  classifyHash,
  merchantKey,
  merchantSalt,
  newTxnId,
  payUSdkEnvironment,
  signHash,
  userCredential,
} from "./payu";
import { settleIntent } from "./settle";
import { writeStockHold } from "./stock_hold";
import { holdId, writeWalletEntry } from "../wallet/ledger";
import { WALLET_BALANCE_CHANGED, WALLET_COVERS_ORDER, walletBalanceOf, walletToApply } from "../wallet/model";
import { HOT } from "../shared/scaling";

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
 * Stock: the quoted units are held for the payment (payments/stock_hold.ts)
 * in the transaction that creates the intent.
 *
 * Wallet (`useWallet`): the balance is checked and the wallet part
 * reserved (taken off the balance, `pay_{txnid}` held) in the same
 * transaction that creates the intent, so it can't be spent twice while
 * PayU is open. PayU is asked only for the rest. A failed / expired
 * payment gives the reservation back (settle.ts, reconcile.ts). If the
 * wallet covers it all, use placeOrder with "Wallet" (WALLET_COVERS_ORDER).
 *
 * Request: {paymentMethod: "UPI" | "Credit or debit card", addressId,
 *           deliverySlotId, couponCode?, tipPaise?, useWallet?, walletBalancePaise?}
 * Response: {txnid, key, amount, productInfo, firstName, email, phone,
 *            environment, userCredential, amountPaise, walletPaise, totalPaise}
 */
export const createPayUOrder = onCall({ ...HOT, secrets: PAYU_SECRETS }, async (request) => {
  const uid = requireUid(request);
  const data = (request.data ?? {}) as Record<string, unknown>;

  const paymentMethod = typeof data.paymentMethod === "string" ? data.paymentMethod : "UPI";
  if (!ONLINE_METHODS.includes(paymentMethod)) {
    throw new HttpsError("invalid-argument", "Invalid request");
  }
  const features = await getFeatures();
  assertCanOrder(features, paymentMethod);
  await assertNotBlocked(uid);

  const params = {
    uid,
    closedAreaIds: features.closedAreaIds,
    openAt: new Date(),
    addressId: requireString(data.addressId, "addressId"),
    deliverySlotId: requireString(data.deliverySlotId, "deliverySlotId"),
    couponCode: typeof data.couponCode === "string" ? data.couponCode : null,
    tipPaise: Math.trunc(Number(data.tipPaise ?? 0)),
    paymentMethod,
  };

  const useWallet = data.useWallet === true;
  const shownBalancePaise = Number.isInteger(data.walletBalancePaise) ? (data.walletBalancePaise as number) : null;
  const txnid = newTxnId();
  const intentRef = db.collection("paymentIntents").doc(txnid);
  const userDocRef = db.collection("users").doc(uid);
  let result: { user: Record<string, unknown>; walletPaise: number; totalPaise: number };
  try {
    // One transaction: the quote's stock is held for this payment (so the
    // last unit can't be sold to someone else while PayU is open) with the
    // wallet part and the intent.
    result = await db.runTransaction(async (tx) => {
      const quote = await quoteOrder(tx, params);
      const totalPaise = quote.totalPaise;
      const snap = await tx.get(userDocRef);
      const balance = walletBalanceOf(snap.data());
      if (useWallet && shownBalancePaise != null && shownBalancePaise !== balance) {
        throw new HttpsError("failed-precondition", WALLET_BALANCE_CHANGED);
      }
      const walletPaise = walletToApply(balance, totalPaise, useWallet);
      if (walletPaise >= totalPaise) throw new HttpsError("failed-precondition", WALLET_COVERS_ORDER);
      // Writes from here on.
      const stockHold = writeStockHold(tx, quote);
      tx.create(intentRef, {
        userId: uid,
        // What PayU charges; plus walletPaise = totalPaise.
        amountPaise: totalPaise - walletPaise,
        walletPaise,
        totalPaise,
        paymentMethod,
        addressId: params.addressId,
        deliverySlotId: params.deliverySlotId,
        couponCode: params.couponCode,
        tipPaise: params.tipPaise,
        status: "created",
        transactionId: null,
        orderId: null,
        failureReason: null,
        stockHold,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      if (walletPaise > 0) {
        writeWalletEntry(tx, uid, holdId(txnid), {
          type: "spend",
          amountPaise: -walletPaise,
          reason: "Reserved for an online payment",
          intentId: txnid,
          status: "held",
        });
      }
      return { user: snap.data() ?? {}, walletPaise, totalPaise };
    });
  } catch (error) {
    toHttpsError(error);
  }
  const { user, walletPaise, totalPaise } = result;
  const amountPaise = totalPaise - walletPaise;
  const payer = payerDetails(user, request.auth?.token.phone_number);

  return {
    txnid,
    key: merchantKey(),
    amount: amountString(amountPaise),
    productInfo: PRODUCT_INFO,
    ...payer,
    environment: payUSdkEnvironment(),
    // CheckoutPro refuses to take a payment without one, even with saved
    // cards off; it scopes any card the customer chooses to save.
    userCredential: userCredential(merchantKey(), uid),
    amountPaise,
    walletPaise,
    totalPaise,
  };
});

// A payment hash is only signed for an intent created recently.
const SIGNABLE_INTENT_AGE_MS = 60 * 60 * 1000;
// Offers / quick-pay hashes only while a checkout opened this recently.
const SDK_EVENT_INTENT_AGE_MS = 15 * 60 * 1000;

/**
 * Signs a hash CheckoutPro asks for (its `generateHash` callback). The
 * salt stays here, and only safe strings are signed: allow-listed
 * read-only commands, a payment for one of the caller's own open
 * intents at exactly the quoted amount, or (offers / quick-pay) a
 * fresh `body|date|` string during the caller's own open checkout.
 *
 * Request: {hashName, hashString, hashType?, postSalt?}
 * Response: {[hashName]: hash}
 */
export const signPayUHash = onCall({ ...HOT, secrets: PAYU_SECRETS }, async (request) => {
  const uid = requireUid(request);
  const data = (request.data ?? {}) as Record<string, unknown>;
  const hashRequest = {
    hashName: requireString(data.hashName, "hashName"),
    hashString: requireString(data.hashString, "hashString"),
    hashType: typeof data.hashType === "string" ? data.hashType : null,
    postSalt: typeof data.postSalt === "string" ? data.postSalt : null,
  };

  const decision = classifyHash(hashRequest, merchantKey());
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
    case "userCommand":
      if (decision.credential !== userCredential(merchantKey(), uid)) {
        return refuse("another user's credential");
      }
      break;
    case "sdkEvent": {
      // Only during the caller's own checkout: an open intent from the
      // last 15 minutes.
      const open = await db
        .collection("paymentIntents")
        .where("userId", "==", uid)
        .where("status", "==", "created")
        .get();
      if (
        decision.credential !== null &&
        decision.credential !== userCredential(merchantKey(), uid)
      ) {
        return refuse("another user's credential");
      }
      const fresh = open.docs.some((doc) => {
        const createdAt = doc.get("createdAt") as Timestamp | undefined;
        return (
          createdAt &&
          Date.now() - createdAt.toMillis() <= SDK_EVENT_INTENT_AGE_MS &&
          (decision.amountPaise === null || doc.get("amountPaise") === decision.amountPaise) &&
          (decision.txnid === null || doc.id === decision.txnid)
        );
      });
      if (!fresh) return refuse("no open checkout for this amount / txnid");
      logger.info("Signed PayU SDK event hash", {
        uid,
        hashName: hashRequest.hashName,
        body: decision.bodyShape,
      });
      break;
    }
  }

  return { [hashRequest.hashName]: signHash(hashRequest, merchantSalt()) };
});

/**
 * Confirms a PayU payment server-side (verify_payment) and, once captured
 * for the quoted amount, creates the order. Safe to call repeatedly.
 *
 * Request: {txnid}
 * Response: {verified, pending, orderId, needsReview}
 */
export const verifyPayUPayment = onCall({ ...HOT, secrets: PAYU_SECRETS }, async (request) => {
  const uid = requireUid(request);
  const txnid = requireString(request.data?.txnid, "txnid");

  // Only the payer may check (and complete) their own payment.
  const intent = (await db.collection("paymentIntents").doc(txnid).get()).data();
  if (!intent || intent.userId !== uid) {
    throw new HttpsError("not-found", "Unknown payment");
  }

  let settlement;
  try {
    settlement = await settleIntent(txnid);
  } catch (error) {
    logger.error("PayU verify failed", { txnid, error: String(error) });
    throw new HttpsError("unavailable", "Could not check payment");
  }

  switch (settlement.state) {
    case "completed":
      return { verified: true, pending: false, orderId: settlement.orderId, needsReview: false };
    case "needs_review":
      return { verified: true, pending: false, orderId: null, needsReview: true };
    case "pending":
      return { verified: false, pending: true, orderId: null, needsReview: false };
    case "failed":
      return { verified: false, pending: false, orderId: null, needsReview: false };
  }
});
