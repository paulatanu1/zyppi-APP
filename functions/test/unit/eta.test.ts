import { describe, expect, it } from "vitest";
import { validateStore } from "../../src/admin/settings_model";
import { DEFAULT_PREP_MINUTES, RIDER_REACH_MINUTES, estimateEtaMinutes } from "../../src/dispatch/pickups";

describe("order ETA", () => {
  it("is packing (or the rider reaching the store) plus the ride", () => {
    // 3 km straight → 3.9 km by road at 300 m/min = 13 min; slowest store packs in 12.
    expect(estimateEtaMinutes({ slotMinutes: 10, prepMinutes: [5, 12], routeM: 3000 })).toBe(12 + 13);
    // Quick packing: the rider still has to get there.
    expect(estimateEtaMinutes({ slotMinutes: null, prepMinutes: [1], routeM: 0 })).toBe(RIDER_REACH_MINUTES + 1);
  });

  it("never promises less than the slot and defaults packing time", () => {
    expect(estimateEtaMinutes({ slotMinutes: 60, prepMinutes: [null], routeM: 1000 })).toBe(60);
    expect(estimateEtaMinutes({ slotMinutes: 0, prepMinutes: [undefined], routeM: 1000 })).toBe(DEFAULT_PREP_MINUTES + 5);
    expect(estimateEtaMinutes({ slotMinutes: null, prepMinutes: [], routeM: 0 })).toBeNull();
  });

  it("stores can set a packing time", () => {
    const base = { name: "Dark store", serviceAreaId: "a1" };
    expect(validateStore({ ...base, prepMinutes: 12 }).prepMinutes).toBe(12);
    expect(validateStore(base).prepMinutes).toBeNull();
    expect(() => validateStore({ ...base, prepMinutes: 999 })).toThrow("Packing time");
  });
});
