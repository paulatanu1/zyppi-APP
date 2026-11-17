import { Timestamp } from "firebase-admin/firestore";
import { describe, expect, it } from "vitest";
import {
  type CouponContext,
  couponProblem,
  discountFor,
  normalizeCode,
  parseCoupon,
  validateCouponInput,
} from "../../src/coupons/model";

const NOW = Date.UTC(2026, 10, 14, 12);
const ctx = (over: Partial<CouponContext> = {}): CouponContext => ({
  nowMs: NOW,
  userRedemptions: 0,
  hasPastOrder: false,
  serviceAreaId: "a1",
  ...over,
});
const coupon = (over: Record<string, unknown> = {}) =>
  parseCoupon("SAVE", { description: "x", isActive: true, discountPaise: 5000, ...over });

describe("parseCoupon", () => {
  it("reads a v1 coupon as flat with no limits", () => {
    const c = parseCoupon("ZYPPI50", {
      description: "₹50 off",
      discountPaise: 5000,
      minOrderPaise: 30000,
      isActive: true,
      expiresAt: null,
    });
    expect(c).toMatchObject({
      type: "flat",
      discountPaise: 5000,
      minOrderPaise: 30000,
      usageLimit: null,
      perUserLimit: null,
      usedCount: 0,
      firstOrderOnly: false,
      serviceAreaIds: [],
      expiresAtMs: null,
    });
  });

  it("reads timestamps as millis", () => {
    const c = coupon({ startAt: Timestamp.fromMillis(NOW), expiresAt: Timestamp.fromMillis(NOW + 1) });
    expect(c.startAtMs).toBe(NOW);
    expect(c.expiresAtMs).toBe(NOW + 1);
  });
});

describe("discountFor", () => {
  it("gives nothing below the minimum, the flat amount above", () => {
    const c = coupon({ minOrderPaise: 30000 });
    expect(discountFor(c, 29999)).toBe(0);
    expect(discountFor(c, 30000)).toBe(5000);
  });

  it("never takes off more than the items cost", () => {
    expect(discountFor(coupon({ discountPaise: 9000 }), 6400)).toBe(6400);
  });

  it("rounds a percent down to the paisa and applies the cap", () => {
    const c = coupon({ type: "percent", percent: 15, maxDiscountPaise: null });
    expect(discountFor(c, 12345)).toBe(1851);
    const capped = coupon({ type: "percent", percent: 20, maxDiscountPaise: 10000 });
    expect(discountFor(capped, 40000)).toBe(8000);
    expect(discountFor(capped, 80000)).toBe(10000);
  });
});

describe("couponProblem", () => {
  it("accepts a plain active coupon", () => {
    expect(couponProblem(coupon(), ctx())).toBeNull();
  });

  it("refuses missing, off and not-yet-started coupons as invalid", () => {
    expect(couponProblem(null, ctx())).toBe("invalid");
    expect(couponProblem(coupon({ isActive: false }), ctx())).toBe("invalid");
    expect(couponProblem(coupon({ startAt: Timestamp.fromMillis(NOW + 60_000) }), ctx())).toBe(
      "invalid",
    );
  });

  it("refuses an expired coupon", () => {
    expect(couponProblem(coupon({ expiresAt: Timestamp.fromMillis(NOW) }), ctx())).toBe("expired");
  });

  it("enforces total and per-customer limits", () => {
    expect(couponProblem(coupon({ usageLimit: 10, usedCount: 10 }), ctx())).toBe("used_up");
    expect(couponProblem(coupon({ usageLimit: 10, usedCount: 9 }), ctx())).toBeNull();
    expect(couponProblem(coupon({ perUserLimit: 1 }), ctx({ userRedemptions: 1 }))).toBe(
      "user_limit",
    );
  });

  it("keeps first-order coupons for new customers", () => {
    const c = coupon({ firstOrderOnly: true });
    expect(couponProblem(c, ctx({ hasPastOrder: true }))).toBe("first_order");
    expect(couponProblem(c, ctx())).toBeNull();
  });

  it("checks the area only once it is known", () => {
    const c = coupon({ serviceAreaIds: ["a2"] });
    expect(couponProblem(c, ctx())).toBe("area");
    expect(couponProblem(c, ctx({ serviceAreaId: "a2" }))).toBeNull();
    expect(couponProblem(c, ctx({ serviceAreaId: null }))).toBeNull();
  });
});

describe("normalizeCode", () => {
  it("upper-cases and rejects anything that can't be a doc id", () => {
    expect(normalizeCode(" zyppi50 ")).toBe("ZYPPI50");
    expect(normalizeCode("a/b")).toBeNull();
    expect(normalizeCode("AB")).toBeNull();
    expect(normalizeCode(42)).toBeNull();
  });
});

describe("validateCouponInput", () => {
  const flat = {
    code: "save50",
    description: "₹50 off",
    type: "flat",
    discountPaise: 5000,
    minOrderPaise: 30000,
  };

  it("normalises a flat coupon", () => {
    expect(validateCouponInput(flat)).toMatchObject({
      code: "SAVE50",
      type: "flat",
      discountPaise: 5000,
      percent: 0,
      maxDiscountPaise: null,
      usageLimit: null,
      isActive: true,
    });
  });

  it("needs a percent for percent coupons and keeps the cap", () => {
    expect(() => validateCouponInput({ ...flat, type: "percent" })).toThrow(/percent/);
    expect(() => validateCouponInput({ ...flat, type: "percent", percent: 95 })).toThrow(
      /Percent/,
    );
    expect(
      validateCouponInput({ ...flat, type: "percent", percent: 20, maxDiscountPaise: 10000 }),
    ).toMatchObject({ percent: 20, maxDiscountPaise: 10000, discountPaise: 0 });
  });

  it("rejects bad codes, a discount above the minimum and backwards dates", () => {
    expect(() => validateCouponInput({ ...flat, code: "x" })).toThrow(/Code/);
    expect(() => validateCouponInput({ ...flat, discountPaise: 40000 })).toThrow(/minimum/);
    expect(() =>
      validateCouponInput({ ...flat, startAtMs: NOW, expiresAtMs: NOW - 1 }),
    ).toThrow(/after the start/);
  });

  it("rejects limits that aren't positive whole numbers", () => {
    expect(() => validateCouponInput({ ...flat, usageLimit: 0 })).toThrow(/Total uses/);
    expect(() => validateCouponInput({ ...flat, perUserLimit: 1.5 })).toThrow(/per customer/);
  });
});
