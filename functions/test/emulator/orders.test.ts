import { beforeEach, describe, expect, it } from "vitest";
import { db } from "../../src/shared/firebase";
import { OrderError, placeOrderInTx, quoteOrder } from "../../src/orders/quote";
import { placePaidOrder } from "../../src/payments/place_paid_order";
import { STORE_A, STORE_B, UID, params, resetData } from "./fixtures";

const quote = (p = params()) => db.runTransaction((tx) => quoteOrder(tx, p as never));
const place = (p = params()) =>
  db.runTransaction((tx) =>
    placeOrderInTx(tx, p as never, { status: "pending", providerReference: null }),
  );
const stockOf = async (store: string, variant: string) =>
  (await db.doc(`inventory/${store}_${variant}`).get()).get("quantity");

async function intent(id: string, amountPaise: number) {
  await db.doc(`paymentIntents/${id}`).set({
    userId: UID, amountPaise, paymentMethod: "UPI", addressId: "home",
    deliverySlotId: "slot-1", couponCode: null, tipPaise: 0, status: "created", orderId: null,
  });
}

describe("quoteOrder", () => {
  beforeEach(() => resetData());

  it("prices the cart with the handling fee and tip", async () => {
    const q = await quote(params({ tipPaise: 2000 }));
    expect(q.itemTotalPaise).toBe(12800);
    expect(q.totalPaise).toBe(12800 + 500 + 2000);
  });

  it("applies a coupon only above its minimum", async () => {
    expect((await quote(params({ couponCode: "zyppi50" }))).discountPaise).toBe(0);
    await resetData({ "v-rice": 1 });
    const q = await quote(params({ couponCode: "zyppi50" }));
    expect(q.discountPaise).toBe(5000);
    expect(q.totalPaise).toBe(68000 + 500 - 5000);
  });

  it("rejects an address outside every service area", async () => {
    await expect(quote(params({ addressId: "far" }))).rejects.toThrow(
      "Address not found or not serviceable",
    );
  });

  it("rejects too little stock across the area's stores", async () => {
    await resetData({ "v-milk": 6 });
    await expect(quote()).rejects.toThrow("Insufficient stock for Toned Milk");
  });

  it("rejects an empty cart and a tip over the cap", async () => {
    await expect(quote(params({ tipPaise: 50001 }))).rejects.toThrow("Invalid tip");
    await resetData({});
    await expect(quote()).rejects.toThrow("Cart is empty");
  });
});

describe("placeOrderInTx", () => {
  beforeEach(() => resetData({ "v-milk": 4 }));

  it("creates the order, spreads stock across stores and empties the cart", async () => {
    const orderId = await place();
    const order = (await db.doc(`orders/${orderId}`).get()).data()!;
    expect(order.userId).toBe(UID);
    expect(order.status).toBe("placed");
    expect(order.totalPaise).toBe(4 * 6400 + 500);
    expect(order.items[0]).toMatchObject({ variantId: "v-milk", quantity: 4, unit: "1 L" });
    expect(order.addressText).toBe("12 Station Rd, Ward 5, Purulia, 723101");
    expect(order.address).toMatchObject({ label: "Home", postalCode: "723101", landmark: null });

    // 3 from the fuller store, 1 from the other.
    expect(await stockOf(STORE_A, "v-milk")).toBe(0);
    expect(await stockOf(STORE_B, "v-milk")).toBe(1);
    expect((await db.collection(`users/${UID}/cart`).get()).empty).toBe(true);
    expect((await db.collection(`orders/${orderId}/events`).get()).docs[0].get("status")).toBe("placed");
  });

  it("rolls back everything when the order can't be placed", async () => {
    await db.doc("products/p-milk").update({ isActive: false });
    await expect(place()).rejects.toBeInstanceOf(OrderError);
    expect(await stockOf(STORE_A, "v-milk")).toBe(3);
    expect((await db.collection(`users/${UID}/cart`).get()).size).toBe(1);
  });
});

describe("placePaidOrder", () => {
  beforeEach(() => resetData());

  it("creates the order once and is idempotent", async () => {
    await intent("m1", 2 * 6400 + 500);
    const first = await placePaidOrder("m1", "T1", 2 * 6400 + 500);
    expect(first).toBeTruthy();
    expect(await placePaidOrder("m1", "T1", 2 * 6400 + 500)).toBe(first);
    expect((await db.collection("orders").get()).size).toBe(1);
    const order = (await db.doc(`orders/${first}`).get()).data()!;
    expect(order.payment).toMatchObject({ status: "succeeded", providerReference: "T1" });
    expect((await db.doc("paymentIntents/m1").get()).get("status")).toBe("completed");
  });

  it("sends an amount mismatch to review without creating an order", async () => {
    await intent("m2", 13300);
    expect(await placePaidOrder("m2", "T2", 100)).toBeNull();
    const i = (await db.doc("paymentIntents/m2").get()).data()!;
    expect(i.status).toBe("needs_review");
    expect(i.failureReason).toBe("Paid amount differs from quote");
    expect((await db.collection("orders").get()).empty).toBe(true);
  });

  it("sends a paid-but-unplaceable order to review", async () => {
    await intent("m3", 13300);
    await db.doc(`inventory/${STORE_A}_v-milk`).update({ quantity: 0 });
    await db.doc(`inventory/${STORE_B}_v-milk`).update({ quantity: 0 });
    expect(await placePaidOrder("m3", "T3", 13300)).toBeNull();
    expect((await db.doc("paymentIntents/m3").get()).get("failureReason")).toBe(
      "Insufficient stock for Toned Milk",
    );
  });

  it("refuses to reuse one payment for a second order", async () => {
    await intent("m4", 13300);
    expect(await placePaidOrder("m4", "T4", 13300)).toBeTruthy();
    await resetData();
    await intent("m5", 13300);
    await db.doc("paymentReferences/T4").set({ merchantOrderId: "m4" });
    expect(await placePaidOrder("m5", "T4", 13300)).toBeNull();
    expect((await db.doc("paymentIntents/m5").get()).get("status")).toBe("needs_review");
  });
});
