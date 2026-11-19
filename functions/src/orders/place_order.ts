import { assertNotBlocked } from "../admin/customers";
import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { requireString, requireUid, toHttpsError } from "../shared/callable";
import { assertCanOrder, getFeatures } from "../shared/features";
import { COD, placeOrderInTx } from "./quote";
import { WALLET_METHOD } from "../wallet/model";
import { HOT } from "../shared/scaling";
import { rateLimit } from "../shared/rate_limit";

/**
 * Client entry point for cash-on-delivery and wallet orders (port of
 * `place_order`). PayU orders are only created by verifyPayUPayment.
 *
 * Wallet: `useWallet` spends the balance (cash covers the rest);
 * paymentMethod "Wallet" means the wallet pays it all. `walletBalancePaise`
 * is the balance the app showed: if the live balance differs, the order is
 * refused with WALLET_BALANCE_CHANGED and nothing is charged.
 *
 * Request: {addressId, deliverySlotId, paymentMethod, couponCode?, tipPaise?,
 *           useWallet?, walletBalancePaise?}
 * Response: {orderId}
 */
export const placeOrder = onCall(HOT, async (request) => {
  const uid = requireUid(request);
  rateLimit("placeOrder", uid);
  const data = (request.data ?? {}) as Record<string, unknown>;

  const paymentMethod = requireString(data.paymentMethod, "paymentMethod");
  if (paymentMethod !== COD && paymentMethod !== WALLET_METHOD) {
    throw new HttpsError(
      "permission-denied",
      "Online payments must be confirmed by the server",
    );
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

  try {
    const orderId = await db.runTransaction((tx) =>
      placeOrderInTx(tx, params, { status: "pending", providerReference: null }, undefined, {
        wallet: {
          kind: "direct",
          useWallet: data.useWallet === true || paymentMethod === WALLET_METHOD,
          shownBalancePaise: Number.isInteger(data.walletBalancePaise) ? (data.walletBalancePaise as number) : null,
        },
      }),
    );
    return { orderId };
  } catch (error) {
    toHttpsError(error);
  }
});
