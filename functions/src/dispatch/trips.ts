import { onDocumentWritten } from "firebase-functions/firestore";
import { db } from "../shared/firebase";
import { RIDERS } from "../riders/model";

/**
 * riders/{uid}/trips/{orderId}: the rider's own record of an order, without
 * the customer's address or phone, for the rider app's History. The rider
 * can read orders/{id} only while it's open (and briefly after), so their
 * past customers' details don't stay in their hands (firestore.rules).
 */
export const TRIPS = "trips";

const FIELDS = [
  "status",
  "riderStage",
  "placedAt",
  "deliveredAt",
  "cancelledAt",
  "riderEarning",
  "totalPaise",
  "tipPaise",
  "paymentMethod",
  "serviceAreaId",
] as const;

/** The rider-safe copy of an order (no address, phone, items or codes). */
export function tripOf(order: Record<string, unknown>): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const f of FIELDS) if (order[f] !== undefined) out[f] = order[f];
  const address = (order.address ?? {}) as Record<string, unknown>;
  // The area name only (History shows where it went, not the house).
  if (typeof address.area === "string") out.area = address.area;
  return out;
}

/** True when the trip copy would change. */
export function tripChanged(before: Record<string, unknown> | undefined, after: Record<string, unknown>): boolean {
  if (!before || before.riderId !== after.riderId) return true;
  return JSON.stringify(tripOf(before)) !== JSON.stringify(tripOf(after));
}

export const onOrderForRiders = onDocumentWritten("orders/{orderId}", async (e) => {
  const before = e.data?.before?.data();
  const after = e.data?.after?.data();
  const orderId = e.params.orderId;
  const prev = (before?.riderId as string | null | undefined) ?? null;
  const now = (after?.riderId as string | null | undefined) ?? null;
  // Reassigned / unassigned: the previous rider loses it, unless they
  // were paid for the trip (cancelled after pickup).
  if (prev && prev !== now && !(before?.riderEarning as { cancelledTrip?: boolean } | undefined)?.cancelledTrip) {
    await db.collection(RIDERS).doc(prev).collection(TRIPS).doc(orderId).delete();
  }
  if (!after || !now || !tripChanged(before, after)) return;
  await db.collection(RIDERS).doc(now).collection(TRIPS).doc(orderId).set(tripOf(after));
});
