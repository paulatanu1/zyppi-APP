import { FieldValue, type Transaction } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { auth, db } from "../shared/firebase";
import { requireString } from "../shared/callable";
import { type Actor, requireRole } from "../shared/roles";
import { writeAudit } from "../shared/audit";
import { PAYU_SECRETS, type PayURefunds, payURefunds } from "../payments/payu";
import { createRefund } from "../payments/refunds";

export const ORDER_STATUSES = ["placed", "packed", "out_for_delivery", "delivered", "cancelled"];
export type OrderStatus = (typeof ORDER_STATUSES)[number];

/** Allowed moves. Delivered and cancelled are final. */
export const TRANSITIONS: Record<string, string[]> = {
  placed: ["packed", "cancelled"],
  packed: ["out_for_delivery", "cancelled"],
  out_for_delivery: ["delivered", "cancelled"],
  delivered: [],
  cancelled: [],
};

export interface StatusInput {
  orderId?: unknown;
  status?: unknown;
  reason?: unknown;
  riderName?: unknown;
  riderPhone?: unknown;
}

interface Allocation {
  storeId: string;
  productId: string;
  variantId: string;
  quantity: number;
}

/**
 * Status change (or just rider details when `status` is unchanged), in one
 * transaction with its event (which pushes the customer and drives live
 * tracking) and an audit row.
 * - Cancelling needs a reason, puts the stock back in the stores it came
 *   from (inventoryMovements "order_cancel"), and refunds an online
 *   payment in full right after.
 * - Delivering a cash order marks the cash as collected.
 * Exported for the emulator tests.
 */
export async function updateOrderStatus(
  actor: Actor,
  input: StatusInput,
  payu: PayURefunds = payURefunds,
): Promise<{ ok: true; refund?: { refundId: string; status: string } }> {
  const orderId = requireString(input.orderId, "orderId");
  const status = requireString(input.status, "status");
  if (!ORDER_STATUSES.includes(status)) {
    throw new HttpsError("invalid-argument", `Invalid status: ${status}`);
  }
  const reason = typeof input.reason === "string" ? input.reason.trim() : "";

  const orderRef = db.collection("orders").doc(orderId);
  const refundDue = await db.runTransaction(async (tx) => {
    const order = await tx.get(orderRef);
    if (!order.exists) throw new HttpsError("not-found", `Order not found: ${orderId}`);
    const d = order.data()!;
    const from = d.status as string;

    const update: Record<string, unknown> = { updatedAt: FieldValue.serverTimestamp() };
    for (const field of ["riderName", "riderPhone"] as const) {
      const value = input[field];
      if (typeof value === "string") update[field] = value.trim().slice(0, 80) || null;
    }

    if (status === from) {
      tx.update(orderRef, update);
      return 0;
    }
    if (!TRANSITIONS[from]?.includes(status)) {
      throw new HttpsError("failed-precondition", `Can’t move an order from ${label(from)} to ${label(status)}`);
    }
    update.status = status;
    update[`${status === "out_for_delivery" ? "outForDelivery" : status}At`] = FieldValue.serverTimestamp();

    let due = 0;
    if (status === "cancelled") {
      if (reason.length < 3) throw new HttpsError("invalid-argument", "Give a reason for cancelling");
      update.cancelReason = reason.slice(0, 300);
      update.cancelledBy = actor.uid;
      await restock(tx, orderRef.id, d, actor);
      const online = d.payment?.method && d.payment.method !== "Cash on delivery";
      if (online && d.payment?.status === "succeeded") {
        due = (d.payment.amountPaise as number) - ((d.refundedPaise as number) ?? 0);
        if (due > 0) update.refundStatus = "pending";
      }
    }
    if (status === "delivered" && d.payment?.method === "Cash on delivery") {
      update["payment.status"] = "succeeded";
    }

    tx.update(orderRef, update);
    tx.create(orderRef.collection("events").doc(), {
      status,
      createdAt: FieldValue.serverTimestamp(),
      by: actor.uid,
      ...(reason ? { note: reason.slice(0, 300) } : {}),
    });
    writeAudit(
      actor,
      { action: "order.status", target: orderRef.path, before: { status: from }, after: { status, reason: reason || null } },
      tx,
    );
    return due;
  });

  if (refundDue > 0) {
    const refund = await createRefund(
      actor,
      { orderId },
      { amountPaise: refundDue, reason: `Order cancelled: ${reason}`.slice(0, 300) },
      payu,
    );
    return { ok: true, refund };
  }
  return { ok: true };
}

const label = (s: string) => s.replace(/_/g, " ");

/**
 * Puts a cancelled order's stock back. Orders placed before `allocations`
 * existed go back to the first active store of their area.
 */
async function restock(
  tx: Transaction,
  orderId: string,
  order: Record<string, unknown>,
  actor: Actor,
): Promise<void> {
  let allocations = (order.allocations as Allocation[] | undefined) ?? [];
  if (!allocations.length) {
    const stores = await tx.get(
      db.collection("stores")
        .where("serviceAreaId", "==", order.serviceAreaId ?? "")
        .where("isActive", "==", true)
        .limit(1),
    );
    const storeId = stores.docs[0]?.id;
    if (!storeId) return;
    allocations = ((order.items as Allocation[] | undefined) ?? []).map((i) => ({
      storeId,
      productId: i.productId,
      variantId: i.variantId,
      quantity: i.quantity,
    }));
  }
  const refs = allocations.map((a) => db.collection("inventory").doc(`${a.storeId}_${a.variantId}`));
  const snaps = refs.length ? await tx.getAll(...refs) : [];
  allocations.forEach((a, i) => {
    const before = (snaps[i].get("quantity") as number | undefined) ?? 0;
    tx.set(
      refs[i],
      {
        storeId: a.storeId,
        productId: a.productId,
        variantId: a.variantId,
        quantity: before + a.quantity,
        updatedAt: FieldValue.serverTimestamp(),
      },
      { merge: true },
    );
    tx.create(db.collection("inventoryMovements").doc(), {
      storeId: a.storeId,
      productId: a.productId,
      variantId: a.variantId,
      delta: a.quantity,
      before,
      after: before + a.quantity,
      reason: "order_cancel",
      note: null,
      orderId,
      actorUid: actor.uid,
      actorEmail: actor.email,
      at: FieldValue.serverTimestamp(),
    });
  });
}

/**
 * Orders board → status / rider / cancel (ops).
 * Request: {orderId, status, reason?, riderName?, riderPhone?}
 */
export const adminUpdateOrderStatus = onCall({ secrets: PAYU_SECRETS }, async (request) =>
  updateOrderStatus(requireRole(request, ["ops"]), request.data ?? {}),
);

/**
 * Users list for the admin panel: profile docs joined with Auth (email
 * lives only in Auth).
 *
 * Response: [{id, email, phone, fullName, createdAt}] newest first.
 */
export const adminListUsers = onCall(async (request) => {
  requireRole(request, ["ops", "support"]);

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
