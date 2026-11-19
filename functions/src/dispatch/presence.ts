import { type DocumentSnapshot, FieldValue, Timestamp } from "firebase-admin/firestore";
import { withToken } from "../notifications/tokens";
import { requireRider } from "./rider_auth";
import { slotPresence } from "./gigs";
import { HttpsError, onCall } from "firebase-functions/https";
import { requireUid } from "../shared/callable";
import { db } from "../shared/firebase";
import { RIDERS } from "../riders/model";
import { dispatchWaiting, respondOffer } from "./dispatch";
import { respondReturnOffer } from "../returns/dispatch";
import { istDayAndWeek } from "./earnings";
import { distanceM, etaMinutes, impossibleJump, isPoint, requirePoint } from "./model";
import { HOT } from "../shared/scaling";

const ms = (v: unknown) => (v instanceof Timestamp ? v.toMillis() : null);

/** Adds the session's minutes to the rider's day (Home "login hours"). */
function addOnlineMinutes(rider: DocumentSnapshot, batch: FirebaseFirestore.WriteBatch, nowMs: number) {
  const since = ms(rider.get("presence.onlineSince"));
  if (!since || nowMs <= since) return;
  const minutes = Math.min(24 * 60, Math.round((nowMs - since) / 60_000));
  const { day } = istDayAndWeek(new Date(nowMs));
  batch.set(rider.ref.collection("days").doc(day), { day, onlineMinutes: FieldValue.increment(minutes) }, { merge: true });
}

/** Request: {online, lat?, lng?, accuracy?}. Going online needs a position. */
export const riderSetOnline = onCall(async (request) => {
  const rider = await requireRider(request);
  const online = request.data?.online === true;
  const now = Date.now();
  const batch = db.batch();
  if (online) {
    const p = requirePoint(request.data);
    if (request.data?.mocked === true) throw new HttpsError("failed-precondition", "MOCK_LOCATION");
    const wasOnline = rider.get("presence.online") === true;
    batch.update(rider.ref, {
      "presence.online": true,
      "presence.lat": p.lat,
      "presence.lng": p.lng,
      "presence.accuracy": p.accuracy,
      "presence.at": FieldValue.serverTimestamp(),
      "presence.onBreakUntil": null,
      "presence.offlineReason": null,
      ...(wasOnline ? {} : { "presence.onlineSince": FieldValue.serverTimestamp() }),
      ...(rider.get("presence.activeOrderId") ? {} : { "presence.idleSince": FieldValue.serverTimestamp() }),
      ...(await slotPresence(rider)),
    });
    await batch.commit();
    await dispatchWaiting((rider.get("serviceAreaId") as string) ?? "");
    return { online: true };
  }
  if (rider.get("presence.activeOrderId") || rider.get("presence.activeReturnId")) {
    throw new HttpsError("failed-precondition", "FINISH_DELIVERY_FIRST");
  }
  addOnlineMinutes(rider, batch, now);
  batch.update(rider.ref, {
    "presence.online": false,
    "presence.onlineSince": null,
    "presence.offlineReason": "rider",
  });
  await batch.commit();
  const offer = rider.get("presence.offerOrderId") as string | null | undefined;
  if (offer) await respondOffer(rider.id, offer, false);
  const returnOffer = rider.get("presence.offerReturnId") as string | null | undefined;
  if (returnOffer) await respondReturnOffer(rider.id, returnOffer, false);
  return { online: false };
});

/** Seconds between pings the server accepts (the app sends ~20–60 s). */
const MIN_PING_GAP_MS = 8_000;

/**
 * Request: {lat, lng, accuracy?}. Updates the rider's position; on a
 * delivery also the customer's live distance / ETA.
 * Response: {online, activeOrderId, offerOrderId, activeReturnId, offerReturnId}.
 */
export const riderPing = onCall(HOT, async (request) => {
  const rider = await requireRider(request);
  const p = requirePoint(request.data);
  const presence = (rider.get("presence") ?? {}) as Record<string, unknown>;
  const state = {
    online: presence.online === true,
    activeOrderId: (presence.activeOrderId as string | null | undefined) ?? null,
    offerOrderId: (presence.offerOrderId as string | null | undefined) ?? null,
    // Return pickups (returns/dispatch.ts).
    activeReturnId: (presence.activeReturnId as string | null | undefined) ?? null,
    offerReturnId: (presence.offerReturnId as string | null | undefined) ?? null,
  };
  if (!state.online) return state;
  const now = Date.now();
  const lastMs = ms(presence.at);
  if (lastMs && now - lastMs < MIN_PING_GAP_MS) return state;
  const prev = isPoint({ lat: presence.lat, lng: presence.lng })
    ? { lat: presence.lat as number, lng: presence.lng as number }
    : null;
  if (request.data?.mocked === true || impossibleJump(prev, p, lastMs ? (now - lastMs) / 1000 : 0)) {
    await rider.ref.update({ "presence.at": FieldValue.serverTimestamp(), "presence.jumps": FieldValue.increment(1) });
    return state;
  }
  const slotCheckedMs = ms(presence.slotCheckedAt) ?? 0;
  const slotEndsMs = ms(presence.slotEndsAt);
  const recheckSlot = now - slotCheckedMs > 5 * 60_000 || (slotEndsMs != null && slotEndsMs <= now);
  await rider.ref.update({
    "presence.lat": p.lat,
    "presence.lng": p.lng,
    "presence.accuracy": p.accuracy,
    "presence.at": FieldValue.serverTimestamp(),
    ...(recheckSlot ? await slotPresence(rider, now) : {}),
  });
  if (state.activeOrderId) {
    const order = await db.collection("orders").doc(state.activeOrderId).get();
    const a = (order.get("address") ?? {}) as Record<string, unknown>;
    const to = { lat: a.lat, lng: a.lng };
    if (order.get("status") === "out_for_delivery" && isPoint(to)) {
      const d = distanceM(p, to);
      await order.ref.collection("tracking").doc("live").set({
        lat: p.lat,
        lng: p.lng,
        distanceM: d,
        etaMinutes: etaMinutes(d),
        at: FieldValue.serverTimestamp(),
        // The rider's position: deleted by the TTL policy a day after the
        // last ping (firestore.indexes.json fieldOverrides).
        expireAt: Timestamp.fromMillis(Date.now() + TRACKING_TTL_MS),
      });
    }
  }
  return state;
});

/** How long the live position stays after the last ping. */
export const TRACKING_TTL_MS = 24 * 60 * 60 * 1000;

/** Request: {minutes: 0 | 15 | 30}. Pauses new offers; 0 ends the break. */
export const riderBreak = onCall(async (request) => {
  const rider = await requireRider(request);
  const minutes = request.data?.minutes;
  if (![0, 15, 30].includes(minutes)) throw new HttpsError("invalid-argument", "Invalid break");
  const until = minutes ? Timestamp.fromMillis(Date.now() + minutes * 60_000) : null;
  await rider.ref.update({ "presence.onBreakUntil": until });
  const offer = rider.get("presence.offerOrderId") as string | null | undefined;
  if (minutes && offer) await respondOffer(rider.id, offer, false);
  const returnOffer = rider.get("presence.offerReturnId") as string | null | undefined;
  if (minutes && returnOffer) await respondReturnOffer(rider.id, returnOffer, false);
  if (!minutes) await dispatchWaiting((rider.get("serviceAreaId") as string) ?? "");
  return { onBreakUntil: until?.toMillis() ?? null };
});

/** Request: {token, appVersion}. Where to ring new-order offers. */
export const riderRegisterDevice = onCall(async (request) => {
  const uid = requireUid(request);
  const token = typeof request.data?.token === "string" ? request.data.token.slice(0, 4096) : "";
  const appVersion = typeof request.data?.appVersion === "string" ? request.data.appVersion.slice(0, 20) : null;
  if (!token) throw new HttpsError("invalid-argument", "Invalid token");
  const ref = db.collection(RIDERS).doc(uid);
  const rider = await ref.get();
  if (!rider.exists) throw new HttpsError("permission-denied", "NOT_A_RIDER");
  // Every phone the rider is signed in on rings (newest last, at most 5).
  await ref.update({ fcmToken: token, pushTokens: withToken(rider.get("pushTokens"), token), appVersion });
  return { ok: true };
});

/** Request: {orderId, accept}. */
export const riderRespondOffer = onCall(HOT, async (request) => {
  const rider = await requireRider(request);
  return respondOffer(rider.id, request.data?.orderId, request.data?.accept);
});

