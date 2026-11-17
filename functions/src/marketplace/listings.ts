import { FieldValue, Timestamp, type Transaction } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { PRODUCTS, type Variant } from "../catalog/model";
import { adjustStock } from "../catalog/inventory";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import {
  LISTINGS,
  SELLERS,
  SELLER_PLANS,
  ZYPPI_SELLER_ID,
  listingIdFor,
} from "./model";
import { listingPriceInput, readListing } from "./offers";
import {
  type ListingModel,
  type ListingPrice,
  PricingError,
  nextPriceChangeAt,
  pricingProblems,
  priceListing,
  readAdjustment,
  readSpecialDiscount,
} from "./pricing";
import { requireSeller, sellerStoreId } from "./sellers";

/**
 * Listings: one per (seller, area, variant), holding the money fields
 * (docs/MARKETPLACE.md → Pricing rules). Sellers set their own price,
 * special discount and on/off; Zyppi staff set the add-on (subscription),
 * the supply and selling prices (supply) and can override anything.
 * The listing trigger turns them into public offers.
 */

/** What a save may change; absent = keep the current value. */
export interface ListingChange {
  sellerPricePaise?: number;
  zyppiPricePaise?: number | null;
  addon?: ReturnType<typeof readAdjustment>;
  specialDiscount?: ReturnType<typeof readSpecialDiscount>;
  allowNegativeMargin?: boolean;
  isActive?: boolean;
}

const MONEY_KEYS = ["sellerPricePaise", "zyppiPricePaise", "addon", "specialDiscount"] as const;

export interface SaveTarget {
  sellerId: string;
  areaId: string;
  productId: string;
  variantId: string;
}

/**
 * Writes a listing in a transaction: merges the change into the current
 * listing, prices it (refusing anything pricingProblems flags), keeps the
 * computed prices on the listing, and appends a priceHistory row when a
 * money field changed. Returns the new prices.
 */
async function writeListing(
  tx: Transaction,
  t: SaveTarget,
  change: ListingChange,
  by: { uid: string; kind: "seller" | "staff"; reason: string | null },
  now: Date,
): Promise<{ id: string; price: ListingPrice; before: Record<string, unknown> | null }> {
  const id = listingIdFor(t.sellerId, t.areaId, t.variantId);
  const ref = db.collection(LISTINGS).doc(id);
  const [snap, product, seller] = await tx.getAll(
    ref,
    db.collection(PRODUCTS).doc(t.productId),
    db.collection(SELLERS).doc(t.sellerId),
  );
  if (!product.exists) throw new HttpsError("not-found", "Product not found");
  const variant = ((product.get("variants") as Variant[] | undefined) ?? []).find((v) => v.id === t.variantId);
  if (!variant) throw new HttpsError("not-found", "Variant not found");
  if (!seller.exists) throw new HttpsError("not-found", "Seller not found");
  const model = seller.get("model") as ListingModel;
  if (model !== "subscription" && model !== "supply") {
    throw new HttpsError("failed-precondition", "Zyppi's own prices are set on the product");
  }

  const current = snap.exists ? readListing(id, snap.data()!) : null;
  const merged = {
    ...(current ?? {
      id,
      sellerId: t.sellerId,
      serviceAreaId: t.areaId,
      productId: t.productId,
      variantId: t.variantId,
      model,
      sellerPricePaise: 0,
      zyppiPricePaise: null,
      addon: null,
      specialDiscount: null,
      allowNegativeMargin: false,
      isActive: false,
    }),
    model,
    ...Object.fromEntries(Object.entries(change).filter(([, v]) => v !== undefined)),
  };
  const input = listingPriceInput(merged, variant.mrpPaise);
  const problems = pricingProblems(input);
  if (merged.allowNegativeMargin && !by.reason) problems.push("Give a reason for selling below the supply price");
  if (problems.length) throw new HttpsError("invalid-argument", problems.join("; "));
  const price = priceListing(input, now);

  const next = nextPriceChangeAt(merged.specialDiscount, now);
  const ts = (d: Date | null) => (d ? Timestamp.fromDate(d) : null);
  const doc = {
    sellerId: t.sellerId,
    serviceAreaId: t.areaId,
    productId: t.productId,
    variantId: t.variantId,
    model,
    sellerPricePaise: merged.sellerPricePaise,
    zyppiPricePaise: merged.zyppiPricePaise,
    addon: merged.addon,
    specialDiscount: merged.specialDiscount
      ? { ...merged.specialDiscount, startsAt: ts(merged.specialDiscount.startsAt), endsAt: ts(merged.specialDiscount.endsAt) }
      : null,
    allowNegativeMargin: merged.allowNegativeMargin,
    marginOverrideReason: merged.allowNegativeMargin ? by.reason : null,
    isActive: merged.isActive,
    // Snapshot at save time; quoteOrder always re-prices from the fields above.
    mrpPaise: variant.mrpPaise,
    ...price,
    nextPriceChangeAt: ts(next),
    updatedBy: by.uid,
    updatedAt: FieldValue.serverTimestamp(),
    ...(snap.exists ? {} : { createdAt: FieldValue.serverTimestamp() }),
  };
  tx.set(ref, doc, { merge: true });

  const moneyChanged = !current || MONEY_KEYS.some((k) => JSON.stringify(current[k]) !== JSON.stringify(merged[k]));
  if (moneyChanged) {
    tx.create(ref.collection("priceHistory").doc(), {
      by: by.uid,
      kind: by.kind,
      reason: by.reason,
      sellerPricePaise: merged.sellerPricePaise,
      zyppiPricePaise: merged.zyppiPricePaise,
      addon: merged.addon,
      ...price,
      at: FieldValue.serverTimestamp(),
    });
  }
  return { id, price, before: snap.exists ? snap.data()! : null };
}

const paise = (v: unknown) => (v === undefined ? undefined : Number(v));
const bool = (v: unknown) => (v === undefined ? undefined : v === true);
const idOf = (v: unknown, field: string) => {
  if (typeof v !== "string" || !/^[\w-]{1,128}$/.test(v)) throw new HttpsError("invalid-argument", `Invalid ${field}`);
  return v;
};

/**
 * Seller app → product price. Request: {productId, variantId,
 * sellerPricePaise?, specialDiscount?: {type, value, startsAt?, endsAt?} | null,
 * isActive?}. A subscription seller sets their own price; a supply seller
 * only switches the listing on/off and runs discounts (Zyppi agrees the
 * supply price). The add-on is Zyppi's and can't be changed here.
 */
export const sellerSaveListing = onCall(async (request) => {
  const me = await requireSeller(request);
  const d = request.data ?? {};
  const model = me.seller.get("model") as ListingModel;
  const areaId = me.seller.get("serviceAreaId") as string;
  const t = { sellerId: me.sellerId, areaId, productId: idOf(d.productId, "product"), variantId: idOf(d.variantId, "variant") };
  const change: ListingChange = {
    isActive: bool(d.isActive),
    ...("specialDiscount" in d ? { specialDiscount: readSpecialDiscount(d.specialDiscount) } : {}),
  };
  if (d.sellerPricePaise !== undefined) {
    if (model !== "subscription") throw new HttpsError("permission-denied", "Zyppi sets the supply price with you");
    change.sellerPricePaise = paise(d.sellerPricePaise);
  }
  const now = new Date();
  try {
    return await db.runTransaction(async (tx) => {
      const existing = await tx.get(db.collection(LISTINGS).doc(listingIdFor(t.sellerId, t.areaId, t.variantId)));
      if (!existing.exists && model === "supply") {
        throw new HttpsError("failed-precondition", "Zyppi adds supply products for you");
      }
      if (change.isActive === true && !(existing.get("isActive") === true)) await assertListingLimit(tx, me.seller.get("planId"), t.sellerId);
      const r = await writeListing(tx, t, change, { uid: me.uid, kind: "seller", reason: null }, now);
      return { id: r.id, ...r.price };
    });
  } catch (e) {
    if (e instanceof PricingError) throw new HttpsError("invalid-argument", e.message);
    throw e;
  }
});

/** A subscription plan's listing limit (0 / no plan = no limit). */
async function assertListingLimit(tx: Transaction, planId: unknown, sellerId: string) {
  if (typeof planId !== "string" || !planId) return;
  const plan = await tx.get(db.collection(SELLER_PLANS).doc(planId));
  const max = (plan.get("maxListings") as number | undefined) ?? 0;
  if (!max) return;
  const count = await tx.get(
    db.collection(LISTINGS).where("sellerId", "==", sellerId).where("isActive", "==", true).count(),
  );
  if (count.data().count >= max) {
    throw new HttpsError("resource-exhausted", `Your plan allows ${max} products on sale`);
  }
}

/**
 * Admin → seller listing. Request: {sellerId, productId, variantId,
 * areaId?, sellerPricePaise?, zyppiPricePaise?, addon?: {type, value} | null,
 * specialDiscount?, allowNegativeMargin?, isActive?, reason?}.
 * Catalog and finance staff; audited.
 */
export async function adminSaveListingFor(actor: Actor, d: Record<string, unknown>) {
  const sellerId = idOf(d.sellerId, "seller");
  if (sellerId === ZYPPI_SELLER_ID) throw new HttpsError("failed-precondition", "Zyppi's own prices are set on the product");
  const seller = await db.collection(SELLERS).doc(sellerId).get();
  if (!seller.exists) throw new HttpsError("not-found", "Seller not found");
  const areaId = d.areaId === undefined ? (seller.get("serviceAreaId") as string) : idOf(d.areaId, "area");
  const t = { sellerId, areaId, productId: idOf(d.productId, "product"), variantId: idOf(d.variantId, "variant") };
  const reason = typeof d.reason === "string" ? d.reason.trim().slice(0, 300) || null : null;
  const change: ListingChange = {
    sellerPricePaise: paise(d.sellerPricePaise),
    zyppiPricePaise: d.zyppiPricePaise === undefined ? undefined : d.zyppiPricePaise === null ? null : Number(d.zyppiPricePaise),
    ...("addon" in d ? { addon: readAdjustment(d.addon) } : {}),
    ...("specialDiscount" in d ? { specialDiscount: readSpecialDiscount(d.specialDiscount) } : {}),
    allowNegativeMargin: bool(d.allowNegativeMargin),
    isActive: bool(d.isActive),
  };
  const now = new Date();
  try {
    return await db.runTransaction(async (tx) => {
      const r = await writeListing(tx, t, change, { uid: actor.uid, kind: "staff", reason }, now);
      writeAudit(actor, { action: "listing.save", target: `${LISTINGS}/${r.id}`, before: r.before, after: { ...change, reason, ...r.price } }, tx);
      return { id: r.id, ...r.price };
    });
  } catch (e) {
    if (e instanceof PricingError) throw new HttpsError("invalid-argument", e.message);
    throw e;
  }
}

export const adminSaveListing = onCall(async (request) =>
  adminSaveListingFor(requireRole(request, ["catalog", "finance"]), request.data ?? {}),
);

/**
 * Seller app → stock in the seller's own shop. Request: {items:
 * [{productId, variantId, mode: add|set, value}], reason, note?}. Stock a
 * supply seller keeps in a Zyppi store is counted by Zyppi
 * (adminAdjustStock with sellerId).
 */
export const sellerAdjustStock = onCall(async (request) => {
  const me = await requireSeller(request);
  if (me.seller.get("fulfilment") !== "seller_shop") {
    throw new HttpsError("failed-precondition", "Zyppi counts the stock you supply to its store");
  }
  return adjustStock(
    { uid: me.uid, email: null, seller: { sellerId: me.sellerId, storeId: sellerStoreId(me.sellerId) } },
    request.data ?? {},
  );
});
