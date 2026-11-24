import { Timestamp } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import { onDocumentCreated } from "firebase-functions/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/https";
import { auth, db } from "./shared/firebase";
import { requireUid } from "./shared/callable";
import { ORDER_ISSUES, walletBalanceOf } from "./wallet/model";

/**
 * Deletes the caller's account (Google Play requires an in-app path).
 * Personal data (profile, addresses, cart, favourites, payment intents)
 * is removed; orders are kept for accounting but unlinked from the person
 * — each order keeps its address text snapshot, as invoices require.
 *
 * A wallet balance is lost with the account, so deletion is refused with
 * WALLET_NOT_EMPTY until the app has warned the customer and sends
 * `forfeitWallet: true`. Claims are kept (unlinked) like orders.
 *
 * Refused with ACTIVE_ORDERS while an order is still on its way, a PayU
 * payment is open, or a claim / return is being handled: the customer
 * would lose track of goods or money that are still moving.
 *
 * Also removed: the phone on kept orders, the pickup address / phone of
 * finished returns, claim photos in Storage; support chats are unlinked.
 *
 * Request: {confirm: "DELETE", forfeitWallet?: boolean}
 */
export const OPEN_ORDER_STATUSES = ["placed", "packed", "out_for_delivery"];
export const OPEN_ISSUE_STATUSES = ["open", "resolving", "returning"];

/** Why the account can't be deleted yet, or null. */
export function deletionBlocker(input: {
  orderStatuses: string[];
  intentStatuses: string[];
  issueStatuses: string[];
}): string | null {
  if (input.orderStatuses.some((s) => OPEN_ORDER_STATUSES.includes(s))) return "ACTIVE_ORDERS";
  if (input.intentStatuses.includes("created")) return "ACTIVE_ORDERS";
  if (input.issueStatuses.some((s) => OPEN_ISSUE_STATUSES.includes(s))) return "ACTIVE_ORDERS";
  return null;
}
export const deleteAccount = onCall(async (request) => {
  const uid = requireUid(request);
  if (request.data?.confirm !== "DELETE") {
    throw new HttpsError("invalid-argument", "Confirmation required");
  }

  const balance = walletBalanceOf((await db.collection("users").doc(uid).get()).data());
  if (balance > 0 && request.data?.forfeitWallet !== true) {
    throw new HttpsError("failed-precondition", "WALLET_NOT_EMPTY", { walletPaise: balance });
  }

  const [orders, issues, intents, returns, chats] = await Promise.all([
    db.collection("orders").where("userId", "==", uid).get(),
    db.collection(ORDER_ISSUES).where("userId", "==", uid).get(),
    db.collection("paymentIntents").where("userId", "==", uid).get(),
    db.collection("returns").where("userId", "==", uid).get(),
    db.collection("supportChats").where("userId", "==", uid).get(),
  ]);
  const blocker = deletionBlocker({
    orderStatuses: orders.docs.map((d) => d.get("status") as string),
    intentStatuses: intents.docs.map((d) => d.get("status") as string),
    issueStatuses: issues.docs.map((d) => d.get("status") as string),
  });
  if (blocker) throw new HttpsError("failed-precondition", blocker);

  // Lock the account first: no new ID tokens while its data is removed, so
  // a half-finished deletion can't leave a live session without a profile.
  // If the cleanup fails the account is unlocked again; every step below is
  // safe to repeat, so the customer can simply retry.
  await auth.updateUser(uid, { disabled: true });
  await auth.revokeRefreshTokens(uid);
  try {
    await removeAccountData(uid, { orders, intents, issues, returns, chats });
  } catch (e) {
    await auth.updateUser(uid, { disabled: false }).catch(() => undefined);
    throw e;
  }
  // The data is gone. The same login may also be a rider, a shop login or
  // staff (one Firebase project); then only the customer part goes.
  if (await loginStillUsed(uid)) {
    await auth.updateUser(uid, { disabled: false });
    return { deleted: true };
  }
  // A disabled user is harmless if this last call fails.
  await auth.deleteUser(uid).catch(async () => auth.deleteUser(uid));

  return { deleted: true };
});

/**
 * True while something else still uses this login: a customer profile, a
 * rider or seller application that isn't deleted, a shop login, or staff.
 */
export async function loginStillUsed(uid: string): Promise<boolean> {
  const [user, rider, member, shop, staff] = await Promise.all([
    db.collection("users").doc(uid).get(),
    db.collection("riders").doc(uid).get(),
    db.collection("sellerUsers").doc(uid).get(),
    db.collection("sellers").doc(uid).get(),
    db.collection("staff").doc(uid).get(),
  ]);
  const live = (s: FirebaseFirestore.DocumentSnapshot) => s.exists && s.get("status") !== "deleted";
  return user.exists || live(rider) || member.exists || live(shop) || staff.exists;
}

/**
 * The last step of a rider / seller deletion: the Auth user is deleted,
 * unless the login is still used elsewhere; then only `claims` are removed
 * and its sessions ended. Returns whether the login was deleted.
 */
export async function retireLogin(uid: string, claims: string[]): Promise<boolean> {
  const user = await auth.getUser(uid).catch(() => null);
  if (!user) return true;
  if (!(await loginStillUsed(uid))) {
    await auth.deleteUser(uid).catch(async () => auth.deleteUser(uid));
    return true;
  }
  const kept: Record<string, unknown> = { ...(user.customClaims ?? {}) };
  for (const c of claims) delete kept[c];
  await auth.setCustomUserClaims(uid, kept);
  await auth.revokeRefreshTokens(uid);
  return false;
}

/** The fields of `data` not in `keep` (to remove). Pure, for the tests. */
export function dropFieldsExcept(data: Record<string, unknown>, keep: readonly string[]): string[] {
  return Object.keys(data).filter((k) => !keep.includes(k));
}

type Snap = FirebaseFirestore.QuerySnapshot;

/** Unlinks kept records and deletes personal data. Idempotent. */
async function removeAccountData(
  uid: string,
  { orders, intents, issues, returns, chats }: Record<"orders" | "intents" | "issues" | "returns" | "chats", Snap>,
): Promise<void> {
  const writer = db.bulkWriter();
  for (const order of orders.docs) writer.update(order.ref, { userId: null, addressId: null, contactPhone: null });
  for (const intent of intents.docs) writer.update(intent.ref, { userId: null, addressId: null });
  for (const issue of issues.docs) writer.update(issue.ref, { userId: null });
  for (const r of returns.docs) {
    writer.update(r.ref, { userId: null });
    writer.delete(r.ref.collection("private").doc("customer"));
  }
  for (const chat of chats.docs) writer.update(chat.ref, { userId: null });
  await writer.close();

  // Claim photos (users/{uid}/claims/...).
  await deleteStorageFolder(`users/${uid}/`);
  await db.recursiveDelete(db.collection("users").doc(uid));
}

/**
 * The sign-up time for users/{uid}.createdAt: Firebase Auth's creation
 * time when it parses, otherwise `now`.
 */
export function signUpTime(authCreationTime: string | undefined, now: Date = new Date()): Timestamp {
  const ms = authCreationTime ? Date.parse(authCreationTime) : Number.NaN;
  return Timestamp.fromMillis(Number.isNaN(ms) ? now.getTime() : ms);
}

/**
 * The app saves profiles without createdAt, and the admin panel's
 * Customers list sorts by it (Firestore leaves out docs missing the
 * field), so it's filled here from the Auth account when a profile is
 * created. scripts/backfill-user-created-at.ts did the existing ones.
 */
export const onUserProfileCreated = onDocumentCreated("users/{uid}", async (event) => {
  const snap = event.data;
  if (!snap || snap.get("createdAt") != null) return;
  const user = await auth.getUser(event.params.uid).catch(() => null);
  await snap.ref.update({ createdAt: signUpTime(user?.metadata.creationTime) });
});

/**
 * Deletes every Storage file under `prefix`. A failure is logged, not
 * thrown: the account deletion goes on, and ops can rerun it from the log.
 */
export async function deleteStorageFolder(prefix: string): Promise<void> {
  try {
    await getStorage().bucket().deleteFiles({ prefix });
  } catch (e) {
    logger.warn("Storage cleanup failed", { prefix, error: String(e) });
  }
}
