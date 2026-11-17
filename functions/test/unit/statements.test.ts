import { describe, expect, it } from "vitest";
import { buildStatement, monthRange, taxCsv } from "../../src/marketplace/statements_model";

describe("buildStatement", () => {
  it("adds up a month of the ledger", () => {
    const s = buildStatement([
      { type: "order", grossPaise: 11000, payoutPaise: 10000, tcsPaise: 50, tdsPaise: 10, amountPaise: 9940 },
      { type: "order", grossPaise: 5500, payoutPaise: 5000, tcsPaise: 25, tdsPaise: 5, amountPaise: 4970 },
      { type: "return", grossPaise: -5500, payoutPaise: -5000, tcsPaise: -25, tdsPaise: -5, amountPaise: -4970 },
      { type: "adjustment", amountPaise: -500 },
      { type: "payout", amountPaise: -9000, duesPaise: 1000 },
    ]);
    expect(s.orders).toBe(2);
    expect(s.salesPaise).toBe(11000);
    expect(s.tcsPaise).toBe(50);
    expect(s.tdsPaise).toBe(10);
    expect(s.returnsPaise).toBe(-4970);
    expect(s.netPaise).toBe(9940 - 500);
    expect(s.paidOutPaise).toBe(8000);
    expect(s.feesDeductedPaise).toBe(1000);
  });
});

describe("monthRange", () => {
  it("covers the whole month, leap years included", () => {
    expect(monthRange("2028-02")).toEqual({ from: "2028-02-01", to: "2028-02-29" });
    expect(monthRange("2026-11")).toEqual({ from: "2026-11-01", to: "2026-11-30" });
    expect(monthRange("2026-13")).toBeNull();
    expect(monthRange(42)).toBeNull();
  });
});

describe("taxCsv", () => {
  it("quotes commas and blocks spreadsheet formulas", () => {
    const csv = taxCsv("2026-11", [
      { sellerId: "s1", shopName: "Ram, & Sons", ownerName: "=HYPERLINK(1)", gstin: "", pan: "ABCDE1234F", orders: 3, salesPaise: 12345, tcsPaise: 62, tdsPaise: 12 },
    ]);
    const line = csv.split("\n")[1];
    expect(line).toContain('"Ram, & Sons"');
    expect(line).toContain("'=HYPERLINK(1)");
    expect(line).toContain("123.45");
  });
});
