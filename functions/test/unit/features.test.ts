import { HttpsError } from "firebase-functions/https";
import { describe, expect, it } from "vitest";
import {
  DEFAULT_FEATURES,
  METHOD_UNAVAILABLE,
  MAINTENANCE_DEFAULT_MESSAGE,
  applyFeaturesPatch,
  assertCanOrder,
  parseFeatures,
} from "../../src/shared/features";
import { roleAllows, roleOf } from "../../src/shared/roles";

describe("parseFeatures", () => {
  it("treats a missing doc as everything on", () => {
    expect(parseFeatures(undefined)).toEqual(DEFAULT_FEATURES);
  });

  it("falls back per field on bad data", () => {
    const f = parseFeatures({
      placesSearch: "no",
      supportBot: false,
      payments: { upi: false },
      closedAreaIds: ["a", 3],
      minAppVersion: "1.2",
    });
    expect(f.placesSearch).toBe(true);
    expect(f.supportBot).toBe(false);
    expect(f.payments).toEqual({ upi: false, card: true });
    expect(f.closedAreaIds).toEqual(["a"]);
    expect(f.minAppVersion).toBeNull();
  });
});

describe("applyFeaturesPatch", () => {
  const base = DEFAULT_FEATURES;

  it("applies nested partial updates without touching the rest", () => {
    const next = applyFeaturesPatch(base, {
      payments: { card: false },
      maintenance: { enabled: true, message: "  Back at 6 pm  " },
      closedAreaIds: ["x", "x", "y"],
      minAppVersion: "1.4.0",
    });
    expect(next.payments).toEqual({ upi: true, card: false });
    expect(next.maintenance).toEqual({ enabled: true, message: "Back at 6 pm" });
    expect(next.closedAreaIds).toEqual(["x", "y"]);
    expect(next.minAppVersion).toBe("1.4.0");
    expect(base.payments.card).toBe(true); // not mutated
  });

  it("rejects unknown keys and wrong types", () => {
    expect(() => applyFeaturesPatch(base, { placesSearh: false })).toThrow(HttpsError);
    expect(() => applyFeaturesPatch(base, { supportBot: "off" })).toThrow("Invalid supportBot");
    expect(() => applyFeaturesPatch(base, { payments: { cod: false } })).toThrow(
      "Invalid payments.cod",
    );
    expect(() => applyFeaturesPatch(base, { minAppVersion: "v2" })).toThrow();
    expect(() => applyFeaturesPatch(base, { maintenance: { message: "x".repeat(301) } })).toThrow();
    expect(() => applyFeaturesPatch(base, null)).toThrow("Invalid patch");
  });
});

describe("assertCanOrder", () => {
  it("blocks every order during maintenance with the admin's message", () => {
    const f = applyFeaturesPatch(DEFAULT_FEATURES, { maintenance: { enabled: true } });
    expect(() => assertCanOrder(f, "Cash on delivery")).toThrow(MAINTENANCE_DEFAULT_MESSAGE);
    const g = applyFeaturesPatch(f, { maintenance: { message: "Stock-taking" } });
    expect(() => assertCanOrder(g, "UPI")).toThrow("Stock-taking");
  });

  it("blocks only the switched-off online method", () => {
    const f = applyFeaturesPatch(DEFAULT_FEATURES, { payments: { upi: false } });
    expect(() => assertCanOrder(f, "UPI")).toThrow(METHOD_UNAVAILABLE);
    expect(() => assertCanOrder(f, "Credit or debit card")).not.toThrow();
    expect(() => assertCanOrder(f, "Cash on delivery")).not.toThrow();
  });
});

describe("roles", () => {
  it("reads the role claim and maps the legacy admin claim", () => {
    expect(roleOf({ role: "finance" })).toBe("finance");
    expect(roleOf({ admin: true })).toBe("super_admin");
    expect(roleOf({ role: "rider" })).toBeNull();
    expect(roleOf(undefined)).toBeNull();
  });

  it("lets super_admin through and checks the list for others", () => {
    expect(roleAllows("super_admin", [])).toBe(true);
    expect(roleAllows("ops", [])).toBe(false);
    expect(roleAllows("support", ["support", "ops"])).toBe(true);
    expect(roleAllows(null, ["ops"])).toBe(false);
  });
});
