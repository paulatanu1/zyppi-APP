import { FieldValue, type Transaction } from "firebase-admin/firestore";
import { db } from "../shared/firebase";
import { inventoryIdFor } from "../marketplace/model";

/**
 * Stock held for open orders.
 *
 * inventory/{id}.quantity is what can still be sold (every reader uses it).
 * inventory/{id}.reserved is what was sold but is still on the shelf: an
 * order takes units off `quantity` and adds them to `reserved`; they leave
 * `reserved` when the rider collects them (or ops sends the order out) and
 * go back to `quantity` if the order is cancelled first. A stock count
 * ("set") is a shelf count, so it sets quantity = counted − reserved.
 * Without this, counting the shelf while orders wait for pickup counted
 * their units twice and the store oversold.
 *
 * orders/{id}.reservedStores lists the stores whose units are still held,
 * so each is released exactly once. Orders placed before this existed have
 * no list: nothing is released for them (they never reserved).
 */
export const RESERVED_STORES = "reservedStores";

interface Allocation {
  storeId: string;
  sellerId?: string | null;
  variantId: string;
  quantity: number;
}

/** Stores whose units this order still holds. */
export function reservedStoresOf(order: Record<string, unknown>): string[] {
  const v = order[RESERVED_STORES];
  return Array.isArray(v) ? v.filter((s): s is string => typeof s === "string") : [];
}

/** Units to release per inventory doc id when `stores` hand over their goods. */
export function releasePlan(order: Record<string, unknown>, stores: readonly string[]): Map<string, number> {
  const held = new Set(reservedStoresOf(order));
  const plan = new Map<string, number>();
  for (const a of (order.allocations as Allocation[] | undefined) ?? []) {
    if (!held.has(a.storeId) || !stores.includes(a.storeId)) continue;
    if (!Number.isInteger(a.quantity) || a.quantity <= 0) continue;
    const id = inventoryIdFor(a.storeId, a.sellerId, a.variantId);
    plan.set(id, (plan.get(id) ?? 0) + a.quantity);
  }
  return plan;
}

/**
 * Releases what `stores` held for this order (their goods left with the
 * rider). Writes the inventory docs; returns the new `reservedStores` for
 * the caller to put in its own order update (one write per doc).
 */
export function releaseReservation(
  tx: Transaction,
  order: Record<string, unknown>,
  stores: readonly string[],
): string[] {
  for (const [id, units] of releasePlan(order, stores)) {
    tx.update(db.collection("inventory").doc(id), { reserved: FieldValue.increment(-units) });
  }
  return reservedStoresOf(order).filter((s) => !stores.includes(s));
}

/** A shelf count of `counted` with `reserved` units waiting for pickup → sellable units. */
export function availableFromCount(counted: number, reserved: unknown): number {
  const held = typeof reserved === "number" && Number.isFinite(reserved) ? Math.max(0, reserved) : 0;
  return Math.max(0, counted - held);
}
