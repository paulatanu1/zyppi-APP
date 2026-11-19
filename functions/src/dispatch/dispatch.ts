import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { cashToCollect } from "../wallet/model";
import { pushToDevices, tokensOf } from "../notifications/tokens";
import { logger } from "firebase-functions";
import { onDocumentWritten } from "firebase-functions/firestore";
import { HttpsError } from "firebase-functions/https";
import { onSchedule } from "firebase-functions/scheduler";
import { db } from "../shared/firebase";
import { RIDERS } from "../riders/model";
import { bindRider, withdrawOffer } from "./effects";
import { pickupPoint } from "./earnings";
import {
  type Candidate,
  type DispatchState,
  OFFERS,
  RIDER_CONFIG_DOC,
  distanceM,
  earningFor,
  isPoint,
  parseRiderConfig,
  pickRider,
} from "./model";
import { HOT } from "../shared/scaling";

const ORDERS = "orders";
const OPEN = ["placed", "packed"];

const ms = (v: unknown) => (v instanceof Timestamp ? v.toMillis() : null);

export function candidateFrom(id: string, d: Record<string, unknown>): Candidate {
  const p = (d.presence ?? {}) as Record<string, unknown>;
  return {
    uid: id,
    lat: typeof p.lat === "number" ? p.lat : null,
    lng: typeof p.lng === "number" ? p.lng : null,
    pingAtMs: ms(p.at),
    // A rider on (or offered) a return pickup is busy too (returns/dispatch.ts).
    activeOrderId: (p.activeOrderId as string | null | undefined) ?? (p.activeReturnId as string | null | undefined) ?? null,
    offerOrderId: (p.offerOrderId as string | null | undefined) ?? (p.offerReturnId as string | null | undefined) ?? null,
    onBreakUntilMs: ms(p.onBreakUntil),
    idleSinceMs: ms(p.idleSince),
    inSlot: (ms(p.slotEndsAt) ?? 0) > Date.now(),
    codBalancePaise: typeof d.codBalancePaise === "number" ? d.codBalancePaise : 0,
  };
}

interface Offered {
  riderId: string;
  tokens: string[];
  expiresAtMs: number;
}

/**
 * Offers an open, unassigned order to the best free rider in its area
 * (see pickRider), or flags it unassigned for ops. Safe to call any time:
 * it does nothing for orders that already have a rider or a live offer.
 */
export async function offerOrder(orderId: string, nowMs = Date.now()): Promise<Offered | null> {
  const orderRef = db.collection(ORDERS).doc(orderId);
  const offered = await db.runTransaction(async (tx) => {
    const [orderSnap, configSnap] = await Promise.all([tx.get(orderRef), tx.get(db.doc(RIDER_CONFIG_DOC))]);
    const o = orderSnap.data();
    if (!o || !OPEN.includes(o.status as string) || o.riderId) return null;
    const config = parseRiderConfig(configSnap.data());
    const state = (o.dispatch as { state?: DispatchState } | undefined)?.state;
    if (state === "manual" || state === "assigned" || state === "issue") return null;
    const offer = o.offer as { riderId?: string; expiresAt?: Timestamp } | undefined;
    if (offer?.riderId && (offer.expiresAt?.toMillis() ?? 0) > nowMs) return null;
    if (!config.dispatch.auto) {
      if (state !== "unassigned") {
        tx.update(orderRef, { dispatch: { state: "unassigned", updatedAt: FieldValue.serverTimestamp() } });
      }
      return null;
    }
    const tried = ((o.dispatch as { tried?: string[] } | undefined)?.tried ?? []).slice();
    if (offer?.riderId && !tried.includes(offer.riderId)) tried.push(offer.riderId);

    const store = await pickupPoint(tx, o);
    const cod = (o.payment as { method?: string } | undefined)?.method === "Cash on delivery";
    // The wallet may have paid part of a cash order.
    const collectPaise = cod ? cashToCollect(o) : 0;
    const riders = await tx.get(
      db
        .collection(RIDERS)
        .where("serviceAreaId", "==", o.serviceAreaId ?? "")
        .where("status", "==", "approved")
        .where("presence.online", "==", true)
        .limit(100),
    );
    const pick =
      tried.length < config.dispatch.maxOffers && store
        ? pickRider(riders.docs.map((r) => candidateFrom(r.id, r.data())), store, config.dispatch, tried, nowMs, {
            collectPaise,
            cashLimitPaise: config.cashLimitPaise,
          })
        : null;

    // Writes from here on.
    if (offer?.riderId) withdrawOffer(tx, orderId, offer.riderId);
    if (!pick) {
      tx.update(orderRef, {
        offer: FieldValue.delete(),
        dispatch: { state: "unassigned", tried, updatedAt: FieldValue.serverTimestamp() },
      });
      return null;
    }
    const expiresAt = Timestamp.fromMillis(nowMs + config.dispatch.offerSeconds * 1000);
    const address = (o.address ?? {}) as Record<string, unknown>;
    const to = { lat: address.lat, lng: address.lng };
    const dropM = store && isPoint(to) ? distanceM(store, to) : 0;
    const allocations = (o.allocations as { storeId: string }[] | undefined) ?? [];
    const storeIds = [...new Set(allocations.map((a) => a.storeId))];
    tx.update(orderRef, {
      offer: { riderId: pick.uid, expiresAt, at: FieldValue.serverTimestamp() },
      dispatch: { state: "offered", tried: [...tried, pick.uid], updatedAt: FieldValue.serverTimestamp() },
    });
    const riderDoc = riders.docs.find((r) => r.id === pick.uid)!;
    tx.update(riderDoc.ref, { "presence.offerOrderId": orderId });
    tx.set(riderDoc.ref.collection(OFFERS).doc(orderId), {
      orderId,
      shortId: orderId.slice(0, 8).toUpperCase(),
      expiresAt,
      pickupDistanceM: pick.distanceM,
      dropDistanceM: dropM,
      dropArea: [address.area, address.city].filter((x) => typeof x === "string" && x).join(", "),
      storeIds,
      itemCount: ((o.items as { quantity?: number }[] | undefined) ?? []).reduce((n, i) => n + (i.quantity ?? 0), 0),
      collectPaise,
      cod,
      earningPaise:
        earningFor(config, (o.serviceAreaId as string) ?? "", dropM, new Date(nowMs)).totalPaise +
        Math.max(0, (o.tipPaise as number | undefined) ?? 0),
      at: FieldValue.serverTimestamp(),
    });
    return {
      riderId: pick.uid,
      tokens: tokensOf(riderDoc.data()),
      expiresAtMs: expiresAt.toMillis(),
    };
  });
  if (offered?.tokens.length) await pushOffer(offered.tokens, orderId, offered.expiresAtMs, offered.riderId);
  return offered;
}

/** Data-only, high priority: the app rings and shows the offer full-screen. */
async function pushOffer(tokens: string[], orderId: string, expiresAtMs: number, riderId: string): Promise<void> {
  const ref = db.collection(RIDERS).doc(riderId);
  const rider = await ref.get();
  const sent = await pushToDevices(ref, rider.data(), {
    data: { type: "offer", orderId, expiresAt: String(expiresAtMs) },
    android: { priority: "high", ttl: Math.max(1000, expiresAtMs - Date.now()) },
  });
  if (!sent) logger.warn("Offer push reached no device", { orderId, riderId, devices: tokens.length });
}

/** Accept (the order becomes theirs) or reject (it goes to the next rider). */
export async function respondOffer(uid: string, orderIdRaw: unknown, accept: unknown): Promise<{ ok: true }> {
  const orderId = typeof orderIdRaw === "string" && /^[\w-]{1,64}$/.test(orderIdRaw) ? orderIdRaw : null;
  if (!orderId || typeof accept !== "boolean") throw new HttpsError("invalid-argument", "Invalid request");
  const orderRef = db.collection(ORDERS).doc(orderId);
  const riderRef = db.collection(RIDERS).doc(uid);
  await db.runTransaction(async (tx) => {
    const [order, rider] = await Promise.all([tx.get(orderRef), tx.get(riderRef)]);
    const offer = order.get("offer") as { riderId?: string; expiresAt?: Timestamp } | undefined;
    const mine = offer?.riderId === uid;
    if (!mine || order.get("riderId")) {
      // Gone already (timed out, taken by ops): just tidy the rider's side.
      withdrawOffer(tx, orderId, uid);
      if (accept) throw new HttpsError("failed-precondition", "OFFER_GONE");
      return;
    }
    if (!accept) {
      withdrawOffer(tx, orderId, uid);
      tx.update(orderRef, { offer: FieldValue.delete() });
      return;
    }
    if ((offer.expiresAt?.toMillis() ?? 0) < Date.now() - 3000) {
      withdrawOffer(tx, orderId, uid);
      throw new HttpsError("failed-precondition", "OFFER_GONE");
    }
    if (rider.get("presence.activeOrderId") || rider.get("presence.activeReturnId")) {
      throw new HttpsError("failed-precondition", "FINISH_DELIVERY_FIRST");
    }
    bindRider(tx, orderId, uid);
    tx.update(orderRef, {
      riderId: uid,
      riderName: rider.get("fullName") ?? null,
      riderPhone: rider.get("phone") ?? null,
      riderAssignedAt: FieldValue.serverTimestamp(),
      riderStage: "accepted",
      offer: FieldValue.delete(),
      dispatch: {
        state: "assigned",
        tried: (order.get("dispatch.tried") as string[] | undefined) ?? [],
        updatedAt: FieldValue.serverTimestamp(),
      },
    });
  });
  if (!accept) await offerOrder(orderId);
  return { ok: true };
}

/** Looks for riders for an area's waiting orders (a rider just came online). */
export async function dispatchWaiting(serviceAreaId: string): Promise<void> {
  const waiting = await db
    .collection(ORDERS)
    .where("dispatch.state", "==", "unassigned")
    .where("serviceAreaId", "==", serviceAreaId)
    .limit(5)
    .get();
  for (const o of waiting.docs) {
    try {
      await offerOrder(o.id);
    } catch (e) {
      logger.warn("dispatchWaiting failed", { orderId: o.id, e });
    }
  }
}

/**
 * Starts the search when an order reaches the configured status
 * (placed or packed) without a rider.
 */
export const onOrderDispatch = onDocumentWritten({ ...HOT, document: "orders/{orderId}" }, async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!after || after.riderId || after.dispatch) return;
  if (!OPEN.includes(after.status as string) || before?.status === after.status) return;
  const config = parseRiderConfig((await db.doc(RIDER_CONFIG_DOC).get()).data());
  if (config.dispatch.assignAt === "packed" && after.status !== "packed") return;
  await offerOrder(event.params.orderId);
});

/**
 * Every minute: expired offers go to the next rider, waiting orders are
 * retried, and riders whose app stopped pinging go offline.
 */
export const dispatchSweep = onSchedule({ schedule: "every 1 minutes", timeoutSeconds: 120 }, async () => {
  const now = Timestamp.now();
  const [expired, waiting, stale] = await Promise.all([
    db.collection(ORDERS).where("dispatch.state", "==", "offered").where("offer.expiresAt", "<=", now).limit(50).get(),
    db.collection(ORDERS).where("dispatch.state", "==", "unassigned").limit(50).get(),
    db
      .collection(RIDERS)
      .where("presence.online", "==", true)
      .where("presence.at", "<", Timestamp.fromMillis(now.toMillis() - 10 * 60_000))
      .limit(100)
      .get(),
  ]);
  for (const o of [...expired.docs, ...waiting.docs]) {
    if (!OPEN.includes(o.get("status") as string)) continue;
    try {
      await offerOrder(o.id, now.toMillis());
    } catch (e) {
      logger.warn("sweep offer failed", { orderId: o.id, e });
    }
  }
  for (const r of stale.docs) {
    if (r.get("presence.activeOrderId") || r.get("presence.activeReturnId")) continue; // keep them on their job
    await r.ref.update({ "presence.online": false, "presence.offlineReason": "no_signal" });
  }
});
