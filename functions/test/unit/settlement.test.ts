import { describe, expect, it } from "vitest";
import {
  DEFAULT_SETTLEMENT as CFG,
  addMonths,
  applyFeePayment,
  payoutSplit,
  percentOf,
  remindersDue,
  sellerCredit,
  settlementConfigFrom,
  subscriptionStatus,
} from "../../src/marketplace/settlement_model";
import { ZYPPI_SELLER, sellerCanSell } from "../../src/marketplace/offers";

const DAY = 86_400_000;

describe("seller credit on delivery", () => {
  it("pays the seller's price minus TCS (GSTIN only) and TDS; Zyppi's add-on never reaches the seller", () => {
    // ₹116 to the customer, ₹110 is the seller's price (₹6 add-on).
    const c = sellerCredit({ itemTotalPaise: 11600, payoutPaise: 11000 }, true, CFG);
    expect(c).toEqual({ grossPaise: 11600, payoutPaise: 11000, tcsPaise: 55, tdsPaise: 11, netPaise: 10934 });
    expect(sellerCredit({ itemTotalPaise: 11600, payoutPaise: 11000 }, false, CFG).tcsPaise).toBe(0);
  });

  it("rounds percents half up to the paisa", () => {
    expect(percentOf(100, 0.5)).toBe(1); // 0.5 paise
    expect(percentOf(99, 0.5)).toBe(0); // 0.495
    expect(percentOf(12345, 0.1)).toBe(12); // 12.345
  });

  it("reads config with safe defaults", () => {
    expect(settlementConfigFrom({ settlement: { holdDays: 3, tcsPercent: 99 } })).toEqual({ ...CFG, holdDays: 3 });
  });
});

describe("payouts", () => {
  it("takes dues off first and refuses below the minimum", () => {
    expect(payoutSplit(50000, 14900, 10000)).toEqual({ duesDeductedPaise: 14900, payablePaise: 35100 });
    expect(payoutSplit(20000, 14900, 10000)).toBeNull(); // ₹51 left < ₹100
    expect(payoutSplit(20000, 0, 10000)).toEqual({ duesDeductedPaise: 0, payablePaise: 20000 });
  });
});

describe("subscription fees", () => {
  const periods = [
    { id: "jan", feePaise: 50000, paidPaise: 20000, startMs: 1 },
    { id: "apr", feePaise: 50000, paidPaise: 0, startMs: 2 },
  ];

  it("pays the oldest period first", () => {
    expect(applyFeePayment(periods, 40000)).toEqual({ paid: { jan: 50000, apr: 10000 }, leftPaise: 0 });
    expect(applyFeePayment(periods, 100000)).toEqual({ paid: { jan: 50000, apr: 50000 }, leftPaise: 20000 });
  });

  it("is active when paid, grace for graceDays, then expired (offers hidden)", () => {
    const start = Date.UTC(2026, 10, 1);
    expect(subscriptionStatus(null, start + 30 * DAY, 3)).toBe("active");
    expect(subscriptionStatus(start, start + 2 * DAY, 3)).toBe("grace");
    expect(subscriptionStatus(start, start + 3 * DAY, 3)).toBe("expired");
    const seller = { ...ZYPPI_SELLER, model: "subscription" };
    expect(sellerCanSell({ ...seller, subscriptionStatus: "grace" })).toBe(true);
    expect(sellerCanSell({ ...seller, subscriptionStatus: "expired" })).toBe(false);
    expect(sellerCanSell({ ...seller, licenceExpired: true })).toBe(false);
  });

  it("adds months, clamping to the month's last day", () => {
    expect(new Date(addMonths(Date.UTC(2026, 0, 31), 1)).toISOString().slice(0, 10)).toBe("2026-02-28");
    expect(new Date(addMonths(Date.UTC(2026, 10, 17), 6)).toISOString().slice(0, 10)).toBe("2027-05-17");
  });

  it("reminds 7, 3 and 1 days before the end, once each", () => {
    const end = Date.UTC(2026, 11, 1);
    expect(remindersDue(end, end - 6 * DAY, [])).toEqual([7]);
    expect(remindersDue(end, end - 6 * DAY, [7])).toEqual([]);
    expect(remindersDue(end, end - 0.5 * DAY, [7])).toEqual([3, 1]);
    expect(remindersDue(end, end + DAY, [])).toEqual([]);
  });
});
