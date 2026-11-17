import { onDocumentCreated } from "firebase-functions/firestore";
import { db } from "./shared/firebase";
import { addToInbox } from "./notifications/inbox";
import { pushToDevices } from "./notifications/tokens";

const STATUS_COPY: Record<string, { title: string; body: string }> = {
  placed: { title: "Order placed", body: "We've got your order!" },
  packed: { title: "Order packed", body: "Your order is packed and ready." },
  out_for_delivery: { title: "Out for delivery", body: "Your order is on its way." },
  delivered: { title: "Delivered", body: "Your order has been delivered." },
  cancelled: { title: "Order cancelled", body: "Your order was cancelled." },
};

/**
 * One push to an order's customer (rider app: "rider outside"), on every
 * device they're signed in on, plus an entry in their notification list.
 * Respects the customer's order-update preference; forgets dead tokens.
 */
export async function pushOrderCustomer(
  orderId: string,
  copy: { title: string; body: string },
  data: Record<string, string> = {},
): Promise<void> {
  const order = await db.collection("orders").doc(orderId).get();
  const userId = order.get("userId") as string | null | undefined;
  if (!userId) return;
  const profile = await db.collection("users").doc(userId).get();
  await addToInbox(userId, { kind: "order", ...copy, data: { orderId, ...data } });
  if (profile.get("notifyOrderUpdates") === false) return;
  await pushToDevices(profile.ref, profile.data(), {
    notification: copy,
    data: { orderId, ...data },
    android: { priority: "high" },
  });
}

/**
 * Sends an FCM push for every new order event. Events are only written by
 * placeOrder / placePaidOrder / adminUpdateOrderStatus, so nobody can
 * trigger a push for someone else's order. Deep links via `orderId`. The
 * entry id is fixed per order and status, so a retried trigger doesn't
 * list it twice.
 */
export const onOrderEventCreated = onDocumentCreated("orders/{orderId}/events/{eventId}", async (event) => {
  const status = event.data?.get("status") as string | undefined;
  const orderId = event.params.orderId;
  if (!status) return;

  const order = await db.collection("orders").doc(orderId).get();
  const userId = order.get("userId") as string | null | undefined;
  if (!userId) return;

  const copy = STATUS_COPY[status] ?? {
    title: "Order update",
    body: `Your order is now ${status}.`,
  };
  await addToInbox(userId, { kind: "order", ...copy, data: { orderId, status } }, `o_${orderId}_${status}`);

  const profile = await db.collection("users").doc(userId).get();
  // Account → Notification preferences.
  if (profile.get("notifyOrderUpdates") === false) return;
  await pushToDevices(profile.ref, profile.data(), {
    notification: copy,
    data: { orderId, status },
    android: { priority: "high" },
  });
});
