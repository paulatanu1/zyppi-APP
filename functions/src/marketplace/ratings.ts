import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { requireUid } from "../shared/callable";
import { db } from "../shared/firebase";
import { SELLERS, SELLER_USERS, ZYPPI_SELLER_ID } from "./model";
import { rateLimit } from "../shared/rate_limit";

/** New average after adding `stars` (1 decimal is shown; 3 kept). */
export function nextRating(sum: number, count: number, stars: number): { sum: number; count: number; avg: number } {
  const s = sum + stars;
  const c = count + 1;
  return { sum: s, count: c, avg: Math.round((s / c) * 1000) / 1000 };
}

/**
 * Request: {orderId, ratings: {sellerId: 1–5}}. The customer rates each
 * marketplace seller of a delivered order, once per seller. A seller's own
 * login can't rate their shop. Ratings feed the offer ranking.
 */
export const rateSellers = onCall(async (request) => {
  const uid = requireUid(request);
  rateLimit("rateSellers", uid);
  const orderId = typeof request.data?.orderId === "string" ? request.data.orderId : "";
  const raw = (request.data?.ratings ?? {}) as Record<string, unknown>;
  const ratings = Object.entries(raw).filter(
    ([id, stars]) => /^[\w-]{1,128}$/.test(id) && id !== ZYPPI_SELLER_ID && Number.isInteger(stars) && (stars as number) >= 1 && (stars as number) <= 5,
  ) as [string, number][];
  if (!/^[\w-]{1,64}$/.test(orderId) || !ratings.length || ratings.length > 10) {
    throw new HttpsError("invalid-argument", "Invalid rating");
  }
  const orderRef = db.collection("orders").doc(orderId);
  await db.runTransaction(async (tx) => {
    const [order, member] = [await tx.get(orderRef), await tx.get(db.collection(SELLER_USERS).doc(uid))];
    if (!order.exists || order.get("userId") !== uid) throw new HttpsError("not-found", "Order not found");
    if (order.get("status") !== "delivered") throw new HttpsError("failed-precondition", "Not delivered yet");
    const sellerIds = (order.get("sellerIds") as string[] | undefined) ?? [];
    const done = (order.get("sellerRatings") ?? {}) as Record<string, unknown>;
    const todo = ratings.filter(([id]) => sellerIds.includes(id) && !done[id] && member.get("sellerId") !== id);
    if (!todo.length) throw new HttpsError("already-exists", "Already rated");
    const sellers = await Promise.all(todo.map(([id]) => tx.get(db.collection(SELLERS).doc(id))));
    todo.forEach(([id, stars], i) => {
      const r = (sellers[i].get("rating") ?? {}) as { sum?: number; count?: number };
      const next = nextRating(r.sum ?? 0, r.count ?? 0, stars);
      tx.set(db.collection(SELLERS).doc(id), { rating: next }, { merge: true });
    });
    tx.update(orderRef, Object.fromEntries(todo.map(([id, stars]) => [`sellerRatings.${id}`, { stars, at: FieldValue.serverTimestamp() }])));
  });
  return { ok: true };
});
