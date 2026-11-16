import { randomInt } from "node:crypto";
import { type Point, distanceM, isPoint } from "./model";

/**
 * Pickup stops (docs/MARKETPLACE.md → Rider pickups): an order is filled
 * from one or more stores; each is a stop on the rider's route.
 *
 *   orders/{id}.pickups.{storeId}    the stop (below)
 *   orders/{id}.pickupOrder          storeIds in route order
 *   orders/{id}/pickupCodes/{storeId}  {code, attempts} — the assigned rider
 *                                    and staff only (never the customer)
 *
 * A marketplace seller's shop needs the seller to accept, mark it ready and
 * enter the rider's pickup code (storeConfirmPickup). Zyppi's own stores
 * keep the existing flow: ops marks the order packed, the rider taps
 * picked up (riderPickUp).
 */
export const PICKUP_CODES = "pickupCodes";

/** The rider must be this close to a seller's shop to arrive there. */
export const STORE_GEOFENCE_M = 150;

export type StopStatus = "pending" | "accepted" | "ready" | "picked" | "issue";

export interface StopItem {
  productId: string;
  variantId: string;
  name: string;
  unit: string;
  quantity: number;
}

export interface PickupStop {
  seq: number;
  storeName: string;
  /** The seller whose shop this is; null = a Zyppi store. */
  sellerId: string | null;
  address: string | null;
  lat: number | null;
  lng: number | null;
  phone: string | null;
  items: StopItem[];
  status: StopStatus;
  /** Seller's shop: accept → ready → pickup code. */
  otpRequired: boolean;
}

export interface StoreInfo {
  id: string;
  name: string;
  sellerId: string | null;
  address: string | null;
  lat: number | null;
  lng: number | null;
  phone: string | null;
}

export interface AllocationLike {
  storeId: string;
  productId: string;
  variantId: string;
  name: string;
  unit: string;
  take: number;
}

const isOutsideSeller = (sellerId: string | null | undefined) => !!sellerId && sellerId !== "zyppi";

/**
 * The cheapest order to visit `stops` and then reach `end` (brute force:
 * an order has at most a handful of stores). Stops without a location keep
 * their place at the end, in the order given.
 */
export function routeOrder<T extends { id: string; point: Point | null }>(stops: T[], end: Point | null): T[] {
  const located = stops.filter((s) => s.point);
  const rest = stops.filter((s) => !s.point);
  if (located.length <= 1 || located.length > 7) return [...located, ...rest];
  let best: T[] = located;
  let bestM = Infinity;
  const permute = (done: T[], left: T[]) => {
    if (!left.length) {
      const m = pathM([...done.map((s) => s.point!), ...(end ? [end] : [])]);
      if (m < bestM - 1e-6) [best, bestM] = [done, m];
      return;
    }
    left.forEach((s, i) => permute([...done, s], [...left.slice(0, i), ...left.slice(i + 1)]));
  };
  permute([], located);
  return [...best, ...rest];
}

/** Straight-line metres along `points` in order. */
export function pathM(points: Point[]): number {
  let m = 0;
  for (let i = 1; i < points.length; i++) m += distanceM(points[i - 1], points[i]);
  return m;
}

const pointOf = (s: { lat: number | null; lng: number | null }): Point | null =>
  isPoint({ lat: s.lat, lng: s.lng }) ? { lat: s.lat as number, lng: s.lng as number } : null;

/** One stop per store an order takes stock from, in route order. */
export function buildPickupStops(
  allocations: AllocationLike[],
  stores: Map<string, StoreInfo>,
  customer: Point | null,
): { stops: Record<string, PickupStop>; order: string[] } {
  const byStore = new Map<string, StopItem[]>();
  for (const a of allocations) {
    if (a.take <= 0) continue;
    const items = byStore.get(a.storeId) ?? [];
    const same = items.find((i) => i.variantId === a.variantId && i.productId === a.productId);
    if (same) same.quantity += a.take;
    else items.push({ productId: a.productId, variantId: a.variantId, name: a.name, unit: a.unit, quantity: a.take });
    byStore.set(a.storeId, items);
  }
  const route = routeOrder(
    [...byStore.keys()].map((id) => ({ id, point: pointOf(stores.get(id) ?? { lat: null, lng: null }) })),
    customer,
  );
  const stops: Record<string, PickupStop> = {};
  route.forEach(({ id }, i) => {
    const s = stores.get(id);
    const outside = isOutsideSeller(s?.sellerId);
    stops[id] = {
      seq: i + 1,
      storeName: s?.name ?? "Store",
      sellerId: outside ? s!.sellerId : null,
      address: s?.address ?? null,
      lat: s?.lat ?? null,
      lng: s?.lng ?? null,
      phone: s?.phone ?? null,
      items: byStore.get(id)!,
      status: "pending",
      otpRequired: outside,
    };
  });
  return { stops, order: route.map((r) => r.id) };
}

/** 4-digit code the rider shows at a seller's shop. */
export function newPickupCode(): string {
  return String(randomInt(0, 10000)).padStart(4, "0");
}

/** Sellers who have to accept / prepare the order (their shop is a stop). */
export function sellersToAccept(stops: Record<string, PickupStop>): string[] {
  return [...new Set(Object.values(stops).flatMap((s) => (s.otpRequired && s.sellerId ? [s.sellerId] : [])))];
}

type StopLike = Partial<PickupStop> & { pickedAt?: unknown; reachedAt?: unknown };

/**
 * Whether the rider may collect from this stop now: a seller's shop once
 * the seller marked it ready; a Zyppi store once ops packed the order
 * (older orders without stops: the order is packed).
 */
export function stopReady(stop: StopLike | undefined, orderStatus: string): boolean {
  if (stop?.otpRequired) return stop.status === "ready";
  return orderStatus === "packed";
}

/** Every stop collected (`done` = stores picked so far, including this one). */
export function allStopsPicked(storeIds: string[], done: Set<string>): boolean {
  return storeIds.every((s) => done.has(s));
}

/**
 * Route distance for pay: first stop → … → last stop → customer, straight
 * line (earningFor applies the road factor). Stops in `pickupOrder`; older
 * orders fall back to the first store.
 */
export function routeDistanceM(stops: StopLike[], customer: Point | null): number {
  const pts = stops.map((s) => pointOf({ lat: s.lat ?? null, lng: s.lng ?? null })).filter((p): p is Point => !!p);
  if (customer) pts.push(customer);
  return pathM(pts);
}

/** After the seller's last stop is ready, a seller-only order is packed. */
export function sellerOnlyOrderReady(stops: Record<string, StopLike>): boolean {
  const all = Object.values(stops);
  return all.length > 0 && all.every((s) => s.otpRequired && (s.status === "ready" || s.status === "picked"));
}
