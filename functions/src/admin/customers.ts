import { FieldValue } from "firebase-admin/firestore";
import { addToInbox } from "../notifications/inbox";
import { pushToDevices, tokensOf } from "../notifications/tokens";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { requireString } from "../shared/callable";
import { auth, db } from "../shared/firebase";
import { hasContactPhone } from "../shared/account_checks";
import { type Actor, requireRole } from "../shared/roles";

/**
 * Customers module. Profiles, addresses and orders are read by the admin
 * straight from Firestore (rules: isAdmin); these callables cover what it
 * can't do itself: Auth details, blocking, and a one-off push.
 */

export const BLOCKED_MESSAGE = "ACCOUNT_BLOCKED";

/** Throws when the customer is blocked from ordering (entry points only). */
export async function assertNotBlocked(uid: string): Promise<void> {
  const user = await db.collection("users").doc(uid).get();
  if (user.get("blocked") === true) throw new HttpsError("failed-precondition", BLOCKED_MESSAGE);
}

/** Auth-only facts about a customer (email and sign-in methods live in Auth). */
export async function customerAuth(uid: string) {
  try {
    const u = await auth.getUser(uid);
    return {
      exists: true,
      email: u.email ?? null,
      phone: u.phoneNumber ?? null,
      providers: u.providerData.map((p) => p.providerId),
      anonymous: u.providerData.length === 0,
      disabled: u.disabled,
      createdAt: u.metadata.creationTime ? new Date(u.metadata.creationTime).toISOString() : null,
      lastSignInAt: u.metadata.lastSignInTime ? new Date(u.metadata.lastSignInTime).toISOString() : null,
    };
  } catch (e) {
    if ((e as { code?: string }).code === "auth/user-not-found") return { exists: false };
    throw e;
  }
}

export async function setBlocked(actor: Actor, uidRaw: unknown, blockedRaw: unknown, reasonRaw: unknown) {
  const uid = requireString(uidRaw, "uid");
  if (typeof blockedRaw !== "boolean") throw new HttpsError("invalid-argument", "Invalid blocked");
  const reason = typeof reasonRaw === "string" ? reasonRaw.trim().slice(0, 300) : "";
  if (blockedRaw && reason.length < 3) throw new HttpsError("invalid-argument", "Give a reason for blocking");
  const ref = db.collection("users").doc(uid);
  await db.runTransaction(async (tx) => {
    const user = await tx.get(ref);
    if (!user.exists) throw new HttpsError("not-found", "Customer not found");
    const after = blockedRaw
      ? { blocked: true, blockedReason: reason, blockedBy: actor.uid, blockedAt: FieldValue.serverTimestamp() }
      : { blocked: false, blockedReason: null, blockedBy: actor.uid, blockedAt: null };
    tx.update(ref, after);
    writeAudit(
      actor,
      {
        action: blockedRaw ? "customer.block" : "customer.unblock",
        target: `users/${uid}`,
        before: { blocked: user.get("blocked") === true },
        after: { blocked: blockedRaw, reason },
      },
      tx,
    );
  });
  return { ok: true };
}

export async function pushCustomer(actor: Actor, raw: Record<string, unknown>) {
  const uid = requireString(raw.uid, "uid");
  const title = requireString(raw.title, "title").trim().slice(0, 65);
  const body = requireString(raw.body, "body").trim().slice(0, 240);
  const user = await db.collection("users").doc(uid).get();
  if (!tokensOf(user.data()).length) {
    throw new HttpsError("failed-precondition", "This customer has no device registered for notifications");
  }
  const sent = await pushToDevices(user.ref, user.data(), { notification: { title, body }, android: { priority: "high" } });
  if (!sent) throw new HttpsError("failed-precondition", "Their device is no longer registered");
  await addToInbox(uid, { kind: "account", title, body, data: {} });
  await writeAudit(actor, { action: "customer.push", target: `users/${uid}`, after: { title, body } });
  return { ok: true };
}

/** Request: {uid}. Response: Auth details (see customerAuth). */
export const adminGetCustomerAuth = onCall(async (request) => {
  requireRole(request, ["ops", "support"]);
  return customerAuth(requireString(request.data?.uid, "uid"));
});

/** Request: {uid, blocked, reason?}. Blocked customers can't place new orders. */
export const adminSetCustomerBlocked = onCall(async (request) =>
  setBlocked(requireRole(request, ["ops"]), request.data?.uid, request.data?.blocked, request.data?.reason),
);

/** Request: {uid, title, body}. A one-off push to one customer's phone. */
export const adminPushCustomer = onCall(async (request) =>
  pushCustomer(requireRole(request, ["ops", "support"]), (request.data ?? {}) as Record<string, unknown>),
);

/**
 * Support changes a customer's phone (the app sets it only once:
 * firestore.rules users/{uid}, audit SEC-A03). Needs a reason; audited.
 * Request: {uid, phone, reason}.
 */
export async function setCustomerPhone(actor: Actor, input: { uid?: unknown; phone?: unknown; reason?: unknown }) {
  const uid = requireString(input.uid, "uid");
  const phone = typeof input.phone === "string" ? input.phone.trim().replace(/[\s-]/g, "") : "";
  if (!hasContactPhone(phone)) throw new HttpsError("invalid-argument", "Enter a valid phone number");
  const reason = typeof input.reason === "string" ? input.reason.trim().slice(0, 300) : "";
  if (reason.length < 3) throw new HttpsError("invalid-argument", "Give a reason");
  const ref = db.collection("users").doc(uid);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError("not-found", "Customer not found");
    const before = (snap.get("phone") as string | undefined) ?? null;
    tx.update(ref, { phone, updatedAt: FieldValue.serverTimestamp() });
    writeAudit(actor, { action: "customer.phone", target: ref.path, before: { phone: before }, after: { phone, reason } }, tx);
  });
  return { ok: true };
}

export const adminSetCustomerPhone = onCall(async (request) =>
  setCustomerPhone(requireRole(request, ["ops", "support"]), (request.data ?? {}) as Record<string, unknown>),
);
