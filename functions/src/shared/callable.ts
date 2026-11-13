import { CallableRequest, HttpsError } from "firebase-functions/https";
import { OrderError } from "../orders/quote";
import { roleOf } from "./roles";

/** The caller's uid; anonymous (guest) users count as signed in. */
export function requireUid(request: CallableRequest): string {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Not authenticated");
  return uid;
}

/** Any staff role (see shared/roles.ts; use requireRole to narrow it). */
export function requireAdmin(request: CallableRequest): string {
  const uid = requireUid(request);
  if (roleOf(request.auth?.token as Record<string, unknown> | undefined) === null) {
    throw new HttpsError("permission-denied", "Not authorized");
  }
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
