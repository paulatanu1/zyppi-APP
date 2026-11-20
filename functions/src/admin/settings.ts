import { randomUUID } from "node:crypto";
import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import { DELIVERY_CONFIG_PATH } from "../orders/delivery_config";
import {
  APP_CONFIG_DOC,
  optionalId,
  validateAppConfig,
  validateDeliveryConfig,
  validateServiceArea,
  validateSlot,
  validateStore,
} from "./settings_model";

/**
 * Creates or replaces one settings doc with its audit row, in one
 * transaction. `fields` is already validated.
 */
async function saveDoc(
  actor: Actor,
  action: string,
  path: string,
  fields: Record<string, unknown>,
  check?: (tx: FirebaseFirestore.Transaction) => Promise<void>,
): Promise<{ id: string }> {
  const ref = db.doc(path);
  await db.runTransaction(async (tx) => {
    await check?.(tx);
    const before = await tx.get(ref);
    tx.set(ref, { ...fields, updatedAt: FieldValue.serverTimestamp(), updatedBy: actor.uid }, { merge: true });
    writeAudit(
      actor,
      { action, target: path, before: before.exists ? before.data() : null, after: fields },
      tx,
    );
  });
  return { id: ref.id };
}

/** Request: {id?, name, centerLat, centerLng, radiusMeters, isActive}. */
export const adminSaveServiceArea = onCall(async (request) => {
  const actor = requireRole(request, ["ops"]);
  const input = validateServiceArea(request.data);
  const id = optionalId(request.data?.id) ?? randomUUID();
  return saveDoc(actor, "serviceArea.save", `serviceAreas/${id}`, { ...input });
});

/** Request: {id?, name, serviceAreaId, address?, phone?, hours?: {open, close} | null, isActive}. */
export const adminSaveStore = onCall(async (request) => {
  const actor = requireRole(request, ["ops"]);
  const input = validateStore(request.data);
  const id = optionalId(request.data?.id) ?? randomUUID();
  return saveDoc(actor, "store.save", `stores/${id}`, { ...input }, async (tx) => {
    const area = await tx.get(db.collection("serviceAreas").doc(input.serviceAreaId));
    if (!area.exists) throw new HttpsError("invalid-argument", "That service area doesn’t exist");
  });
});

/** Request: {id?, label, etaMinutes, isExpress, isActive, sortOrder?}. */
export const adminSaveDeliverySlot = onCall(async (request) => {
  const actor = requireRole(request, ["ops"]);
  const input = validateSlot(request.data);
  const id = optionalId(request.data?.id) ?? randomUUID();
  return saveDoc(actor, "deliverySlot.save", `deliverySlots/${id}`, { ...input });
});

/** Request: {feePaise, freeAbovePaise, minOrderPaise, handlingFeePaise?} (int paise). */
export const adminSaveDeliveryConfig = onCall(async (request) => {
  const actor = requireRole(request, ["ops", "finance"]);
  return saveDoc(actor, "delivery.update", DELIVERY_CONFIG_PATH, { ...validateDeliveryConfig(request.data) });
});

/** Request: {supportPhone?, whatsappNumber?, supportEmail?, announcement: {enabled, text, tone}}. */
export const adminSaveAppConfig = onCall(async (request) => {
  const actor = requireRole(request, ["ops"]);
  return saveDoc(actor, "appConfig.update", APP_CONFIG_DOC, { ...validateAppConfig(request.data) });
});
