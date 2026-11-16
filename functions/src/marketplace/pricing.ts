import { MAX_PRICE_PAISE } from "../catalog/model";

/**
 * How a listing's customer price, the seller's payout and Zyppi's margin
 * are made (docs/MARKETPLACE.md → Pricing rules). Pure: the callables,
 * the offers trigger and quoteOrder all go through `priceListing`.
 *
 *   subscription  price = sellerPrice − discount + addon   payout = sellerPrice − discount
 *   supply        price = zyppiPrice  − discount           payout = supplyPrice − discount
 *   own           price = zyppiPrice  − discount           payout = 0
 *
 * The special discount is always passed to the customer and paid for by
 * the seller (by Zyppi for `own`). A percent add-on is taken on the
 * seller's price before the discount, so a seller's promotion doesn't eat
 * Zyppi's add-on. Money is int paise; percents round half up to a paisa.
 */
export const LISTING_MODELS = ["subscription", "supply", "own"] as const;
export type ListingModel = (typeof LISTING_MODELS)[number];

export interface Adjustment {
  type: "fixed" | "percent";
  /** Paise for `fixed`; 0–100 (up to 2 decimals) for `percent`. */
  value: number;
}

export interface SpecialDiscount extends Adjustment {
  startsAt: Date | null;
  endsAt: Date | null;
}

export interface ListingPriceInput {
  model: ListingModel;
  mrpPaise: number;
  /** subscription: the seller's own selling price. supply: the agreed supply price. own: ignored. */
  sellerPricePaise: number;
  /** supply / own: the customer price Zyppi sets. Ignored for subscription. */
  zyppiPricePaise?: number | null;
  /** subscription only: Zyppi's add-on on top of the seller's price. */
  addon?: Adjustment | null;
  specialDiscount?: SpecialDiscount | null;
  /** supply: allow price below the supply price (admin override, needs a reason). */
  allowNegativeMargin?: boolean;
}

export interface ListingPrice {
  pricePaise: number;
  payoutPaise: number;
  marginPaise: number;
  addonPaise: number;
  discountPaise: number;
  discountActive: boolean;
  /** What the customer would pay without the special discount (for "x% off"). */
  regularPricePaise: number;
}

export const MAX_DISCOUNT_PERCENT = 90;
export const MAX_ADDON_PERCENT = 100;

const isPaise = (v: unknown): v is number =>
  Number.isInteger(v) && (v as number) >= 0 && (v as number) <= MAX_PRICE_PAISE;

const isPercent = (v: unknown, max: number): v is number =>
  typeof v === "number" && Number.isFinite(v) && v > 0 && v <= max && Math.round(v * 100) === v * 100;

/** `base × percent` rounded half up, or the fixed amount. */
export function adjustmentPaise(basePaise: number, a: Adjustment | null | undefined): number {
  if (!a) return 0;
  if (a.type === "fixed") return a.value;
  // Integer maths on basis points avoids 0.1 + 0.2 style drift.
  return Math.floor((basePaise * Math.round(a.value * 100) + 5000) / 10000);
}

export function isDiscountActive(d: SpecialDiscount | null | undefined, now: Date): boolean {
  if (!d) return false;
  if (d.startsAt && now < d.startsAt) return false;
  if (d.endsAt && now >= d.endsAt) return false;
  return true;
}

/** Every problem with a listing's prices, readable for the seller app and admin. */
export function pricingProblems(input: ListingPriceInput): string[] {
  const out: string[] = [];
  const { model } = input;
  if (!(LISTING_MODELS as readonly string[]).includes(model)) return ["Unknown pricing model"];
  if (!isPaise(input.mrpPaise) || input.mrpPaise <= 0) out.push("MRP must be more than ₹0");

  const base = model === "subscription" ? input.sellerPricePaise : input.zyppiPricePaise;
  if (model === "subscription" || model === "supply") {
    if (!isPaise(input.sellerPricePaise) || input.sellerPricePaise <= 0) {
      out.push(model === "subscription" ? "Your price must be more than ₹0" : "Supply price must be more than ₹0");
    }
  }
  if (model !== "subscription" && (!isPaise(base) || (base as number) <= 0)) {
    out.push("Selling price must be more than ₹0");
  }

  const addon = input.addon;
  if (addon) {
    if (model !== "subscription") out.push("An add-on applies only to subscription sellers");
    else if (addon.type === "fixed" ? !isPaise(addon.value) : !isPercent(addon.value, MAX_ADDON_PERCENT)) {
      out.push(addon.type === "fixed" ? "Add-on must be ₹0 or more" : `Add-on must be 0.01–${MAX_ADDON_PERCENT}%`);
    }
  }

  const d = input.specialDiscount;
  if (d) {
    if (d.type === "fixed" ? !isPaise(d.value) || d.value <= 0 : !isPercent(d.value, MAX_DISCOUNT_PERCENT)) {
      out.push(d.type === "fixed" ? "Discount must be more than ₹0" : `Discount must be 0.01–${MAX_DISCOUNT_PERCENT}%`);
    }
    if (d.startsAt && d.endsAt && d.endsAt <= d.startsAt) out.push("Discount must end after it starts");
  }
  if (out.length) return out;

  // Checks on the computed amounts (only once the inputs are sane).
  const r = compute(input, true);
  if (d && r.discountPaise >= (model === "subscription" || model === "supply" ? input.sellerPricePaise : base!)) {
    out.push("Discount must be less than the price");
  } else if (r.pricePaise <= 0) {
    out.push("Price after the discount must be more than ₹0");
  }
  if (r.regularPricePaise > input.mrpPaise) {
    out.push(`Customer price ₹${rupees(r.regularPricePaise)} is above the MRP ₹${rupees(input.mrpPaise)}`);
  }
  if (r.regularPricePaise > MAX_PRICE_PAISE) out.push("Price is too high");
  if (model === "supply" && r.marginPaise < 0 && !input.allowNegativeMargin) {
    out.push("Selling price is below the supply price (Zyppi would lose money)");
  }
  return out;
}

export class PricingError extends Error {
  constructor(readonly problems: string[]) {
    super(problems.join("; "));
  }
}

/** The listing's prices `now`. Throws PricingError for an invalid listing. */
export function priceListing(input: ListingPriceInput, now: Date = new Date()): ListingPrice {
  const problems = pricingProblems(input);
  if (problems.length) throw new PricingError(problems);
  return compute(input, isDiscountActive(input.specialDiscount, now));
}

function compute(input: ListingPriceInput, discountOn: boolean): ListingPrice {
  const seller = input.model === "own" ? 0 : input.sellerPricePaise;
  const regular = input.model === "subscription" ? seller + adjustmentPaise(seller, input.addon) : input.zyppiPricePaise!;
  const addonPaise = input.model === "subscription" ? regular - seller : 0;
  // The discount is worked out on what the seller (or Zyppi, for own) charges.
  const discountBase = input.model === "own" ? regular : seller;
  const discountPaise = discountOn ? adjustmentPaise(discountBase, input.specialDiscount) : 0;
  const pricePaise = regular - discountPaise;
  const payoutPaise = input.model === "own" ? 0 : seller - discountPaise;
  return {
    pricePaise,
    payoutPaise,
    marginPaise: pricePaise - payoutPaise,
    addonPaise,
    discountPaise,
    discountActive: discountOn && discountPaise > 0,
    regularPricePaise: regular,
  };
}

const rupees = (p: number) => (p / 100).toFixed(2).replace(/\.00$/, "");

/** Reads an adjustment sent by a client; null when absent or empty. */
export function readAdjustment(raw: unknown): Adjustment | null {
  if (!raw || typeof raw !== "object") return null;
  const r = raw as Record<string, unknown>;
  const type = r.type === "percent" ? "percent" : r.type === "fixed" ? "fixed" : null;
  const value = Number(r.value);
  if (!type || !Number.isFinite(value) || value === 0) return null;
  return { type, value };
}

/** Reads a special discount (dates as ISO strings or epoch ms). */
export function readSpecialDiscount(raw: unknown): SpecialDiscount | null {
  const a = readAdjustment(raw);
  if (!a) return null;
  const r = raw as Record<string, unknown>;
  return { ...a, startsAt: readDate(r.startsAt), endsAt: readDate(r.endsAt) };
}

function readDate(v: unknown): Date | null {
  if (v == null || v === "") return null;
  if (v instanceof Date) return Number.isNaN(v.getTime()) ? null : v;
  const d = new Date(typeof v === "number" ? v : String(v));
  return Number.isNaN(d.getTime()) ? null : d;
}
