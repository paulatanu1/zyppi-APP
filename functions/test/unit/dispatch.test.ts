import { describe, expect, it } from "vitest";
import { istDayAndWeek } from "../../src/dispatch/earnings";
import {
  type Candidate,
  DEFAULT_RIDER_CONFIG,
  distanceM,
  earningFor,
  etaMinutes,
  impossibleJump,
  istHhmm,
  newHandoverCode,
  parseRiderConfig,
  pickRider,
  requirePoint,
} from "../../src/dispatch/model";

const store = { lat: 23.3324, lng: 86.3617 }; // Purulia
// ~0.0045° latitude ≈ 500 m.
const at = (dLat: number) => ({ lat: store.lat + dLat, lng: store.lng });
const now = Date.UTC(2026, 10, 16, 6, 0);

const rider = (uid: string, dLat: number, over: Partial<Candidate> = {}): Candidate => ({
  uid,
  ...at(dLat),
  pingAtMs: now - 30_000,
  activeOrderId: null,
  offerOrderId: null,
  onBreakUntilMs: null,
  idleSinceMs: now - 60_000,
  inSlot: false,
  ...over,
});

const cfg = DEFAULT_RIDER_CONFIG.dispatch;

describe("geo", () => {
  it("measures straight-line distance and road ETA", () => {
    expect(distanceM(store, at(0.009))).toBeGreaterThan(950);
    expect(distanceM(store, at(0.009))).toBeLessThan(1050);
    expect(etaMinutes(0)).toBe(1);
    expect(etaMinutes(1000)).toBe(5); // 1.3 km at 18 km/h
  });

  it("flags impossible GPS jumps", () => {
    expect(impossibleJump(store, at(0.009), 60)).toBe(false); // 1 km/min
    expect(impossibleJump(store, at(0.09), 30)).toBe(true); // 10 km in 30 s
    expect(impossibleJump(null, store, 5)).toBe(false);
  });

  it("validates positions from the app", () => {
    expect(requirePoint({ lat: 23.3, lng: 86.3, accuracy: 12.4 })).toEqual({ lat: 23.3, lng: 86.3, accuracy: 12 });
    expect(() => requirePoint({ lat: 0, lng: 0 })).toThrow(/LOCATION_REQUIRED/);
    expect(() => requirePoint({ lat: "x" })).toThrow();
  });
});

describe("pickRider", () => {
  it("picks the nearest free rider with a fresh position", () => {
    const pick = pickRider([rider("far", 0.018), rider("near", 0.002)], store, cfg, [], now);
    expect(pick?.uid).toBe("near");
  });

  it("skips busy, offered, on-break, stale, tried and out-of-range riders", () => {
    const riders = [
      rider("busy", 0.001, { activeOrderId: "o1" }),
      rider("offered", 0.001, { offerOrderId: "o2" }),
      rider("break", 0.001, { onBreakUntilMs: now + 60_000 }),
      rider("stale", 0.001, { pingAtMs: now - 10 * 60_000 }),
      rider("tried", 0.001),
      rider("far", 0.1), // ~11 km
      rider("ok", 0.03),
    ];
    expect(pickRider(riders, store, cfg, ["tried"], now)?.uid).toBe("ok");
    expect(pickRider(riders.slice(0, 6), store, cfg, ["tried"], now)).toBeNull();
  });

  it("within 500 m prefers booked-slot riders, then the longest idle", () => {
    const a = rider("idle-short", 0.001, { idleSinceMs: now - 60_000 });
    const b = rider("idle-long", 0.002, { idleSinceMs: now - 30 * 60_000 });
    expect(pickRider([a, b], store, cfg, [], now)?.uid).toBe("idle-long");
    const c = rider("slot", 0.003, { inSlot: true });
    expect(pickRider([a, b, c], store, cfg, [], now)?.uid).toBe("slot");
    // A slot rider 2 km away loses to a free one next door.
    const d = rider("slot-far", 0.018, { inSlot: true });
    expect(pickRider([a, d], store, cfg, [], now)?.uid).toBe("idle-short");
  });
});

describe("parseRiderConfig", () => {
  it("defaults everything", () => {
    expect(parseRiderConfig(undefined)).toEqual(DEFAULT_RIDER_CONFIG);
  });

  it("clamps and cleans admin values", () => {
    const c = parseRiderConfig({
      dispatch: { auto: false, assignAt: "packed", offerSeconds: 5, maxOffers: 99, maxDistanceKm: 3 },
      emergency: { accident: " 1033 ", ambulance: "" },
      pay: { default: { basePaise: 3000, perKmPaise: 800, minPaise: 3000, maxPaise: 100 }, a1: { basePaise: 2000 } },
      peak: [{ start: "18:00", end: "21:00", extraPaise: 500 }, { start: "bad", end: "x" }],
      surge: { enabled: true, extraPaise: 1500 },
    });
    expect(c.dispatch).toMatchObject({ auto: false, assignAt: "packed", offerSeconds: 15, maxOffers: 10, maxDistanceKm: 3 });
    expect(c.emergency).toEqual({ ambulance: "108", police: "112", accident: "1033" });
    expect(c.pay.default.maxPaise).toBe(3000); // never below min
    expect(c.pay.a1.basePaise).toBe(2000);
    expect(c.peak).toHaveLength(1);
    expect(c.surge).toMatchObject({ enabled: true, extraPaise: 1500 });
  });
});

describe("earningFor", () => {
  const config = parseRiderConfig({
    pay: { default: { basePaise: 2500, perKmPaise: 600, minPaise: 3000, maxPaise: 8000 } },
    peak: [{ start: "18:00", end: "21:00", extraPaise: 500 }],
  });
  // 06:00 UTC = 11:30 IST; 13:30 UTC = 19:00 IST.
  const morning = new Date(Date.UTC(2026, 10, 16, 6, 0));
  const evening = new Date(Date.UTC(2026, 10, 16, 13, 30));

  it("pays base + per road km, clamped to min / max", () => {
    expect(earningFor(config, "a1", 0, morning).totalPaise).toBe(3000); // min
    const e = earningFor(config, "a1", 2000, morning); // 2.6 km by road
    expect(e.distanceM).toBe(2600);
    expect(e.totalPaise).toBe(2500 + 1560);
    expect(e.basePaise + e.distancePaise).toBe(e.totalPaise);
    expect(earningFor(config, "a1", 20000, morning).totalPaise).toBe(8000); // max
  });

  it("adds peak-hour and surge extras", () => {
    expect(earningFor(config, "a1", 2000, evening).peakPaise).toBe(500);
    const surge = parseRiderConfig({ surge: { enabled: true, extraPaise: 1000 } });
    expect(earningFor(surge, "a1", 0, morning).surgePaise).toBe(1000);
  });

  it("uses India time", () => {
    expect(istHhmm(evening)).toBe("19:00");
    expect(istDayAndWeek(new Date(Date.UTC(2026, 10, 15, 20, 0)))).toEqual({ day: "2026-11-16", week: "2026-11-16" });
    expect(istDayAndWeek(new Date(Date.UTC(2026, 10, 15, 6, 0)))).toEqual({ day: "2026-11-15", week: "2026-11-09" });
  });
});

it("handover codes are 4 digits", () => {
  for (let i = 0; i < 50; i++) expect(newHandoverCode()).toMatch(/^\d{4}$/);
});
