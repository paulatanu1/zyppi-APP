import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { requireString, requireUid } from "../shared/callable";
import { db } from "../shared/firebase";
import { requireRole } from "../shared/roles";
import { RIDERS } from "../riders/model";
import { SOS_ALERTS, isPoint } from "./model";

export const SOS_KINDS = ["ambulance", "accident", "police"] as const;

/**
 * Request: {kind, lat?, lng?}. Sent when a rider taps an Emergency button
 * (the phone call itself is made by the app): ops sees a live alarm with
 * the rider, their position and active order. Any rider (even pending)
 * can raise one; one open alert per rider is updated rather than repeated.
 */
export const riderSos = onCall(async (request) => {
  const uid = requireUid(request, "partner");
  const kind = request.data?.kind;
  if (!(SOS_KINDS as readonly string[]).includes(kind)) throw new HttpsError("invalid-argument", "Invalid kind");
  const rider = await db.collection(RIDERS).doc(uid).get();
  if (!rider.exists) throw new HttpsError("permission-denied", "NOT_A_RIDER");
  const p = { lat: request.data?.lat, lng: request.data?.lng };
  const position = isPoint(p) ? { lat: p.lat as number, lng: p.lng as number } : null;
  const ref = db.collection(SOS_ALERTS).doc(`${uid}_open`);
  await ref.set(
    {
      riderId: uid,
      riderName: rider.get("fullName") ?? null,
      riderPhone: rider.get("phone") ?? null,
      serviceAreaId: rider.get("serviceAreaId") ?? null,
      kinds: FieldValue.arrayUnion(kind),
      lastKind: kind,
      position: position ?? rider.get("presence") ?? null,
      orderId: rider.get("presence.activeOrderId") ?? null,
      status: "open",
      at: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  return { ok: true };
});

/** Request: {id, note}. Ops closes an alert (kept as history). */
export const adminResolveSos = onCall(async (request) => {
  const actor = requireRole(request, ["ops", "support"]);
  const id = requireString(request.data?.id, "id");
  const note = typeof request.data?.note === "string" ? request.data.note.trim().slice(0, 300) : "";
  const ref = db.collection(SOS_ALERTS).doc(id);
  const snap = await ref.get();
  if (!snap.exists || snap.get("status") !== "open") throw new HttpsError("not-found", "Alert not found");
  // Archive under its own id so the rider's next alert starts fresh.
  const archive = db.collection(SOS_ALERTS).doc();
  const batch = db.batch();
  batch.set(archive, {
    ...snap.data(),
    status: "resolved",
    resolvedBy: actor.uid,
    resolvedNote: note || null,
    resolvedAt: FieldValue.serverTimestamp(),
  });
  batch.delete(ref);
  await batch.commit();
  await writeAudit(actor, { action: "sos.resolve", target: `${SOS_ALERTS}/${archive.id}`, after: { note } });
  return { ok: true };
});
