import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { requireUid } from "../shared/callable";
import { auth, db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import {
  EDITABLE,
  RIDERS,
  type RiderStatus,
  applicationProblems,
  assertNoProblems,
  payoutSummary,
  readApplication,
} from "./model";

/**
 * Rider portal: saves the application (draft) or submits it for review.
 * Allowed while new, draft, changes requested or rejected. Bank details go
 * to riders/{uid}/private/payout (rider + finance only).
 * Exported for the emulator tests.
 */
export async function saveApplication(
  uid: string,
  tokenPhone: string | null,
  raw: Record<string, unknown>,
  now = new Date(),
): Promise<{ status: RiderStatus }> {
  const submit = raw.submit === true;
  const app = readApplication(raw, uid);
  // A phone verified by OTP wins over a typed one.
  if (tokenPhone) app.phone = tokenPhone;
  assertNoProblems(applicationProblems(app, submit, now));
  if (app.serviceAreaId) {
    const area = await db.collection("serviceAreas").doc(app.serviceAreaId).get();
    if (!area.exists || area.get("isActive") !== true) {
      throw new HttpsError("invalid-argument", "That area isn’t open for riders");
    }
  }

  const ref = db.collection(RIDERS).doc(uid);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const current = (snap.get("status") as RiderStatus | undefined) ?? null;
    if (current && !EDITABLE.includes(current)) {
      throw new HttpsError(
        "failed-precondition",
        current === "submitted" ? "Your application is being reviewed" : "Your application can’t be changed now",
      );
    }
    const status: RiderStatus = submit ? "submitted" : (current ?? "draft");
    const { payout, ...rest } = app;
    tx.set(
      ref,
      {
        ...rest,
        payout: payoutSummary(payout),
        status,
        updatedAt: FieldValue.serverTimestamp(),
        ...(snap.exists ? {} : {
          createdAt: FieldValue.serverTimestamp(),
          deliveredCount: 0,
          onTimeCount: 0,
          codBalancePaise: 0,
        }),
        ...(submit ? { submittedAt: FieldValue.serverTimestamp(), reviewNote: null } : {}),
      },
      { merge: true },
    );
    if (payout) tx.set(ref.collection("private").doc("payout"), { ...payout, updatedAt: FieldValue.serverTimestamp() });
    if (submit) {
      tx.create(ref.collection("events").doc(), {
        type: "submitted",
        at: FieldValue.serverTimestamp(),
        by: uid,
        note: null,
      });
    }
    return { status };
  });
}

export const riderSaveApplication = onCall(async (request) => {
  const uid = requireUid(request);
  if (request.auth?.token.firebase?.sign_in_provider === "anonymous") {
    throw new HttpsError("permission-denied", "Sign in with your phone or Google account");
  }
  const phone = request.auth?.token.phone_number;
  return saveApplication(uid, typeof phone === "string" ? phone : null, request.data ?? {});
});

export const REVIEW_ACTIONS = ["approve", "reject", "request_changes", "suspend", "reinstate"] as const;
type ReviewAction = (typeof REVIEW_ACTIONS)[number];

const MOVES: Record<ReviewAction, { from: RiderStatus[]; to: RiderStatus; needsReason: boolean }> = {
  approve: { from: ["submitted"], to: "approved", needsReason: false },
  reject: { from: ["submitted"], to: "rejected", needsReason: true },
  request_changes: { from: ["submitted"], to: "changes_requested", needsReason: true },
  suspend: { from: ["approved"], to: "suspended", needsReason: true },
  reinstate: { from: ["suspended"], to: "approved", needsReason: false },
};

/**
 * Riders → review. Approving grants the `rider` claim; suspending removes
 * it and ends the rider's sessions. Exported for the emulator tests.
 */
export async function reviewRider(
  actor: Actor,
  input: { uid?: unknown; action?: unknown; reason?: unknown; checklist?: unknown },
) {
  const uid = typeof input.uid === "string" ? input.uid : "";
  const action = input.action as ReviewAction;
  if (!uid || !(action in MOVES)) throw new HttpsError("invalid-argument", "Invalid review");
  const reason = typeof input.reason === "string" ? input.reason.trim().slice(0, 500) : "";
  const move = MOVES[action];
  if (move.needsReason && reason.length < 3) {
    throw new HttpsError("invalid-argument", "Tell the rider why (they will see this)");
  }
  const checklist =
    input.checklist && typeof input.checklist === "object" && !Array.isArray(input.checklist)
      ? Object.fromEntries(
          Object.entries(input.checklist as Record<string, unknown>)
            .filter(([k, v]) => /^[a-zA-Z]{1,30}$/.test(k) && typeof v === "boolean")
            .slice(0, 12),
        )
      : null;

  const ref = db.collection(RIDERS).doc(uid);
  const from = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError("not-found", "Rider not found");
    const status = snap.get("status") as RiderStatus;
    if (!move.from.includes(status)) {
      throw new HttpsError("failed-precondition", `Can’t ${action.replace("_", " ")} a rider who is ${status.replace("_", " ")}`);
    }
    tx.update(ref, {
      status: move.to,
      reviewNote: reason || null,
      reviewedBy: actor.uid,
      reviewedAt: FieldValue.serverTimestamp(),
      ...(checklist ? { checklist } : {}),
      ...(move.to === "approved" ? { approvedAt: FieldValue.serverTimestamp() } : {}),
      ...(move.to === "suspended" ? { isOnline: false } : {}),
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.create(ref.collection("events").doc(), {
      type: action,
      at: FieldValue.serverTimestamp(),
      by: actor.uid,
      note: reason || null,
    });
    writeAudit(actor, { action: `rider.${action}`, target: ref.path, before: { status }, after: { status: move.to, reason: reason || null } }, tx);
    return status;
  });

  // Claims after the doc changed (a failure here is retried by reviewing again).
  const user = await auth.getUser(uid).catch(() => null);
  if (user) {
    const claims: Record<string, unknown> = { ...(user.customClaims ?? {}) };
    if (move.to === "approved") claims.rider = true;
    else delete claims.rider;
    await auth.setCustomUserClaims(uid, claims);
    if (move.to === "suspended") await auth.revokeRefreshTokens(uid);
  }
  return { from, status: move.to };
}

export const adminReviewRider = onCall(async (request) =>
  reviewRider(requireRole(request, ["ops"]), request.data ?? {}),
);

/**
 * Cash a rider hands over to the store, against the COD balance they
 * collected. Ledger: riders/{uid}/cash. Exported for the emulator tests.
 */
export async function settleRiderCash(
  actor: Actor,
  input: { uid?: unknown; amountPaise?: unknown; note?: unknown },
) {
  const uid = typeof input.uid === "string" ? input.uid : "";
  const amount = Number(input.amountPaise);
  const note = typeof input.note === "string" ? input.note.trim().slice(0, 200) : "";
  if (!uid || !Number.isInteger(amount) || amount <= 0) {
    throw new HttpsError("invalid-argument", "Enter the amount received");
  }
  const ref = db.collection(RIDERS).doc(uid);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError("not-found", "Rider not found");
    const balance = (snap.get("codBalancePaise") as number | undefined) ?? 0;
    if (amount > balance) {
      throw new HttpsError("failed-precondition", `The rider only holds ₹${(balance / 100).toFixed(2)}`);
    }
    tx.update(ref, { codBalancePaise: balance - amount, updatedAt: FieldValue.serverTimestamp() });
    tx.create(ref.collection("cash").doc(), {
      type: "settled",
      amountPaise: -amount,
      balanceAfterPaise: balance - amount,
      orderId: null,
      note: note || null,
      by: actor.uid,
      at: FieldValue.serverTimestamp(),
    });
    writeAudit(actor, { action: "rider.cashSettled", target: ref.path, before: { balance }, after: { balance: balance - amount, note } }, tx);
    return { balancePaise: balance - amount };
  });
}

export const adminSettleRiderCash = onCall(async (request) =>
  settleRiderCash(requireRole(request, ["finance", "ops"]), request.data ?? {}),
);
