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
 * Request: {confirm: "DELETE", forfeitWallet?: boolean}
 */
export const deleteAccount = onCall(async (request) => {
  const uid = requireUid(request);
  if (request.data?.confirm !== "DELETE") {
    throw new HttpsError("invalid-argument", "Confirmation required");
  }

  const balance = walletBalanceOf((await db.collection("users").doc(uid).get()).data());
  if (balance > 0 && request.data?.forfeitWallet !== true) {
    throw new HttpsError("failed-precondition", "WALLET_NOT_EMPTY", { walletPaise: balance });
  }

  const orders = await db.collection("orders").where("userId", "==", uid).get();
  const issues = await db.collection(ORDER_ISSUES).where("userId", "==", uid).get();
  const intents = await db.collection("paymentIntents").where("userId", "==", uid).get();
  const writer = db.bulkWriter();
  for (const order of orders.docs) writer.update(order.ref, { userId: null, addressId: null });
  for (const intent of intents.docs) writer.update(intent.ref, { userId: null, addressId: null });
  for (const issue of issues.docs) writer.update(issue.ref, { userId: null });
  await writer.close();

  await db.recursiveDelete(db.collection("users").doc(uid));
  await auth.deleteUser(uid);

  return { deleted: true };
});
