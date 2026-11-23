import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { deleteStorageFolder, dropFieldsExcept, OPEN_ORDER_STATUSES, retireLogin } from "../account";
import { respondOffer } from "../dispatch/dispatch";
import { istDayAndWeek } from "../dispatch/earnings";
import { GIG_SLOTS, SLOTS } from "../dispatch/gigs";
import { PAYOUTS } from "../dispatch/pay";
import { RETURNS, RIDER_STATUSES as RETURN_RIDER_STATUSES } from "../returns/model";
import { requireUid } from "../shared/callable";
import { db } from "../shared/firebase";
import { RIDERS } from "./model";

/**
 * Rider app → Delete account (Google Play requires an in-app way).
 *
 * Refused until the rider and Zyppi are square, so no money is lost either
 * way: ACTIVE_DELIVERY (an order or return pickup in hand), CASH_HELD
 * (cash on delivery not yet handed over), PAYOUT_PENDING (finance hasn't
 * paid a request yet), EARNINGS_UNPAID (earnings not yet paid out).
 *
 * Then personal data goes: name, phone, date of birth, address, licence
 * and vehicle numbers, KYC photos, bank / UPI details, devices, location,
 * inbox and open offers; the rider's name and phone are removed from orders,
 * returns and SOS alerts. Kept for accounting and disputes, without those
 * details: riders/{uid} with status "deleted" and its earnings, payouts,
 * cash, trips, days, slots, events and signed consents.
 *
 * The login is deleted too, unless it is also a customer, shop or staff
 * login (account.ts → retireLogin). Request: {confirm: "DELETE"}.
 */
export const riderDeleteAccount = onCall(async (request) => {
  const uid = requireUid(request, "web");
  if (request.data?.confirm !== "DELETE") throw new HttpsError("invalid-argument", "Confirmation required");
  return deleteRiderAccount(uid);
});

/** What riders/{uid} keeps after deletion. Everything else is removed. */
export const RIDER_KEPT_FIELDS = [
  "status",
  "serviceAreaId",
  "vehicleType",
  "createdAt",
  "submittedAt",
  "approvedAt",
  "reviewedAt",
  "deliveredCount",
  "onTimeCount",
  "codBalancePaise",
  "earningsBalancePaise",
  "earnedTotalPaise",
  "paidOutTotalPaise",
  "rating",
] as const;

export type RiderDeletionBlocker = "ACTIVE_DELIVERY" | "CASH_HELD" | "PAYOUT_PENDING" | "EARNINGS_UNPAID";

/** Why the rider can't delete yet, or null. Pure, for the tests. */
export function riderDeletionBlocker(input: {
  activeDelivery: boolean;
  codBalancePaise: number;
  payoutPending: boolean;
  earningsBalancePaise: number;
}): RiderDeletionBlocker | null {
  if (input.activeDelivery) return "ACTIVE_DELIVERY";
  if (input.codBalancePaise > 0) return "CASH_HELD";
  if (input.payoutPending) return "PAYOUT_PENDING";
  if (input.earningsBalancePaise > 0) return "EARNINGS_UNPAID";
  return null;
}

/** Exported for the emulator tests. Safe to repeat. */
export async function deleteRiderAccount(uid: string, now = new Date()): Promise<{ deleted: true; loginDeleted: boolean }> {
  const ref = db.collection(RIDERS).doc(uid);

  // Flip the status first, re-checking money in the same transaction, so a
  // payout or delivery can't start in between (requireRider wants "approved").
  const before = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return null;
    const [payouts, orders, returns] = await Promise.all([
      tx.get(ref.collection(PAYOUTS).where("status", "==", "requested").limit(1)),
      tx.get(db.collection("orders").where("riderId", "==", uid).where("status", "in", OPEN_ORDER_STATUSES).limit(1)),
      tx.get(db.collection(RETURNS).where("riderId", "==", uid).where("status", "in", RETURN_RIDER_STATUSES).limit(1)),
    ]);
    const data = snap.data() ?? {};
    const balances = {
      codBalancePaise: Number(data.codBalancePaise ?? 0),
      earningsBalancePaise: Number(data.earningsBalancePaise ?? 0),
    };
    const blocker = riderDeletionBlocker({
      activeDelivery: !orders.empty || !returns.empty || !!snap.get("presence.activeOrderId") || !!snap.get("presence.activeReturnId"),
      payoutPending: !payouts.empty,
      ...balances,
    });
    if (blocker) throw new HttpsError("failed-precondition", blocker, balances);

    const drop = dropFieldsExcept(data, RIDER_KEPT_FIELDS);
    tx.update(ref, {
      ...Object.fromEntries(drop.map((k) => [k, FieldValue.delete()])),
      status: "deleted",
      presence: { online: false, offlineReason: "deleted" },
      deletedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    if (data.status !== "deleted") {
      tx.create(ref.collection("events").doc(), { type: "deleted", at: FieldValue.serverTimestamp(), by: uid, note: null });
    }
    return data;
  });

  if (before) {
    // An order offer still ringing goes to the next rider (gone already is fine).
    const offered = (before.presence as Record<string, unknown> | undefined)?.offerOrderId;
    if (typeof offered === "string") await respondOffer(uid, offered, false).catch(() => undefined);
    await cancelFutureSlots(ref, String(before.serviceAreaId ?? ""), now);
    await removeRiderData(uid);
  }
  return { deleted: true, loginDeleted: await retireLogin(uid, ["rider"]) };
}

/** Booked slots from today on are cancelled and their capacity freed. */
async function cancelFutureSlots(ref: FirebaseFirestore.DocumentReference, areaId: string, now: Date) {
  const today = istDayAndWeek(now).day;
  const booked = await ref.collection(SLOTS).where("status", "==", "booked").get();
  const future = booked.docs.filter((d) => String(d.get("date") ?? "") >= today);
  const writer = db.bulkWriter();
  for (const slot of future) {
    writer.update(slot.ref, { status: "cancelled", cancelledAt: FieldValue.serverTimestamp(), cancelReason: "account_deleted" });
    if (areaId) writer.set(db.collection(GIG_SLOTS).doc(`${areaId}_${slot.id}`), { booked: FieldValue.increment(-1) }, { merge: true });
  }
  await writer.close();
}

/** Personal data outside riders/{uid}. Idempotent. */
async function removeRiderData(uid: string) {
  const ref = db.collection(RIDERS).doc(uid);
  const [orders, returns, sos] = await Promise.all([
    db.collection("orders").where("riderId", "==", uid).get(),
    db.collection(RETURNS).where("riderId", "==", uid).get(),
    db.collection("sosAlerts").where("riderId", "==", uid).get(),
  ]);
  const writer = db.bulkWriter();
  for (const o of orders.docs) {
    writer.update(o.ref, { riderName: null, riderPhone: null });
    writer.delete(o.ref.collection("tracking").doc("live"));
  }
  for (const r of returns.docs) writer.update(r.ref, { riderName: null, riderPhone: null });
  for (const s of sos.docs) writer.update(s.ref, { riderName: null, riderPhone: null });
  await writer.close();

  // Bank / UPI details, offers, the inbox.
  for (const sub of ["private", "offers", "returnOffers", "inbox"]) {
    await db.recursiveDelete(ref.collection(sub));
  }
  // KYC photos (riders/{uid}/kyc/...).
  await deleteStorageFolder(`${RIDERS}/${uid}/`);
}
