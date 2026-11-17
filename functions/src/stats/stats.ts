import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/firestore";
import { db } from "../shared/firebase";
import { EVENTS, type Labels, STATS, type StatsDelta, type Tree, statsDeltas } from "./model";
import { HOT } from "../shared/scaling";

/** Applied-event markers are only needed while a retry could still come. */
const EVENT_MARKER_TTL_MS = 7 * 24 * 3600_000;

/** Nested `FieldValue.increment`s for a set-with-merge. */
export function increments(t: Tree): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const [k, v] of Object.entries(t)) {
    out[k] = typeof v === "number" ? FieldValue.increment(v) : increments(v);
  }
  return out;
}

function docData(d: StatsDelta): Record<string, unknown> {
  const data: Record<string, unknown> = {
    ...increments(d.counts),
    date: d.day,
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (d.areaId) data.areaId = d.areaId;
  if (Object.keys(d.labels).length) data.names = d.labels as Labels;
  return data;
}

/**
 * Keeps `stats/*` in step with every order write (see stats/model.ts).
 * Writes that change nothing counted cost no Firestore writes. Each event
 * is applied once: a marker doc is created in the same transaction.
 */
export const onOrderWritten = onDocumentWritten({ ...HOT, document: "orders/{orderId}" }, async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  const deltas = statsDeltas(before, after);
  if (!deltas.length) return;

  const marker = db.collection(STATS).doc(EVENTS).collection("ids").doc(event.id);
  await db.runTransaction(async (tx) => {
    if ((await tx.get(marker)).exists) return;
    tx.create(marker, {
      orderId: event.params.orderId,
      expireAt: Timestamp.fromMillis(Date.now() + EVENT_MARKER_TTL_MS),
    });
    for (const d of deltas) {
      tx.set(db.doc(`${STATS}/${d.path}`), docData(d), { merge: true });
    }
  });
});
