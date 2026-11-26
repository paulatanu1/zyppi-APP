import { Timestamp } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { WHOLE_ORDER, dropSellers } from "../../src/orders/partial_cancel";
import type { PayURefunds } from "../../src/payments/payu";
import { AUTO_REFUND_AFTER_MS, autoRefundNeedsReview } from "../../src/payments/refunds";
import { db } from "../../src/shared/firebase";
import type { Actor } from "../../src/shared/roles";
import { UID, resetData } from "./fixtures";

const system: Actor = { uid: "seller:s1", role: "ops", email: null };

function fakePayU() {
  const calls: { mihpayid: string; token: string; amountPaise: number }[] = [];
  const payu: PayURefunds = {
    request: async (mihpayid, token, amountPaise) => {
      calls.push({ mihpayid, token, amountPaise });
      return { ok: true, requestId: `req-${calls.length}` };
    },
    check: async () => "succeeded",
  };
  return { payu, calls };
}

const item = (sellerId: string, pricePaise: number, quantity: number) => ({
  productId: `p-${sellerId}`, variantId: `v-${sellerId}`, name: `Item ${sellerId}`, unit: "1 pc", image: null,
  quantity, pricePaise, sellerId, sellerName: `Shop ${sellerId}`, offerId: null, model: "commission",
  payoutPaise: pricePaise - 10, marginPaise: 10,
});

/** Paid online: shop s1 (₹100) + shop s2 (2 × ₹150), ₹40 coupon, ₹20 delivery. */
async function seedOrder(id = "o-split") {
  await db.doc(`inventory/st1_s1_v-s1`).set({ storeId: "st1", sellerId: "s1", productId: "p-s1", variantId: "v-s1", quantity: 0, reserved: 1 });
  await db.doc(`inventory/st2_s2_v-s2`).set({ storeId: "st2", sellerId: "s2", productId: "p-s2", variantId: "v-s2", quantity: 0, reserved: 2 });
  await db.doc(`orders/${id}`).set({
    userId: UID,
    status: "placed",
    items: [item("s1", 10000, 1), item("s2", 15000, 2)],
    allocations: [
      { storeId: "st1", sellerId: "s1", productId: "p-s1", variantId: "v-s1", quantity: 1 },
      { storeId: "st2", sellerId: "s2", productId: "p-s2", variantId: "v-s2", quantity: 2 },
    ],
    pickups: {
      st1: { sellerId: "s1", otpRequired: true, status: "pending", items: [] },
      st2: { sellerId: "s2", otpRequired: true, status: "accepted", items: [] },
    },
    pickupOrder: ["st1", "st2"],
    pickupCount: 2,
    reservedStores: ["st1", "st2"],
    sellerIds: ["s1", "s2"],
    sellerStatus: { s1: "pending", s2: "accepted" },
    sellersPending: true,
    sellerTotals: { s1: { itemTotalPaise: 10000, payoutPaise: 9990 }, s2: { itemTotalPaise: 30000, payoutPaise: 29980 } },
    itemTotalPaise: 40000,
    discountPaise: 4000,
    deliveryFeePaise: 2000,
    totalPaise: 38000,
    walletPaise: 0,
    paymentMethod: "UPI",
    payment: { method: "UPI", status: "succeeded", amountPaise: 38000, providerReference: "mih-split" },
  });
  return id;
}

describe("dropSellers (audit S5)", () => {
  beforeEach(() => resetData());

  it("drops one seller's lines, refunds them and keeps the rest of the order", async () => {
    const id = await seedOrder();
    const { payu, calls } = fakePayU();
    const res = await dropSellers(system, id, ["s1"], { reason: "Seller can't fulfil: out of stock", statusLabel: "rejected", issueBy: "u-s1" }, payu);
    expect(res.valuePaise).toBe(9000);
    expect(calls).toEqual([expect.objectContaining({ mihpayid: "mih-split", amountPaise: 9000 })]);
    const o = (await db.doc(`orders/${id}`).get()).data()!;
    expect(o.status).toBe("placed");
    expect(o.items.map((i: { sellerId: string }) => i.sellerId)).toEqual(["s2"]);
    expect([o.itemTotalPaise, o.discountPaise, o.totalPaise, o.refundedPaise]).toEqual([30000, 3000, 29000, 9000]);
    expect(Object.keys(o.pickups)).toEqual(["st2"]);
    expect(o.pickupOrder).toEqual(["st2"]);
    expect(o.sellerStatus).toEqual({ s1: "rejected", s2: "accepted" });
    expect(o.sellersPending).toBe(false);
    expect(Object.keys(o.sellerTotals)).toEqual(["s2"]);
    expect(o.reservedStores).toEqual(["st2"]);
    expect(o.removedItems).toHaveLength(1);
    // The dropped unit is back on sale; s2's stay held.
    const s1 = (await db.doc("inventory/st1_s1_v-s1").get()).data()!;
    expect([s1.quantity, s1.reserved]).toEqual([1, 0]);
    expect((await db.doc("inventory/st2_s2_v-s2").get()).get("reserved")).toBe(2);
    expect((await db.doc("sellers/s1").get()).get("stats.cancelled")).toBe(1);
  });

  it("refuses with WHOLE_ORDER when nothing else is in the order", async () => {
    const id = await seedOrder();
    await expect(
      dropSellers(system, id, ["s1", "s2"], { reason: "late", statusLabel: "expired", issueBy: "system" }, fakePayU().payu),
    ).rejects.toThrow(WHOLE_ORDER);
    expect((await db.doc(`orders/${id}`).get()).get("items")).toHaveLength(2);
  });
});

describe("autoRefundNeedsReview (audit S2)", () => {
  beforeEach(() => resetData());

  it("refunds an old, safe needs-review payment and leaves the rest", async () => {
    const old = Timestamp.fromMillis(Date.now() - AUTO_REFUND_AFTER_MS - 60_000);
    await db.doc("paymentIntents/zA").set({ userId: UID, amountPaise: 20000, status: "needs_review", transactionId: "mih-a", orderId: null, failureReason: "Insufficient stock for Milk", updatedAt: old });
    await db.doc("paymentIntents/zB").set({ userId: UID, amountPaise: 20000, status: "needs_review", transactionId: "mih-b", orderId: null, failureReason: "Payment reference already used", updatedAt: old });
    await db.doc("paymentIntents/zC").set({ userId: UID, amountPaise: 20000, status: "needs_review", transactionId: "mih-c", orderId: null, failureReason: "Insufficient stock for Milk", updatedAt: Timestamp.now() });
    const { payu, calls } = fakePayU();
    expect(await autoRefundNeedsReview(Date.now(), payu)).toEqual(["zA"]);
    expect(calls).toEqual([expect.objectContaining({ mihpayid: "mih-a", amountPaise: 20000 })]);
    expect((await db.doc("paymentIntents/zA").get()).get("status")).toBe("refunded");
    expect((await db.doc("paymentIntents/zB").get()).get("status")).toBe("needs_review");
    expect((await db.doc("paymentIntents/zC").get()).get("status")).toBe("needs_review");
  });
});
