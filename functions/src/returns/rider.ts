import { type DocumentSnapshot, FieldValue, type Transaction } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { HttpsError, onCall } from "firebase-functions/https";
import { MAX_CODE_ATTEMPTS, RIDER_CONFIG_DOC, distanceM, isPoint, parseRiderConfig, type Point } from "../dispatch/model";
import { STORE_GEOFENCE_M } from "../dispatch/pickups";
import { requireRider } from "../dispatch/rider_auth";
import { notifySeller } from "../marketplace/seller_notify";
import { db } from "../shared/firebase";
import { decodeClaimPhoto } from "../wallet/model";
import { customerPoint, earningRef, payReturnRider, releaseReturnRider, respondReturnOffer, returnIdOf, storePoint } from "./dispatch";
import { CUSTOMER_GEOFENCE_M, DONE_STATUSES, MAX_PICKUP_TRIES, MAX_RETURN_PHOTOS, RETURNS, type ReturnStatus } from "./model";
import { tellCustomer } from "./notify";
import { closeIssueIfDone, sendToReview } from "./settle";

/**
 * The rider's steps on a return pickup (rider app → "Return pickup"):
 * accept → at the customer (within 200 m) → collected (the customer's
 * 4-digit code + 1–3 photos of the items) → at the store (within 150 m)
 * → the store enters the rider's code (store.ts). At the door the rider
 * can also report that the item doesn't match (→ ops) or that nobody is
 * there (twice → cancelled).
 */

interface Ctx {
  ref: FirebaseFirestore.DocumentReference;
  data: Record<string, unknown>;
  rider: DocumentSnapshot;
}

async function onMyReturn<T>(riderId: string, raw: unknown, step: (tx: Transaction, c: Ctx) => Promise<T>): Promise<T> {
  const ref = db.collection(RETURNS).doc(returnIdOf(raw));
  return db.runTransaction(async (tx) => {
    const [snap, rider] = await Promise.all([tx.get(ref), tx.get(db.collection("riders").doc(riderId))]);
    if (!snap.exists || snap.get("riderId") !== riderId) throw new HttpsError("permission-denied", "NOT_YOUR_RETURN");
    if (DONE_STATUSES.includes(snap.get("status") as ReturnStatus)) throw new HttpsError("failed-precondition", "RETURN_CLOSED");
    return step(tx, { ref, data: snap.data()!, rider });
  });
}

function needStatus(data: Record<string, unknown>, allowed: ReturnStatus[]): void {
  if (!allowed.includes(data.status as ReturnStatus)) throw new HttpsError("failed-precondition", "WRONG_STEP");
}

/** The rider's position from their last accepted ping (riderPing refuses mocked GPS). */
function freshPosition(rider: DocumentSnapshot): Point | null {
  const p = (rider.get("presence") ?? {}) as Record<string, unknown>;
  const at = p.at as { toMillis?: () => number } | undefined;
  const fresh = typeof at?.toMillis === "function" && Date.now() - at.toMillis() <= 3 * 60_000;
  return fresh && isPoint({ lat: p.lat, lng: p.lng }) ? { lat: p.lat as number, lng: p.lng as number } : null;
}

function mustBeNear(rider: DocumentSnapshot, place: Point | null, metres: number): void {
  if (!place) return; // no pin to check against (older data): don't block the rider
  const here = freshPosition(rider);
  if (!here) throw new HttpsError("failed-precondition", "NO_LOCATION");
  if (distanceM(here, place) > metres) throw new HttpsError("failed-precondition", "TOO_FAR");
}

/** Saves the rider's photos (base64; real JPEG / PNG / WebP only). */
async function savePhotos(returnId: string, prefix: string, raw: unknown, required: boolean): Promise<string[]> {
  const list = Array.isArray(raw) ? raw : [];
  if (list.length > MAX_RETURN_PHOTOS) throw new HttpsError("invalid-argument", "TOO_MANY_PHOTOS");
  if (required && list.length === 0) throw new HttpsError("failed-precondition", "PHOTO_REQUIRED");
  const photos = list.map(decodeClaimPhoto);
  if (photos.some((p) => p === null)) throw new HttpsError("invalid-argument", "INVALID_PHOTO");
  const bucket = getStorage().bucket();
  const stamp = Date.now();
  const paths = photos.map((p, i) => `${RETURNS}/${returnId}/${prefix}_${stamp}_${i}.${p!.ext}`);
  await Promise.all(
    photos.map((p, i) => bucket.file(paths[i]).save(p!.bytes, { contentType: p!.contentType, resumable: false })),
  );
  return paths;
}

/** Request: {returnId, accept}. */
export const riderRespondReturnOffer = onCall(async (request) => {
  const rider = await requireRider(request);
  return respondReturnOffer(rider.id, request.data?.returnId, request.data?.accept);
});

/** Request: {returnId}. At the customer's door (within 200 m). */
export const riderReturnReachedCustomer = onCall(async (request) => {
  const rider = await requireRider(request);
  const r = await onMyReturn(rider.id, request.data?.returnId, async (tx, { ref, data, rider: me }) => {
    needStatus(data, ["assigned", "at_customer"]);
    mustBeNear(me, customerPoint(data), CUSTOMER_GEOFENCE_M);
    if (data.status === "at_customer") return null;
    tx.update(ref, { status: "at_customer", reachedCustomerAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    return data;
  });
  if (r) await tellCustomer({ ...r, id: r.issueId as string }, "riderAtDoor");
  return { ok: true };
});

/**
 * Request: {returnId, code, photos: [base64]}. The customer tells the rider
 * their pickup code; the rider photographs what they collect. Five wrong
 * codes lock it (ops can still sort it out).
 */
export const riderReturnPickedUp = onCall(async (request) => {
  const rider = await requireRider(request);
  const returnId = returnIdOf(request.data?.returnId);
  const code = typeof request.data?.code === "string" ? request.data.code.trim() : "";
  if (!/^\d{4}$/.test(code)) throw new HttpsError("invalid-argument", "WRONG_CODE");
  const photos = await savePhotos(returnId, "pickup", request.data?.photos, true);
  const out = await onMyReturn(rider.id, returnId, async (tx, { ref, data }) => {
    needStatus(data, ["at_customer"]);
    const codeRef = ref.collection("private").doc("pickup");
    const c = await tx.get(codeRef);
    const attempts = (c.get("attempts") as number | undefined) ?? 0;
    if (attempts >= MAX_CODE_ATTEMPTS) throw new HttpsError("failed-precondition", "CODE_LOCKED");
    if (c.get("code") !== code) {
      tx.set(codeRef, { attempts: FieldValue.increment(1) }, { merge: true });
      return { wrong: true, left: MAX_CODE_ATTEMPTS - attempts - 1, data };
    }
    tx.update(ref, {
      status: "picked_up",
      pickedUpAt: FieldValue.serverTimestamp(),
      pickupPhotos: photos,
      updatedAt: FieldValue.serverTimestamp(),
    });
    return { wrong: false, left: MAX_CODE_ATTEMPTS, data };
  });
  if (out.wrong) {
    await Promise.all(photos.map((p) => getStorage().bucket().file(p).delete().catch(() => undefined)));
    throw new HttpsError("invalid-argument", out.left > 0 ? "WRONG_CODE" : "CODE_LOCKED", { left: out.left });
  }
  await Promise.all([
    tellCustomer({ ...out.data, id: out.data.issueId as string }, "pickedUp"),
    notifySeller(out.data.sellerId as string, out.data.orderId as string, "return_picked", { returnId }),
  ]);
  return { ok: true };
});

/**
 * Request: {returnId, note, photos?}. The item at the door isn't what was
 * reported (wrong product, sealed, nothing to collect): the rider doesn't
 * take it, and ops decides. The rider is still paid for the trip.
 */
export const riderReturnMismatch = onCall(async (request) => {
  const rider = await requireRider(request);
  const returnId = returnIdOf(request.data?.returnId);
  const note = typeof request.data?.note === "string" ? request.data.note.trim().slice(0, 300) : "";
  if (note.length < 3) throw new HttpsError("invalid-argument", "Say what doesn't match");
  const photos = await savePhotos(returnId, "mismatch", request.data?.photos, false);
  const data = await onMyReturn(rider.id, returnId, async (tx, { ref, data, rider: me }) => {
    needStatus(data, ["at_customer"]);
    const [config, earned] = [await tx.get(db.doc(RIDER_CONFIG_DOC)), await tx.get(earningRef(me.id, returnId))];
    payReturnRider(tx, me, returnId, data, config.data(), earned);
    releaseReturnRider(tx, me.id);
    tx.update(ref, {
      status: "review",
      mismatch: { note, photos, at: FieldValue.serverTimestamp() },
      updatedAt: FieldValue.serverTimestamp(),
    });
    return data;
  });
  await sendToReview(data.issueId as string, `Rider: item doesn't match: ${note}`);
  await tellCustomer({ ...data, id: data.issueId as string }, "review");
  return { ok: true };
});

/**
 * Request: {returnId}. Nobody at the door. The first time the customer is
 * told and the rider waits (config/riders.waitMinutes); the second time the
 * return is cancelled. The rider is paid for the trip.
 */
export const riderReturnNotHome = onCall(async (request) => {
  const rider = await requireRider(request);
  const returnId = returnIdOf(request.data?.returnId);
  const out = await onMyReturn(rider.id, returnId, async (tx, { ref, data, rider: me }) => {
    needStatus(data, ["at_customer"]);
    const [configSnap, earned] = [await tx.get(db.doc(RIDER_CONFIG_DOC)), await tx.get(earningRef(me.id, returnId))];
    const waitMs = parseRiderConfig(configSnap.data()).waitMinutes * 60_000;
    const tries = ((data.tries as number | undefined) ?? 0) + 1;
    const last = (data.lastTryAt as { toMillis?: () => number } | undefined)?.toMillis?.() ?? 0;
    if (tries > 1 && Date.now() - last < waitMs) throw new HttpsError("failed-precondition", "WAIT_LONGER");
    if (tries < MAX_PICKUP_TRIES) {
      tx.update(ref, { tries, lastTryAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
      return { data, failed: false };
    }
    payReturnRider(tx, me, returnId, data, configSnap.data(), earned);
    releaseReturnRider(tx, me.id);
    tx.update(ref, { tries, status: "failed", failReason: "customer_not_available", updatedAt: FieldValue.serverTimestamp() });
    return { data, failed: true };
  });
  await tellCustomer({ ...out.data, id: out.data.issueId as string }, out.failed ? "failed" : "notHomeFirst");
  if (out.failed) await closeIssueIfDone(out.data.issueId as string);
  return { failed: out.failed };
});

/** Request: {returnId}. At the store (within 150 m): the store is alerted. */
export const riderReturnReachedStore = onCall(async (request) => {
  const rider = await requireRider(request);
  const returnId = returnIdOf(request.data?.returnId);
  const data = await onMyReturn(rider.id, returnId, async (tx, { ref, data, rider: me }) => {
    needStatus(data, ["picked_up", "at_store"]);
    mustBeNear(me, storePoint(data), STORE_GEOFENCE_M);
    if (data.status === "at_store") return null;
    tx.update(ref, { status: "at_store", reachedStoreAt: FieldValue.serverTimestamp(), updatedAt: FieldValue.serverTimestamp() });
    return data;
  });
  if (data) await notifySeller(data.sellerId as string, data.orderId as string, "return_arrived", { returnId });
  return { ok: true };
});
