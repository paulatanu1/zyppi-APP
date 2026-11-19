import { describe, expect, it } from "vitest";
import { LIMITS, RateLimiter, rateLimit } from "../../src/shared/rate_limit";

describe("rate limits", () => {
  it("allows the limit per minute, then refuses until the window resets", () => {
    const l = new RateLimiter();
    const t = 1_000_000;
    for (let i = 0; i < 3; i++) expect(l.take("a", 3, t + i)).toBe(true);
    expect(l.take("a", 3, t + 10)).toBe(false);
    expect(l.take("b", 3, t + 10)).toBe(true); // per caller
    expect(l.take("a", 3, t + 60_000)).toBe(true); // new window
  });

  it("throws resource-exhausted for a limited callable", () => {
    const l = new RateLimiter();
    for (let i = 0; i < LIMITS.checkCoupon; i++) rateLimit("checkCoupon", "u1", 5, l);
    expect(() => rateLimit("checkCoupon", "u1", 6, l)).toThrow("RATE_LIMITED");
    expect(() => rateLimit("placeOrder", "u1", 6, l)).not.toThrow(); // separate bucket
  });
});
