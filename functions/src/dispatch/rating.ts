import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { requireUid } from "../shared/callable";
import { db } from "../shared/firebase";
import { RIDERS } from "../riders/model";
import { rateLimit } from "../shared/rate_limit";

export const RATING_TAGS = ["polite", "on_time", "careful", "late", "rude", "damaged"] as const;

/**
 * Request: {orderId, stars 1–5, tags?}. The customer rates the rider of a
 * delivered order, once. Updates the rider's average (rating.sum / count).
 */
export const rateRider = onCall(async (request) => {
  const uid = requireUid(request);
  rateLimit("rateRider", uid);
  const orderId = typeof request.data?.orderId === "string" ? request.data.orderId : "";
  const stars = request.data?.stars;
  if (!/^[\w-]{1,64}$/.test(orderId) || !Number.isInteger(stars) || stars < 1 || stars > 5) {
    throw new HttpsError("invalid-argument", "Invalid rating");
  }
  const tags = Array.isArray(request.data?.tags)
    ? [...new Set(request.data.tags.filter((t: unknown) => (RATING_TAGS as readonly unknown[]).includes(t)))]
    : [];
  const orderRef = db.collection("orders").doc(orderId);
  await db.runTransaction(async (tx) => {
    const order = await tx.get(orderRef);
    if (!order.exists || order.get("userId") !== uid) throw new HttpsError("not-found", "Order not found");
    if (order.get("status") !== "delivered") throw new HttpsError("failed-precondition", "Not delivered yet");
    if (order.get("riderRating")) throw new HttpsError("already-exists", "Already rated");
    const riderId = order.get("riderId") as string | undefined;
    if (!riderId) throw new HttpsError("failed-precondition", "No rider on this order");
    tx.update(orderRef, { riderRating: { stars, tags, at: FieldValue.serverTimestamp() } });
    tx.set(
      db.collection(RIDERS).doc(riderId),
      { rating: { sum: FieldValue.increment(stars), count: FieldValue.increment(1) } },
      { merge: true },
    );
  });
  return { ok: true };
});
