import { HttpsError } from "firebase-functions/https";
import { db } from "./firebase";

/** A usable contact number on the profile (set at sign-up, never empty). */
export function hasContactPhone(phone: unknown): boolean {
  return typeof phone === "string" && /^\+?\d{10,15}$/.test(phone.trim());
}

/**
 * Orders need a number the rider can call. Every new account gives one at
 * sign-up; older accounts without one are refused with PHONE_REQUIRED and
 * the app asks for it ("Add mobile number").
 */
export async function assertHasPhone(uid: string): Promise<void> {
  const snap = await db.collection("users").doc(uid).get();
  if (!hasContactPhone(snap.get("phone"))) {
    throw new HttpsError("failed-precondition", "PHONE_REQUIRED");
  }
}
