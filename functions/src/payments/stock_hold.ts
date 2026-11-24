import { FieldValue, type DocumentReference, type Transaction } from "firebase-admin/firestore";
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

/**
 * Takes the quote's units off sale for this payment (writes only; the quote
 * did the reads). `priorHeld`: units the customer's earlier open intents
 * held (see readPriorHolds), already counted in each allocation's `current`
 * and already in `reserved`, so they move to this payment rather than being
 * reserved twice; whatever this quote doesn't take goes back on sale.
 */
export function writeStockHold(
  tx: Transaction,
  quote: Pick<Quote, "lines">,
  priorHeld: ReadonlyMap<string, number> = new Map(),
): HeldRow[] {
  const taken = new Set<string>();
  for (const line of quote.lines) {
    for (const a of line.allocations) {
      const wasHeld = taken.has(a.ref.path) ? 0 : (priorHeld.get(a.ref.path) ?? 0);
      taken.add(a.ref.path);
      tx.update(a.ref, {
        quantity: a.current - a.take,
        reserved: FieldValue.increment(a.take - wasHeld),
        updatedAt: FieldValue.serverTimestamp(),
      });
    }
  }
  for (const [path, units] of priorHeld) {
    if (taken.has(path) || units <= 0) continue;
    tx.update(db.doc(path), {
      quantity: FieldValue.increment(units),
      reserved: FieldValue.increment(-units),
      updatedAt: FieldValue.serverTimestamp(),
    });
  }
  return holdRowsFrom(quote);
}

/** How many of a customer's latest open intents a new checkout looks at. */
export const PRIOR_INTENTS_LIMIT = 5;

export interface PriorHolds {
  /** Open intents whose stock hold moves to the new payment. */
  refs: DocumentReference[];
  /** Their held units by inventory path. */
  held: Map<string, number>;
}

/**
 * One stock hold per customer (audit OPT-03): the customer's latest open
 * intents that still hold stock. A new checkout takes their units over
 * (quoteOrder counts them as available, writeStockHold moves them), so
 * retrying checkout can't lock up more than one cart. Read inside the
 * new intent's transaction, before any write.
 */
export async function readPriorHolds(tx: Transaction, uid: string): Promise<PriorHolds> {
  const snap = await tx.get(
    db
      .collection("paymentIntents")
      .where("userId", "==", uid)
      .where("status", "==", "created")
      .orderBy("createdAt", "desc")
      .limit(PRIOR_INTENTS_LIMIT),
  );
  const refs: DocumentReference[] = [];
  const held = new Map<string, number>();
  for (const doc of snap.docs) {
    if (doc.get("orderId")) continue;
    const units = heldUnitsOf(doc.data());
    if (!units.size) continue;
    refs.push(doc.ref);
    for (const [path, n] of units) held.set(path, (held.get(path) ?? 0) + n);
  }
  return { refs, held };
}

/**
 * Marks the earlier intents' holds as moved to [txnid]. Only the stock
 * hold: each intent stays `created` (PayU can still capture it; that order
 * is then placed from live stock or goes to review, as after the
 * reconciler releases a hold) and keeps its wallet reservation.
 */
export function clearPriorHolds(tx: Transaction, prior: PriorHolds, txnid: string): void {
  for (const ref of prior.refs) {
    tx.update(ref, {
      stockHold: [],
      stockReleasedAt: FieldValue.serverTimestamp(),
      stockReleasedFor: txnid,
      updatedAt: FieldValue.serverTimestamp(),
    });
  }
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
