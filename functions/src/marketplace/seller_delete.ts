import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { deleteStorageFolder, dropFieldsExcept, OPEN_ORDER_STATUSES, retireLogin } from "../account";
import { auth, db } from "../shared/firebase";
import { requireUid } from "../shared/callable";
import { SELLER_STORE_CODES, SELLER_USERS, SELLERS, ZYPPI_SELLER_ID } from "./model";
import { sellerStoreId } from "./sellers";

const PAYOUTS = "payouts";
const SELLER_CLAIMS = ["sellerId", "sellerRole"];

/**
 * Seller app → Delete account (Google Play requires an in-app way).
 *
 * A staff login only removes itself from the shop. The owner (or an
 * applicant who was never approved) closes the shop: its products come off
 * sale, every staff login loses access, and personal data goes (owner name,
 * phone, email, PAN, Aadhaar digits, address and location, KYC photos, bank
 * / UPI details, devices, inbox, the order list with customer details, the
 * Store ID). Kept for GST and accounting, without those details:
 * sellers/{id} with status "deleted" (shop name, GSTIN, FSSAI number,
 * balances) and its earnings, payouts, subscriptions, fee payments, events
 * and signed consents.
 *
 * The owner is refused until the shop and Zyppi are square: OPEN_ORDERS,
 * PAYOUT_PENDING, BALANCE_UNPAID (earnings or money still held for the
 * return window), DUES_UNPAID (fees owed to Zyppi).
 *
 * The login itself is deleted unless it is also a customer, rider or staff
 * login (account.ts → retireLogin). Request: {confirm: "DELETE"}.
 */
export const sellerDeleteAccount = onCall(async (request) => {
  const uid = requireUid(request, "partner");
  if (request.data?.confirm !== "DELETE") throw new HttpsError("invalid-argument", "Confirmation required");
  return deleteSellerAccount(uid);
});

/** What sellers/{id} keeps after the shop is closed. Everything else is removed. */
export const SELLER_KEPT_FIELDS = [
  "status",
  "shopName",
  "shopCategory",
  "gstin",
  "fssaiNo",
  "model",
  "fulfilment",
  "serviceAreaId",
  "planId",
  "subscription",
  "rating",
  "stats",
  "earningsBalancePaise",
  "heldPaise",
  "earnedTotalPaise",
  "paidOutTotalPaise",
  "duesPaise",
  "createdAt",
  "submittedAt",
  "approvedAt",
  "reviewedAt",
] as const;

export type SellerDeletionBlocker = "OPEN_ORDERS" | "PAYOUT_PENDING" | "BALANCE_UNPAID" | "DUES_UNPAID";

/** Why the owner can't close the shop yet, or null. Pure, for the tests. */
export function sellerDeletionBlocker(input: {
  openOrders: boolean;
  payoutPending: boolean;
  earningsBalancePaise: number;
  heldPaise: number;
  duesPaise: number;
}): SellerDeletionBlocker | null {
  if (input.openOrders) return "OPEN_ORDERS";
  if (input.payoutPending) return "PAYOUT_PENDING";
  if (input.earningsBalancePaise > 0 || input.heldPaise > 0) return "BALANCE_UNPAID";
  if (input.duesPaise > 0) return "DUES_UNPAID";
  return null;
}

/** Exported for the emulator tests. Safe to repeat. */
export async function deleteSellerAccount(uid: string): Promise<{ deleted: true; shopClosed: boolean; loginDeleted: boolean }> {
  const member = await db.collection(SELLER_USERS).doc(uid).get();
  const memberShop = member.exists ? (member.get("sellerId") as string) : null;

  // Staff: leave the shop, nothing else.
  if (member.exists && member.get("role") !== "owner") {
    await removeLogin(uid, memberShop);
    return { deleted: true, shopClosed: false, loginDeleted: await retireLogin(uid, SELLER_CLAIMS) };
  }

  // Owner (approved: sellerUsers says which shop) or applicant (sellers/{uid}).
  const sellerId = memberShop ?? uid;
  if (sellerId === ZYPPI_SELLER_ID) throw new HttpsError("permission-denied", "Zyppi's own stores can't be closed here");
  const ref = db.collection(SELLERS).doc(sellerId);

  const closed = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) return false;
    const owner = (snap.get("ownerUid") as string | undefined) ?? sellerId;
    if (snap.get("status") !== "deleted" && owner !== uid) {
      throw new HttpsError("permission-denied", "Only the shop owner can close the shop");
    }
    const [orders, payouts] = await Promise.all([
      tx.get(ref.collection("orders").where("status", "in", OPEN_ORDER_STATUSES).limit(1)),
      tx.get(ref.collection(PAYOUTS).where("status", "==", "requested").limit(1)),
    ]);
    const data = snap.data() ?? {};
    const money = {
      earningsBalancePaise: Number(data.earningsBalancePaise ?? 0),
      heldPaise: Number(data.heldPaise ?? 0),
      duesPaise: Number(data.duesPaise ?? 0),
    };
    const blocker = sellerDeletionBlocker({ openOrders: !orders.empty, payoutPending: !payouts.empty, ...money });
    if (blocker) throw new HttpsError("failed-precondition", blocker, money);

    const drop = dropFieldsExcept(data, SELLER_KEPT_FIELDS);
    tx.update(ref, {
      ...Object.fromEntries(drop.map((k) => [k, FieldValue.delete()])),
      status: "deleted",
      isOnline: false,
      deletedAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    if (data.status !== "deleted") {
      tx.create(ref.collection("events").doc(), { type: "deleted", at: FieldValue.serverTimestamp(), by: uid, note: null });
    }
    const storeCode = data.storeCode as string | undefined;
    if (storeCode) tx.delete(db.collection(SELLER_STORE_CODES).doc(storeCode));
    return true;
  });

  if (closed) await closeShop(sellerId, uid);
  else if (member.exists) await removeLogin(uid, memberShop);
  return { deleted: true, shopClosed: closed, loginDeleted: await retireLogin(uid, SELLER_CLAIMS) };
}

/**
 * The shop's store (pickups) is closed and its contact details removed;
 * every login loses access; private data goes. The status change itself
 * takes the offers and the public profile down (offers_sync.ts →
 * onSellerWritten). Idempotent.
 */
async function closeShop(sellerId: string, ownerUid: string) {
  const ref = db.collection(SELLERS).doc(sellerId);
  const store = db.collection("stores").doc(sellerStoreId(sellerId));
  if ((await store.get()).exists) {
    await store.update({
      isActive: false,
      address: null,
      phone: null,
      hours: null,
      lat: null,
      lng: null,
      updatedAt: FieldValue.serverTimestamp(),
    });
  }

  const logins = await db.collection(SELLER_USERS).where("sellerId", "==", sellerId).get();
  for (const login of logins.docs) {
    await login.ref.delete();
    if (login.id === ownerUid) continue; // retireLogin handles the owner.
    await stripSellerClaims(login.id);
  }
  // Bank / UPI details, devices, inbox, the order list (it shows customers).
  for (const sub of ["private", "devices", "inbox", "orders"]) {
    await db.recursiveDelete(ref.collection(sub));
  }
  // KYC photos (sellers/{id}/kyc/...). Product photos stay with the catalogue.
  await deleteStorageFolder(`${SELLERS}/${sellerId}/kyc/`);
}

/** A staff login leaves its shop: membership, its devices, claims. */
async function removeLogin(uid: string, sellerId: string | null) {
  await db.collection(SELLER_USERS).doc(uid).delete();
  if (sellerId) {
    const devices = await db.collection(SELLERS).doc(sellerId).collection("devices").where("uid", "==", uid).get();
    await Promise.all(devices.docs.map((d) => d.ref.delete()));
  }
}

async function stripSellerClaims(uid: string) {
  const user = await auth.getUser(uid).catch(() => null);
  if (!user) return;
  const claims: Record<string, unknown> = { ...(user.customClaims ?? {}) };
  for (const c of SELLER_CLAIMS) delete claims[c];
  await auth.setCustomUserClaims(uid, claims);
  await auth.revokeRefreshTokens(uid);
}
