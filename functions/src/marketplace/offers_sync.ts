import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/firestore";
import { onSchedule } from "firebase-functions/scheduler";
import { PRODUCTS, type Variant } from "../catalog/model";
import { db } from "../shared/firebase";
import {
  LISTINGS,
  MARKETPLACE_CONFIG_DOC,
  OFFERS,
  SELLERS,
  ZYPPI_SELLER_ID,
} from "./model";
import {
  type BuiltOffers,
  type ListingLite,
  type StoreLite,
  buildOffers,
  readListing,
  readSellerLite,
  stockIdsNeeded,
} from "./offers";
import { nextPriceChangeAt } from "./pricing";
import { marketplaceConfigFrom } from "./ranking";

/**
 * Keeps offers/{id} and products/{id}.{areaBest, rank} in step with
 * listings, stock, sellers, stores and the product (docs/MARKETPLACE.md).
 * Everything is rebuilt per product and only what changed is written, so
 * the product trigger (which this also fires) settles at once.
 */

/** Stable JSON (sorted keys) for change detection. */
function stable(v: unknown): string {
  if (Array.isArray(v)) return `[${v.map(stable).join(",")}]`;
  if (v && typeof v === "object" && !(v instanceof Timestamp)) {
    return `{${Object.keys(v as object)
      .filter((k) => k !== "updatedAt")
      .sort()
      .map((k) => `${JSON.stringify(k)}:${stable((v as Record<string, unknown>)[k])}`)
      .join(",")}}`;
  }
  return JSON.stringify(v ?? null);
}

/** Rebuilds one product's offers. Returns how many offer docs changed. */
export async function rebuildProductOffers(productId: string, now = new Date()): Promise<number> {
  const productRef = db.collection(PRODUCTS).doc(productId);
  const [product, areas, stores, listingsSnap, existing, cfgSnap] = await Promise.all([
    productRef.get(),
    db.collection("serviceAreas").get(),
    db.collection("stores").get(),
    db.collection(LISTINGS).where("productId", "==", productId).get(),
    db.collection(OFFERS).where("productId", "==", productId).get(),
    db.doc(MARKETPLACE_CONFIG_DOC).get(),
  ]);

  let built: BuiltOffers = { offers: [], areaBest: {}, rank: {} };
  if (product.exists) {
    const variants = ((product.get("variants") as Variant[] | undefined) ?? []).filter((v) => v?.id);
    const storeLites: StoreLite[] = stores.docs.map((s) => ({
      id: s.id,
      serviceAreaId: String(s.get("serviceAreaId") ?? ""),
      isActive: s.get("isActive") === true,
      sellerId: (s.get("sellerId") as string | undefined) ?? null,
    }));
    const activeAreaIds = areas.docs.filter((a) => a.get("isActive") === true).map((a) => a.id);
    const listings: ListingLite[] = listingsSnap.docs.map((d) => readListing(d.id, d.data()));
    const sellerIds = [...new Set([ZYPPI_SELLER_ID, ...listings.map((l) => l.sellerId)])];
    const sellerSnaps = await db.getAll(...sellerIds.map((id) => db.collection(SELLERS).doc(id)));
    const sellers = new Map(
      sellerSnaps.flatMap((s) => {
        const lite = readSellerLite(s.data());
        return lite ? [[s.id, lite] as const] : [];
      }),
    );
    const stockIds = stockIdsNeeded({ variants }, storeLites, activeAreaIds, listings);
    const stockSnaps = stockIds.length ? await db.getAll(...stockIds.map((id) => db.collection("inventory").doc(id))) : [];
    const stock = new Map(stockSnaps.map((s) => [s.id, (s.get("quantity") as number | undefined) ?? 0]));
    built = buildOffers({
      product: { id: productId, isActive: product.get("isActive") === true, variants },
      activeAreaIds,
      stores: storeLites,
      listings,
      sellers,
      stock,
      now,
      cfg: marketplaceConfigFrom(cfgSnap.data()),
    });
  }

  const writer = db.bulkWriter();
  let changed = 0;
  const keep = new Set(built.offers.map((o) => o.id));
  const before = new Map(existing.docs.map((d) => [d.id, d.data()]));
  for (const offer of built.offers) {
    const { id, ...data } = offer;
    if (stable(before.get(id)) === stable(data)) continue;
    changed++;
    writer.set(db.collection(OFFERS).doc(id), { ...data, updatedAt: FieldValue.serverTimestamp() });
  }
  for (const id of before.keys()) {
    if (keep.has(id)) continue;
    changed++;
    writer.delete(db.collection(OFFERS).doc(id));
  }
  if (product.exists) {
    const summary = { areaBest: built.areaBest, rank: built.rank };
    if (stable({ areaBest: product.get("areaBest") ?? {}, rank: product.get("rank") ?? {} }) !== stable(summary)) {
      // update() replaces each map whole (stale areas disappear).
      writer.update(productRef, summary);
    }
  }
  await writer.close();
  return changed;
}

/** Every product (store or Zyppi-wide changes), a few at a time. */
export async function rebuildAllOffers(now = new Date()): Promise<{ products: number; changed: number }> {
  const ids = (await db.collection(PRODUCTS).select().get()).docs.map((d) => d.id);
  let changed = 0;
  for (let i = 0; i < ids.length; i += 5) {
    const counts = await Promise.all(ids.slice(i, i + 5).map((id) => rebuildProductOffers(id, now)));
    changed += counts.reduce((a, b) => a + b, 0);
  }
  return { products: ids.length, changed };
}

async function rebuildSellerProducts(sellerId: string): Promise<void> {
  if (sellerId === ZYPPI_SELLER_ID) {
    await rebuildAllOffers();
    return;
  }
  const listings = await db.collection(LISTINGS).where("sellerId", "==", sellerId).select("productId").get();
  const ids = [...new Set(listings.docs.map((d) => d.get("productId") as string))];
  for (let i = 0; i < ids.length; i += 5) await Promise.all(ids.slice(i, i + 5).map((id) => rebuildProductOffers(id)));
}

const productIdOf = (e: { data?: { before?: { get(f: string): unknown }; after?: { get(f: string): unknown } } }) =>
  (e.data?.after?.get("productId") ?? e.data?.before?.get("productId")) as string | undefined;

export const onListingWritten = onDocumentWritten(`${LISTINGS}/{id}`, async (event) => {
  const id = productIdOf(event);
  if (id) await rebuildProductOffers(id);
});

/** Only when a row runs out or comes back (offers carry in stock / out of stock). */
export const onInventoryWritten = onDocumentWritten("inventory/{id}", async (event) => {
  const had = ((event.data?.before?.get("quantity") as number | undefined) ?? 0) > 0;
  const has = ((event.data?.after?.get("quantity") as number | undefined) ?? 0) > 0;
  const id = productIdOf(event);
  if (id && had !== has) await rebuildProductOffers(id);
});

const SELLER_FIELDS = ["status", "shopName", "rating", "stats", "subscription", "model", "fulfilment"];

export const onSellerWritten = onDocumentWritten({ document: `${SELLERS}/{sellerId}`, timeoutSeconds: 540 }, async (event) => {
  const b = event.data?.before?.data() ?? {};
  const a = event.data?.after?.data() ?? {};
  // Zyppi's rating / stats move with every order; rebuilding the whole
  // catalogue for that isn't worth it (other triggers pick it up).
  const fields = event.params.sellerId === ZYPPI_SELLER_ID ? ["status", "shopName"] : SELLER_FIELDS;
  if (fields.every((f) => stable(b[f]) === stable(a[f]))) return;
  await rebuildSellerProducts(event.params.sellerId);
});

const STORE_FIELDS = ["isActive", "sellerId", "serviceAreaId"];

export const onStoreWritten = onDocumentWritten({ document: "stores/{storeId}", timeoutSeconds: 540 }, async (event) => {
  const b = event.data?.before?.data() ?? {};
  const a = event.data?.after?.data() ?? {};
  if (STORE_FIELDS.every((f) => stable(b[f]) === stable(a[f]))) return;
  const sellerId = (a.sellerId ?? b.sellerId) as string | undefined;
  // A seller's shop only affects that seller's offers; a Zyppi store, every product.
  if (sellerId && sellerId !== ZYPPI_SELLER_ID) await rebuildSellerProducts(sellerId);
  else await rebuildAllOffers();
});

/**
 * Special discounts start and end on their own: every 15 minutes, touch
 * the listings whose price changes now (the listing trigger rebuilds the
 * offer) and set when they next change.
 */
export const refreshTimedOffers = onSchedule(
  { schedule: "every 15 minutes", timeZone: "Asia/Kolkata" },
  async () => {
    const now = new Date();
    const due = await db.collection(LISTINGS).where("nextPriceChangeAt", "<=", Timestamp.fromDate(now)).limit(500).get();
    const writer = db.bulkWriter();
    for (const d of due.docs) {
      const next = nextPriceChangeAt(readListing(d.id, d.data()).specialDiscount, now);
      writer.update(d.ref, {
        nextPriceChangeAt: next ? Timestamp.fromDate(next) : null,
        priceRefreshedAt: FieldValue.serverTimestamp(),
      });
    }
    await writer.close();
  },
);
