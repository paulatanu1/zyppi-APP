import { FieldValue } from "firebase-admin/firestore";
import { onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import {
  FEATURES_DOC,
  type Features,
  applyFeaturesPatch,
  clearFeaturesCache,
  parseFeatures,
} from "../shared/features";
import { type Actor, requireRole } from "../shared/roles";

/**
 * Applies a validated partial update to config/features and logs it, in
 * one transaction. Exported for the emulator tests.
 */
export async function updateFeatures(actor: Actor, patch: unknown): Promise<Features> {
  const ref = db.doc(FEATURES_DOC);
  const next = await db.runTransaction(async (tx) => {
    const before = parseFeatures((await tx.get(ref)).data());
    const after = applyFeaturesPatch(before, patch);
    tx.set(ref, { ...after, updatedAt: FieldValue.serverTimestamp(), updatedBy: actor.uid });
    writeAudit(actor, { action: "features.update", target: FEATURES_DOC, before, after }, tx);
    return after;
  });
  clearFeaturesCache();
  return next;
}

/**
 * Settings → Services (super_admin only).
 * Request: {patch: Partial<Features>} — e.g. {placesSearch: false}.
 * Response: the full Features after the change.
 */
export const adminUpdateFeatures = onCall(async (request) => {
  const actor = requireRole(request, []);
  return updateFeatures(actor, request.data?.patch);
});
