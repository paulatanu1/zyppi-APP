import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { requireString, requireUid, toHttpsError } from "../shared/callable";
import { COD, placeOrderInTx } from "./quote";

/**
 * Client entry point for cash-on-delivery orders (port of `place_order`).
 * Prepaid orders are only created by verifyPhonePePayment.
 *
 * Request: {addressId, deliverySlotId, paymentMethod, couponCode?, tipPaise?}
 * Response: {orderId}
 */
export const placeOrder = onCall(async (request) => {
  const uid = requireUid(request);
  const data = (request.data ?? {}) as Record<string, unknown>;

  const paymentMethod = requireString(data.paymentMethod, "paymentMethod");
  if (paymentMethod !== COD) {
    throw new HttpsError(
      "permission-denied",
      "Online payments must be confirmed by the server",
    );
  }

  const params = {
    uid,
    addressId: requireString(data.addressId, "addressId"),
    deliverySlotId: requireString(data.deliverySlotId, "deliverySlotId"),
    couponCode: typeof data.couponCode === "string" ? data.couponCode : null,
    tipPaise: Math.trunc(Number(data.tipPaise ?? 0)),
    paymentMethod,
  };

  try {
    const orderId = await db.runTransaction((tx) =>
      placeOrderInTx(tx, params, { status: "pending", providerReference: null }),
    );
    return { orderId };
  } catch (error) {
    toHttpsError(error);
  }
});
