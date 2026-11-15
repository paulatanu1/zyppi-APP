import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { requireUid } from "../shared/callable";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import {
  COUPONS,
  COUPON_MESSAGES,
  type CouponProblem,
  normalizeCode,
  validateCouponInput,
} from "./model";
import { lookupCoupon, problemOf } from "./usage";

/**
 * Customer pre-check from the cart (the bill shows the discount before
 * checkout). placeOrder checks again; this is only so the cart can say why
 * a code doesn't work.
 *
 * Request: {code, serviceAreaId?}
 * Response: the terms the app's bill needs; or failed-precondition with
 * one of COUPON_MESSAGES and `details.reason`.
 */
export const checkCoupon = onCall(async (request) => {
  const uid = requireUid(request);
  const code = normalizeCode(request.data?.code);
  const area =
    typeof request.data?.serviceAreaId === "string" && request.data.serviceAreaId
      ? (request.data.serviceAreaId as string)
      : null;
  const fail = (reason: CouponProblem) => {
    throw new HttpsError("failed-precondition", COUPON_MESSAGES[reason], { reason });
  };
  if (!code) return fail("invalid");
  const lookup = await db.runTransaction((tx) => lookupCoupon(tx, code, uid), { readOnly: true });
  const problem = problemOf(lookup, area);
  if (problem) return fail(problem);
  const t = lookup.terms!;
  return {
    code: t.code,
    description: t.description,
    type: t.type,
    discountPaise: t.discountPaise,
    percent: t.percent,
    maxDiscountPaise: t.maxDiscountPaise,
    minOrderPaise: t.minOrderPaise,
  };
});

const stamp = (ms: number | null) => (ms == null ? null : Timestamp.fromMillis(ms));

/**
 * Creates (`isNew: true`) or edits a coupon. The code is the doc id, so it
 * can't change; usage counters are kept. Exported for the emulator tests.
 */
export async function saveCoupon(actor: Actor, raw: Record<string, unknown>) {
  const input = validateCouponInput(raw);
  const isNew = raw.isNew === true;
  if (input.serviceAreaIds.length > 0) {
    const areas = await db.getAll(
      ...input.serviceAreaIds.map((id) => db.collection("serviceAreas").doc(id)),
    );
    const missing = areas.find((a) => !a.exists);
    if (missing) throw new HttpsError("invalid-argument", `Unknown area: ${missing.id}`);
  }

  const ref = db.collection(COUPONS).doc(input.code);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (isNew && snap.exists) {
      throw new HttpsError("already-exists", `${input.code} already exists`);
    }
    if (!isNew && !snap.exists) throw new HttpsError("not-found", "Coupon not found");
    const before = snap.data();
    const doc = {
      description: input.description,
      type: input.type,
      discountPaise: input.discountPaise,
      percent: input.type === "percent" ? input.percent : null,
      maxDiscountPaise: input.maxDiscountPaise,
      minOrderPaise: input.minOrderPaise,
      startAt: stamp(input.startAtMs),
      expiresAt: stamp(input.expiresAtMs),
      usageLimit: input.usageLimit,
      perUserLimit: input.perUserLimit,
      firstOrderOnly: input.firstOrderOnly,
      serviceAreaIds: input.serviceAreaIds,
      isActive: input.isActive,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: actor.uid,
      ...(before
        ? {}
        : { usedCount: 0, totalDiscountPaise: 0, createdAt: FieldValue.serverTimestamp() }),
    };
    tx.set(ref, doc, { merge: true });
    writeAudit(
      actor,
      {
        action: before ? "coupon.update" : "coupon.create",
        target: ref.path,
        before: before ? summary(before) : null,
        after: summary(doc),
      },
      tx,
    );
    return { code: input.code };
  });
}

const summary = (d: Record<string, unknown>) => ({
  type: d.type ?? "flat",
  discountPaise: d.discountPaise ?? null,
  percent: d.percent ?? null,
  minOrderPaise: d.minOrderPaise ?? null,
  usageLimit: d.usageLimit ?? null,
  perUserLimit: d.perUserLimit ?? null,
  isActive: d.isActive ?? null,
});

/** Only never-used coupons can go; used ones are switched off instead, so reports keep their code. */
export async function deleteCoupon(actor: Actor, rawCode: unknown) {
  const code = normalizeCode(rawCode);
  if (!code) throw new HttpsError("invalid-argument", "Invalid code");
  const ref = db.collection(COUPONS).doc(code);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Coupon not found");
  const used = Number(snap.get("usedCount")) || 0;
  if (used > 0) {
    throw new HttpsError(
      "failed-precondition",
      `Used ${used} time${used === 1 ? "" : "s"}, so it can’t be deleted. Turn it off instead`,
    );
  }
  await ref.delete();
  await writeAudit(actor, {
    action: "coupon.delete",
    target: ref.path,
    before: summary(snap.data()!),
    after: null,
  });
  return { ok: true };
}

export const adminSaveCoupon = onCall(async (request) =>
  saveCoupon(
    requireRole(request, ["catalog", "finance"]),
    (request.data ?? {}) as Record<string, unknown>,
  ),
);

export const adminDeleteCoupon = onCall(async (request) =>
  deleteCoupon(requireRole(request, ["catalog", "finance"]), request.data?.code),
);
