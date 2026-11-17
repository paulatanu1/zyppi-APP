import { Timestamp } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";

/**
 * Coupons v2 (`coupons/{CODE}`, doc id = the upper-cased code). Pure
 * helpers shared by quoteOrder, the customer's checkCoupon pre-check and
 * the admin callables. Money is int paise.
 *
 * Usage: `usedCount` / `totalDiscountPaise` on the coupon and
 * `coupons/{CODE}/redemptions/{uid}.count` per customer, written only by
 * placeOrderInTx (and undone when an order is cancelled).
 */
export const COUPONS = "coupons";
export const REDEMPTIONS = "redemptions";

export type CouponType = "flat" | "percent";

export interface CouponTerms {
  code: string;
  description: string;
  type: CouponType;
  /** Flat coupons: the amount off. */
  discountPaise: number;
  /** Percent coupons: 1–90. */
  percent: number;
  /** Percent coupons: the most it can take off (null = no cap). */
  maxDiscountPaise: number | null;
  minOrderPaise: number;
  startAtMs: number | null;
  expiresAtMs: number | null;
  /** All customers together (null = unlimited). */
  usageLimit: number | null;
  /** Per customer (null = unlimited). */
  perUserLimit: number | null;
  usedCount: number;
  firstOrderOnly: boolean;
  /** Empty = every area. */
  serviceAreaIds: string[];
  isActive: boolean;
}

const int = (v: unknown, fallback: number) =>
  typeof v === "number" && Number.isFinite(v) ? Math.trunc(v) : fallback;
const intOrNull = (v: unknown) =>
  typeof v === "number" && Number.isFinite(v) ? Math.trunc(v) : null;
const millis = (v: unknown) => (v instanceof Timestamp ? v.toMillis() : null);

/** Reads a stored coupon; v1 docs (flat `discountPaise` only) still work. */
export function parseCoupon(code: string, d: Record<string, unknown>): CouponTerms {
  return {
    code,
    description: typeof d.description === "string" ? d.description : "",
    type: d.type === "percent" ? "percent" : "flat",
    discountPaise: Math.max(int(d.discountPaise, 0), 0),
    percent: Math.min(Math.max(int(d.percent, 0), 0), 100),
    maxDiscountPaise: intOrNull(d.maxDiscountPaise),
    minOrderPaise: Math.max(int(d.minOrderPaise, 0), 0),
    startAtMs: millis(d.startAt),
    expiresAtMs: millis(d.expiresAt),
    usageLimit: intOrNull(d.usageLimit),
    perUserLimit: intOrNull(d.perUserLimit),
    usedCount: Math.max(int(d.usedCount, 0), 0),
    firstOrderOnly: d.firstOrderOnly === true,
    serviceAreaIds: Array.isArray(d.serviceAreaIds)
      ? d.serviceAreaIds.filter((s): s is string => typeof s === "string")
      : [],
    isActive: d.isActive === true,
  };
}

/**
 * The amount off an item total: 0 below the minimum; a percent is rounded
 * down to the paisa and capped. Never more than the items cost. The app's
 * BillCalculator does the same sum.
 */
export function discountFor(c: CouponTerms, itemTotalPaise: number): number {
  if (itemTotalPaise <= 0 || itemTotalPaise < c.minOrderPaise) return 0;
  let off =
    c.type === "percent" ? Math.floor((itemTotalPaise * c.percent) / 100) : c.discountPaise;
  if (c.type === "percent" && c.maxDiscountPaise != null) off = Math.min(off, c.maxDiscountPaise);
  return Math.max(Math.min(off, itemTotalPaise), 0);
}

export type CouponProblem =
  | "invalid"
  | "expired"
  | "used_up"
  | "user_limit"
  | "first_order"
  | "area";

/**
 * Fixed English sentences: quoteOrder throws them as OrderError messages
 * and the app's checkout_errors.dart matches them to translated text.
 */
export const COUPON_MESSAGES: Record<CouponProblem, string> = {
  invalid: "Coupon is not valid",
  expired: "Coupon has expired",
  used_up: "Coupon has been fully used",
  user_limit: "Coupon limit reached for your account",
  first_order: "Coupon is for first orders only",
  area: "Coupon is not available in your area",
};

export interface CouponContext {
  nowMs: number;
  /** This customer's earlier uses. */
  userRedemptions: number;
  /** Has a placed/delivered (not cancelled) order already. */
  hasPastOrder: boolean;
  /** Null when not known yet (cart before an address is picked). */
  serviceAreaId: string | null;
}

/** Why the coupon can't be used, or null. The minimum order is not a problem (see discountFor). */
export function couponProblem(c: CouponTerms | null, ctx: CouponContext): CouponProblem | null {
  if (!c || !c.isActive) return "invalid";
  if (c.startAtMs != null && c.startAtMs > ctx.nowMs) return "invalid";
  if (c.expiresAtMs != null && c.expiresAtMs <= ctx.nowMs) return "expired";
  if (c.usageLimit != null && c.usedCount >= c.usageLimit) return "used_up";
  if (c.perUserLimit != null && ctx.userRedemptions >= c.perUserLimit) return "user_limit";
  if (c.firstOrderOnly && ctx.hasPastOrder) return "first_order";
  if (
    c.serviceAreaIds.length > 0 &&
    ctx.serviceAreaId != null &&
    !c.serviceAreaIds.includes(ctx.serviceAreaId)
  ) {
    return "area";
  }
  return null;
}

/** Upper-cased code, or null when it can't be a coupon id. */
export function normalizeCode(raw: unknown): string | null {
  if (typeof raw !== "string") return null;
  const code = raw.trim().toUpperCase();
  return CODE_PATTERN.test(code) ? code : null;
}

export const CODE_PATTERN = /^[A-Z0-9]{3,20}$/;
/** ₹10,000: a coupon worth more than this is almost certainly a typo. */
export const MAX_COUPON_PAISE = 1_000_000;
export const MAX_PERCENT = 90;

/** What the admin form sends (dates as epoch millis). */
export interface CouponInput {
  code: string;
  description: string;
  type: CouponType;
  discountPaise: number;
  percent: number;
  maxDiscountPaise: number | null;
  minOrderPaise: number;
  startAtMs: number | null;
  expiresAtMs: number | null;
  usageLimit: number | null;
  perUserLimit: number | null;
  firstOrderOnly: boolean;
  serviceAreaIds: string[];
  isActive: boolean;
}

const bad = (message: string) => new HttpsError("invalid-argument", message);

function optionalInt(v: unknown, field: string, min: number, max: number): number | null {
  if (v === null || v === undefined || v === "") return null;
  if (typeof v !== "number" || !Number.isInteger(v) || v < min || v > max) {
    throw bad(`${field} must be a whole number from ${min} to ${max}`);
  }
  return v;
}

/** Validates the admin form. Throws invalid-argument with a readable reason. */
export function validateCouponInput(raw: Record<string, unknown>): CouponInput {
  const code = normalizeCode(raw.code);
  if (!code) throw bad("Code must be 3–20 letters or digits");
  const description = typeof raw.description === "string" ? raw.description.trim() : "";
  if (description.length < 3 || description.length > 120) {
    throw bad("Description must be 3–120 characters");
  }
  const type = raw.type === "percent" ? "percent" : raw.type === "flat" ? "flat" : null;
  if (!type) throw bad("Choose flat or percent");

  let discountPaise = 0;
  let percent = 0;
  let maxDiscountPaise: number | null = null;
  if (type === "flat") {
    discountPaise = optionalInt(raw.discountPaise, "Discount", 100, MAX_COUPON_PAISE) ?? 0;
    if (discountPaise === 0) throw bad("Enter the discount (at least ₹1)");
  } else {
    percent = optionalInt(raw.percent, "Percent", 1, MAX_PERCENT) ?? 0;
    if (percent === 0) throw bad(`Enter a percent from 1 to ${MAX_PERCENT}`);
    maxDiscountPaise = optionalInt(raw.maxDiscountPaise, "Maximum discount", 100, MAX_COUPON_PAISE);
  }
  const minOrderPaise = optionalInt(raw.minOrderPaise, "Minimum order", 0, 10_000_000) ?? 0;
  if (type === "flat" && minOrderPaise > 0 && discountPaise > minOrderPaise) {
    throw bad("The discount is more than the minimum order");
  }

  const startAtMs = optionalInt(raw.startAtMs, "Start", 0, Number.MAX_SAFE_INTEGER);
  const expiresAtMs = optionalInt(raw.expiresAtMs, "End", 0, Number.MAX_SAFE_INTEGER);
  if (startAtMs != null && expiresAtMs != null && expiresAtMs <= startAtMs) {
    throw bad("The end must be after the start");
  }

  const serviceAreaIds = Array.isArray(raw.serviceAreaIds)
    ? [...new Set(raw.serviceAreaIds.filter((s): s is string => typeof s === "string" && !!s))]
    : [];
  if (serviceAreaIds.length > 50) throw bad("Too many areas");

  return {
    code,
    description,
    type,
    discountPaise,
    percent,
    maxDiscountPaise,
    minOrderPaise,
    startAtMs,
    expiresAtMs,
    usageLimit: optionalInt(raw.usageLimit, "Total uses", 1, 10_000_000),
    perUserLimit: optionalInt(raw.perUserLimit, "Uses per customer", 1, 1000),
    firstOrderOnly: raw.firstOrderOnly === true,
    serviceAreaIds,
    isActive: raw.isActive !== false,
  };
}
