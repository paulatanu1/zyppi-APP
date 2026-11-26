import { Timestamp } from "firebase-admin/firestore";
import { describe, expect, it } from "vitest";
import { planSellerDrop } from "../../src/orders/partial_cancel";
import { AUTO_REFUND_AFTER_MS, autoRefundDue } from "../../src/payments/refunds";

const item = (sellerId: string, pricePaise: number, quantity = 1) => ({
  productId: `p-${sellerId}`,
  variantId: `v-${sellerId}`,
  name: `Item ${sellerId}`,
  quantity,
  pricePaise,
  sellerId,
  sellerName: `Shop ${sellerId}`,
  payoutPaise: pricePaise - 10,
  marginPaise: 10,
});

/** Two sellers (₹100 + ₹300 items), ₹40 coupon, ₹20 delivery fee. */
function order(over: Record<string, unknown> = {}) {
  return {
    status: "placed",
    items: [item("s1", 10000), item("s2", 15000, 2)],
    allocations: [
      { storeId: "st1", sellerId: "s1", productId: "p-s1", variantId: "v-s1", quantity: 1 },
      { storeId: "st2", sellerId: "s2", productId: "p-s2", variantId: "v-s2", quantity: 2 },
    ],
    pickups: { st1: { sellerId: "s1", otpRequired: true, status: "pending" }, st2: { sellerId: "s2", otpRequired: true, status: "accepted" } },
    itemTotalPaise: 40000,
    discountPaise: 4000,
    deliveryFeePaise: 2000,
    totalPaise: 38000,
    walletPaise: 0,
    payment: { method: "UPI", status: "succeeded", amountPaise: 38000, providerReference: "mih1" },
    ...over,
  };
}

describe("planSellerDrop (audit S5)", () => {
  it("drops only that seller's lines and refunds them minus their coupon share", () => {
    const plan = planSellerDrop(order(), ["s1"])!;
    expect(plan.dropped.map((i) => i.sellerId)).toEqual(["s1"]);
    expect(plan.kept.map((i) => i.sellerId)).toEqual(["s2"]);
    expect(plan.droppedStops).toEqual(["st1"]);
    expect(plan.droppedAllocations).toHaveLength(1);
    expect(plan.itemPaise).toBe(10000);
    expect(plan.discountSharePaise).toBe(1000); // a quarter of the items → a quarter of ₹40
    expect(plan.valuePaise).toBe(9000);
    expect(plan.refundPaise).toBe(9000); // all back through PayU; the delivery fee stays
    expect(plan.walletPaise).toBe(0);
    expect(plan.cashCutPaise).toBe(0);
  });

  it("is null when nothing would be left, nothing is theirs, or it's an old order", () => {
    expect(planSellerDrop(order(), ["s1", "s2"])).toBeNull();
    expect(planSellerDrop(order(), ["s9"])).toBeNull();
    expect(planSellerDrop(order({ allocations: [] }), ["s1"])).toBeNull();
    expect(planSellerDrop(order({ replacementOf: "o0" }), ["s1"])).toBeNull();
  });

  it("cash on delivery: less cash at the door, the wallet part back to the wallet", () => {
    const cod = order({
      payment: { method: "Cash on delivery", status: "pending", amountPaise: 33000 },
      cashToCollectPaise: 33000,
      walletPaise: 5000,
    });
    const plan = planSellerDrop(cod, ["s1"])!;
    expect(plan.cashCutPaise).toBe(9000);
    expect(plan.walletPaise).toBe(0);
    const small = planSellerDrop({ ...cod, cashToCollectPaise: 6000 }, ["s1"])!;
    expect(small.cashCutPaise).toBe(6000);
    expect(small.walletPaise).toBe(3000);
  });

  it("online: PayU up to what's still refundable, the rest to the wallet", () => {
    const plan = planSellerDrop(order({ walletPaise: 30000, payment: { method: "UPI", status: "succeeded", amountPaise: 8000, providerReference: "m" } }), ["s1"])!;
    expect(plan.refundPaise).toBe(8000);
    expect(plan.walletPaise).toBe(1000);
  });

  it("never gives back more than was paid", () => {
    const plan = planSellerDrop(order({ walletPaise: 0, refundedPaise: 37000 }), ["s1"])!;
    expect(plan.refundPaise).toBe(1000);
    expect(plan.walletPaise).toBe(0);
  });
});

describe("autoRefundDue (audit S2)", () => {
  const now = Date.UTC(2026, 10, 26, 12);
  const intent = (over: Record<string, unknown> = {}) => ({
    status: "needs_review",
    transactionId: "mih1",
    amountPaise: 25000,
    failureReason: "Insufficient stock for Milk",
    updatedAt: Timestamp.fromMillis(now - AUTO_REFUND_AFTER_MS),
    ...over,
  });

  it("refunds a paid-but-no-order payment nobody handled in 30 minutes", () => {
    expect(autoRefundDue(intent(), now)).toBe(true);
  });

  it("waits 30 minutes first", () => {
    expect(autoRefundDue(intent({ updatedAt: Timestamp.fromMillis(now - AUTO_REFUND_AFTER_MS + 1000) }), now)).toBe(false);
  });

  it("leaves risky or handled ones to a person", () => {
    expect(autoRefundDue(intent({ failureReason: "Payment reference already used" }), now)).toBe(false);
    expect(autoRefundDue(intent({ failureReason: "Paid amount differs from quote" }), now)).toBe(false);
    expect(autoRefundDue(intent({ autoRefund: false }), now)).toBe(false);
    expect(autoRefundDue(intent({ refundedPaise: 100 }), now)).toBe(false);
    expect(autoRefundDue(intent({ refundStatus: "failed" }), now)).toBe(false);
    expect(autoRefundDue(intent({ transactionId: null }), now)).toBe(false);
    expect(autoRefundDue(intent({ status: "refunded" }), now)).toBe(false);
  });
});
