import { CallableRequest, HttpsError } from "firebase-functions/https";
import { OrderError } from "../orders/quote";
import { type Caller, checkAppCheck } from "./hardening";
import { roleOf } from "./roles";

/**
 * The caller's uid; anonymous (guest) users count as signed in. `caller`
 * picks the App Check switch (shared/hardening.ts): "web" for callables
 * the admin panel / rider portal use too.
 */
export function requireUid(request: CallableRequest, caller: Caller = "app"): string {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Not authenticated");
  checkAppCheck(request, undefined, caller);
  return uid;
}

/** True for a Firebase anonymous ("Continue as guest") sign-in. */
export function isGuestToken(token: unknown): boolean {
  const firebase = (token as { firebase?: { sign_in_provider?: unknown } } | undefined)?.firebase;
  return firebase?.sign_in_provider === "anonymous";
}

/**
 * Like [requireUid], but a guest (anonymous) caller is refused with
 * ACCOUNT_REQUIRED: guests may browse, but anything that reserves stock,
 * starts a payment or uses a paid service (support bot) needs a real
 * account. The app sends guests to "Save your account" first.
 */
export function requireAccount(request: CallableRequest, caller: Caller = "app"): string {
  const uid = requireUid(request, caller);
  if (isGuestToken(request.auth?.token)) {
    throw new HttpsError("failed-precondition", "ACCOUNT_REQUIRED");
  }
  return uid;
}

/** Any staff role (see shared/roles.ts; use requireRole to narrow it). */
export function requireAdmin(request: CallableRequest): string {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Not authenticated");
  if (roleOf(request.auth?.token as Record<string, unknown> | undefined) === null) {
    throw new HttpsError("permission-denied", "Not authorized");
  }
  checkAppCheck(request, undefined, "web");
  return uid;
}

export function requireString(value: unknown, field: string): string {
  if (typeof value !== "string" || value.trim() === "") {
    throw new HttpsError("invalid-argument", `Invalid ${field}`);
  }
  return value;
}

/** OrderError → `failed-precondition` carrying the readable reason. */
export function toHttpsError(error: unknown): never {
  if (error instanceof HttpsError) throw error;
  if (error instanceof OrderError) {
    throw new HttpsError("failed-precondition", error.message);
  }
  throw error;
}
