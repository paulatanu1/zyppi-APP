import { FieldValue } from "firebase-admin/firestore";
import { db, messaging } from "../shared/firebase";
import { SELLERS } from "./model";

/**
 * Pushes to every device of a seller's logins (sellers/{id}/devices, from
 * sellerRegisterDevice) and keeps an inbox row. New orders are data-only,
 * high priority: the seller app rings and shows the order full-screen
 * until accepted (docs/MARKETPLACE.md → Seller app). Best effort: a failed
 * push never fails the order step that triggered it.
 */
export type SellerEvent =
  | "new_order"
  | "escalate"
  | "rider_arrived"
  | "cancelled"
  | "subscription_reminder"
  | "subscription_expired"
  | "licence_expired"
  | "product_approved"
  | "product_rejected";

const TEXT: Record<SellerEvent, { title: string; body: string }> = {
  new_order: { title: "New order", body: "Accept it in the Zyppi Seller app." },
  escalate: { title: "Order waiting", body: "Accept the order now — Zyppi support has been alerted." },
  rider_arrived: { title: "Rider arrived", body: "Hand over after entering the rider's pickup code." },
  cancelled: { title: "Order cancelled", body: "Don't pack this order." },
  subscription_reminder: { title: "Plan renews soon", body: "Your Zyppi plan renews in a few days. Keep the fee ready." },
  subscription_expired: { title: "Products hidden", body: "Your plan fee is unpaid. Pay it to show your products again." },
  licence_expired: { title: "FSSAI licence expired", body: "Your products are paused. Upload your renewed licence." },
  product_approved: { title: "Product approved", body: "Set your price and stock to start selling it." },
  product_rejected: { title: "Product not approved", body: "Open the app to see why and fix it." },
};

export async function notifySeller(sellerId: string, orderId: string, kind: SellerEvent): Promise<void> {
  try {
    const seller = db.collection(SELLERS).doc(sellerId);
    const [devices] = await Promise.all([
      seller.collection("devices").get(),
      seller.collection("inbox").add({ kind, orderId, ...TEXT[kind], read: false, at: FieldValue.serverTimestamp() }),
    ]);
    const targets = devices.docs.flatMap((d) => {
      const token = d.get("token");
      return typeof token === "string" && token ? [{ ref: d.ref, token }] : [];
    });
    if (!targets.length) return;
    const ringing = kind === "new_order" || kind === "escalate";
    const res = await messaging.sendEachForMulticast({
      tokens: targets.map((t) => t.token),
      data: { type: kind, orderId, ...TEXT[kind] },
      android: ringing
        ? { priority: "high", ttl: 10 * 60_000 }
        : { priority: "high", notification: { ...TEXT[kind], channelId: "orders" } },
    });
    // Forget tokens of uninstalled apps.
    await Promise.all(
      res.responses.map((r, i) =>
        r.error?.code?.includes("registration-token") ? targets[i].ref.delete() : Promise.resolve(),
      ),
    );
  } catch (e) {
    console.warn("notifySeller failed", sellerId, orderId, kind, e);
  }
}
