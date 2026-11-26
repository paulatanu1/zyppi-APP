import { randomUUID } from "node:crypto";
import { type DocumentSnapshot, FieldValue } from "firebase-admin/firestore";
import { type CallableRequest, HttpsError, onCall } from "firebase-functions/https";
import { assertConsented } from "../legal/legal";
import { writeAudit } from "../shared/audit";
import { openPeriod, readPlan as readPlanTx } from "./periods";
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
  SELLER_STORE_CODES,
  assertNoProblems,
  fssaiMissing,
  newStoreCode,
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
    throw new HttpsError("failed-precondition", "This login is already staff of another shop");
  }

  // The seller agreement + privacy policy (once published; legal/legal.ts).
  if (submit) await assertConsented("seller", uid);

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
    // Store ID for "Log in with Store ID": given once, on the first save.
    let storeCode = (snap.get("storeCode") as string | undefined) ?? null;
    if (!storeCode) {
      for (let i = 0; i < 6 && !storeCode; i++) {
        const candidate = newStoreCode();
        if (!(await tx.get(db.collection(SELLER_STORE_CODES).doc(candidate))).exists) storeCode = candidate;
      }
      if (!storeCode) throw new HttpsError("unavailable", "Couldn't create a Store ID. Try again.");
      tx.create(db.collection(SELLER_STORE_CODES).doc(storeCode), { sellerId: uid, createdAt: FieldValue.serverTimestamp() });
    }
    const { payout, ...rest } = app;
    tx.set(
      ref,
      {
        ...rest,
        ownerUid: uid,
        storeCode,
        fssaiMissing: fssaiMissing(app),
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
  const uid = requireUid(request, "partner");
  if (request.auth?.token.firebase?.sign_in_provider === "anonymous") {
    throw new HttpsError("permission-denied", "Sign in with your email or Google to apply");
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
    // A subscription seller's first period starts on first approval.
    const planId = snap.get("planId") as string | undefined;
    const startPlan =
      move.to === "approved" && snap.get("model") === "subscription" && !!planId && !snap.get("subscription.periodEnd");
    const plan = startPlan ? await readPlanTx(tx, planId!) : null;
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
    if (plan) openPeriod(tx, ref, plan, Date.now());
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
  const uid = requireUid(request, "partner");
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

/**
 * Seller app → Online / Offline. A seller's own shop only gets orders
 * while online (offers are hidden otherwise); supply sellers' stock in
 * Zyppi's stores sells regardless. Request: {online}.
 */
export const sellerSetOnline = onCall(async (request) => {
  const me = await requireSeller(request);
  const online = request.data?.online === true;
  await me.seller.ref.update({ isOnline: online, onlineChangedAt: FieldValue.serverTimestamp(), onlineChangedBy: me.uid });
  return { online };
});

/**
 * The Auth user a shop owner / ops typed in: an email (seller logins now
 * use email, Google or Store ID) or, for older logins, a 10-digit mobile.
 */
export async function findLogin(rawInput: unknown) {
  const raw = typeof rawInput === "string" ? rawInput.trim() : "";
  if (raw.includes("@")) {
    const email = raw.toLowerCase();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) throw new HttpsError("invalid-argument", "Enter a valid email address");
    return { user: await auth.getUserByEmail(email).catch(() => null), label: email };
  }
  const digits = raw.replace(/[\s-]/g, "");
  const phone = /^[6-9]\d{9}$/.test(digits) ? `+91${digits}` : digits;
  if (!/^\+91[6-9]\d{9}$/.test(phone)) throw new HttpsError("invalid-argument", "Enter an email address or a 10-digit mobile number");
  return { user: await auth.getUserByPhoneNumber(phone).catch(() => null), label: phone };
}

/**
 * Owner adds a staff login by email (or, for older logins, phone). The
 * person must have signed in to the seller app once. Request: {email} or {phone}.
 */
export const sellerAddStaff = onCall(async (request) => {
  const me = await requireSeller(request, ["owner"]);
  const { user } = await findLogin(request.data?.email ?? request.data?.phone);
  if (!user) throw new HttpsError("not-found", "Ask them to sign in to the Zyppi Seller app once first");
  if (user.uid === me.uid) throw new HttpsError("invalid-argument", "That's you");
  const ref = db.collection(SELLER_USERS).doc(user.uid);
  await db.runTransaction(async (tx) => {
    const existing = await tx.get(ref);
    if (existing.exists && existing.get("sellerId") !== me.sellerId) {
      throw new HttpsError("failed-precondition", "This login already works for another shop");
    }
    const team = await tx.get(db.collection(SELLER_USERS).where("sellerId", "==", me.sellerId));
    if (team.size >= 10 && !existing.exists) throw new HttpsError("resource-exhausted", "At most 10 logins per shop");
    tx.set(ref, { sellerId: me.sellerId, role: "staff" satisfies SellerRole, addedBy: me.uid, addedAt: FieldValue.serverTimestamp() });
  });
  await auth.setCustomUserClaims(user.uid, { ...(user.customClaims ?? {}), sellerId: me.sellerId, sellerRole: "staff" });
  return { uid: user.uid };
});

/** Owner removes a staff login: claims removed and sessions ended. Request: {uid}. */
export const sellerRemoveStaff = onCall(async (request) => {
  const me = await requireSeller(request, ["owner"]);
  const uid = typeof request.data?.uid === "string" ? request.data.uid : "";
  const ref = db.collection(SELLER_USERS).doc(uid);
  const member = await ref.get();
  if (!member.exists || member.get("sellerId") !== me.sellerId || member.get("role") !== "staff") {
    throw new HttpsError("not-found", "Not a staff login of your shop");
  }
  await ref.delete();
  const user = await auth.getUser(uid).catch(() => null);
  if (user) {
    const claims: Record<string, unknown> = { ...(user.customClaims ?? {}) };
    delete claims.sellerId;
    delete claims.sellerRole;
    await auth.setCustomUserClaims(uid, claims);
    await auth.revokeRefreshTokens(uid);
  }
  return { ok: true };
});

/**
 * Ops: dark-store staff log in to the Zyppi Seller app as staff of the
 * "zyppi" seller (Zyppi's own stores have no owner login), so they get
 * return alerts and can receive returns (functions/src/returns/store.ts).
 * Request: {email (or phone), action: "add" | "remove"}
 */
export const adminSetZyppiStoreStaff = onCall(async (request) => {
  const actor = requireRole(request, ["ops"]);
  const action = request.data?.action;
  if (action !== "add" && action !== "remove") throw new HttpsError("invalid-argument", "Choose add or remove");
  const { user, label } = await findLogin(request.data?.email ?? request.data?.phone);
  if (!user) throw new HttpsError("not-found", "Ask them to sign in to the Zyppi Seller app once first");
  const ref = db.collection(SELLER_USERS).doc(user.uid);
  const existing = await ref.get();
  if (action === "add") {
    if (existing.exists && existing.get("sellerId") !== "zyppi") {
      throw new HttpsError("failed-precondition", "This login already works for another shop");
    }
    await ref.set({ sellerId: "zyppi", role: "staff" satisfies SellerRole, addedBy: actor.uid, addedAt: FieldValue.serverTimestamp() });
    await auth.setCustomUserClaims(user.uid, { ...(user.customClaims ?? {}), sellerId: "zyppi", sellerRole: "staff" });
  } else {
    if (!existing.exists || existing.get("sellerId") !== "zyppi") throw new HttpsError("not-found", "Not dark-store staff");
    await ref.delete();
    const claims: Record<string, unknown> = { ...(user.customClaims ?? {}) };
    delete claims.sellerId;
    delete claims.sellerRole;
    await auth.setCustomUserClaims(user.uid, claims);
    await auth.revokeRefreshTokens(user.uid);
  }
  await writeAudit(actor, { action: `zyppiStaff.${action}`, target: `${SELLER_USERS}/${user.uid}`, after: { login: label } });
  return { uid: user.uid };
});
