import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import { PRODUCTS, type Variant } from "./model";

export const INVENTORY = "inventory";
export const MOVEMENTS = "inventoryMovements";
export const STOCK_REASONS = ["restock", "count", "damage", "expired", "return", "correction"] as const;
export type StockReason = (typeof STOCK_REASONS)[number];
export const MAX_STOCK_ITEMS = 200;
export const MAX_QUANTITY = 100_000;

export interface StockItem {
  storeId: string;
  productId: string;
  variantId: string;
  /** add: change by `value` (may be negative); set: new absolute count. */
  mode: "add" | "set";
  value: number;
}

/**
 * Adjusts stock for up to 200 (store, variant) rows in one transaction and
 * records each change in inventoryMovements (who, why, before → after).
 * Stock never goes below zero. Exported for the emulator tests.
 */
export async function adjustStock(
  actor: Actor,
  input: { items?: unknown; reason?: unknown; note?: unknown },
): Promise<{ updated: number }> {
  const reason = input.reason as StockReason;
  if (!(STOCK_REASONS as readonly string[]).includes(reason)) {
    throw new HttpsError("invalid-argument", "Pick a reason");
  }
  const note = typeof input.note === "string" ? input.note.trim().slice(0, 200) : "";
  const items = Array.isArray(input.items) ? (input.items as StockItem[]) : [];
  if (items.length === 0 || items.length > MAX_STOCK_ITEMS) {
    throw new HttpsError("invalid-argument", `Send 1–${MAX_STOCK_ITEMS} rows`);
  }
  const seen = new Set<string>();
  for (const it of items) {
    const ok =
      typeof it?.storeId === "string" && it.storeId &&
      typeof it.productId === "string" && it.productId &&
      typeof it.variantId === "string" && it.variantId &&
      (it.mode === "add" || it.mode === "set") &&
      Number.isInteger(it.value) && Math.abs(it.value) <= MAX_QUANTITY &&
      (it.mode === "add" || it.value >= 0);
    if (!ok) throw new HttpsError("invalid-argument", "Invalid stock row");
    const key = `${it.storeId}_${it.variantId}`;
    if (seen.has(key)) throw new HttpsError("invalid-argument", "A variant appears twice for one store");
    seen.add(key);
  }

  return db.runTransaction(async (tx) => {
    const storeIds = [...new Set(items.map((i) => i.storeId))];
    const productIds = [...new Set(items.map((i) => i.productId))];
    const [stores, products, rows] = await Promise.all([
      tx.getAll(...storeIds.map((id) => db.collection("stores").doc(id))),
      tx.getAll(...productIds.map((id) => db.collection(PRODUCTS).doc(id))),
      tx.getAll(...items.map((i) => db.collection(INVENTORY).doc(`${i.storeId}_${i.variantId}`))),
    ]);
    const missingStore = stores.find((s) => !s.exists);
    if (missingStore) throw new HttpsError("not-found", `Store not found: ${missingStore.id}`);
    const variantsOf = new Map(
      products.map((p) => [p.id, ((p.get("variants") as Variant[]) ?? []).map((v) => v.id)]),
    );

    items.forEach((it, i) => {
      if (!variantsOf.get(it.productId)?.includes(it.variantId)) {
        throw new HttpsError("not-found", "Product or variant not found");
      }
      const before = (rows[i].get("quantity") as number | undefined) ?? 0;
      const after = it.mode === "set" ? it.value : before + it.value;
      if (after < 0) throw new HttpsError("failed-precondition", "Stock can’t go below zero");
      if (after > MAX_QUANTITY) throw new HttpsError("invalid-argument", "Quantity too large");
      tx.set(
        rows[i].ref,
        {
          storeId: it.storeId,
          variantId: it.variantId,
          productId: it.productId,
          quantity: after,
          updatedAt: FieldValue.serverTimestamp(),
        },
        { merge: true },
      );
      tx.create(db.collection(MOVEMENTS).doc(), {
        storeId: it.storeId,
        productId: it.productId,
        variantId: it.variantId,
        delta: after - before,
        before,
        after,
        reason,
        note: note || null,
        actorUid: actor.uid,
        actorEmail: actor.email,
        at: FieldValue.serverTimestamp(),
      });
    });
    writeAudit(
      actor,
      {
        action: "stock.adjust",
        target: INVENTORY,
        before: null,
        after: { reason, note: note || null, rows: items.length },
      },
      tx,
    );
    return { updated: items.length };
  });
}

/** Inventory → adjust / stock import. Request: {items: StockItem[], reason, note?}. */
export const adminAdjustStock = onCall(async (request) =>
  adjustStock(requireRole(request, ["ops", "catalog"]), request.data ?? {}),
);
