import { Timestamp } from "firebase-admin/firestore";
import { describe, expect, it } from "vitest";
import { doorWaitLeftMs, nearAnyStore } from "../../src/dispatch/delivery";
import { cancelledTripPaise, goodsLeftStore } from "../../src/dispatch/earnings";
import { DEFAULT_RIDER_CONFIG, parseRiderConfig } from "../../src/dispatch/model";
import { settledWeek } from "../../src/dispatch/pay";

describe("cancelled after pickup", () => {
  it("knows when the goods left the store", () => {
    expect(goodsLeftStore({ status: "placed" })).toBe(false);
    expect(goodsLeftStore({ status: "packed", riderStage: "at_store" })).toBe(false);
    expect(goodsLeftStore({ status: "out_for_delivery" })).toBe(true);
    expect(goodsLeftStore({ status: "packed", riderStage: "returning" })).toBe(true);
    // One of two stores collected.
    expect(goodsLeftStore({ status: "placed", pickups: { s1: { pickedAt: Timestamp.now() }, s2: {} } })).toBe(true);
  });

  it("pays a share of the trip, clamped", () => {
    expect(cancelledTripPaise(4000, 100)).toBe(4000);
    expect(cancelledTripPaise(4001, 50)).toBe(2001);
    expect(cancelledTripPaise(4000, 150)).toBe(4000);
    expect(cancelledTripPaise(-10, 100)).toBe(0);
  });

  it("defaults to the full trip and lets ops change it", () => {
    expect(DEFAULT_RIDER_CONFIG.cancelledTripPercent).toBe(100);
    expect(parseRiderConfig({ cancelledTripPercent: 40 }).cancelledTripPercent).toBe(40);
    expect(parseRiderConfig({ cancelledTripPercent: 500 }).cancelledTripPercent).toBe(100);
  });
});

describe("failed delivery", () => {
  const now = Date.UTC(2026, 10, 19, 10, 0);

  it("makes the rider wait at the door before 'customer unreachable'", () => {
    expect(doorWaitLeftMs(undefined, 10, now)).toBe(10 * 60_000);
    expect(doorWaitLeftMs(Timestamp.fromMillis(now - 4 * 60_000), 10, now)).toBe(6 * 60_000);
    expect(doorWaitLeftMs(Timestamp.fromMillis(now - 11 * 60_000), 10, now)).toBe(0);
  });

  it("checks the rider is back at one of the order's stores", () => {
    const order = { pickups: { s1: { lat: 23.3324, lng: 86.3617 }, s2: { lat: 23.4, lng: 86.4 } } };
    expect(nearAnyStore(order, { lat: 23.3325, lng: 86.3618 })).toBe(true);
    expect(nearAnyStore(order, { lat: 23.35, lng: 86.37 })).toBe(false);
    // No store positions on record (older Zyppi orders): not blocked.
    expect(nearAnyStore({}, { lat: 23.35, lng: 86.37 })).toBe(true);
  });
});

describe("weekly settlement", () => {
  it("settles the week that just ended (Mon–Sun, India time)", () => {
    // Monday 2026-11-23 06:00 IST → week of Monday 2026-11-16.
    expect(settledWeek(new Date("2026-11-23T00:30:00Z"))).toBe("2026-11-16");
    // Sunday night 23:30 IST still belongs to the week of 11-16 → previous week 11-09.
    expect(settledWeek(new Date("2026-11-22T18:00:00Z"))).toBe("2026-11-09");
  });
});

describe("late sellers", async () => {
  const { lateCancelDue } = await import("../../src/marketplace/seller_orders");
  const { marketplaceConfigFrom } = await import("../../src/marketplace/ranking");
  const now = Date.UTC(2026, 10, 19, 10, 0);

  it("cancels only when switched on and the wait is over", () => {
    expect(lateCancelDue(now - 20 * 60_000, 0, now)).toBe(false); // off by default
    expect(lateCancelDue(now - 9 * 60_000, 10, now)).toBe(false);
    expect(lateCancelDue(now - 10 * 60_000, 10, now)).toBe(true);
    expect(lateCancelDue(null, 10, now)).toBe(false);
    expect(marketplaceConfigFrom(undefined).autoCancelLateMinutes).toBe(0);
    expect(marketplaceConfigFrom({ autoCancelLateMinutes: 15 }).autoCancelLateMinutes).toBe(15);
  });
});
