import { randomInt } from "node:crypto";

/**
 * Automatic returns (docs/RETURNS.md). A claim for wrong / damaged /
 * expired items that passes the automatic checks becomes one return per
 * store the items came from:
 *
 *   returns/{issueId}_{storeId}     the return (below)
 *   returns/{id}/private/pickup     {code, attempts}: the customer shows it,
 *                                   the rider types it at the door
 *   returns/{id}/private/store      {code, attempts}: the rider shows it,
 *                                   the store types it on receipt
 *
 * requested → offered → assigned → at_customer → picked_up → at_store →
 * received (refund, seller charge, stock, replacement), or
 * review (ops) / failed (customer not home twice) / cancelled.
 *
 * Every function here is pure, so the rules are unit tested.
 */

export const RETURNS = "returns";
export const RETURN_OFFERS = "returnOffers";
export const CLAIMS_CONFIG_DOC = "config/claims";

export type ReturnStatus =
  | "requested"
  | "offered"
  | "assigned"
  | "at_customer"
  | "picked_up"
  | "at_store"
  | "received"
  | "review"
  | "failed"
  | "cancelled";

/** Statuses a rider is working on. */
export const RIDER_STATUSES: ReturnStatus[] = ["assigned", "at_customer", "picked_up", "at_store"];
/** Final: nothing more happens. */
export const DONE_STATUSES: ReturnStatus[] = ["received", "review", "failed", "cancelled"];

/** After this many "customer not available" visits, the return is cancelled. */
export const MAX_PICKUP_TRIES = 2;
/** The rider must be this close to the customer / store to arrive there. */
export const CUSTOMER_GEOFENCE_M = 200;
export const MAX_RETURN_PHOTOS = 3;

export interface ClaimsConfig {
  /** Off = every claim waits for ops, as before. */
  autoReturns: boolean;
  /** Claims above this go to ops (paise). */
  autoMaxPaise: number;
  /** A customer with this many claims in 30 days (this one included) goes to ops. */
  autoMaxClaims30d: number;
}

export const DEFAULT_CLAIMS_CONFIG: ClaimsConfig = {
  autoReturns: true,
  autoMaxPaise: 50_000,
  autoMaxClaims30d: 3,
};

const num = (v: unknown, fb: number, min: number, max: number) =>
  typeof v === "number" && Number.isFinite(v) ? Math.min(max, Math.max(min, Math.round(v))) : fb;

/** Tolerant read of config/claims: anything missing keeps its default. */
export function claimsConfigFrom(raw: Record<string, unknown> | undefined): ClaimsConfig {
  const d = DEFAULT_CLAIMS_CONFIG;
  const r = raw ?? {};
  return {
    autoReturns: typeof r.autoReturns === "boolean" ? r.autoReturns : d.autoReturns,
    autoMaxPaise: num(r.autoMaxPaise, d.autoMaxPaise, 0, 10_000_000),
    autoMaxClaims30d: num(r.autoMaxClaims30d, d.autoMaxClaims30d, 1, 100),
  };
}

export type AutoDecision = { auto: true } | { auto: false; reason: string };

/**
 * Whether a new claim goes straight to a return pickup or waits for ops.
 * Missing items always wait (nothing to collect; store or rider may be at
 * fault), as do big claims and customers who claim often.
 */
export function autoReturnDecision(input: {
  kinds: string[];
  amountPaise: number;
  /** Claims in the last 30 days, this one included. */
  claims30d: number;
  config: ClaimsConfig;
}): AutoDecision {
  if (!input.config.autoReturns) return { auto: false, reason: "Automatic returns are off" };
  if (input.kinds.includes("missing")) return { auto: false, reason: "Missing items are checked by ops" };
  if (input.amountPaise > input.config.autoMaxPaise) {
    return { auto: false, reason: `Over the automatic limit of ₹${Math.round(input.config.autoMaxPaise / 100)}` };
  }
  if (input.claims30d >= input.config.autoMaxClaims30d) {
    return { auto: false, reason: `${input.claims30d} claims in 30 days` };
  }
  return { auto: true };
}

export interface ReturnLine {
  index: number;
  productId: string;
  variantId: string;
  name: string;
  unit: string;
  quantity: number;
  kind: string;
  sellerId: string;
  amountPaise: number;
}

export interface Allocation {
  storeId: string;
  productId: string;
  variantId: string;
  quantity: number;
  sellerId?: string | null;
}

/**
 * Which store each claimed unit goes back to: the stores that filled that
 * line (order.allocations), in the order they were used. Lines of older
 * orders without allocations go to [fallbackStoreId]. A line's value is
 * split by units, the last store taking the rounding.
 */
export function splitByStore(
  lines: (Omit<ReturnLine, "unit"> & { unit?: string })[],
  allocations: Allocation[],
  fallbackStoreId: string | null,
): Map<string, ReturnLine[]> {
  const out = new Map<string, ReturnLine[]>();
  const add = (storeId: string, l: ReturnLine) => {
    const list = out.get(storeId) ?? [];
    list.push(l);
    out.set(storeId, list);
  };
  // Units of each allocation already handed to an earlier line.
  const used = allocations.map(() => 0);
  for (const line of lines) {
    let left = line.quantity;
    let paiseLeft = line.amountPaise;
    const parts: { storeId: string; units: number }[] = [];
    allocations.forEach((a, i) => {
      if (left <= 0 || a.variantId !== line.variantId || a.productId !== line.productId) return;
      if ((a.sellerId ?? "zyppi") !== (line.sellerId ?? "zyppi") && a.sellerId != null) return;
      const take = Math.min(left, a.quantity - used[i]);
      if (take <= 0) return;
      used[i] += take;
      left -= take;
      parts.push({ storeId: a.storeId, units: take });
    });
    if (left > 0) {
      if (fallbackStoreId) parts.push({ storeId: fallbackStoreId, units: left });
      else if (parts.length) parts[parts.length - 1].units += left;
    }
    parts.forEach((p, i) => {
      const value = i === parts.length - 1 ? paiseLeft : Math.floor((line.amountPaise * p.units) / line.quantity);
      paiseLeft -= value;
      add(p.storeId, { ...line, unit: line.unit ?? "", quantity: p.units, amountPaise: value });
    });
  }
  return out;
}

/** A 4-digit code for the door or the store. */
export function newReturnCode(): string {
  return String(randomInt(0, 10_000)).padStart(4, "0");
}

/** What happens to returned units at the store. */
export type Restock = "shelf" | "write_off";

/**
 * The store's choice for each returned line, defaulting to write-off for
 * damaged and expired items (they can't be sold again) and back on the
 * shelf for wrong items in good condition.
 */
export function restockPlan(lines: Pick<ReturnLine, "index" | "kind">[], chosen: unknown): Record<string, Restock> {
  const c = (chosen && typeof chosen === "object" ? chosen : {}) as Record<string, unknown>;
  const out: Record<string, Restock> = {};
  for (const l of lines) {
    const v = c[String(l.index)];
    out[String(l.index)] = v === "shelf" || v === "write_off" ? v : l.kind === "wrong" ? "shelf" : "write_off";
  }
  return out;
}

/** Wrong / damaged / expired from an outside seller: their fault. Zyppi's own stock: nobody to charge. */
export function sellerAtFault(sellerId: string, lines: Pick<ReturnLine, "kind">[]): boolean {
  return sellerId !== "zyppi" && lines.length > 0 && lines.every((l) => l.kind !== "missing");
}
