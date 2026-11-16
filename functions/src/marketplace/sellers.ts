import { randomUUID } from "node:crypto";
import { type DocumentSnapshot, FieldValue } from "firebase-admin/firestore";
import { type CallableRequest, HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { requireUid } from "../shared/callable";
import { auth, db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import {
  SELLERS,
  SELLER_EDITABLE,
  SELLER_PLANS,
  SELLER_USERS,
  type SellerRole,
  type SellerStatus,
  assertNoProblems,
  payoutSummary,
  planProblems,
  readPlan,
  readSellerApplication,
  sellerApplicationProblems,
} from "./model";

/**
 * Seller app → registration: saves the application (draft) or submits it
 * for review. The seller doc is keyed by the owner's uid. Bank / UPI goes
 * to sellers/{id}/private/payout (owner + finance only).
 * Exported for the emulator tests.
 */
export async function saveSellerApplication(
  uid: string,
  tokenPhone: string | null,
  raw: Record<string, unknown>,
  now = new Date(),
): Promise<{ status: SellerStatus }> {
  const submit = raw.submit === true;
  const app = readSellerApplication(raw, uid);
  // A phone verified by OTP wins over a typed one.
  if (tokenPhone) app.phone = tokenPhone;
  assertNoProblems(sellerApplicationProblems(app, submit, now));

  if (app.serviceAreaId) {
    const area = await db.collection("serviceAreas").doc(app.serviceAreaId).get();
    if (!area.exists || area.get("isActive") !== true) {
      throw new HttpsError("invalid-argument", "Zyppi isn’t open for sellers in that area yet");
    }
  }
  if (app.model === "subscription" && app.planId) {
    const plan = await db.collection(SELLER_PLANS).doc(app.planId).get();
    if (!plan.exists || plan.get("isActive") !== true) {
      throw new HttpsError("invalid-argument", "That plan isn’t available");
    }
  }
  // Someone already working for another shop can't open a second one.
  const member = await db.collection(SELLER_USERS).doc(uid).get();
  if (member.exists && member.get("sellerId") !== uid) {
    throw new HttpsError("failed-precondition", "This number is already a staff login for another shop");
  }

  const ref = db.collection(SELLERS).doc(uid);
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const current = (snap.get("status") as SellerStatus | undefined) ?? null;
    if (current && !SELLER_EDITABLE.includes(current)) {
      throw new HttpsError(
        "failed-precondition",
        current === "applied" ? "Your application is being reviewed" : "Your application can’t be changed now",
      );
    }
    const status: SellerStatus = submit ? "applied" : (current ?? "draft");
    const { payout, ...rest } = app;
    tx.set(
      ref,
      {
        ...rest,
        ownerUid: uid,
        payout: payoutSummary(payout),
        status,
        updatedAt: FieldValue.serverTimestamp(),
        ...(snap.exists
          ? {}
          : {
              createdAt: FieldValue.serverTimestamp(),
              rating: { avg: 0, count: 0 },
              stats: { orders: 0, cancelled: 0, lateAccepts: 0 },
              earningsBalancePaise: 0,
              heldPaise: 0,
              earnedTotalPaise: 0,
              paidOutTotalPaise: 0,
              duesPaise: 0,
              isOnline: false,
            }),
        ...(submit ? { submittedAt: FieldValue.serverTimestamp(), reviewNote: null } : {}),
      },
      { merge: true },
    );
    if (payout) tx.set(ref.collection("private").doc("payout"), { ...payout, updatedAt: FieldValue.serverTimestamp() });
    if (submit) {
      tx.create(ref.collection("events").doc(), { type: "submitted", at: FieldValue.serverTimestamp(), by: uid, note: null });
    }
    return { status };
  });
}

export const sellerSaveApplication = onCall(async (request) => {
  const uid = requireUid(request);
  if (request.auth?.token.firebase?.sign_in_provider === "anonymous") {
    throw new HttpsError("permission-denied", "Sign in with your phone number");
  }
  const phone = request.auth?.token.phone_number;
  return saveSellerApplication(uid, typeof phone === "string" ? phone : null, request.data ?? {});
});

export const SELLER_REVIEW_ACTIONS = ["approve", "reject", "request_changes", "suspend", "reinstate"] as const;
type ReviewAction = (typeof SELLER_REVIEW_ACTIONS)[number];

const MOVES: Record<ReviewAction, { from: SellerStatus[]; to: SellerStatus; needsReason: boolean }> = {
  approve: { from: ["applied"], to: "approved", needsReason: false },
  reject: { from: ["applied"], to: "rejected", needsReason: true },
  request_changes: { from: ["applied"], to: "changes_requested", needsReason: true },
  suspend: { from: ["approved"], to: "suspended", needsReason: true },
  reinstate: { from: ["suspended"], to: "approved", needsReason: false },
};

/** The seller's own shop as a pickup store (seller_shop fulfilment). */
export const sellerStoreId = (sellerId: string) => `seller_${sellerId}`;

/**
 * Sellers → review. Approving makes the owner a seller login (claim
 * `sellerId`, sellerUsers/{uid}) and, for seller-shop fulfilment, creates
 * the shop as a store. Suspending removes the claim from every login of
 * the shop, ends their sessions and closes the store.
 * Exported for the emulator tests.
 */
export async function reviewSeller(
  actor: Actor,
  input: { sellerId?: unknown; action?: unknown; reason?: unknown },
) {
  const sellerId = typeof input.sellerId === "string" ? input.sellerId : "";
  const action = input.action as ReviewAction;
  if (!sellerId || !(action in MOVES)) throw new HttpsError("invalid-argument", "Invalid review");
  const reason = typeof input.reason === "string" ? input.reason.trim().slice(0, 500) : "";
  const move = MOVES[action];
  if (move.needsReason && reason.length < 3) {
    throw new HttpsError("invalid-argument", "Tell the seller why (they will see this)");
  }

  const ref = db.collection(SELLERS).doc(sellerId);
  const { from, ownerUid } = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (!snap.exists) throw new HttpsError("not-found", "Seller not found");
    const status = snap.get("status") as SellerStatus;
    if (!move.from.includes(status)) {
      throw new HttpsError("failed-precondition", `Can’t ${action.replace("_", " ")} a seller who is ${status.replace("_", " ")}`);
    }
    const owner = (snap.get("ownerUid") as string | undefined) ?? sellerId;
    const storeRef = db.collection("stores").doc(sellerStoreId(sellerId));
    const touchesStore = move.to === "approved" || move.to === "suspended";
    const store = touchesStore && snap.get("fulfilment") === "seller_shop" ? await tx.get(storeRef) : null;

    tx.update(ref, {
      status: move.to,
      reviewNote: reason || null,
      reviewedBy: actor.uid,
      reviewedAt: FieldValue.serverTimestamp(),
      ...(move.to === "approved" ? { approvedAt: FieldValue.serverTimestamp() } : { isOnline: false }),
      updatedAt: FieldValue.serverTimestamp(),
    });
    if (move.to === "approved") {
      tx.set(db.collection(SELLER_USERS).doc(owner), { sellerId, role: "owner" satisfies SellerRole, addedAt: FieldValue.serverTimestamp() });
    }
    if (store) {
      // The shop goes live for pickups on approval; offers (Phase 7 M1)
      // decide what is sold from it. Edits after that are the seller's.
      tx.set(
        storeRef,
        {
          name: snap.get("shopName"),
          serviceAreaId: snap.get("serviceAreaId"),
          address: snap.get("address") ?? null,
          phone: snap.get("phone") ?? null,
          hours: snap.get("hours") ?? null,
          lat: snap.get("lat") ?? null,
          lng: snap.get("lng") ?? null,
          sellerId,
          fulfilment: "seller_shop",
          isActive: move.to === "approved",
          updatedAt: FieldValue.serverTimestamp(),
          ...(store.exists ? {} : { createdAt: FieldValue.serverTimestamp() }),
        },
        { merge: true },
      );
    }
    tx.create(ref.collection("events").doc(), { type: action, at: FieldValue.serverTimestamp(), by: actor.uid, note: reason || null });
    writeAudit(actor, { action: `seller.${action}`, target: ref.path, before: { status }, after: { status: move.to, reason: reason || null } }, tx);
    return { from: status, ownerUid: owner };
  });

  // Claims after the docs changed (a failure here is fixed by reviewing again).
  const members = await db.collection(SELLER_USERS).where("sellerId", "==", sellerId).get();
  const logins = new Map(members.docs.map((d) => [d.id, d.get("role") as SellerRole]));
  if (move.to === "approved") logins.set(ownerUid, "owner");
  for (const [uid, role] of logins) {
    const user = await auth.getUser(uid).catch(() => null);
    if (!user) continue;
    const claims: Record<string, unknown> = { ...(user.customClaims ?? {}) };
    if (move.to === "approved") {
      claims.sellerId = sellerId;
      claims.sellerRole = role;
    } else {
      delete claims.sellerId;
      delete claims.sellerRole;
    }
    await auth.setCustomUserClaims(uid, claims);
    if (move.to === "suspended") await auth.revokeRefreshTokens(uid);
  }
  return { from, status: move.to };
}

export const adminReviewSeller = onCall(async (request) =>
  reviewSeller(requireRole(request, ["ops"]), request.data ?? {}),
);

/** Request: {id?, name, months: 1|3|6, feePaise, maxListings, isActive}. Finance owns pricing of plans. */
export const adminSaveSellerPlan = onCall(async (request) => {
  const actor = requireRole(request, ["finance"]);
  const plan = readPlan(request.data ?? {});
  assertNoProblems(planProblems(plan));
  const rawId = request.data?.id;
  const id = typeof rawId === "string" && /^[\w-]{1,128}$/.test(rawId) ? rawId : randomUUID();
  const ref = db.collection(SELLER_PLANS).doc(id);
  await db.runTransaction(async (tx) => {
    const before = await tx.get(ref);
    tx.set(ref, {
      ...plan,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: actor.uid,
      ...(before.exists ? {} : { createdAt: FieldValue.serverTimestamp() }),
    }, { merge: true });
    writeAudit(actor, { action: "sellerPlan.save", target: ref.path, before: before.data() ?? null, after: plan }, tx);
  });
  return { id };
});

/** The caller as a login of an approved seller. */
export interface SellerCaller {
  uid: string;
  sellerId: string;
  role: SellerRole;
  seller: DocumentSnapshot;
}

/**
 * The caller as an approved seller's login (owner or staff). Reads
 * sellerUsers/{uid} rather than trusting the claim alone, so a removed
 * staff login stops working at once.
 */
export async function requireSeller(request: CallableRequest, roles: readonly SellerRole[] = ["owner", "staff"]): Promise<SellerCaller> {
  const uid = requireUid(request);
  const member = await db.collection(SELLER_USERS).doc(uid).get();
  if (!member.exists) throw new HttpsError("permission-denied", "NOT_A_SELLER");
  const sellerId = member.get("sellerId") as string;
  const role = member.get("role") as SellerRole;
  if (!roles.includes(role)) throw new HttpsError("permission-denied", "Only the shop owner can do this");
  const seller = await db.collection(SELLERS).doc(sellerId).get();
  if (!seller.exists || seller.get("status") !== "approved") {
    throw new HttpsError("permission-denied", "SELLER_NOT_APPROVED");
  }
  return { uid, sellerId, role, seller };
}
