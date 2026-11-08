import { HttpsError, onCall } from "firebase-functions/https";
import { auth, db } from "./shared/firebase";
import { requireUid } from "./shared/callable";

/**
 * Deletes the caller's account (Google Play requires an in-app path).
 * Personal data (profile, addresses, cart, favourites, payment intents)
 * is removed; orders are kept for accounting but unlinked from the person
 * — each order keeps its address text snapshot, as invoices require.
 *
 * Request: {confirm: "DELETE"}
 */
export const deleteAccount = onCall(async (request) => {
  const uid = requireUid(request);
  if (request.data?.confirm !== "DELETE") {
    throw new HttpsError("invalid-argument", "Confirmation required");
  }

  const orders = await db.collection("orders").where("userId", "==", uid).get();
  const intents = await db.collection("paymentIntents").where("userId", "==", uid).get();
  const writer = db.bulkWriter();
  for (const order of orders.docs) writer.update(order.ref, { userId: null, addressId: null });
  for (const intent of intents.docs) writer.update(intent.ref, { userId: null, addressId: null });
  await writer.close();

  await db.recursiveDelete(db.collection("users").doc(uid));
  await auth.deleteUser(uid);

  return { deleted: true };
});
