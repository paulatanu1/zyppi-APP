import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { onDocumentWritten } from "firebase-functions/firestore";
import { onSchedule } from "firebase-functions/scheduler";
import { onTaskDispatched } from "firebase-functions/tasks";
import { MAX_TASK_AHEAD_MS, enqueueSafely, scheduleFor, taskId } from "../shared/tasks";
import { PRODUCTS, type Variant } from "../catalog/model";
import { db } from "../shared/firebase";
import {
  LISTINGS,
  MARKETPLACE_CONFIG_DOC,
  OFFERS,
  SELLERS,
  SELLER_PROFILES,
  ZYPPI_SELLER_ID,
  publicSellerProfile,
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
      // updatedAt lets the app's delta catalog sync pick up the new prices.
      writer.update(productRef, { ...summary, updatedAt: FieldValue.serverTimestamp() });
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
  // A special discount starts or ends later: a task at that moment.
  const next = event.data?.after?.get("nextPriceChangeAt") as Timestamp | null | undefined;
  const prev = event.data?.before?.get("nextPriceChangeAt") as Timestamp | null | undefined;
  if (next && next.toMillis() !== prev?.toMillis()) {
    const at = scheduleFor(next.toMillis());
    if (at) {
      await enqueueSafely(
        PRICE_TASK,
        { listingId: event.params.id },
        { id: taskId("price", event.params.id, next.toMillis()), scheduleTime: at },
      );
    }
  }
});

/** Only when a row runs out or comes back (offers carry in stock / out of stock). */
export const onInventoryWritten = onDocumentWritten("inventory/{id}", async (event) => {
  const had = ((event.data?.before?.get("quantity") as number | undefined) ?? 0) > 0;
  const has = ((event.data?.after?.get("quantity") as number | undefined) ?? 0) > 0;
  const id = productIdOf(event);
  if (id && had !== has) await rebuildProductOffers(id);
});

const SELLER_FIELDS = ["status", "shopName", "rating", "stats", "subscription", "model", "fulfilment", "compliance", "isOnline"];

export const onSellerWritten = onDocumentWritten({ document: `${SELLERS}/{sellerId}`, timeoutSeconds: 540 }, async (event) => {
  const b = event.data?.before?.data() ?? {};
  const a = event.data?.after?.data() ?? {};
  // The public profile customers open from "Sold by".
  const profile = publicSellerProfile(event.data?.after?.data());
  const before = publicSellerProfile(event.data?.before?.data());
  if (stable(profile) !== stable(before)) {
    const ref = db.collection(SELLER_PROFILES).doc(event.params.sellerId);
    await (profile ? ref.set({ ...profile, updatedAt: FieldValue.serverTimestamp() }) : ref.delete());
  }
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

const PRICE_TASK = "applyListingPriceChange";

/**
 * A listing's special discount starts or ends now: touch it (the listing
 * trigger rebuilds the offer and queues the next change). Does nothing
 * if it isn't due (an older task, a discount edited since).
 */
export async function applyPriceChange(listingId: string, now = new Date()): Promise<boolean> {
  const ref = db.collection(LISTINGS).doc(listingId);
  return db.runTransaction(async (tx) => {
    const d = await tx.get(ref);
    const at = d.get("nextPriceChangeAt") as Timestamp | null | undefined;
    if (!d.exists || !at || at.toMillis() > now.getTime() + 5_000) return false;
    const next = nextPriceChangeAt(readListing(d.id, d.data()!).specialDiscount, now);
    tx.update(ref, {
      nextPriceChangeAt: next ? Timestamp.fromDate(next) : null,
      priceRefreshedAt: FieldValue.serverTimestamp(),
    });
    return true;
  });
}

/** Queued by onListingWritten for the moment a discount starts or ends. */
export const applyListingPriceChange = onTaskDispatched<{ listingId: string }>(
  { retryConfig: { maxAttempts: 5, minBackoffSeconds: 30 }, rateLimits: { maxConcurrentDispatches: 10 } },
  async (req) => {
    const id = req.data?.listingId;
    if (typeof id === "string" && id && !id.includes("/")) await applyPriceChange(id);
  },
);

/**
 * Hourly safety net, not the timer (applyListingPriceChange is): listings
 * whose task never ran, and changes more than 30 days ahead that are now
 * inside the Cloud Tasks window.
 */
export const refreshTimedOffers = onSchedule(
  { schedule: "every 60 minutes", timeZone: "Asia/Kolkata" },
  async () => {
    const due = await db
      .collection(LISTINGS)
      .where("nextPriceChangeAt", "<=", Timestamp.fromMillis(Date.now() - 5 * 60_000))
      .limit(500)
      .get();
    for (const d of due.docs) await applyPriceChange(d.id);
    const soon = await db
      .collection(LISTINGS)
      .where("nextPriceChangeAt", ">", Timestamp.now())
      .where("nextPriceChangeAt", "<=", Timestamp.fromMillis(Date.now() + MAX_TASK_AHEAD_MS))
      .limit(500)
      .get();
    // Re-queueing is harmless: the id is fixed per listing and change time.
    for (const d of soon.docs) {
      const at = (d.get("nextPriceChangeAt") as Timestamp).toMillis();
      if (at > Date.now() + MAX_TASK_AHEAD_MS - 2 * 3_600_000) {
        await enqueueSafely(PRICE_TASK, { listingId: d.id }, { id: taskId("price", d.id, at), scheduleTime: new Date(at) });
      }
    }
  },
);
