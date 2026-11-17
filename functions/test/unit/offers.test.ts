import type { DocumentReference } from "firebase-admin/firestore";
import { describe, expect, it } from "vitest";
import { offersDependOnChange } from "../../src/catalog/products";
import {
  type ListingLite,
  type SellerLite,
  type StoreLite,
  ZYPPI_SELLER,
  buildOffers,
  candidateStores,
  readListing,
  sellerCanSell,
  stockIdsNeeded,
} from "../../src/marketplace/offers";
import { nextPriceChangeAt } from "../../src/marketplace/pricing";
import { DEFAULT_MARKETPLACE_CONFIG as CFG, bayesRating, marketplaceConfigFrom, rankOffers } from "../../src/marketplace/ranking";
import { OrderError, priceCartLines, sellerSummary } from "../../src/orders/quote";

const now = new Date(Date.UTC(2026, 10, 17, 6));

describe("ranking", () => {
  const base = { inStock: true, ratingAvg: 4.5, ratingCount: 50, orders: 100, badOrders: 2 };

  it("puts the cheaper of two equal sellers first", () => {
    const r = rankOffers(
      [
        { ...base, id: "a", sellerId: "a", pricePaise: 5500 },
        { ...base, id: "b", sellerId: "b", pricePaise: 5000 },
      ],
      CFG,
    );
    expect(r.map((o) => o.id)).toEqual(["b", "a"]);
    expect(r[0].rankScore).toBeGreaterThan(r[1].rankScore);
  });

  it("one 5★ review doesn't beat 300 reviews at 4.6★ (Bayesian average)", () => {
    expect(bayesRating(5, 1, CFG)).toBeLessThan(bayesRating(4.6, 300, CFG));
    const r = rankOffers(
      [
        { ...base, id: "new", sellerId: "new", pricePaise: 5000, ratingAvg: 5, ratingCount: 1 },
        { ...base, id: "old", sellerId: "old", pricePaise: 5000, ratingAvg: 4.6, ratingCount: 300 },
      ],
      CFG,
    );
    expect(r[0].id).toBe("old");
  });

  it("sinks out-of-stock and unreliable sellers", () => {
    const r = rankOffers(
      [
        { ...base, id: "oos", sellerId: "oos", pricePaise: 4000, inStock: false },
        { ...base, id: "late", sellerId: "late", pricePaise: 5000, badOrders: 60 },
        { ...base, id: "good", sellerId: "good", pricePaise: 5000 },
      ],
      CFG,
    );
    expect(r.map((o) => o.id)).toEqual(["good", "late", "oos"]);
  });

  it("breaks exact ties for Zyppi, then by id", () => {
    const r = rankOffers(
      [
        { ...base, id: "x", sellerId: "x", pricePaise: 5000 },
        { ...base, id: "z", sellerId: "zyppi", pricePaise: 5000 },
      ],
      CFG,
    );
    expect(r[0].sellerId).toBe("zyppi");
  });

  it("reads config with defaults for bad values", () => {
    expect(marketplaceConfigFrom({ ranking: { price: 2, rating: 0.5 }, maxSellersPerOrder: 2.4 })).toEqual({
      ...CFG,
      ranking: { ...CFG.ranking, rating: 0.5 },
      maxSellersPerOrder: 2,
    });
  });
});

// Purulia has Zyppi's dark store, Sima's shop and a supply seller "sup" in Zyppi's store.
const stores: StoreLite[] = [
  { id: "dark1", serviceAreaId: "pur", isActive: true, sellerId: "zyppi" },
  { id: "old", serviceAreaId: "pur", isActive: true, sellerId: null },
  { id: "seller_sima", serviceAreaId: "pur", isActive: true, sellerId: "sima" },
  { id: "closed", serviceAreaId: "pur", isActive: false, sellerId: null },
  { id: "dark2", serviceAreaId: "rag", isActive: true, sellerId: "zyppi" },
];
const product = {
  id: "p-milk",
  isActive: true,
  variants: [{ id: "v1", label: "1 L", pricePaise: 6000, mrpPaise: 6400 }],
};
const listing = (over: Partial<ListingLite> = {}): ListingLite => ({
  id: "sima_pur_v1",
  sellerId: "sima",
  serviceAreaId: "pur",
  productId: "p-milk",
  variantId: "v1",
  model: "subscription",
  sellerPricePaise: 5500,
  zyppiPricePaise: null,
  addon: { type: "fixed", value: 300 },
  specialDiscount: null,
  allowNegativeMargin: false,
  isActive: true,
  ...over,
});
const sima: SellerLite = { ...ZYPPI_SELLER, name: "Sima Store", model: "subscription", fulfilment: "seller_shop", ratingAvg: 4.8, ratingCount: 40, orders: 50 };
const sellers = new Map<string, SellerLite>([["sima", sima]]);

describe("candidateStores", () => {
  it("Zyppi uses its own stores; a seller its shop and Zyppi stores (supply)", () => {
    expect(candidateStores(stores, "pur", "zyppi").map((s) => s.id)).toEqual(["dark1", "old"]);
    expect(candidateStores(stores, "pur", "sima").map((s) => s.id)).toEqual(["dark1", "old", "seller_sima"]);
  });

  it("lists every stock row to read", () => {
    expect(stockIdsNeeded(product, stores, ["pur"], [listing()]).sort()).toEqual(
      ["dark1_v1", "old_v1", "dark1_sima_v1", "old_sima_v1", "seller_sima_sima_v1"].sort(),
    );
  });
});

describe("buildOffers", () => {
  const build = (over: Partial<Parameters<typeof buildOffers>[0]> = {}) =>
    buildOffers({
      product,
      activeAreaIds: ["pur", "rag"],
      stores,
      listings: [listing()],
      sellers,
      stock: new Map([["dark1_v1", 0], ["seller_sima_sima_v1", 7], ["dark2_v1", 3]]),
      now,
      cfg: CFG,
      ...over,
    });

  it("offers Zyppi in every area it has a store, and the seller at price + add-on", () => {
    const r = build();
    expect(r.offers.map((o) => [o.id, o.pricePaise, o.inStock])).toEqual([
      ["sima_pur_v1", 5800, true],
      ["zyppi_pur_v1", 6000, false],
      ["zyppi_rag_v1", 6000, true],
    ]);
    expect(r.offers[0]).toMatchObject({ sellerName: "Sima Store", sellerRating: 4.8, mrpPaise: 6400, fulfilment: "seller_shop" });
    // Never public: payout or margin.
    expect(Object.keys(r.offers[0])).not.toContain("payoutPaise");
    expect(r.areaBest.pur.v1).toEqual({ offerId: "sima_pur_v1", sellerId: "sima", sellerName: "Sima Store", pricePaise: 5800, mrpPaise: 6400, inStock: true, offerCount: 2 });
    expect(r.areaBest.rag.v1.offerId).toBe("zyppi_rag_v1");
    expect(r.rank.pur).toBeGreaterThan(0);
  });

  it("hides a seller who isn't approved, is expired, or whose listing is off", () => {
    const ids = (o: ReturnType<typeof build>) => o.offers.map((x) => x.id);
    expect(ids(build({ sellers: new Map([["sima", { ...sima, status: "suspended" }]]) }))).not.toContain("sima_pur_v1");
    expect(ids(build({ sellers: new Map([["sima", { ...sima, subscriptionStatus: "expired" }]]) }))).not.toContain("sima_pur_v1");
    expect(ids(build({ listings: [listing({ isActive: false })] }))).not.toContain("sima_pur_v1");
  });

  it("hides a listing whose price went above a lowered MRP", () => {
    const cheaper = { ...product, variants: [{ ...product.variants[0], mrpPaise: 5600 }] };
    expect(build({ product: cheaper }).offers.map((o) => o.id)).not.toContain("sima_pur_v1");
  });

  it("an inactive product has no offers", () => {
    expect(build({ product: { ...product, isActive: false } })).toEqual({ offers: [], areaBest: {}, rank: {} });
  });

  it("shows the special discount while it runs", () => {
    const r = build({ listings: [listing({ specialDiscount: { type: "percent", value: 10, startsAt: null, endsAt: null } })] });
    expect(r.offers[0]).toMatchObject({ pricePaise: 5250, regularPricePaise: 5800, discountActive: true });
  });
});

describe("readListing / timed prices", () => {
  it("reads Firestore Timestamps in the special discount", () => {
    const at = new Date("2026-11-20T00:00:00Z");
    const l = readListing("x", { sellerId: "s", model: "supply", sellerPricePaise: 1, specialDiscount: { type: "fixed", value: 100, startsAt: { toDate: () => at }, endsAt: null }, isActive: true });
    expect(l.specialDiscount?.startsAt).toEqual(at);
    expect(nextPriceChangeAt(l.specialDiscount, now)).toEqual(at);
    expect(nextPriceChangeAt({ type: "fixed", value: 1, startsAt: null, endsAt: null }, now)).toBeNull();
  });

  it("only approved, unexpired sellers sell", () => {
    expect(sellerCanSell(sima)).toBe(true);
    expect(sellerCanSell(undefined)).toBe(false);
    expect(sellerCanSell({ ...sima, model: "supply", subscriptionStatus: "expired" })).toBe(true);
  });
});

const ref = (path: string) => ({ path }) as unknown as DocumentReference;
const pricingProduct = { name: "Milk", isActive: true, imageUrl: null, variants: product.variants };

describe("priceCartLines", () => {
  const run = (over: Partial<Parameters<typeof priceCartLines>[0]> = {}) =>
    priceCartLines({
      cart: [
        { offerId: null, productId: "p-milk", variantId: "v1", quantity: 3 },
        { offerId: "sima_pur_v1", productId: "p-milk", variantId: "v1", quantity: 2 },
      ],
      products: new Map([["p-milk", pricingProduct]]),
      sellerOf: ["zyppi", "sima"],
      listings: [null, listing()],
      sellers: new Map([["sima", sima]]),
      candidates: [
        [{ storeId: "dark1", ref: ref("inventory/dark1_v1"), current: 1 }, { storeId: "old", ref: ref("inventory/old_v1"), current: 5 }],
        [{ storeId: "seller_sima", ref: ref("inventory/seller_sima_sima_v1"), current: 2 }],
      ],
      areaId: "pur",
      now,
      ...over,
    });

  it("prices Zyppi from the product and the seller from the listing, and snapshots payout / margin", () => {
    const { lines, itemTotal } = run();
    expect(itemTotal).toBe(3 * 6000 + 2 * 5800);
    expect(lines[0]).toMatchObject({ offerId: "zyppi_pur_v1", sellerId: "zyppi", pricePaise: 6000, payoutPaise: 0, marginPaise: 6000, model: "own" });
    expect(lines[1]).toMatchObject({ offerId: "sima_pur_v1", sellerId: "sima", sellerName: "Sima Store", pricePaise: 5800, payoutPaise: 5500, marginPaise: 300, model: "subscription" });
  });

  it("takes from the fullest store first and spills over", () => {
    const { lines } = run();
    expect(lines[0].allocations.map((a) => [a.storeId, a.take])).toEqual([["old", 3]]);
    const big = run({ cart: [{ offerId: null, productId: "p-milk", variantId: "v1", quantity: 6 }], sellerOf: ["zyppi"], listings: [null] });
    expect(big.lines[0].allocations.map((a) => [a.storeId, a.take])).toEqual([["old", 5], ["dark1", 1]]);
  });

  it("refuses too little stock, a seller who can't sell, and a closed seller", () => {
    expect(() => run({ cart: [{ offerId: "sima_pur_v1", productId: "p-milk", variantId: "v1", quantity: 3 }], sellerOf: ["sima"], listings: [listing()], candidates: [[{ storeId: "seller_sima", ref: ref("a"), current: 2 }]] }))
      .toThrow("Insufficient stock for Milk");
    expect(() => run({ sellers: new Map([["sima", { ...sima, status: "suspended" }]]) })).toThrow("Product unavailable: Milk");
    expect(() => run({ listings: [null, listing({ isActive: false })] })).toThrow(OrderError);
    expect(() => run({ candidates: [[{ storeId: "old", ref: ref("b"), current: 9 }], []] })).toThrow("STORES_CLOSED");
  });

  it("uses the price at `now` (a discount that ended no longer applies)", () => {
    const ended = listing({ specialDiscount: { type: "fixed", value: 500, startsAt: null, endsAt: new Date(now.getTime() - 1000) } });
    expect(run({ listings: [null, ended] }).lines[1].pricePaise).toBe(5800);
    const running = listing({ specialDiscount: { type: "fixed", value: 500, startsAt: null, endsAt: new Date(now.getTime() + 1000) } });
    expect(run({ listings: [null, running] }).lines[1]).toMatchObject({ pricePaise: 5300, payoutPaise: 5000, marginPaise: 300 });
  });
});

describe("sellerSummary", () => {
  it("lists outside sellers, what each is owed and Zyppi's margin", () => {
    const lines = [
      { sellerId: "zyppi", quantity: 3, pricePaise: 6000, payoutPaise: 0, marginPaise: 6000 },
      { sellerId: "sima", quantity: 2, pricePaise: 5800, payoutPaise: 5500, marginPaise: 300 },
      { sellerId: "sima", quantity: 1, pricePaise: 1000, payoutPaise: 900, marginPaise: 100 },
    ];
    expect(sellerSummary(lines)).toEqual({
      sellerIds: ["sima"],
      sellerTotals: { sima: { itemTotalPaise: 12600, payoutPaise: 11900 } },
      payoutTotalPaise: 11900,
      marginTotalPaise: 18000 + 600 + 100,
    });
  });
});

describe("offersDependOnChange", () => {
  const p = { isActive: true, variants: [{ id: "v1", pricePaise: 1 }], name: "A" };
  it("rebuilds on price / active / create / delete, not on the offers' own write", () => {
    expect(offersDependOnChange(p, { ...p, name: "B", areaBest: { x: 1 }, rank: { x: 1 } })).toBe(false);
    expect(offersDependOnChange(p, { ...p, variants: [{ id: "v1", pricePaise: 2 }] })).toBe(true);
    expect(offersDependOnChange(p, { ...p, isActive: false })).toBe(true);
    expect(offersDependOnChange(undefined, p)).toBe(true);
    expect(offersDependOnChange(p, undefined)).toBe(true);
  });
});
