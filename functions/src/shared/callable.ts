import { CallableRequest, HttpsError } from "firebase-functions/https";
import { OrderError } from "../orders/quote";

/** The caller's uid; anonymous (guest) users count as signed in. */
export function requireUid(request: CallableRequest): string {
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Not authenticated");
  return uid;
}

export function requireAdmin(request: CallableRequest): string {
  const uid = requireUid(request);
  if (request.auth?.token.admin !== true) {
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
