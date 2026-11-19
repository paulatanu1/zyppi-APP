import { type DocumentReference, type DocumentSnapshot, FieldValue, type Transaction } from "firebase-admin/firestore";
import { db } from "../shared/firebase";
import {
  type OrderEarning,
  type Point,
  RIDER_CONFIG_DOC,
  type RiderConfig,
  distanceM,
  earningFor,
  isPoint,
  parseRiderConfig,
} from "./model";
import { type PickupStop, routeDistanceM } from "./pickups";

export const EARNINGS = "earnings";

/** yyyy-mm-dd India time, and the Monday of that week. */
export function istDayAndWeek(at: Date): { day: string; week: string } {
  const ist = new Date(at.getTime() + 330 * 60_000);
  const day = ist.toISOString().slice(0, 10);
  const dow = (ist.getUTCDay() + 6) % 7; // Monday = 0
  const week = new Date(ist.getTime() - dow * 86_400_000).toISOString().slice(0, 10);
  return { day, week };
}

/** An order's pickup stops in route order (none on older orders). */
export function orderStops(order: Record<string, unknown>): (Partial<PickupStop> & { storeId: string })[] {
  const pickups = (order.pickups ?? {}) as Record<string, Partial<PickupStop>>;
  const ids = Array.isArray(order.pickupOrder) ? (order.pickupOrder as string[]) : [];
  return ids.filter((id) => pickups[id]).map((id) => ({ ...pickups[id], storeId: id }));
}

/** Where an order was picked up: its first store, else its area's centre. */
export async function pickupPoint(tx: Transaction, order: Record<string, unknown>): Promise<Point | null> {
  const allocations = (order.allocations as { storeId?: string }[] | undefined) ?? [];
  const storeId = allocations[0]?.storeId;
  if (storeId) {
    const store = await tx.get(db.collection("stores").doc(storeId));
    const p = { lat: store.get("lat"), lng: store.get("lng") };
    if (isPoint(p)) return p;
  }
  const areaId = order.serviceAreaId as string | undefined;
  if (!areaId) return null;
  const area = await tx.get(db.collection("serviceAreas").doc(areaId));
  const p = { lat: area.get("centerLat"), lng: area.get("centerLng") };
  return isPoint(p) ? p : null;
}

/**
 * The rider's pay for this order's trip (rate card on the whole route +
 * peak + surge + extra stops), and the rider config. Reads only.
 */
export async function tripPay(
  tx: Transaction,
  order: Record<string, unknown>,
): Promise<{ pay: OrderEarning; config: RiderConfig }> {
  const configSnap = await tx.get(db.doc(RIDER_CONFIG_DOC));
  const config = parseRiderConfig(configSnap.data());
  const address = order.address as Partial<Point> | null | undefined;
  const to = address && isPoint({ lat: address.lat, lng: address.lng }) ? (address as Point) : null;
  // Marketplace orders: the whole route (every pickup stop → customer).
  const stops = orderStops(order);
  let straight = 0;
  if (stops.length) {
    straight = routeDistanceM(stops, to);
  } else {
    const from = await pickupPoint(tx, order);
    straight = from && to ? distanceM(from, to) : 0;
  }
  const pay = earningFor(config, (order.serviceAreaId as string) ?? "", straight, new Date(), Math.max(0, stops.length - 1));
  return { pay, config };
}

/** True once any of the order's goods left a store with the rider. */
export function goodsLeftStore(order: Record<string, unknown>): boolean {
  if (order.status === "out_for_delivery") return true;
  const stage = order.riderStage as string | undefined;
  if (stage === "picked_up" || stage === "at_customer" || stage === "returning") return true;
  const pickups = (order.pickups ?? {}) as Record<string, { pickedAt?: unknown } | undefined>;
  return Object.values(pickups).some((p) => !!p?.pickedAt);
}

/** What a cancelled trip pays: `percent` of the trip's pay (no tip). */
export function cancelledTripPaise(tripTotalPaise: number, percent: number): number {
  return Math.round((Math.max(0, tripTotalPaise) * Math.min(100, Math.max(0, percent))) / 100);
}

/**
 * The order was cancelled after the rider collected it (customer
 * unreachable, refused, ops cancelled on the way): the rider still made
 * the trip and is paid `config.cancelledTripPercent` of it, as a "trip" row
 * (not "order": it doesn't count towards delivery incentives). Reads now;
 * call the returned `apply` once the transaction's writes begin.
 * Deterministic id, so a repeat writes the same row.
 */
export async function prepareCancelledTrip(
  tx: Transaction,
  orderRef: DocumentReference,
  order: Record<string, unknown>,
  riderId: string,
): Promise<(() => number) | null> {
  if (!goodsLeftStore(order)) return null;
  const riderRef = db.collection("riders").doc(riderId);
  const [{ pay, config }, row] = await Promise.all([tripPay(tx, order), tx.get(riderRef.collection(EARNINGS).doc(`${orderRef.id}_trip`))]);
  if (row.exists) return null;
  const amount = cancelledTripPaise(pay.totalPaise, config.cancelledTripPercent);
  if (amount <= 0) return null;
  return () => {
    const { day, week } = istDayAndWeek(new Date());
    tx.set(riderRef.collection(EARNINGS).doc(`${orderRef.id}_trip`), {
      type: "trip",
      orderId: orderRef.id,
      amountPaise: amount,
      kind: "cancelled_after_pickup",
      // Shown in the rider app's Pocket.
      reason: "Trip paid: order cancelled after pickup",
      breakdown: { tripPaise: pay.totalPaise, percent: config.cancelledTripPercent, distanceM: pay.distanceM },
      day,
      week,
      at: FieldValue.serverTimestamp(),
    });
    tx.set(
      riderRef,
      { earningsBalancePaise: FieldValue.increment(amount), earnedTotalPaise: FieldValue.increment(amount) },
      { merge: true },
    );
    return amount;
  };
}

/**
 * Credits the rider for a delivery: order pay (rate card + peak + surge)
 * and the customer's tip, as ledger rows in riders/{uid}/earnings, and
 * stamps the order with what the rider earned. Reads first, then writes;
 * returns the fields to add to the rider's update.
 */
export async function deliveryEarning(
  tx: Transaction,
  orderRef: DocumentReference,
  order: Record<string, unknown>,
  rider: DocumentSnapshot,
): Promise<Record<string, unknown>> {
  const { pay } = await tripPay(tx, order);
  const now = new Date();
  const tip = Math.max(0, Math.round((order.tipPaise as number | undefined) ?? 0));
  const { day, week } = istDayAndWeek(now);
  const ledger = rider.ref.collection(EARNINGS);
  const at = FieldValue.serverTimestamp();

  tx.set(ledger.doc(`${orderRef.id}_order`), {
    type: "order",
    orderId: orderRef.id,
    amountPaise: pay.totalPaise,
    breakdown: {
      basePaise: pay.basePaise,
      distancePaise: pay.distancePaise,
      peakPaise: pay.peakPaise,
      surgePaise: pay.surgePaise,
      pickupPaise: pay.pickupPaise,
      distanceM: pay.distanceM,
    },
    day,
    week,
    at,
  });
  if (tip > 0) {
    tx.set(ledger.doc(`${orderRef.id}_tip`), { type: "tip", orderId: orderRef.id, amountPaise: tip, day, week, at });
  }
  tx.update(orderRef, { riderEarning: { totalPaise: pay.totalPaise, tipPaise: tip, distanceM: pay.distanceM } });
  const total = pay.totalPaise + tip;
  return {
    earningsBalancePaise: FieldValue.increment(total),
    earnedTotalPaise: FieldValue.increment(total),
  };
}
