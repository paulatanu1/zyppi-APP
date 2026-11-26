import { HttpsError, onCall } from "firebase-functions/https";
import { updateOrderStatus } from "../admin/orders";
import { PAYU_SECRETS } from "../payments/payu";
import { requireString, requireUid } from "../shared/callable";
import type { Actor } from "../shared/roles";
import { rateLimit } from "../shared/rate_limit";

/** Why the customer cancelled (the app shows these). */
export const CUSTOMER_CANCEL_REASONS = [
  "changed_mind",
  "ordered_by_mistake",
  "delivery_too_slow",
  "wrong_address",
  "other",
] as const;

/** Rider stages after which the goods have left the store. */
const PICKED_UP = ["picked_up", "at_customer", "returning", "delivered"];

/**
 * Null when the customer `uid` may still cancel `order`, else the reason
 * code: only their own order, only while it's "placed" (not packed), no
 * shop has packed its part yet (audit S6: their work isn't wasted; support
 * can still cancel) and no rider has picked anything up. A customer cancel
 * never counts against a seller (no sellerIssues).
 */
export function customerCancelProblem(order: Record<string, unknown>, uid: string): string | null {
  if (order.userId !== uid) return "NOT_YOUR_ORDER";
  if (order.status === "cancelled") return "ALREADY_CANCELLED";
  if (order.status !== "placed") return "TOO_LATE_TO_CANCEL";
  if (PICKED_UP.includes(order.riderStage as string)) return "TOO_LATE_TO_CANCEL";
  const sellers = Object.values((order.sellerStatus ?? {}) as Record<string, string>);
  if (sellers.includes("ready")) return "SHOP_PACKED";
  const stops = Object.values((order.pickups ?? {}) as Record<string, { status?: string }>);
  if (stops.some((s) => s?.status === "ready" || s?.status === "picked")) return "SHOP_PACKED";
  return null;
}

/** The audit / cancelledBy identity for a customer's own cancel. */
export function customerActor(uid: string): Actor {
  return { uid: `customer:${uid}`, role: "ops", email: null };
}

/**
 * Customer → Cancel order. Same effects as an ops cancel (stock back,
 * coupon released, wallet part to the wallet, online part refunded through
 * PayU, seller and rider told), checked in the same transaction.
 * Request: {orderId, reason: one of CUSTOMER_CANCEL_REASONS}.
 * Response: {ok, refund?}.
 */
export const cancelMyOrder = onCall({ secrets: PAYU_SECRETS }, async (request) => {
  const uid = requireUid(request);
  rateLimit("cancelMyOrder", uid);
  const orderId = requireString(request.data?.orderId, "orderId");
  const reason = request.data?.reason;
  if (!(CUSTOMER_CANCEL_REASONS as readonly unknown[]).includes(reason)) {
    throw new HttpsError("invalid-argument", "Pick a reason");
  }
  return updateOrderStatus(
    customerActor(uid),
    { orderId, status: "cancelled", reason: `Customer: ${String(reason).replace(/_/g, " ")}` },
    undefined,
    (order) => {
      const problem = customerCancelProblem(order, uid);
      if (problem === "NOT_YOUR_ORDER") throw new HttpsError("not-found", "Order not found");
      if (problem) throw new HttpsError("failed-precondition", problem);
    },
  );
});
