import { assertNotBlocked } from "../admin/customers";
import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { assertHasPhone } from "../shared/account_checks";
import { requireAccount, requireString, toHttpsError } from "../shared/callable";
import { assertCanOrder, getFeatures } from "../shared/features";
import { COD, OrderError, placeOrderInTx } from "./quote";
import { WALLET_METHOD } from "../wallet/model";
import { HOT } from "../shared/scaling";
import { rateLimit } from "../shared/rate_limit";
import { logLifecycle } from "../shared/log";

/**
 * The total the app showed differs from the server's quote (a seller
 * changed a price, the delivery fee changed…). The app refreshes the cart
 * and shows the new bill; nothing was charged or reserved.
 */
export const PRICE_CHANGED = "PRICE_CHANGED";

/** The total the app showed, when it sent one (older apps don't). */
export function shownTotalOf(data: Record<string, unknown>): number | undefined {
  const v = data.expectedTotalPaise;
  return Number.isInteger(v) && (v as number) >= 0 ? (v as number) : undefined;
}

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
 *           useWallet?, walletBalancePaise?, expectedTotalPaise?}
 *
 * `expectedTotalPaise` is the bill total the app showed (before wallet).
 * If the server's total differs, the order is refused with PRICE_CHANGED,
 * so the customer never owes a different amount at the door (audit S11).
 * Response: {orderId}
 */
export const placeOrder = onCall(HOT, async (request) => {
  const uid = requireAccount(request);
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
  await assertHasPhone(uid);

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

  const shownTotal = shownTotalOf(data);
  try {
    const orderId = await db.runTransaction((tx) =>
      placeOrderInTx(tx, params, { status: "pending", providerReference: null }, shownTotal, {
        wallet: {
          kind: "direct",
          useWallet: data.useWallet === true || paymentMethod === WALLET_METHOD,
          shownBalancePaise: Number.isInteger(data.walletBalancePaise) ? (data.walletBalancePaise as number) : null,
        },
      }),
    );
    logLifecycle("order.placed", { orderId, uid, paymentMethod, shownTotalPaise: shownTotal ?? null });
    return { orderId };
  } catch (error) {
    toHttpsError(priceChanged(error), { event: "order.refused", uid, paymentMethod, shownTotalPaise: shownTotal ?? null });
  }
});

/** placeOrderInTx's total check, worded for a customer checkout. */
export function priceChanged(error: unknown): unknown {
  return error instanceof OrderError && error.message === "PAYMENT_AMOUNT_MISMATCH"
    ? new OrderError(PRICE_CHANGED)
    : error;
}
