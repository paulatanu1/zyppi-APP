import { describe, expect, it } from "vitest";
import { findServiceableArea, haversineMeters } from "../../src/shared/geo";

const purulia = { id: "p", isActive: true, centerLat: 23.3324, centerLng: 86.3617, radiusMeters: 6000 };
const far = { id: "f", isActive: true, centerLat: 28.6, centerLng: 77.2, radiusMeters: 6000 };

describe("geo", () => {
  it("measures ~0 for the same point", () => {
    expect(haversineMeters(23.3, 86.3, 23.3, 86.3)).toBeCloseTo(0);
  });

  it("finds the covering area and ignores inactive ones", () => {
    expect(findServiceableArea([far, purulia], 23.34, 86.37)?.id).toBe("p");
    expect(findServiceableArea([{ ...purulia, isActive: false }], 23.34, 86.37)).toBeNull();
    expect(findServiceableArea([purulia], 22.57, 88.36)).toBeNull();
  });
});
