/**
 * Orders the offers for one variant in one area (docs/MARKETPLACE.md →
 * Ranking). Pure; the weights come from config/marketplace.
 *
 *   score = wPrice × cheapest/price  + wRating × bayes(avg, count) / 5
 *         + wReliability × (1 − badRate) + wStock × inStock
 *
 * The Bayesian average pulls few-review sellers towards `prior`, so one
 * 5★ review doesn't beat 300 reviews at 4.6★. `badRate` (cancelled or
 * late-accepted orders) is smoothed the same way.
 */
export interface RankingWeights {
  price: number;
  rating: number;
  reliability: number;
  stock: number;
}

export interface MarketplaceConfig {
  ranking: RankingWeights;
  /** Reviews' weight of the prior in the Bayesian average. */
  ratingPriorCount: number;
  ratingPrior: number;
  /** Most different sellers in one order (pickups per delivery). */
  maxSellersPerOrder: number;
  /** A seller has this long to accept a new order before ops is alerted. */
  acceptSlaMinutes: number;
  /**
   * Minutes after the accept deadline before an order a seller still
   * hasn't accepted is cancelled and refunded (0 = never: ops decides).
   */
  autoCancelLateMinutes: number;
}

export const DEFAULT_MARKETPLACE_CONFIG: MarketplaceConfig = {
  ranking: { price: 0.45, rating: 0.25, reliability: 0.15, stock: 0.15 },
  ratingPriorCount: 20,
  ratingPrior: 4,
  maxSellersPerOrder: 3,
  acceptSlaMinutes: 5,
  autoCancelLateMinutes: 0,
};

const num = (v: unknown, min: number, max: number, fallback: number) =>
  typeof v === "number" && Number.isFinite(v) && v >= min && v <= max ? v : fallback;

/** config/marketplace with defaults for anything missing or out of range. */
export function marketplaceConfigFrom(raw: Record<string, unknown> | undefined): MarketplaceConfig {
  const d = DEFAULT_MARKETPLACE_CONFIG;
  const r = (raw?.ranking ?? {}) as Record<string, unknown>;
  return {
    ranking: {
      price: num(r.price, 0, 1, d.ranking.price),
      rating: num(r.rating, 0, 1, d.ranking.rating),
      reliability: num(r.reliability, 0, 1, d.ranking.reliability),
      stock: num(r.stock, 0, 1, d.ranking.stock),
    },
    ratingPriorCount: num(raw?.ratingPriorCount, 0, 1000, d.ratingPriorCount),
    ratingPrior: num(raw?.ratingPrior, 1, 5, d.ratingPrior),
    maxSellersPerOrder: Math.round(num(raw?.maxSellersPerOrder, 1, 10, d.maxSellersPerOrder)),
    acceptSlaMinutes: num(raw?.acceptSlaMinutes, 1, 60, d.acceptSlaMinutes),
    autoCancelLateMinutes: Math.round(num(raw?.autoCancelLateMinutes, 0, 120, d.autoCancelLateMinutes)),
  };
}

export interface RankInput {
  id: string;
  sellerId: string;
  pricePaise: number;
  inStock: boolean;
  ratingAvg: number;
  ratingCount: number;
  /** Delivered + cancelled orders the seller handled. */
  orders: number;
  /** Cancelled by / late for the seller. */
  badOrders: number;
}

export function bayesRating(avg: number, count: number, cfg: MarketplaceConfig): number {
  const c = cfg.ratingPriorCount;
  const n = Math.max(0, count);
  return n + c === 0 ? cfg.ratingPrior : (c * cfg.ratingPrior + avg * n) / (c + n);
}

/** Bad-order rate, smoothed as if there were 10 more good orders. */
export const badRate = (orders: number, bad: number) =>
  Math.min(1, Math.max(0, bad) / (Math.max(0, orders) + 10));

/**
 * Scores (0–1, 4 decimals) for a group of offers of the same variant in
 * the same area, best first. Ties: cheaper, then Zyppi, then id.
 */
export function rankOffers<T extends RankInput>(offers: T[], cfg: MarketplaceConfig): (T & { rankScore: number })[] {
  const w = cfg.ranking;
  const total = w.price + w.rating + w.reliability + w.stock || 1;
  const inStock = offers.filter((o) => o.inStock && o.pricePaise > 0);
  const cheapest = Math.min(...(inStock.length ? inStock : offers).map((o) => o.pricePaise));
  return offers
    .map((o) => {
      const s =
        w.price * (o.pricePaise > 0 ? Math.min(1, cheapest / o.pricePaise) : 0) +
        w.rating * (bayesRating(o.ratingAvg, o.ratingCount, cfg) / 5) +
        w.reliability * (1 - badRate(o.orders, o.badOrders)) +
        w.stock * (o.inStock ? 1 : 0);
      return { ...o, rankScore: Math.round((s / total) * 10000) / 10000 };
    })
    .sort(
      (a, b) =>
        b.rankScore - a.rankScore ||
        a.pricePaise - b.pricePaise ||
        Number(b.sellerId === "zyppi") - Number(a.sellerId === "zyppi") ||
        a.id.localeCompare(b.id),
    );
}
