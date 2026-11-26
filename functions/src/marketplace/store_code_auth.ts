import { createHash } from "node:crypto";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { defineString } from "firebase-functions/params";
import { HttpsError, onCall } from "firebase-functions/https";
import { checkAppCheck } from "../shared/hardening";
import { fetchWithTimeout } from "../shared/http";
import { auth, db } from "../shared/firebase";
import { SELLERS, SELLER_STORE_CODES, STORE_CODE_PATTERN, newStoreCode } from "./model";
import { requireSeller } from "./sellers";

/**
 * Store ID sign-in for the Zyppi Seller app.
 *
 * The app sends {storeId, password}. The server finds the shop owner, checks
 * the password against the owner's email/password sign-in with the Identity
 * Toolkit REST API, and returns a custom token. The owner's email never
 * reaches the app, so a Store ID can't be used to discover it.
 *
 * Wrong passwords are counted per caller (a hash of their IP) under
 * sellerStoreCodes/{code}/attempts: after [MAX_FAILS] that caller is
 * locked out for [LOCK_MINUTES]. Counting per Store ID alone let anyone
 * who knew a shop's ID lock the owner out (audit SEC-A02). A shop-wide
 * ceiling ([STORE_MAX_FAILS] an hour from all callers) still stops a
 * distributed guess.
 */

/** The Firebase Web API key (public client config), used only for password checks. */
const WEB_API_KEY = defineString("SELLER_WEB_API_KEY");

export const MAX_FAILS = 5;
export const LOCK_MINUTES = 15;
/** Wrong passwords per hour, from all callers, before the Store ID locks. */
export const STORE_MAX_FAILS = 30;
const HOUR_MS = 60 * 60_000;

/** Who is trying: a hash of the caller's IP (never stored in the clear). */
export function callerKey(raw: { ip?: string; headers?: Record<string, unknown> } | undefined): string {
  const fwd = raw?.headers?.["x-forwarded-for"];
  const ip = (typeof fwd === "string" ? fwd.split(",")[0] : "").trim() || raw?.ip || "unknown";
  return createHash("sha256").update(ip).digest("hex").slice(0, 32);
}

/** The shop-wide failure window after one more failure. Pure, for the tests. */
export function nextStoreWindow(
  prev: { windowStart?: number | null; fails?: number },
  nowMs: number,
): { windowStart: number; fails: number; lock: boolean } {
  const fresh = prev.windowStart == null || nowMs - prev.windowStart > HOUR_MS;
  const fails = (fresh ? 0 : (prev.fails ?? 0)) + 1;
  return { windowStart: fresh ? nowMs : (prev.windowStart as number), fails, lock: fails >= STORE_MAX_FAILS };
}

/** What to do after a password check. Pure, for the tests. */
export function nextLockState(
  prev: { failCount?: number; lockedUntil?: number | null },
  passwordOk: boolean,
  nowMs: number,
): { failCount: number; lockedUntil: number | null } {
  if (passwordOk) return { failCount: 0, lockedUntil: null };
  const fails = (prev.failCount ?? 0) + 1;
  return fails >= MAX_FAILS
    ? { failCount: 0, lockedUntil: nowMs + LOCK_MINUTES * 60_000 }
    : { failCount: fails, lockedUntil: prev.lockedUntil ?? null };
}

export function readStoreSignIn(raw: Record<string, unknown>): { code: string; password: string } {
  const code = typeof raw.storeId === "string" ? raw.storeId.trim().toUpperCase().replace(/\s+/g, "") : "";
  const password = typeof raw.password === "string" ? raw.password : "";
  if (!STORE_CODE_PATTERN.test(code)) throw new HttpsError("invalid-argument", "STORE_ID_INVALID");
  if (password.length < 6 || password.length > 128) throw new HttpsError("invalid-argument", "WRONG_PASSWORD");
  return { code, password };
}

/** Checks the owner's password with Identity Toolkit. Unreachable → NO_NETWORK. */
export async function passwordMatches(email: string, password: string): Promise<boolean> {
  let res: Response;
  try {
    res = await fetchWithTimeout(`https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=${WEB_API_KEY.value()}`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ email, password, returnSecureToken: false }),
    });
  } catch {
    throw new HttpsError("unavailable", "NO_NETWORK");
  }
  if (res.ok) return true;
  const body = (await res.json().catch(() => ({}))) as { error?: { message?: string } };
  const msg = body.error?.message ?? "";
  if (/INVALID_PASSWORD|INVALID_LOGIN_CREDENTIALS|EMAIL_NOT_FOUND/.test(msg)) return false;
  if (/USER_DISABLED/.test(msg)) throw new HttpsError("permission-denied", "ACCOUNT_DISABLED");
  if (/TOO_MANY_ATTEMPTS/.test(msg)) throw new HttpsError("resource-exhausted", "STORE_ID_LOCKED");
  throw new HttpsError("unavailable", "NO_NETWORK");
}

/** Request: {storeId, password}. Response: {token} (a custom token for signInWithCustomToken). */
export const sellerStoreIdSignIn = onCall(async (request) => {
  checkAppCheck(request, undefined, "partner");
  const { code, password } = readStoreSignIn(request.data ?? {});
  const codeRef = db.collection(SELLER_STORE_CODES).doc(code);
  const attemptRef = codeRef.collection("attempts").doc(callerKey(request.rawRequest as never));
  const [codeSnap, attemptSnap] = await Promise.all([codeRef.get(), attemptRef.get()]);
  // Same answer for an unknown Store ID and a wrong password.
  if (!codeSnap.exists) throw new HttpsError("permission-denied", "WRONG_PASSWORD");

  const now = Date.now();
  const storeLocked = (codeSnap.get("lockedUntil") as Timestamp | null | undefined)?.toMillis() ?? null;
  const lockedUntil = (attemptSnap.get("lockedUntil") as Timestamp | null | undefined)?.toMillis() ?? null;
  if ((storeLocked && storeLocked > now) || (lockedUntil && lockedUntil > now)) {
    throw new HttpsError("resource-exhausted", "STORE_ID_LOCKED");
  }

  const sellerId = codeSnap.get("sellerId") as string;
  const seller = await db.collection(SELLERS).doc(sellerId).get();
  const ownerUid = (seller.get("ownerUid") as string | undefined) ?? sellerId;
  const owner = await auth.getUser(ownerUid).catch(() => null);
  if (!owner || owner.disabled) throw new HttpsError("permission-denied", "WRONG_PASSWORD");
  const hasPassword = owner.providerData.some((p) => p.providerId === "password");
  if (!owner.email || !hasPassword) throw new HttpsError("failed-precondition", "USE_GOOGLE");

  const ok = await passwordMatches(owner.email, password);
  const next = nextLockState(
    { failCount: (attemptSnap.get("failCount") as number | undefined) ?? 0, lockedUntil },
    ok,
    Date.now(),
  );
  await attemptRef.set(
    {
      failCount: next.failCount,
      lockedUntil: next.lockedUntil ? Timestamp.fromMillis(next.lockedUntil) : null,
      updatedAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  if (ok) {
    await codeRef.update({ lastSignInAt: FieldValue.serverTimestamp() });
  } else {
    const win = nextStoreWindow(
      {
        windowStart: (codeSnap.get("failWindowStart") as Timestamp | undefined)?.toMillis() ?? null,
        fails: (codeSnap.get("failWindowCount") as number | undefined) ?? 0,
      },
      Date.now(),
    );
    await codeRef.update({
      failWindowStart: Timestamp.fromMillis(win.windowStart),
      failWindowCount: win.fails,
      ...(win.lock ? { lockedUntil: Timestamp.fromMillis(Date.now() + LOCK_MINUTES * 60_000) } : {}),
    });
  }
  if (!ok) throw new HttpsError("permission-denied", next.lockedUntil ? "STORE_ID_LOCKED" : "WRONG_PASSWORD");
  return { token: await auth.createCustomToken(ownerUid) };
});

/**
 * The shop's Store ID, created now for shops approved before Store IDs
 * existed. Owner or staff. Response: {storeId}.
 */
export const sellerStoreCode = onCall(async (request) => {
  const me = await requireSeller(request);
  const existing = me.seller.get("storeCode") as string | undefined;
  if (existing) return { storeId: existing };
  const sellerRef = me.seller.ref;
  const storeId = await db.runTransaction(async (tx) => {
    const fresh = await tx.get(sellerRef);
    const now = fresh.get("storeCode") as string | undefined;
    if (now) return now;
    for (let i = 0; i < 6; i++) {
      const candidate = newStoreCode();
      const ref = db.collection(SELLER_STORE_CODES).doc(candidate);
      if ((await tx.get(ref)).exists) continue;
      tx.create(ref, { sellerId: me.sellerId, createdAt: FieldValue.serverTimestamp() });
      tx.update(sellerRef, { storeCode: candidate });
      return candidate;
    }
    throw new HttpsError("unavailable", "Couldn't create a Store ID. Try again.");
  });
  return { storeId };
});
