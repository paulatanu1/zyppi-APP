import { describe, expect, it } from "vitest";
import {
  DEFAULT_CLAIMS_CONFIG as CFG,
  autoReturnDecision,
  claimsConfigFrom,
  newReturnCode,
  restockPlan,
  sellerAtFault,
  splitByStore,
} from "../../src/returns/model";

const line = (over: Partial<Parameters<typeof splitByStore>[0][number]> = {}) => ({
  index: 0,
  productId: "p1",
  variantId: "v1",
  name: "Milk",
  unit: "1 L",
  quantity: 2,
  kind: "damaged",
  sellerId: "zyppi",
  amountPaise: 10000,
  ...over,
});

describe("automatic return or ops review", () => {
  it("wrong / damaged / expired within the limits: automatic", () => {
    expect(autoReturnDecision({ kinds: ["damaged", "wrong"], amountPaise: 50_000, claims30d: 2, config: CFG })).toEqual({
      auto: true,
    });
  });
  it("missing items always go to ops", () => {
    expect(autoReturnDecision({ kinds: ["damaged", "missing"], amountPaise: 100, claims30d: 1, config: CFG }).auto).toBe(false);
  });
  it("over ₹500 goes to ops", () => {
    const d = autoReturnDecision({ kinds: ["damaged"], amountPaise: 50_001, claims30d: 1, config: CFG });
    expect(d).toEqual({ auto: false, reason: "Over the automatic limit of ₹500" });
  });
  it("3 claims in 30 days (this one included) goes to ops", () => {
    expect(autoReturnDecision({ kinds: ["expired"], amountPaise: 100, claims30d: 3, config: CFG })).toEqual({
      auto: false,
      reason: "3 claims in 30 days",
    });
  });
  it("can be switched off, and limits come from config/claims", () => {
    expect(autoReturnDecision({ kinds: ["wrong"], amountPaise: 1, claims30d: 1, config: { ...CFG, autoReturns: false } }).auto).toBe(false);
    expect(claimsConfigFrom({ autoMaxPaise: 100_000, autoMaxClaims30d: 0, autoReturns: "yes" })).toEqual({
      autoReturns: true,
      autoMaxPaise: 100_000,
      autoMaxClaims30d: 1,
    });
    expect(claimsConfigFrom(undefined)).toEqual(CFG);
  });
});

describe("which store each unit goes back to", () => {
  it("a line filled by one store", () => {
    const m = splitByStore([line()], [{ storeId: "s1", productId: "p1", variantId: "v1", quantity: 3 }], "s1");
    expect([...m.keys()]).toEqual(["s1"]);
    expect(m.get("s1")![0]).toMatchObject({ quantity: 2, amountPaise: 10000 });
  });

  it("a line split across two stores, value split by units", () => {
    const m = splitByStore(
      [line({ quantity: 3, amountPaise: 1000 })],
      [
        { storeId: "s1", productId: "p1", variantId: "v1", quantity: 1 },
        { storeId: "s2", productId: "p1", variantId: "v1", quantity: 2 },
      ],
      "s1",
    );
    expect(m.get("s1")![0]).toMatchObject({ quantity: 1, amountPaise: 333 });
    expect(m.get("s2")![0]).toMatchObject({ quantity: 2, amountPaise: 667 });
  });

  it("two lines, each to its own seller's shop", () => {
    const m = splitByStore(
      [line(), line({ index: 1, productId: "p2", variantId: "v2", sellerId: "sima", quantity: 1, amountPaise: 4000 })],
      [
        { storeId: "dark", productId: "p1", variantId: "v1", quantity: 2, sellerId: "zyppi" },
        { storeId: "sima-shop", productId: "p2", variantId: "v2", quantity: 1, sellerId: "sima" },
      ],
      "dark",
    );
    expect(m.get("dark")!.map((l) => l.index)).toEqual([0]);
    expect(m.get("sima-shop")!.map((l) => l.index)).toEqual([1]);
  });

  it("older orders without a matching allocation fall back to the first store", () => {
    const m = splitByStore([line()], [], "s9");
    expect(m.get("s9")![0].quantity).toBe(2);
  });
});

describe("at the store", () => {
  it("damaged and expired are written off by default, wrong items go back on the shelf", () => {
    const lines = [
      { index: 0, kind: "damaged" },
      { index: 1, kind: "wrong" },
      { index: 2, kind: "expired" },
    ];
    expect(restockPlan(lines, undefined)).toEqual({ "0": "write_off", "1": "shelf", "2": "write_off" });
    expect(restockPlan(lines, { "0": "shelf", "1": "write_off", "2": "bin" })).toEqual({
      "0": "shelf",
      "1": "write_off",
      "2": "write_off",
    });
  });

  it("outside sellers are charged for their own mistakes; Zyppi's stock has nobody to charge", () => {
    expect(sellerAtFault("sima", [{ kind: "damaged" }])).toBe(true);
    expect(sellerAtFault("zyppi", [{ kind: "damaged" }])).toBe(false);
    expect(sellerAtFault("sima", [{ kind: "missing" }])).toBe(false);
    expect(sellerAtFault("sima", [])).toBe(false);
  });

  it("codes are 4 digits", () => {
    for (let i = 0; i < 50; i++) expect(newReturnCode()).toMatch(/^\d{4}$/);
  });
});
