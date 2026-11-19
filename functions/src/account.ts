import { getStorage } from "firebase-admin/storage";
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
  await getStorage()
    .bucket()
    .deleteFiles({ prefix: `users/${uid}/` })
    .catch(() => undefined);
  await db.recursiveDelete(db.collection("users").doc(uid));
  await auth.deleteUser(uid);

  return { deleted: true };
});
