import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { requireString } from "../shared/callable";
import { auth, db, messaging } from "../shared/firebase";
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
  const token = user.get("fcmToken") as string | null | undefined;
  if (!token) {
    throw new HttpsError("failed-precondition", "This customer has no device registered for notifications");
  }
  try {
    await messaging.send({ token, notification: { title, body }, android: { priority: "high" } });
  } catch (e) {
    const code = (e as { code?: string }).code ?? "";
    if (code.includes("registration-token")) {
      await user.ref.update({ fcmToken: null });
      throw new HttpsError("failed-precondition", "Their device is no longer registered");
    }
    throw e;
  }
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
