import { onDocumentCreated } from "firebase-functions/firestore";
import { logger } from "firebase-functions";
import { db, messaging } from "./shared/firebase";

const STATUS_COPY: Record<string, { title: string; body: string }> = {
  placed: { title: "Order placed", body: "We've got your order!" },
  packed: { title: "Order packed", body: "Your order is packed and ready." },
  out_for_delivery: { title: "Out for delivery", body: "Your order is on its way." },
  delivered: { title: "Delivered", body: "Your order has been delivered." },
  cancelled: { title: "Order cancelled", body: "Your order was cancelled." },
};

/**
 * Sends an FCM push for every new order event. Events are only written by
 * placeOrder / placePaidOrder / adminUpdateOrderStatus, so nobody can
 * trigger a push for someone else's order. Deep links via `orderId`.
 */
export const onOrderEventCreated = onDocumentCreated(
  "orders/{orderId}/events/{eventId}",
  async (event) => {
    const status = event.data?.get("status") as string | undefined;
    const orderId = event.params.orderId;
    if (!status) return;

    const order = await db.collection("orders").doc(orderId).get();
    const userId = order.get("userId") as string | null | undefined;
    if (!userId) return;

    const profile = await db.collection("users").doc(userId).get();
    const token = profile.get("fcmToken") as string | null | undefined;
    if (!token) return;
    // Account → Notification preferences.
    if (profile.get("notifyOrderUpdates") === false) return;

    const copy = STATUS_COPY[status] ?? {
      title: "Order update",
      body: `Your order is now ${status}.`,
    };

    try {
      await messaging.send({
        token,
        notification: copy,
        data: { orderId, status },
        android: { priority: "high" },
      });
    } catch (error) {
      const code = (error as { code?: string }).code;
      // Uninstalled app / rotated token: forget it.
      if (code === "messaging/registration-token-not-registered") {
        await profile.ref.update({ fcmToken: null });
        return;
      }
      logger.error("Push failed", { orderId, status, error });
    }
  },
);
