import { FieldValue, type Transaction } from "firebase-admin/firestore";
import { db } from "../shared/firebase";
import type { Quote } from "../orders/quote";

/**
 * Stock held while the customer pays online.
 *
 * createPayUOrder takes the quoted units off inventory `quantity` (into
 * `reserved`, see catalog/reservations.ts) and records them on the intent
 * (`stockHold`). Placing the paid order counts them as available again for
 * that order only, so another customer can't buy the last unit while this
 * one is on the PayU screen. Failed, expired or abandoned payments give the
 * units back; the reconciler releases holds older than STOCK_HOLD_MS (a
 * capture after that still places the order if stock allows, or goes to
 * review as before).
 */
export const STOCK_HOLD_MS = 15 * 60 * 1000;

export interface HeldRow {
  /** inventory/{id} */
  path: string;
  units: number;
}

/** Units per inventory doc the quote would take. */
export function holdRowsFrom(quote: Pick<Quote, "lines">): HeldRow[] {
  const byPath = new Map<string, number>();
  for (const line of quote.lines) {
    for (const a of line.allocations) {
      byPath.set(a.ref.path, (byPath.get(a.ref.path) ?? 0) + a.take);
    }
  }
  return [...byPath].map(([path, units]) => ({ path, units }));
}

/** Takes the quote's units off sale for this payment (writes only; the quote did the reads). */
export function writeStockHold(tx: Transaction, quote: Pick<Quote, "lines">): HeldRow[] {
  for (const line of quote.lines) {
    for (const a of line.allocations) {
      tx.update(a.ref, {
        quantity: a.current - a.take,
        reserved: FieldValue.increment(a.take),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  }
  return holdRowsFrom(quote);
}

/** The intent's held units by inventory path (empty when none or released). */
export function heldUnitsOf(intent: Record<string, unknown> | undefined): Map<string, number> {
  const rows = Array.isArray(intent?.stockHold) ? (intent!.stockHold as unknown[]) : [];
  const out = new Map<string, number>();
  for (const r of rows) {
    const row = r as Partial<HeldRow>;
    if (typeof row?.path !== "string" || !row.path.startsWith("inventory/")) continue;
    if (!Number.isInteger(row.units) || (row.units as number) <= 0) continue;
    out.set(row.path, (out.get(row.path) ?? 0) + (row.units as number));
  }
  return out;
}

/**
 * Puts an intent's held units back on sale. Writes the inventory docs and
 * returns the fields the caller adds to its own intent update (so the hold
 * is released once). No hold: returns {}.
 */
export function releaseStockHold(tx: Transaction, intent: Record<string, unknown> | undefined): Record<string, unknown> {
  const held = heldUnitsOf(intent);
  if (!held.size) return {};
  for (const [path, units] of held) {
    tx.update(db.doc(path), {
      quantity: FieldValue.increment(units),
      reserved: FieldValue.increment(-units),
      updatedAt: FieldValue.serverTimestamp(),
    });
  }
  return { stockHold: [], stockReleasedAt: FieldValue.serverTimestamp() };
}
