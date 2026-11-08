import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { auth, db } from "../shared/firebase";
import { requireAdmin, requireString } from "../shared/callable";

export const ORDER_STATUSES = ["placed", "packed", "out_for_delivery", "delivered", "cancelled"];

/**
 * Admin status change: updates the order and appends the event (which
 * drives the customer's push and live tracking) in one transaction.
 *
 * Request: {orderId, status, riderName?, riderPhone?}
 */
export const adminUpdateOrderStatus = onCall(async (request) => {
  requireAdmin(request);
  const orderId = requireString(request.data?.orderId, "orderId");
  const status = requireString(request.data?.status, "status");
  if (!ORDER_STATUSES.includes(status)) {
    throw new HttpsError("invalid-argument", `Invalid status: ${status}`);
  }

  const update: Record<string, unknown> = { status, updatedAt: FieldValue.serverTimestamp() };
  for (const field of ["riderName", "riderPhone"] as const) {
    const value = request.data?.[field];
    if (typeof value === "string") update[field] = value.trim() || null;
  }

  const orderRef = db.collection("orders").doc(orderId);
  await db.runTransaction(async (tx) => {
    const order = await tx.get(orderRef);
    if (!order.exists) throw new HttpsError("not-found", `Order not found: ${orderId}`);
    tx.update(orderRef, update);
    tx.create(orderRef.collection("events").doc(), {
      status,
      createdAt: FieldValue.serverTimestamp(),
    });
  });
  return { ok: true };
});

/**
 * Users list for the admin panel: profile docs joined with Auth (email
 * lives only in Auth).
 *
 * Response: [{id, email, phone, fullName, createdAt}] newest first.
 */
export const adminListUsers = onCall(async (request) => {
  requireAdmin(request);

  const authUsers = new Map<string, { email: string | null; phone: string | null; created: string }>();
  let pageToken: string | undefined;
  do {
    const page = await auth.listUsers(1000, pageToken);
    for (const u of page.users) {
      authUsers.set(u.uid, {
        email: u.email ?? null,
        phone: u.phoneNumber ?? null,
        created: u.metadata.creationTime,
      });
    }
    pageToken = page.pageToken;
  } while (pageToken);

  const profiles = await db.collection("users").get();
  const profileById = new Map(profiles.docs.map((d) => [d.id, d.data()]));

  return [...authUsers.entries()]
    .map(([id, a]) => {
      const profile = profileById.get(id) ?? {};
      return {
        id,
        email: (profile.email as string | undefined) ?? a.email,
        phone: (profile.phone as string | undefined) ?? a.phone,
        fullName: (profile.fullName as string | undefined) ?? null,
        createdAt: new Date(a.created).toISOString(),
      };
    })
    .sort((x, y) => y.createdAt.localeCompare(x.createdAt));
});
