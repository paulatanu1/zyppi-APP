import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { requireRole } from "../shared/roles";
import { CLAIMS_CONFIG_DOC, claimsConfigFrom } from "./model";

/**
 * Settings → Claims & returns (ops, finance): when a claim skips ops and
 * goes straight to a return pickup. Request: {autoReturns, autoMaxPaise,
 * autoMaxClaims30d}. Values out of range are refused, not clamped.
 */
export const adminSaveClaimsConfig = onCall(async (request) => {
  const actor = requireRole(request, ["ops", "finance"]);
  const d = (request.data ?? {}) as Record<string, unknown>;
  if (typeof d.autoReturns !== "boolean") throw new HttpsError("invalid-argument", "Choose on or off");
  const max = Number(d.autoMaxPaise);
  if (!Number.isInteger(max) || max < 0 || max > 10_000_000) {
    throw new HttpsError("invalid-argument", "Enter a limit between ₹0 and ₹1,00,000");
  }
  const claims = Number(d.autoMaxClaims30d);
  if (!Number.isInteger(claims) || claims < 1 || claims > 100) {
    throw new HttpsError("invalid-argument", "Enter between 1 and 100 claims");
  }
  const ref = db.doc(CLAIMS_CONFIG_DOC);
  await db.runTransaction(async (tx) => {
    const before = claimsConfigFrom((await tx.get(ref)).data());
    const after = { autoReturns: d.autoReturns as boolean, autoMaxPaise: max, autoMaxClaims30d: claims };
    tx.set(ref, after, { merge: true });
    writeAudit(actor, { action: "config.claims", target: CLAIMS_CONFIG_DOC, before, after }, tx);
  });
  return { ok: true };
});
