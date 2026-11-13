import { CallableRequest, HttpsError } from "firebase-functions/https";

/**
 * Staff roles, carried as the Auth custom claim `role` (set by
 * `adminSetRole` or scripts/set-admin.ts). The legacy `admin: true` claim
 * counts as super_admin until that account is migrated.
 * Keep in sync with firestore.rules / storage.rules `staffRole()` and the
 * admin panel's core/auth/roles.ts.
 */
export const ROLES = ["super_admin", "ops", "catalog", "support", "finance"] as const;
export type Role = (typeof ROLES)[number];

export function isRole(value: unknown): value is Role {
  return typeof value === "string" && (ROLES as readonly string[]).includes(value);
}

export function roleOf(token: Record<string, unknown> | undefined | null): Role | null {
  if (!token) return null;
  if (isRole(token.role)) return token.role;
  return token.admin === true ? "super_admin" : null;
}

/** super_admin passes every check; the others only what `allowed` lists. */
export function roleAllows(role: Role | null, allowed: readonly Role[]): boolean {
  return role !== null && (role === "super_admin" || allowed.includes(role));
}

/** The staff member behind a callable, for permission checks and the audit log. */
export interface Actor {
  uid: string;
  role: Role;
  email: string | null;
}

/**
 * Any staff role in `allowed` (super_admin always). An empty list means
 * super_admin only.
 */
export function requireRole(request: CallableRequest, allowed: readonly Role[]): Actor {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Not authenticated");
  const role = roleOf(request.auth?.token as Record<string, unknown> | undefined);
  if (!roleAllows(role, allowed)) throw new HttpsError("permission-denied", "Not authorized");
  const email = request.auth?.token.email;
  return { uid, role: role!, email: typeof email === "string" ? email : null };
}
