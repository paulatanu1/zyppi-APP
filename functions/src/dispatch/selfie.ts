import { type DocumentSnapshot, FieldValue } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { HttpsError } from "firebase-functions/https";
import { istDayAndWeek } from "./earnings";

/**
 * Go-online selfie (rider app `lib/features/selfie`). The phone checks
 * liveness and matches the live selfie to the application selfie
 * (MobileFaceNet, cosine); this re-checks what it can and keeps every selfie
 * in `riders/{uid}/selfies` so ops can audit.
 */

/** Keep in step with `selfieMatchThreshold` in the rider app (face_math.dart). */
export const SELFIE_MIN_SCORE = 0.65;
/** The selfie must have been uploaded this recently. */
export const SELFIE_MAX_AGE_MS = 5 * 60_000;
/** Failed checks in a day (IST) before going online is locked. */
export const SELFIE_FAILS_PER_DAY = 5;

export const SELFIES = "selfies";

export interface SelfieInput {
  path: string;
  score: number | null;
  noReference: boolean;
}

export type SelfieVerdict = "ok" | "SELFIE_REQUIRED" | "SELFIE_MISMATCH" | "SELFIE_LOCKED";

/** The request's `selfie`, or null when it's missing / not the rider's own. */
export function readSelfie(uid: string, raw: unknown): SelfieInput | null {
  if (!raw || typeof raw !== "object") return null;
  const s = raw as Record<string, unknown>;
  const path = typeof s.path === "string" ? s.path : "";
  // riders/{uid}/duty/{file}: one level, no "..".
  if (!new RegExp(`^riders/${uid}/duty/[A-Za-z0-9_-]+\\.jpg$`).test(path)) return null;
  const score = typeof s.score === "number" && Number.isFinite(s.score) ? s.score : null;
  const noReference = s.noReference === true;
  if (score === null && !noReference) return null;
  return { path, score, noReference };
}

export function judgeSelfie(
  s: SelfieInput | null,
  o: { uploadedMs: number | null; nowMs: number; failsToday: number },
): SelfieVerdict {
  if (o.failsToday >= SELFIE_FAILS_PER_DAY) return "SELFIE_LOCKED";
  if (!s || o.uploadedMs === null) return "SELFIE_REQUIRED";
  const age = o.nowMs - o.uploadedMs;
  if (age > SELFIE_MAX_AGE_MS || age < -60_000) return "SELFIE_REQUIRED";
  if (s.noReference) return "ok";
  return (s.score ?? 0) >= SELFIE_MIN_SCORE ? "ok" : "SELFIE_MISMATCH";
}

async function uploadedMs(path: string): Promise<number | null> {
  try {
    const [meta] = await getStorage().bucket().file(path).getMetadata();
    const t = Date.parse(String(meta.timeCreated ?? ""));
    return Number.isFinite(t) ? t : null;
  } catch {
    return null;
  }
}

/**
 * Throws SELFIE_REQUIRED / SELFIE_MISMATCH / SELFIE_LOCKED unless the
 * request carries a fresh, matching duty selfie. Records every attempt
 * that names a selfie.
 */
export async function requireDutySelfie(rider: DocumentSnapshot, raw: unknown, nowMs = Date.now()): Promise<void> {
  const selfie = readSelfie(rider.id, raw);
  const { day } = istDayAndWeek(new Date(nowMs));
  const dayRef = rider.ref.collection("days").doc(day);
  const failsToday = Number((await dayRef.get()).get("selfieFails") ?? 0);
  const uploaded = selfie ? await uploadedMs(selfie.path) : null;
  const verdict = judgeSelfie(selfie, { uploadedMs: uploaded, nowMs, failsToday });
  if (selfie) {
    const hasKyc = typeof rider.get("docs.selfie") === "string";
    await rider.ref.collection(SELFIES).add({
      path: selfie.path,
      score: selfie.score,
      noReference: selfie.noReference,
      passed: verdict === "ok",
      verdict,
      // Liveness only, or the app said there was nothing to match: ops look.
      review: selfie.noReference,
      hasKycSelfie: hasKyc,
      day,
      at: FieldValue.serverTimestamp(),
    });
  }
  if (verdict === "SELFIE_MISMATCH") {
    await dayRef.set({ day, selfieFails: FieldValue.increment(1) }, { merge: true });
  }
  if (verdict !== "ok") throw new HttpsError("failed-precondition", verdict);
}
