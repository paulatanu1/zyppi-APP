import { type DocumentSnapshot, FieldValue, Timestamp, type Transaction } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { onDocumentCreated } from "firebase-functions/firestore";
import { HttpsError } from "firebase-functions/https";
import { onSchedule } from "firebase-functions/scheduler";
import { candidateFrom } from "../dispatch/dispatch";
import { RIDER_CONFIG_DOC, earningFor, isPoint, parseRiderConfig, pickRider, type Point } from "../dispatch/model";
import { istDayAndWeek } from "../dispatch/earnings";
import { notifySeller } from "../marketplace/seller_notify";
import { pushToDevices } from "../notifications/tokens";
import { RIDERS } from "../riders/model";
import { db } from "../shared/firebase";
import { RETURNS, RETURN_OFFERS } from "./model";
import { tellCustomer } from "./notify";

/**
 * Finding a rider for a return pickup: the same rules as orders (nearest
 * free rider with a fresh position, offers time out and move on), but the
 * pickup point is the customer. Offers go to riders/{uid}/returnOffers so
 * rider apps without return support never see them; unanswered returns
 * show as unassigned on the admin Dispatch board.
 *
 * Rider presence: presence.offerReturnId / presence.activeReturnId (a
 * rider on a return gets no order offers, see dispatch.ts).
 */

const riderRef = (uid: string) => db.collection(RIDERS).doc(uid);
const returnRef = (id: string) => db.collection(RETURNS).doc(id);

export function returnIdOf(raw: unknown): string {
  if (typeof raw !== "string" || !/^[\w-]{1,140}$/.test(raw)) throw new HttpsError("invalid-argument", "Invalid return");
  return raw;
}

/** The customer's pin, from returns/{id}/private/customer. */
export function customerPoint(c: Record<string, unknown> | undefined): Point | null {
  const p = { lat: c?.lat, lng: c?.lng };
  return isPoint(p) ? p : null;
}

export const customerRef = (returnId: string) => returnRef(returnId).collection("private").doc("customer");

export function storePoint(r: Record<string, unknown>): Point | null {
  const p = { lat: r.storeLat, lng: r.storeLng };
  return isPoint(p) ? p : null;
}

function withdrawReturnOffer(tx: Transaction, returnId: string, uid: string): void {
  tx.set(riderRef(uid), { presence: { offerReturnId: null } }, { merge: true });
  tx.delete(riderRef(uid).collection(RETURN_OFFERS).doc(returnId));
}

/** Frees the rider after a return (received, failed, review, cancelled). */
export function releaseReturnRider(tx: Transaction, uid: string): void {
  tx.set(riderRef(uid), { presence: { activeReturnId: null, idleSince: FieldValue.serverTimestamp() } }, { merge: true });
}

/**
 * Pays the rider for a return trip (customer → store on the rate card),
 * once: the ledger row id is fixed. [config] read in the same transaction.
 */
export function payReturnRider(
  tx: Transaction,
  rider: DocumentSnapshot,
  returnId: string,
  r: Record<string, unknown>,
  configRaw: Record<string, unknown> | undefined,
  existing: DocumentSnapshot,
): void {
  if (existing.exists) return;
  const config = parseRiderConfig(configRaw);
  const pay = earningFor(config, (r.serviceAreaId as string) ?? "", (r.legM as number | undefined) ?? 0, new Date());
  const { day, week } = istDayAndWeek(new Date());
  tx.create(existing.ref, {
    type: "return",
    orderId: r.orderId ?? null,
    returnId,
    amountPaise: pay.totalPaise,
    breakdown: { basePaise: pay.basePaise, distancePaise: pay.distancePaise, distanceM: pay.distanceM },
    day,
    week,
    at: FieldValue.serverTimestamp(),
  });
  tx.update(rider.ref, {
    earningsBalancePaise: FieldValue.increment(pay.totalPaise),
    earnedTotalPaise: FieldValue.increment(pay.totalPaise),
  });
}

export const earningRef = (uid: string, returnId: string) => riderRef(uid).collection("earnings").doc(`${returnId}_return`);

/** Offers a waiting return to the best free rider, or marks it unassigned for ops. */
export async function offerReturn(returnId: string, nowMs = Date.now()): Promise<void> {
  const ref = returnRef(returnId);
  const offered = await db.runTransaction(async (tx) => {
    const [snap, configSnap, customer] = await Promise.all([
      tx.get(ref),
      tx.get(db.doc(RIDER_CONFIG_DOC)),
      tx.get(customerRef(returnId)),
    ]);
    const r = snap.data();
    if (!r || !["requested", "offered"].includes(r.status as string) || r.riderId) return null;
    if ((r.dispatch as { state?: string } | undefined)?.state === "manual") return null;
    const config = parseRiderConfig(configSnap.data());
    const offer = r.offer as { riderId?: string; expiresAt?: Timestamp } | undefined;
    if (offer?.riderId && (offer.expiresAt?.toMillis() ?? 0) > nowMs) return null;
    const tried = ((r.dispatch as { tried?: string[] } | undefined)?.tried ?? []).slice();
    if (offer?.riderId && !tried.includes(offer.riderId)) tried.push(offer.riderId);
    const at = customerPoint(customer.data());
    const riders = config.dispatch.auto
      ? await tx.get(
          db
            .collection(RIDERS)
            .where("serviceAreaId", "==", r.serviceAreaId ?? "")
            .where("status", "==", "approved")
            .where("presence.online", "==", true)
            .limit(100),
        )
      : null;
    const pick =
      riders && at && tried.length < config.dispatch.maxOffers
        ? pickRider(riders.docs.map((d) => candidateFrom(d.id, d.data())), at, config.dispatch, tried, nowMs)
        : null;

    if (offer?.riderId) withdrawReturnOffer(tx, returnId, offer.riderId);
    if (!pick) {
      tx.update(ref, {
        status: "requested",
        offer: FieldValue.delete(),
        dispatch: { state: "unassigned", tried, updatedAt: FieldValue.serverTimestamp() },
        updatedAt: FieldValue.serverTimestamp(),
      });
      return null;
    }
    const expiresAt = Timestamp.fromMillis(nowMs + config.dispatch.offerSeconds * 1000);
    const legM = (r.legM as number | undefined) ?? 0;
    tx.update(ref, {
      status: "offered",
      offer: { riderId: pick.uid, expiresAt, at: FieldValue.serverTimestamp() },
      dispatch: { state: "offered", tried: [...tried, pick.uid], updatedAt: FieldValue.serverTimestamp() },
      updatedAt: FieldValue.serverTimestamp(),
    });
    tx.update(riderRef(pick.uid), { "presence.offerReturnId": returnId });
    tx.set(riderRef(pick.uid).collection(RETURN_OFFERS).doc(returnId), {
      returnId,
      orderId: r.orderId ?? null,
      expiresAt,
      pickupDistanceM: pick.distanceM,
      dropDistanceM: legM,
      customerArea: (customer.get("area") as string | undefined) ?? "",
      storeName: r.storeName ?? "Store",
      itemCount: ((r.lines as { quantity?: number }[] | undefined) ?? []).reduce((n, l) => n + (l.quantity ?? 0), 0),
      earningPaise: earningFor(config, (r.serviceAreaId as string) ?? "", legM, new Date(nowMs)).totalPaise,
      at: FieldValue.serverTimestamp(),
    });
    return { riderId: pick.uid, expiresAtMs: expiresAt.toMillis() };
  });
  if (offered) {
    const rider = await riderRef(offered.riderId).get();
    await pushToDevices(rider.ref, rider.data(), {
      data: { type: "return_offer", returnId, expiresAt: String(offered.expiresAtMs) },
      android: { priority: "high", ttl: Math.max(1000, offered.expiresAtMs - Date.now()) },
    });
  }
}

/** Accept (the return becomes theirs) or decline (next rider). */
export async function respondReturnOffer(uid: string, returnIdRaw: unknown, accept: unknown): Promise<{ ok: true }> {
  const returnId = returnIdOf(returnIdRaw);
  if (typeof accept !== "boolean") throw new HttpsError("invalid-argument", "Invalid request");
  const ref = returnRef(returnId);
  const accepted = await db.runTransaction(async (tx) => {
    const [snap, rider] = await Promise.all([tx.get(ref), tx.get(riderRef(uid))]);
    const r = snap.data();
    const offer = r?.offer as { riderId?: string; expiresAt?: Timestamp } | undefined;
    if (!r || offer?.riderId !== uid || r.riderId) {
      withdrawReturnOffer(tx, returnId, uid);
      if (accept) throw new HttpsError("failed-precondition", "OFFER_GONE");
      return null;
    }
    if (!accept || (offer.expiresAt?.toMillis() ?? 0) < Date.now() - 3000) {
      withdrawReturnOffer(tx, returnId, uid);
      tx.update(ref, { offer: FieldValue.delete(), status: "requested" });
      if (accept) throw new HttpsError("failed-precondition", "OFFER_GONE");
      return null;
    }
    if (rider.get("presence.activeOrderId") || rider.get("presence.activeReturnId")) {
      throw new HttpsError("failed-precondition", "FINISH_DELIVERY_FIRST");
    }
    tx.set(riderRef(uid), { presence: { activeReturnId: returnId, offerReturnId: null } }, { merge: true });
    tx.delete(riderRef(uid).collection(RETURN_OFFERS).doc(returnId));
    tx.update(ref, {
      status: "assigned",
      riderId: uid,
      riderName: rider.get("fullName") ?? null,
      riderPhone: rider.get("phone") ?? null,
      assignedAt: FieldValue.serverTimestamp(),
      offer: FieldValue.delete(),
      dispatch: { state: "assigned", tried: (r.dispatch as { tried?: string[] } | undefined)?.tried ?? [], updatedAt: FieldValue.serverTimestamp() },
      updatedAt: FieldValue.serverTimestamp(),
    });
    return r;
  });
  if (accepted) await tellCustomer({ ...accepted, id: accepted.issueId as string }, "riderAssigned");
  else if (!accept) await offerReturn(returnId);
  return { ok: true };
}

/** A new return: tell the store it's coming and find a rider. */
export const onReturnCreated = onDocumentCreated(`${RETURNS}/{returnId}`, async (event) => {
  const r = event.data?.data();
  if (!r) return;
  const lines = (r.lines as { quantity?: number; name?: string }[] | undefined) ?? [];
  const what = lines.map((l) => `${l.quantity ?? 1} × ${l.name ?? "item"}`).join(", ");
  await notifySeller(r.sellerId as string, r.orderId as string, "return_coming", { returnId: event.params.returnId, what });
  await offerReturn(event.params.returnId);
});

/** Every minute: expired return offers move on; unassigned returns are retried. */
export const returnsSweep = onSchedule({ schedule: "every 1 minutes", timeoutSeconds: 120 }, async () => {
  const now = Timestamp.now();
  const [expired, waiting] = await Promise.all([
    db.collection(RETURNS).where("status", "==", "offered").where("offer.expiresAt", "<=", now).limit(50).get(),
    db.collection(RETURNS).where("status", "==", "requested").where("dispatch.state", "==", "unassigned").limit(50).get(),
  ]);
  for (const r of [...expired.docs, ...waiting.docs]) {
    try {
      await offerReturn(r.id, now.toMillis());
    } catch (e) {
      logger.warn("Return offer failed", { returnId: r.id, e: String(e) });
    }
  }
});
