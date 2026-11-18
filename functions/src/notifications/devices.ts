import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { requireUid } from "../shared/callable";
import { db } from "../shared/firebase";
import { isLang } from "./model";
import { isValidToken, withToken } from "./tokens";
import { HOT } from "../shared/scaling";

/**
 * Customer devices for pushes. Every signed-in phone is kept in
 * `users/{uid}.pushTokens` (newest last, at most 5), so order updates reach
 * all of them, not just the last one used. `fcmToken` stays the newest
 * token for older app versions.
 */

/** Request: {token, lang?}. */
export const registerPushToken = onCall(HOT, async (request) => {
  const uid = requireUid(request);
  const token = request.data?.token;
  if (!isValidToken(token)) throw new HttpsError("invalid-argument", "Invalid token");
  const lang = isLang(request.data?.lang) ? request.data.lang : null;
  const ref = db.collection("users").doc(uid);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    // The profile is created by the app at sign-in; no doc, nothing to send to yet.
    if (!snap.exists) throw new HttpsError("failed-precondition", "NO_PROFILE");
    tx.update(ref, {
      pushTokens: withToken(snap.get("pushTokens"), token),
      fcmToken: token,
      ...(lang ? { lang } : {}),
      pushTokenAt: FieldValue.serverTimestamp(),
    });
  });
  // A phone belongs to whoever signed in last: other accounts forget it.
  const others = await db.collection("users").where("pushTokens", "array-contains", token).limit(10).get();
  await Promise.all(
    others.docs
      .filter((d) => d.id !== uid)
      .map((d) =>
        d.ref.update({
          pushTokens: FieldValue.arrayRemove(token),
          ...(d.get("fcmToken") === token ? { fcmToken: null } : {}),
        }),
      ),
  );
  return { ok: true };
});

/** Request: {token}. Logout: this phone stops getting the account's pushes. */
export const unregisterPushToken = onCall(async (request) => {
  const uid = requireUid(request);
  const token = request.data?.token;
  if (!isValidToken(token)) throw new HttpsError("invalid-argument", "Invalid token");
  const ref = db.collection("users").doc(uid);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return;
    tx.update(ref, {
      pushTokens: FieldValue.arrayRemove(token),
      ...(snap.get("fcmToken") === token ? { fcmToken: null } : {}),
    });
  });
  return { ok: true };
});
