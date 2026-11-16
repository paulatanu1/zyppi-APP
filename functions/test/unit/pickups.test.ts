import { describe, expect, it } from "vitest";
import { DEFAULT_RIDER_CONFIG, earningFor } from "../../src/dispatch/model";
import { orderStops } from "../../src/dispatch/earnings";
import {
  type StoreInfo,
  allStopsPicked,
  buildPickupStops,
  newPickupCode,
  pathM,
  routeDistanceM,
  routeOrder,
  sellerOnlyOrderReady,
  sellersToAccept,
  stopReady,
} from "../../src/dispatch/pickups";
import { myStops, sellerOrderView } from "../../src/marketplace/seller_orders";

// Along a line east of Purulia: dark store (west), Sima (middle), customer (east).
const P = (lng: number) => ({ lat: 23.33, lng });
const stores = new Map<string, StoreInfo>([
  ["dark", { id: "dark", name: "Zyppi Dark Store", sellerId: "zyppi", address: "A", phone: null, ...P(86.30) }],
  ["seller_sima", { id: "seller_sima", name: "Sima Store", sellerId: "sima", address: "B", phone: "+91", ...P(86.34) }],
  ["old", { id: "old", name: "Old store", sellerId: null, address: null, phone: null, lat: null, lng: null }],
]);
const alloc = (storeId: string, variantId: string, take: number) => ({
  storeId,
  productId: `p-${variantId}`,
  variantId,
  name: variantId,
  unit: "1 kg",
  take,
});

describe("routeOrder", () => {
  it("visits stores in the order that ends nearest the customer", () => {
    const r = routeOrder(
      [
        { id: "near", point: P(86.34) },
        { id: "far", point: P(86.30) },
      ],
      P(86.38),
    );
    expect(r.map((s) => s.id)).toEqual(["far", "near"]);
  });

  it("keeps stops without a location last", () => {
    expect(routeOrder([{ id: "x", point: null }, { id: "a", point: P(86.3) }], null).map((s) => s.id)).toEqual(["a", "x"]);
  });
});

describe("buildPickupStops", () => {
  it("one stop per store with merged items; only a seller's shop needs a code", () => {
    const { stops, order } = buildPickupStops(
      [alloc("seller_sima", "v1", 2), alloc("dark", "v2", 1), alloc("dark", "v2", 3), alloc("dark", "v3", 0)],
      stores,
      P(86.38),
    );
    expect(order).toEqual(["dark", "seller_sima"]);
    expect(stops.dark).toMatchObject({ seq: 1, sellerId: null, otpRequired: false, status: "pending" });
    expect(stops.dark.items).toEqual([{ productId: "p-v2", variantId: "v2", name: "v2", unit: "1 kg", quantity: 4 }]);
    expect(stops.seller_sima).toMatchObject({ seq: 2, sellerId: "sima", otpRequired: true, storeName: "Sima Store" });
    expect(sellersToAccept(stops)).toEqual(["sima"]);
  });

  it("a Zyppi-only order has nobody to accept", () => {
    const { stops } = buildPickupStops([alloc("dark", "v1", 1), alloc("old", "v1", 1)], stores, null);
    expect(sellersToAccept(stops)).toEqual([]);
    expect(Object.values(stops).every((s) => !s.otpRequired)).toBe(true);
  });
});

describe("stop readiness", () => {
  it("a seller's shop waits for the seller; a Zyppi store for ops' packed", () => {
    expect(stopReady({ otpRequired: true, status: "accepted" }, "packed")).toBe(false);
    expect(stopReady({ otpRequired: true, status: "ready" }, "placed")).toBe(true);
    expect(stopReady({ otpRequired: false }, "placed")).toBe(false);
    expect(stopReady({ otpRequired: false }, "packed")).toBe(true);
    expect(stopReady(undefined, "packed")).toBe(true); // older orders
  });

  it("a seller-only order is packed when every shop is ready; mixed orders wait for ops", () => {
    expect(sellerOnlyOrderReady({ a: { otpRequired: true, status: "ready" }, b: { otpRequired: true, status: "picked" } })).toBe(true);
    expect(sellerOnlyOrderReady({ a: { otpRequired: true, status: "ready" }, b: { otpRequired: true, status: "accepted" } })).toBe(false);
    expect(sellerOnlyOrderReady({ a: { otpRequired: true, status: "ready" }, z: { otpRequired: false } })).toBe(false);
    expect(sellerOnlyOrderReady({})).toBe(false);
  });

  it("out for delivery only after every stop", () => {
    expect(allStopsPicked(["a", "b"], new Set(["a"]))).toBe(false);
    expect(allStopsPicked(["a", "b"], new Set(["a", "b"]))).toBe(true);
  });

  it("codes are 4 digits", () => {
    for (let i = 0; i < 50; i++) expect(newPickupCode()).toMatch(/^\d{4}$/);
  });
});

describe("rider pay over the whole route", () => {
  const order = {
    pickupOrder: ["dark", "seller_sima"],
    pickups: { dark: { ...P(86.30) }, seller_sima: { ...P(86.34) } },
  };

  it("adds every leg and pays the extra stop when configured", () => {
    const stops = orderStops(order);
    expect(stops.map((s) => s.storeId)).toEqual(["dark", "seller_sima"]);
    const route = routeDistanceM(stops, P(86.38));
    expect(route).toBeCloseTo(pathM([P(86.30), P(86.34), P(86.38)]), 3);
    const at = new Date("2026-11-17T06:00:00Z");
    const base = earningFor(DEFAULT_RIDER_CONFIG, "x", route, at, 1);
    expect(base.pickupPaise).toBe(0); // default: no extra-stop pay
    const paid = earningFor({ ...DEFAULT_RIDER_CONFIG, extraPickupPaise: 1000 }, "x", route, at, 1);
    expect(paid.pickupPaise).toBe(1000);
    expect(paid.totalPaise).toBe(base.totalPaise + 1000);
  });

  it("older orders have no stops (pay falls back to the first store)", () => {
    expect(orderStops({})).toEqual([]);
  });
});

describe("seller's view of an order", () => {
  const order = {
    status: "placed",
    userId: "customer-uid",
    address: { line1: "Secret street", lat: 1, lng: 2 },
    contactPhone: "+91999",
    sellerStatus: { sima: "accepted" },
    sellerAcceptDeadline: "t",
    items: [
      { productId: "p1", variantId: "v1", name: "Milk", unit: "1 L", quantity: 2, payoutPaise: 5500, sellerId: "sima", pricePaise: 5800, marginPaise: 300 },
      { productId: "p2", variantId: "v2", name: "Rice", unit: "1 kg", quantity: 1, payoutPaise: 0, sellerId: "zyppi", pricePaise: 9000 },
    ],
    pickups: {
      seller_sima: { otpRequired: true, sellerId: "sima", status: "ready", reachedAt: "t" },
      dark: { otpRequired: false, sellerId: null },
    },
    riderName: "Raju",
  };

  it("shows only the seller's items, payout and stop — no customer details or Zyppi margin", () => {
    expect(myStops(order.pickups, "sima")).toEqual(["seller_sima"]);
    const v = sellerOrderView(order, "sima");
    expect(v).toMatchObject({
      sellerStatus: "accepted",
      payoutPaise: 11000,
      stop: { storeId: "seller_sima", status: "ready", riderAtStore: true },
      riderName: "Raju",
    });
    expect((v.items as unknown[]).length).toBe(1);
    const json = JSON.stringify(v);
    for (const secret of ["Secret street", "+91999", "customer-uid", "marginPaise", "pricePaise"]) {
      expect(json).not.toContain(secret);
    }
  });
});
