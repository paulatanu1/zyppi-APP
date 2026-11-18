import { cashToCollect } from "../wallet/model";
/**
 * Report counters, written only by the `onOrderWritten` trigger (and the
 * `backfill-stats` script), read by the admin dashboard and reports so they
 * never scan `orders`.
 *
 *   stats/daily/days/{yyyy-mm-dd}         every order, by the day it was placed
 *   stats/areas/days/{areaId}_{yyyy-mm-dd} the same, per service area
 *
 * Days are India time (UTC+5:30). An order counts on the day it was placed
 * for its whole life: cancelling or delivering it later changes that day's
 * counters, not today's.
 *
 * Each order "contributes" a tree of numbers (see [orderContribution]); a
 * write applies `after − before` as increments, so counters stay exact
 * however often an order changes.
 */

export const STATS = "stats";
export const DAYS = "days";
export const DAILY = "daily";
export const AREAS = "areas";
/** Event ids already applied (triggers can fire twice). */
export const EVENTS = "events";

const IST_OFFSET_MS = (5 * 60 + 30) * 60_000;

/** Nested numbers; leaves are counts or paise. */
export interface Tree {
  [key: string]: number | Tree;
}

/** Nested display names (product and rider names) kept next to the counts. */
export interface Labels {
  [key: string]: string | Labels;
}

export interface Contribution {
  /** yyyy-mm-dd, India time. */
  day: string;
  areaId: string | null;
  counts: Tree;
  labels: Labels;
}

const COD = "Cash on delivery";

/** "Cash on delivery" → cod, "UPI" → upi, cards → card. */
export function methodKey(method: unknown): string {
  if (method === COD) return "cod";
  if (method === "UPI") return "upi";
  if (method === "Credit or debit card") return "card";
  if (method === "Wallet") return "wallet";
  if (method === "Replacement") return "replacement";
  return "other";
}

/** India-time calendar day and hour for an instant. */
export function istParts(ms: number): { day: string; hour: string } {
  const d = new Date(ms + IST_OFFSET_MS);
  const day = d.toISOString().slice(0, 10);
  const hour = String(d.getUTCHours()).padStart(2, "0");
  return { day, hour };
}

function millis(v: unknown): number | null {
  if (v && typeof (v as { toMillis?: unknown }).toMillis === "function") {
    return (v as { toMillis: () => number }).toMillis();
  }
  return null;
}

function int(v: unknown): number {
  return typeof v === "number" && Number.isFinite(v) ? Math.round(v) : 0;
}

/** Firestore map keys can't be empty; dots are fine in nested-object writes. */
function key(v: unknown): string | null {
  return typeof v === "string" && v.trim() !== "" ? v.trim() : null;
}

/**
 * What one order adds to its day's counters, or null when it can't be
 * counted (no placedAt yet, or no data).
 */
export function orderContribution(order: Record<string, unknown> | undefined): Contribution | null {
  if (!order) return null;
  const placedMs = millis(order.placedAt);
  if (placedMs == null) return null;
  const { day, hour } = istParts(placedMs);
  const status = order.status as string | undefined;
  const total = int(order.totalPaise);
  const counts: Tree = { placed: 1 };
  const labels: Labels = {};

  const refunded = int(order.refundedPaise);
  if (refunded) counts.refundedPaise = refunded;

  if (status === "cancelled") {
    counts.cancelled = 1;
    counts.cancelledPaise = total;
    return { day, areaId: key(order.serviceAreaId), counts, labels };
  }

  counts.orders = 1;
  counts.gmvPaise = total;
  counts.itemPaise = int(order.itemTotalPaise);
  counts.discountPaise = int(order.discountPaise);
  counts.deliveryFeePaise = int(order.deliveryFeePaise);
  counts.handlingFeePaise = int(order.handlingFeePaise);
  counts.tipPaise = int(order.tipPaise);
  // Marketplace (Phase 7): what sellers are owed for their items and what
  // Zyppi keeps of the item value (its own stock + add-ons + supply margin).
  if (order.payoutTotalPaise != null || order.marginTotalPaise != null) {
    counts.payoutPaise = int(order.payoutTotalPaise);
    counts.marginPaise = int(order.marginTotalPaise);
  }
  if (status === "delivered") counts.delivered = 1;

  // New vs repeat: customerOrderNo is set at checkout (orders from before
  // it existed are left out of both).
  const n = int(order.customerOrderNo);
  if (n === 1) counts.newCustomers = 1;
  else if (n > 1) counts.repeatOrders = 1;

  const method = methodKey((order.payment as { method?: unknown } | undefined)?.method ?? order.paymentMethod);
  counts.byMethod = { [method]: { orders: 1, paise: total } };
  counts.byHour = { [hour]: 1 };

  const products: Tree = {};
  const names: Labels = {};
  for (const raw of Array.isArray(order.items) ? order.items : []) {
    const item = raw as Record<string, unknown>;
    const id = key(item.productId);
    if (!id) continue;
    const qty = int(item.quantity);
    const prev = (products[id] as Tree | undefined) ?? { qty: 0, paise: 0 };
    products[id] = {
      qty: (prev.qty as number) + qty,
      paise: (prev.paise as number) + qty * int(item.pricePaise),
    };
    if (typeof item.name === "string") names[id] = item.name;
  }
  if (Object.keys(products).length) counts.products = products;
  if (Object.keys(names).length) labels.products = names;

  const coupon = key(order.couponCode);
  if (coupon) counts.coupons = { [coupon]: { uses: 1, discountPaise: int(order.discountPaise) } };

  const rider = key(order.riderId);
  if (rider && status === "delivered") {
    const deliveredMs = millis(order.deliveredAt);
    const eta = int(order.etaMinutes) || 30;
    const onTime = deliveredMs != null && deliveredMs - placedMs <= eta * 60_000 ? 1 : 0;
    counts.riders = {
      // Cash taken at the door (the wallet may have paid part of it).
      [rider]: { delivered: 1, onTime, codPaise: method === "cod" ? cashToCollect(order) : 0 },
    };
    if (typeof order.riderName === "string") labels.riders = { [rider]: order.riderName };
  }

  return { day, areaId: key(order.serviceAreaId), counts, labels };
}

/** a + sign·b, leaf by leaf. */
export function addInto(a: Tree, b: Tree, sign: 1 | -1): Tree {
  for (const [k, v] of Object.entries(b)) {
    if (typeof v === "number") {
      a[k] = ((a[k] as number | undefined) ?? 0) + sign * v;
    } else {
      const sub = (a[k] as Tree | undefined) ?? {};
      a[k] = addInto(typeof sub === "number" ? {} : sub, v, sign);
    }
  }
  return a;
}

/** Drops zero leaves and empty branches; null when nothing is left. */
export function prune(t: Tree): Tree | null {
  const out: Tree = {};
  for (const [k, v] of Object.entries(t)) {
    if (typeof v === "number") {
      if (v !== 0) out[k] = v;
    } else {
      const sub = prune(v);
      if (sub) out[k] = sub;
    }
  }
  return Object.keys(out).length ? out : null;
}

export interface StatsDelta {
  /** Path under `stats`, e.g. "daily/days/2026-11-15". */
  path: string;
  day: string;
  areaId: string | null;
  counts: Tree;
  labels: Labels;
}

export function dailyPath(day: string): string {
  return `${DAILY}/${DAYS}/${day}`;
}

export function areaPath(areaId: string, day: string): string {
  return `${AREAS}/${DAYS}/${areaId}_${day}`;
}

/**
 * The increments one order write makes, per stats document. Empty when the
 * write doesn't change anything counted (e.g. only `updatedAt`).
 */
export function statsDeltas(
  before: Record<string, unknown> | undefined,
  after: Record<string, unknown> | undefined,
): StatsDelta[] {
  const docs = new Map<string, StatsDelta>();
  const apply = (c: Contribution | null, sign: 1 | -1) => {
    if (!c) return;
    const targets: [string, string | null][] = [[dailyPath(c.day), null]];
    if (c.areaId) targets.push([areaPath(c.areaId, c.day), c.areaId]);
    for (const [path, areaId] of targets) {
      const d = docs.get(path) ?? { path, day: c.day, areaId, counts: {}, labels: {} };
      addInto(d.counts, c.counts, sign);
      if (sign === 1) d.labels = c.labels;
      docs.set(path, d);
    }
  };
  apply(orderContribution(before), -1);
  apply(orderContribution(after), 1);

  const out: StatsDelta[] = [];
  for (const d of docs.values()) {
    const counts = prune(d.counts);
    if (counts) out.push({ ...d, counts });
  }
  return out;
}

/** Sums contributions into whole documents (backfill). */
export function rebuild(orders: Record<string, unknown>[]): Map<string, StatsDelta> {
  const docs = new Map<string, StatsDelta>();
  for (const o of orders) {
    for (const d of statsDeltas(undefined, o)) {
      const cur = docs.get(d.path);
      if (!cur) {
        docs.set(d.path, { ...d, counts: addInto({}, d.counts, 1), labels: mergeLabels({}, d.labels) });
      } else {
        addInto(cur.counts, d.counts, 1);
        mergeLabels(cur.labels, d.labels);
      }
    }
  }
  for (const d of docs.values()) d.counts = prune(d.counts) ?? {};
  return docs;
}

export function mergeLabels(a: Labels, b: Labels): Labels {
  for (const [k, v] of Object.entries(b)) {
    if (typeof v === "string") a[k] = v;
    else a[k] = mergeLabels(typeof a[k] === "object" ? (a[k] as Labels) : {}, v);
  }
  return a;
}
