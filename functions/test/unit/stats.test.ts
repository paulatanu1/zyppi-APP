import { Timestamp } from "firebase-admin/firestore";
import { describe, expect, it } from "vitest";
import {
  istParts,
  methodKey,
  orderContribution,
  prune,
  rebuild,
  statsDeltas,
} from "../../src/stats/model";
import { increments } from "../../src/stats/stats";

// 2026-11-15 08:10 UTC = 13:40 IST.
const placedAt = Timestamp.fromMillis(Date.UTC(2026, 10, 15, 8, 10));

const order = (over: Record<string, unknown> = {}): Record<string, unknown> => ({
  status: "placed",
  placedAt,
  serviceAreaId: "area-1",
  paymentMethod: "Cash on delivery",
  payment: { method: "Cash on delivery", status: "pending", amountPaise: 25000 },
  itemTotalPaise: 24000,
  discountPaise: 1000,
  deliveryFeePaise: 0,
  handlingFeePaise: 500,
  tipPaise: 1500,
  totalPaise: 25000,
  couponCode: "SAVE10",
  customerOrderNo: 1,
  items: [
    { productId: "p1", name: "Milk", quantity: 2, pricePaise: 3000 },
    { productId: "p2", name: "Bread", quantity: 1, pricePaise: 4000 },
    { productId: "p1", name: "Milk", quantity: 1, pricePaise: 3000 },
  ],
  ...over,
});

describe("istParts", () => {
  it("uses India time for the day and hour", () => {
    expect(istParts(placedAt.toMillis())).toEqual({ day: "2026-11-15", hour: "13" });
    // 20:00 UTC on the 14th is 01:30 on the 15th in India.
    expect(istParts(Date.UTC(2026, 10, 14, 20, 0))).toEqual({ day: "2026-11-15", hour: "01" });
  });
});

describe("methodKey", () => {
  it("maps the app's payment labels", () => {
    expect(methodKey("Cash on delivery")).toBe("cod");
    expect(methodKey("UPI")).toBe("upi");
    expect(methodKey("Credit or debit card")).toBe("card");
    expect(methodKey(undefined)).toBe("other");
  });
});

describe("orderContribution", () => {
  it("counts a live order with its money, products, coupon and hour", () => {
    const c = orderContribution(order())!;
    expect(c.day).toBe("2026-11-15");
    expect(c.areaId).toBe("area-1");
    expect(c.counts).toMatchObject({
      placed: 1,
      orders: 1,
      gmvPaise: 25000,
      discountPaise: 1000,
      tipPaise: 1500,
      newCustomers: 1,
      byMethod: { cod: { orders: 1, paise: 25000 } },
      byHour: { "13": 1 },
      products: { p1: { qty: 3, paise: 9000 }, p2: { qty: 1, paise: 4000 } },
      coupons: { SAVE10: { uses: 1, discountPaise: 1000 } },
    });
    expect(c.labels).toEqual({ products: { p1: "Milk", p2: "Bread" } });
  });

  it("counts a cancelled order only as placed and cancelled", () => {
    const c = orderContribution(order({ status: "cancelled", refundedPaise: 25000 }))!;
    expect(c.counts).toEqual({ placed: 1, cancelled: 1, cancelledPaise: 25000, refundedPaise: 25000 });
  });

  it("credits the rider on delivery, on time against the ETA", () => {
    const deliveredAt = Timestamp.fromMillis(placedAt.toMillis() + 20 * 60_000);
    const c = orderContribution(
      order({ status: "delivered", riderId: "r1", riderName: "Asha", etaMinutes: 25, deliveredAt }),
    )!;
    expect(c.counts.delivered).toBe(1);
    expect(c.counts.riders).toEqual({ r1: { delivered: 1, onTime: 1, codPaise: 25000 } });
    expect(c.labels.riders).toEqual({ r1: "Asha" });

    const late = Timestamp.fromMillis(placedAt.toMillis() + 40 * 60_000);
    const l = orderContribution(order({ status: "delivered", riderId: "r1", etaMinutes: 25, deliveredAt: late }))!;
    expect(l.counts.riders).toEqual({ r1: { delivered: 1, onTime: 0, codPaise: 25000 } });
  });

  it("marks repeat orders and leaves old orders out of both", () => {
    expect(orderContribution(order({ customerOrderNo: 3 }))!.counts).toMatchObject({ repeatOrders: 1 });
    const old = orderContribution(order({ customerOrderNo: undefined }))!.counts;
    expect(old.newCustomers).toBeUndefined();
    expect(old.repeatOrders).toBeUndefined();
  });

  it("skips orders without a placedAt", () => {
    expect(orderContribution(order({ placedAt: null }))).toBeNull();
    expect(orderContribution(undefined)).toBeNull();
  });
});

describe("statsDeltas", () => {
  it("adds a new order to the day and its area", () => {
    const deltas = statsDeltas(undefined, order());
    expect(deltas.map((d) => d.path)).toEqual(["daily/days/2026-11-15", "areas/days/area-1_2026-11-15"]);
    expect(deltas[0].counts.orders).toBe(1);
    expect(deltas[1].areaId).toBe("area-1");
  });

  it("writes nothing when nothing counted changes", () => {
    expect(statsDeltas(order(), order({ updatedAt: Timestamp.now() }))).toEqual([]);
    expect(statsDeltas(order(), order({ status: "packed" }))).toEqual([]);
  });

  it("moves a cancelled order from live to cancelled", () => {
    const [daily] = statsDeltas(order(), order({ status: "cancelled" }));
    expect(daily.counts).toMatchObject({
      orders: -1,
      gmvPaise: -25000,
      cancelled: 1,
      cancelledPaise: 25000,
      newCustomers: -1,
      byMethod: { cod: { orders: -1, paise: -25000 } },
      products: { p1: { qty: -3, paise: -9000 } },
    });
    expect(daily.counts.placed).toBeUndefined();
  });

  it("takes a deleted order back off", () => {
    const [daily] = statsDeltas(order(), undefined);
    expect(daily.counts).toMatchObject({ placed: -1, orders: -1 });
  });

  it("sums back to zero over an order's life", () => {
    const steps = [
      undefined,
      order(),
      order({ status: "packed", riderId: "r1" }),
      order({ status: "delivered", riderId: "r1", deliveredAt: placedAt }),
    ];
    const total = new Map<string, number>();
    for (let i = 1; i < steps.length; i++) {
      for (const d of statsDeltas(steps[i - 1], steps[i])) {
        if (d.path.startsWith("daily")) total.set("delivered", (total.get("delivered") ?? 0) + ((d.counts.delivered as number) ?? 0));
      }
    }
    expect(total.get("delivered")).toBe(1);
    expect(statsDeltas(steps[3], undefined)[0].counts).toMatchObject({ placed: -1, delivered: -1 });
  });
});

describe("rebuild", () => {
  it("matches the trigger's running totals", () => {
    const orders = [order(), order({ status: "cancelled" }), order({ paymentMethod: "UPI", payment: { method: "UPI" } })];
    const docs = rebuild(orders);
    const daily = docs.get("daily/days/2026-11-15")!;
    expect(daily.counts).toMatchObject({
      placed: 3,
      orders: 2,
      cancelled: 1,
      gmvPaise: 50000,
      byMethod: { cod: { orders: 1 }, upi: { orders: 1 } },
    });
    expect(daily.labels).toEqual({ products: { p1: "Milk", p2: "Bread" } });
  });
});

describe("prune and increments", () => {
  it("drops zeros and empty maps", () => {
    expect(prune({ a: 0, b: { c: 0 } })).toBeNull();
    expect(prune({ a: 1, b: { c: 0, d: -2 } })).toEqual({ a: 1, b: { d: -2 } });
  });

  it("turns leaves into increments", () => {
    const out = increments({ a: 2, b: { c: -1 } });
    expect(Object.keys(out)).toEqual(["a", "b"]);
    expect(Object.keys(out.b as object)).toEqual(["c"]);
  });
});
