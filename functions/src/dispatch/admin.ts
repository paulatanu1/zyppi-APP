import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { requireRole } from "../shared/roles";
import { RIDER_CONFIG_DOC, parseRiderConfig } from "./model";

/**
 * Request: a full RiderConfig (admin → Rider settings). Values are
 * clamped to safe ranges by parseRiderConfig; what's saved is returned.
 */
export const adminSaveRiderConfig = onCall(async (request) => {
  const actor = requireRole(request, ["ops"]);
  if (!request.data || typeof request.data !== "object") {
    throw new HttpsError("invalid-argument", "Invalid settings");
  }
  const ref = db.doc(RIDER_CONFIG_DOC);
  const after = parseRiderConfig(request.data as Record<string, unknown>);
  await db.runTransaction(async (tx) => {
    const before = await tx.get(ref);
    tx.set(ref, { ...after, updatedAt: FieldValue.serverTimestamp(), updatedBy: actor.uid });
    writeAudit(actor, { action: "riders.config", target: RIDER_CONFIG_DOC, before: before.data() ?? null, after }, tx);
  });
  return after;
});
