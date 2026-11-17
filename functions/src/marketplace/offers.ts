import type { Variant } from "../catalog/model";
import {
  ZYPPI_SELLER_ID,
  inventoryIdFor,
  isZyppiStore,
  listingIdFor,
} from "./model";
import { type ListingPriceInput, type ListingModel, PricingError, priceListing, readDateLike } from "./pricing";
import { type MarketplaceConfig, rankOffers } from "./ranking";

/**
 * What customers see (offers/{offerId}, public) and the per-area summary
 * on products/{id} (`areaBest`, `rank`), built from the product, the
 * listings, the sellers and stock. Pure: offers_sync.ts does the I/O.
 * Payout and margin never leave the listing.
 */

export interface StoreLite {
  id: string;
  serviceAreaId: string;
  isActive: boolean;
  sellerId: string | null;
}

/** The parts of a listing doc pricing and offers need. */
export interface ListingLite {
  id: string;
  sellerId: string;
  serviceAreaId: string;
  productId: string;
  variantId: string;
  model: ListingModel;
  sellerPricePaise: number;
  zyppiPricePaise: number | null;
  addon: ListingPriceInput["addon"];
  specialDiscount: ListingPriceInput["specialDiscount"];
  allowNegativeMargin: boolean;
  isActive: boolean;
}

export interface SellerLite {
  name: string;
  status: string;
  model: string;
  fulfilment: string;
  ratingAvg: number;
  ratingCount: number;
  orders: number;
  badOrders: number;
  subscriptionStatus: string | null;
  /** Food sellers whose FSSAI licence ran out are paused (sellerDaily). */
  licenceExpired: boolean;
  /** Seller app Online / Offline (their own shop only takes orders online). */
  online: boolean;
}

export const ZYPPI_SELLER: SellerLite = {
  name: "Zyppi",
  status: "approved",
  model: "own",
  fulfilment: "zyppi_store",
  ratingAvg: 0,
  ratingCount: 0,
  orders: 0,
  badOrders: 0,
  subscriptionStatus: null,
  licenceExpired: false,
  online: true,
};

export interface OfferDoc {
  id: string;
  productId: string;
  variantId: string;
  serviceAreaId: string;
  sellerId: string;
  sellerName: string;
  sellerRating: number;
  ratingCount: number;
  fulfilment: string;
  pricePaise: number;
  mrpPaise: number;
  /** Price without the special discount (for "x% off" next to MRP). */
  regularPricePaise: number;
  discountActive: boolean;
  inStock: boolean;
  rankScore: number;
  isActive: true;
}

export interface AreaBest {
  offerId: string;
  sellerId: string;
  sellerName: string;
  pricePaise: number;
  mrpPaise: number;
  inStock: boolean;
  offerCount: number;
}

export interface BuiltOffers {
  offers: OfferDoc[];
  /** areaId → variantId → the top offer. */
  areaBest: Record<string, Record<string, AreaBest>>;
  /** areaId → the product's best score there (category / search order). */
  rank: Record<string, number>;
}

/** Whether a seller's offers are shown at all (approval, subscription). */
export function sellerCanSell(s: SellerLite | undefined): boolean {
  if (!s || s.status !== "approved") return false;
  if (s.model === "subscription" && s.subscriptionStatus === "expired") return false;
  if (s.licenceExpired) return false;
  if (s.fulfilment === "seller_shop" && !s.online) return false;
  return true;
}

/**
 * Stores whose stock rows can fill `sellerId`'s offer in `areaId`: Zyppi's
 * own stores for Zyppi; for a seller, their shop and any Zyppi store they
 * supply into. quoteOrder uses the same rule (plus opening hours).
 */
export function candidateStores(stores: StoreLite[], areaId: string, sellerId: string): StoreLite[] {
  return stores.filter(
    (s) =>
      s.isActive &&
      s.serviceAreaId === areaId &&
      (sellerId === ZYPPI_SELLER_ID ? isZyppiStore(s.sellerId) : s.sellerId === sellerId || isZyppiStore(s.sellerId)),
  );
}

/** Every inventory id buildOffers will look at (read them first). */
export function stockIdsNeeded(
  product: { variants: Variant[] },
  stores: StoreLite[],
  areaIds: string[],
  listings: ListingLite[],
): string[] {
  const ids = new Set<string>();
  for (const area of areaIds) {
    for (const v of product.variants) {
      for (const s of candidateStores(stores, area, ZYPPI_SELLER_ID)) ids.add(inventoryIdFor(s.id, ZYPPI_SELLER_ID, v.id));
    }
  }
  for (const l of listings) {
    for (const s of candidateStores(stores, l.serviceAreaId, l.sellerId)) {
      ids.add(inventoryIdFor(s.id, l.sellerId, l.variantId));
    }
  }
  return [...ids];
}

export function listingPriceInput(l: ListingLite, mrpPaise: number): ListingPriceInput {
  return {
    model: l.model,
    mrpPaise,
    sellerPricePaise: l.sellerPricePaise,
    zyppiPricePaise: l.zyppiPricePaise,
    addon: l.addon,
    specialDiscount: l.specialDiscount,
    allowNegativeMargin: l.allowNegativeMargin,
  };
}

export function buildOffers(input: {
  product: { id: string; isActive: boolean; variants: Variant[] };
  activeAreaIds: string[];
  stores: StoreLite[];
  listings: ListingLite[];
  sellers: Map<string, SellerLite>;
  stock: Map<string, number>;
  now: Date;
  cfg: MarketplaceConfig;
}): BuiltOffers {
  const { product, stores, stock, now, cfg } = input;
  const empty: BuiltOffers = { offers: [], areaBest: {}, rank: {} };
  if (!product.isActive) return empty;
  const variants = new Map(product.variants.map((v) => [v.id, v]));
  const units = (areaId: string, sellerId: string, variantId: string) =>
    candidateStores(stores, areaId, sellerId).reduce(
      (sum, s) => sum + Math.max(0, stock.get(inventoryIdFor(s.id, sellerId, variantId)) ?? 0),
      0,
    );

  type Draft = Omit<OfferDoc, "rankScore"> & { orders: number; badOrders: number; ratingAvg: number };
  const drafts: Draft[] = [];
  const zyppi = input.sellers.get(ZYPPI_SELLER_ID) ?? ZYPPI_SELLER;
  const base = (seller: SellerLite, sellerId: string) => ({
    productId: product.id,
    sellerId,
    sellerName: seller.name,
    sellerRating: Math.round(seller.ratingAvg * 10) / 10,
    ratingAvg: seller.ratingAvg,
    ratingCount: seller.ratingCount,
    orders: seller.orders,
    badOrders: seller.badOrders,
    fulfilment: seller.fulfilment,
    isActive: true as const,
  });

  // Zyppi's own stock: priced by the product itself, wherever Zyppi has a store.
  for (const area of input.activeAreaIds) {
    if (candidateStores(stores, area, ZYPPI_SELLER_ID).length === 0) continue;
    for (const v of product.variants) {
      if (!(v.pricePaise > 0)) continue;
      drafts.push({
        ...base(zyppi, ZYPPI_SELLER_ID),
        id: listingIdFor(ZYPPI_SELLER_ID, area, v.id),
        variantId: v.id,
        serviceAreaId: area,
        pricePaise: v.pricePaise,
        mrpPaise: Math.max(v.mrpPaise ?? v.pricePaise, v.pricePaise),
        regularPricePaise: v.pricePaise,
        discountActive: false,
        inStock: units(area, ZYPPI_SELLER_ID, v.id) > 0,
      });
    }
  }

  for (const l of input.listings) {
    const seller = input.sellers.get(l.sellerId);
    const v = variants.get(l.variantId);
    if (!l.isActive || !v || l.sellerId === ZYPPI_SELLER_ID || !sellerCanSell(seller)) continue;
    if (!input.activeAreaIds.includes(l.serviceAreaId)) continue;
    const mrp = v.mrpPaise ?? 0;
    let price;
    try {
      price = priceListing(listingPriceInput(l, mrp), now);
    } catch (e) {
      // e.g. the product's MRP was lowered below this price: hidden until fixed.
      if (e instanceof PricingError) continue;
      throw e;
    }
    drafts.push({
      ...base(seller!, l.sellerId),
      id: l.id,
      variantId: l.variantId,
      serviceAreaId: l.serviceAreaId,
      pricePaise: price.pricePaise,
      mrpPaise: mrp,
      regularPricePaise: price.regularPricePaise,
      discountActive: price.discountActive,
      inStock: units(l.serviceAreaId, l.sellerId, l.variantId) > 0,
    });
  }

  const groups = new Map<string, Draft[]>();
  for (const d of drafts) {
    const k = `${d.serviceAreaId}\u0000${d.variantId}`;
    groups.set(k, [...(groups.get(k) ?? []), d]);
  }
  const out: BuiltOffers = { offers: [], areaBest: {}, rank: {} };
  for (const group of groups.values()) {
    const ranked = rankOffers(group, cfg);
    for (const r of ranked) {
      const { orders: _o, badOrders: _b, ratingAvg: _r, ...offer } = r;
      out.offers.push(offer);
    }
    const best = ranked.find((r) => r.inStock) ?? ranked[0];
    const area = best.serviceAreaId;
    (out.areaBest[area] ??= {})[best.variantId] = {
      offerId: best.id,
      sellerId: best.sellerId,
      sellerName: best.sellerName,
      pricePaise: best.pricePaise,
      mrpPaise: best.mrpPaise,
      inStock: best.inStock,
      offerCount: ranked.length,
    };
    out.rank[area] = Math.max(out.rank[area] ?? 0, best.rankScore);
  }
  out.offers.sort((a, b) => a.id.localeCompare(b.id));
  return out;
}

/** A listing doc (Firestore data) as buildOffers / quoteOrder read it. */
export function readListing(id: string, d: Record<string, unknown>): ListingLite {
  const sd = d.specialDiscount as Record<string, unknown> | null | undefined;
  const addon = d.addon as Record<string, unknown> | null | undefined;
  return {
    id,
    sellerId: String(d.sellerId ?? ""),
    serviceAreaId: String(d.serviceAreaId ?? ""),
    productId: String(d.productId ?? ""),
    variantId: String(d.variantId ?? ""),
    model: (d.model as ListingModel) ?? "subscription",
    sellerPricePaise: Number(d.sellerPricePaise ?? 0),
    zyppiPricePaise: d.zyppiPricePaise == null ? null : Number(d.zyppiPricePaise),
    addon: addon && (addon.type === "fixed" || addon.type === "percent") ? { type: addon.type, value: Number(addon.value) } : null,
    specialDiscount:
      sd && (sd.type === "fixed" || sd.type === "percent")
        ? { type: sd.type, value: Number(sd.value), startsAt: readDateLike(sd.startsAt), endsAt: readDateLike(sd.endsAt) }
        : null,
    allowNegativeMargin: d.allowNegativeMargin === true,
    isActive: d.isActive === true,
  };
}

/** A seller doc as offers need it. */
export function readSellerLite(d: Record<string, unknown> | undefined): SellerLite | undefined {
  if (!d) return undefined;
  const rating = (d.rating ?? {}) as Record<string, unknown>;
  const stats = (d.stats ?? {}) as Record<string, unknown>;
  const sub = (d.subscription ?? {}) as Record<string, unknown>;
  const n = (v: unknown) => (typeof v === "number" && Number.isFinite(v) ? v : 0);
  return {
    name: String(d.shopName ?? d.name ?? "Seller"),
    status: String(d.status ?? ""),
    model: String(d.model ?? ""),
    fulfilment: String(d.fulfilment ?? "seller_shop"),
    ratingAvg: n(rating.avg),
    ratingCount: n(rating.count),
    orders: n(stats.orders),
    badOrders: n(stats.cancelled) + n(stats.lateAccepts),
    subscriptionStatus: typeof sub.status === "string" ? sub.status : null,
    licenceExpired: ((d.compliance ?? {}) as Record<string, unknown>).fssaiExpired === true,
    online: d.isOnline === true,
  };
}
