import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/https";
import { onSchedule } from "firebase-functions/scheduler";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import { PAYU_SECRETS, type PayURefunds, type RefundState, payURefunds } from "./payu";

export const REFUNDS = "refunds";
export type RefundStatus = "requesting" | "requested" | "succeeded" | "failed";

/** What a refund is for: a placed order, or a paid intent that never became one. */
export type RefundTarget = { orderId: string } | { intentId: string };

export interface RefundInput {
  amountPaise: number;
  reason: string;
}

function targetRef(t: RefundTarget) {
  return "orderId" in t
    ? db.collection("orders").doc(t.orderId)
    : db.collection("paymentIntents").doc(t.intentId);
}

/**
 * Reserves the amount on the order / intent (`refundedPaise`, so two
 * refunds can't exceed what was paid), writes refunds/{id} and asks PayU.
 * The refund doc id is PayU's unique token, so retrying the same refund
 * can't pay out twice. Exported for the emulator tests (fake `payu`).
 */
export async function createRefund(
  actor: Actor,
  target: RefundTarget,
  input: RefundInput,
  payu: PayURefunds = payURefunds,
): Promise<{ refundId: string; status: RefundStatus }> {
  const reason = typeof input.reason === "string" ? input.reason.trim() : "";
  if (reason.length < 3 || reason.length > 300) {
    throw new HttpsError("invalid-argument", "Give a reason (3–300 characters)");
  }
  if (!Number.isInteger(input.amountPaise) || input.amountPaise <= 0) {
    throw new HttpsError("invalid-argument", "Enter an amount");
  }

  const ref = targetRef(target);
  const refundRef = db.collection(REFUNDS).doc();
  const { mihpayid } = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError("not-found", "Payment not found");
    const d = snap.data()!;
    let paid: number;
    let mihpayid: string | null;
    if ("orderId" in target) {
      const online = d.payment?.method && d.payment.method !== "Cash on delivery";
      if (!online || d.payment?.status !== "succeeded") {
        throw new HttpsError("failed-precondition", "Only online payments can be refunded here");
      }
      paid = d.payment.amountPaise as number;
      mihpayid = (d.payment.providerReference as string | null) ?? null;
    } else {
      if (d.status !== "needs_review") {
        throw new HttpsError("failed-precondition", "Only payments waiting for review can be refunded here");
      }
      paid = d.amountPaise as number;
      mihpayid = (d.transactionId as string | null) ?? null;
    }
    if (!mihpayid) throw new HttpsError("failed-precondition", "No PayU payment id on record");
    const left = paid - ((d.refundedPaise as number | undefined) ?? 0);
    if (input.amountPaise > left) {
      throw new HttpsError(
        "failed-precondition",
        left > 0 ? `At most ₹${(left / 100).toFixed(2)} can still be refunded` : "Already fully refunded",
      );
    }
    tx.create(refundRef, {
      ...("orderId" in target ? { orderId: target.orderId, intentId: null } : { orderId: null, intentId: target.intentId }),
      userId: d.userId ?? null,
      mihpayid,
      amountPaise: input.amountPaise,
      reason,
      status: "requesting",
      requestId: null,
      failureReason: null,
      createdBy: actor.uid,
      createdByEmail: actor.email,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.update(ref, {
      refundedPaise: FieldValue.increment(input.amountPaise),
      refundStatus: "requesting",
      updatedAt: FieldValue.serverTimestamp(),
    });
    writeAudit(
      actor,
      { action: "payment.refund", target: refundRef.path, before: null, after: { ...target, amountPaise: input.amountPaise, reason } },
      tx,
    );
    return { mihpayid };
  });

  const status = await sendRefund(refundRef.id, mihpayid, input.amountPaise, payu);
  return { refundId: refundRef.id, status };
}

/** Asks PayU (again, same token) and records the answer. */
async function sendRefund(
  refundId: string,
  mihpayid: string,
  amountPaise: number,
  payu: PayURefunds,
): Promise<RefundStatus> {
  try {
    const res = await payu.request(mihpayid, refundId, amountPaise);
    if (res.ok) {
      await applyStatus(refundId, "requested", { requestId: res.requestId });
      return "requested";
    }
    await applyStatus(refundId, "failed", { failureReason: res.reason });
    return "failed";
  } catch (error) {
    // PayU unreachable: stays "requesting" and is retried with the same token.
    logger.error("PayU refund request failed", { refundId, error });
    return "requesting";
  }
}

/**
 * Moves a refund to `status` and mirrors it on the order / intent. A failed
 * refund gives its reserved amount back so it can be tried again.
 */
async function applyStatus(
  refundId: string,
  status: RefundStatus,
  extra: Record<string, unknown> = {},
): Promise<void> {
  const refundRef = db.collection(REFUNDS).doc(refundId);
  await db.runTransaction(async (tx) => {
    const r = (await tx.get(refundRef)).data();
    if (!r || r.status === status || r.status === "succeeded" || r.status === "failed") return;
    const target = r.orderId
      ? db.collection("orders").doc(r.orderId)
      : db.collection("paymentIntents").doc(r.intentId);
    tx.update(refundRef, { status, ...extra, updatedAt: FieldValue.serverTimestamp() });
    tx.update(target, {
      refundStatus: status,
      ...(status === "failed" ? { refundedPaise: FieldValue.increment(-r.amountPaise) } : {}),
      ...(status === "requested" && r.intentId ? { status: "refunded" } : {}),
      updatedAt: FieldValue.serverTimestamp(),
    });
  });
}

/** Checks one refund with PayU (or re-sends one PayU never confirmed). */
export async function refreshRefund(
  refundId: string,
  payu: PayURefunds = payURefunds,
): Promise<RefundStatus> {
  const r = (await db.collection(REFUNDS).doc(refundId).get()).data();
  if (!r) throw new HttpsError("not-found", "Refund not found");
  if (r.status === "requesting") return sendRefund(refundId, r.mihpayid, r.amountPaise, payu);
  if (r.status !== "requested") return r.status as RefundStatus;
  let state: RefundState;
  try {
    state = await payu.check(r.requestId);
  } catch (error) {
    logger.error("PayU refund status failed", { refundId, error });
    return "requested";
  }
  if (state === "pending") return "requested";
  await applyStatus(refundId, state);
  return state;
}

/**
 * Needs-review queue: refund the whole remaining amount, or dismiss
 * (e.g. already refunded from the PayU dashboard) with a note.
 */
export async function resolveIntent(
  actor: Actor,
  input: { intentId?: unknown; action?: unknown; note?: unknown },
  payu: PayURefunds = payURefunds,
) {
  const intentId = typeof input.intentId === "string" ? input.intentId : "";
  const note = typeof input.note === "string" ? input.note.trim() : "";
  if (!intentId) throw new HttpsError("invalid-argument", "Invalid payment");
  const ref = db.collection("paymentIntents").doc(intentId);
  const intent = (await ref.get()).data();
  if (!intent) throw new HttpsError("not-found", "Payment not found");
  if (intent.status !== "needs_review") {
    throw new HttpsError("failed-precondition", "This payment is no longer waiting for review");
  }

  if (input.action === "refund") {
    const left = (intent.amountPaise as number) - ((intent.refundedPaise as number) ?? 0);
    return createRefund(
      actor,
      { intentId },
      { amountPaise: left, reason: note || "Paid but no order could be created" },
      payu,
    );
  }
  if (input.action === "dismiss") {
    if (note.length < 3) throw new HttpsError("invalid-argument", "Add a note saying how it was handled");
    await db.runTransaction(async (tx) => {
      tx.update(ref, {
        status: "dismissed",
        resolutionNote: note,
        resolvedBy: actor.uid,
        resolvedAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
      });
      writeAudit(actor, { action: "payment.dismiss", target: ref.path, before: { status: "needs_review" }, after: { status: "dismissed", note } }, tx);
    });
    return { status: "dismissed" };
  }
  throw new HttpsError("invalid-argument", "Choose refund or dismiss");
}

/** Payments → Refund. Request: {orderId, amountPaise, reason}. */
export const adminRefundPayment = onCall({ secrets: PAYU_SECRETS }, async (request) => {
  const actor = requireRole(request, ["finance"]);
  const orderId = request.data?.orderId;
  if (typeof orderId !== "string" || !orderId) throw new HttpsError("invalid-argument", "Invalid order");
  return createRefund(actor, { orderId }, {
    amountPaise: Number(request.data?.amountPaise),
    reason: String(request.data?.reason ?? ""),
  });
});

/** Payments → Refresh a refund's status. Request: {refundId}. */
export const adminRefreshRefund = onCall({ secrets: PAYU_SECRETS }, async (request) => {
  requireRole(request, ["finance", "ops"]);
  const refundId = request.data?.refundId;
  if (typeof refundId !== "string" || !refundId) throw new HttpsError("invalid-argument", "Invalid refund");
  return { status: await refreshRefund(refundId) };
});

/** Payments → Needs review → Refund / Dismiss. Request: {intentId, action, note}. */
export const adminResolveIntent = onCall({ secrets: PAYU_SECRETS }, async (request) =>
  resolveIntent(requireRole(request, ["finance"]), request.data ?? {}),
);

/** Hourly: chases refunds PayU hasn't confirmed yet. Cheap when there are none. */
export const reconcileRefunds = onSchedule(
  { schedule: "every 60 minutes", secrets: PAYU_SECRETS, timeoutSeconds: 120 },
  async () => {
    const tenMinAgo = Timestamp.fromMillis(Date.now() - 10 * 60_000);
    const open = await db
      .collection(REFUNDS)
      .where("status", "in", ["requesting", "requested"])
      .limit(50)
      .get();
    for (const doc of open.docs) {
      const updated = doc.get("updatedAt") as Timestamp | undefined;
      if (updated && updated.toMillis() > tenMinAgo.toMillis()) continue;
      await refreshRefund(doc.id);
    }
  },
);
