import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { auth, db } from "../shared/firebase";
import { type Actor, type Role, isRole, requireRole, roleOf } from "../shared/roles";

/** Mirror of every staff account's role, for the admin panel's list. */
export const STAFF = "staff";

/**
 * Grants, changes or (role = null) removes a staff role.
 * - sets the `role` claim and drops the legacy `admin` claim;
 * - mirrors it in staff/{uid} (any staff can read; only this writes);
 * - on removal, revokes refresh tokens so the session ends within the hour;
 * - logs the change. You can't change your own role (so the last
 *   super_admin can't lock everyone out).
 * Exported for the emulator tests.
 */
export async function setStaffRole(
  actor: Actor,
  input: { email?: unknown; role?: unknown },
): Promise<{ uid: string; role: Role | null }> {
  const email = typeof input.email === "string" ? input.email.trim().toLowerCase() : "";
  if (!email.includes("@")) throw new HttpsError("invalid-argument", "Invalid email");
  if (input.role !== null && !isRole(input.role)) {
    throw new HttpsError("invalid-argument", "Invalid role");
  }
  const role = input.role as Role | null;

  let user;
  try {
    user = await auth.getUserByEmail(email);
  } catch {
    throw new HttpsError(
      "not-found",
      "No account with that email. Create it first in Firebase Authentication.",
    );
  }
  if (user.uid === actor.uid) {
    throw new HttpsError("failed-precondition", "You can't change your own role");
  }

  const before = roleOf(user.customClaims ?? null);
  const claims: Record<string, unknown> = { ...(user.customClaims ?? {}) };
  delete claims.admin;
  if (role) claims.role = role;
  else delete claims.role;
  await auth.setCustomUserClaims(user.uid, claims);
  if (!role) await auth.revokeRefreshTokens(user.uid);

  const ref = db.collection(STAFF).doc(user.uid);
  const batch = db.batch();
  if (role) {
    batch.set(ref, {
      email: user.email ?? email,
      displayName: user.displayName ?? null,
      role,
      disabled: user.disabled,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: actor.uid,
    });
  } else {
    batch.delete(ref);
  }
  await batch.commit();
  await writeAudit(actor, {
    action: role ? "staff.setRole" : "staff.removeRole",
    target: `${STAFF}/${user.uid}`,
    before: { email, role: before },
    after: { email, role },
  });
  return { uid: user.uid, role };
}

/**
 * Settings → Admins & roles (super_admin only).
 * Request: {email, role: Role | null}. Response: {uid, role}.
 */
export const adminSetRole = onCall(async (request) => {
  const actor = requireRole(request, []);
  return setStaffRole(actor, request.data ?? {});
});
