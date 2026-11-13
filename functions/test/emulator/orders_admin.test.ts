import { beforeEach, describe, expect, it } from "vitest";
import { updateOrderStatus } from "../../src/admin/orders";
import { placeOrderInTx } from "../../src/orders/quote";
import type { PayURefunds } from "../../src/payments/payu";
import { createRefund, refreshRefund, resolveIntent } from "../../src/payments/refunds";
import { settleIntent } from "../../src/payments/settle";
import { db } from "../../src/shared/firebase";
import type { Actor } from "../../src/shared/roles";
import { STORE_A, STORE_B, UID, params, resetData } from "./fixtures";

const ops: Actor = { uid: "ops-1", role: "ops", email: "ops@zyppi.test" };
const fin: Actor = { uid: "fin-1", role: "finance", email: "fin@zyppi.test" };

const stock = async (store: string, variant: string) =>
  (await db.doc(`inventory/${store}_${variant}`).get()).get("quantity");

/** Fake PayU: records calls, answers as told. */
function fakePayU(answer: "ok" | "refused" | "down" = "ok", check: "succeeded" | "pending" = "succeeded") {
  const calls: { mihpayid: string; token: string; amountPaise: number }[] = [];
  const payu: PayURefunds = {
    request: async (mihpayid, token, amountPaise) => {
      calls.push({ mihpayid, token, amountPaise });
      if (answer === "down") throw new Error("ECONNRESET");
      return answer === "ok" ? { ok: true, requestId: `req-${calls.length}` } : { ok: false, reason: "Refused" };
    },
    check: async () => check,
  };
  return { payu, calls };
}

async function place(payment: { status: "pending" | "succeeded"; providerReference: string | null } = { status: "pending", providerReference: null }, method = "Cash on delivery") {
  return db.runTransaction((tx) => placeOrderInTx(tx, { ...params(), paymentMethod: method } as never, payment));
}

describe("order placement", () => {
  beforeEach(() => resetData({ "v-milk": 4 }));

  it("records which store filled each line and logs the sale in stock history", async () => {
    const id = await place();
    const order = (await db.doc(`orders/${id}`).get()).data()!;
    expect(order.allocations).toEqual([
      { storeId: STORE_A, productId: "p-milk", variantId: "v-milk", quantity: 3 },
      { storeId: STORE_B, productId: "p-milk", variantId: "v-milk", quantity: 1 },
    ]);
    const moves = (await db.collection("inventoryMovements").where("orderId", "==", id).get()).docs.map((d) => d.data());
    expect(moves.map((m) => [m.storeId, m.delta, m.reason])).toEqual(
      expect.arrayContaining([[STORE_A, -3, "order"], [STORE_B, -1, "order"]]),
    );
  });
});

describe("updateOrderStatus", () => {
  beforeEach(() => resetData({ "v-milk": 4 }));

  it("moves forward with an event and refuses skips and moves back", async () => {
    const id = await place();
    await updateOrderStatus(ops, { orderId: id, status: "packed", riderName: " Raju ", riderPhone: "9800000000" });
    const order = (await db.doc(`orders/${id}`).get()).data()!;
    expect(order).toMatchObject({ status: "packed", riderName: "Raju" });
    expect(order.packedAt).toBeTruthy();
    const events = (await db.collection(`orders/${id}/events`).get()).docs.map((d) => d.data());
    expect(events).toEqual(expect.arrayContaining([expect.objectContaining({ status: "packed", by: "ops-1" })]));
    await expect(updateOrderStatus(ops, { orderId: id, status: "delivered" })).rejects.toThrow(
      "Can’t move an order from packed to delivered",
    );
    await expect(updateOrderStatus(ops, { orderId: id, status: "placed" })).rejects.toThrow("Can’t move");
  });

  it("updates only the rider when the status is unchanged (no event)", async () => {
    const id = await place();
    await updateOrderStatus(ops, { orderId: id, status: "placed", riderName: "Mona" });
    expect((await db.doc(`orders/${id}`).get()).get("riderName")).toBe("Mona");
    expect((await db.collection(`orders/${id}/events`).get()).size).toBe(1);
  });

  it("marks cash collected on delivery", async () => {
    const id = await place();
    for (const s of ["packed", "out_for_delivery", "delivered"]) {
      await updateOrderStatus(ops, { orderId: id, status: s });
    }
    expect((await db.doc(`orders/${id}`).get()).get("payment.status")).toBe("succeeded");
  });

  it("cancels with a reason and puts stock back where it came from", async () => {
    const id = await place();
    expect([await stock(STORE_A, "v-milk"), await stock(STORE_B, "v-milk")]).toEqual([0, 1]);
    await expect(updateOrderStatus(ops, { orderId: id, status: "cancelled" })).rejects.toThrow("reason");
    const res = await updateOrderStatus(ops, { orderId: id, status: "cancelled", reason: "Customer unreachable" });
    expect(res.refund).toBeUndefined();
    expect([await stock(STORE_A, "v-milk"), await stock(STORE_B, "v-milk")]).toEqual([3, 2]);
    const order = (await db.doc(`orders/${id}`).get()).data()!;
    expect(order).toMatchObject({ status: "cancelled", cancelReason: "Customer unreachable", cancelledBy: "ops-1" });
    const back = await db.collection("inventoryMovements").where("reason", "==", "order_cancel").get();
    expect(back.size).toBe(2);
    await expect(updateOrderStatus(ops, { orderId: id, status: "packed" })).rejects.toThrow("Can’t move");
  });

  it("refunds a paid order in full when it is cancelled", async () => {
    const id = await place({ status: "succeeded", providerReference: "mih-1" }, "UPI");
    const { payu, calls } = fakePayU();
    const res = await updateOrderStatus(ops, { orderId: id, status: "cancelled", reason: "Out of stock" }, payu);
    const total = (await db.doc(`orders/${id}`).get()).get("totalPaise");
    expect(calls).toEqual([{ mihpayid: "mih-1", token: res.refund!.refundId, amountPaise: total }]);
    const order = (await db.doc(`orders/${id}`).get()).data()!;
    expect(order).toMatchObject({ refundStatus: "requested", refundedPaise: total });
    const refund = (await db.doc(`refunds/${res.refund!.refundId}`).get()).data()!;
    expect(refund).toMatchObject({ status: "requested", requestId: "req-1", orderId: id });
  });
});

describe("refunds", () => {
  let orderId: string;
  beforeEach(async () => {
    await resetData({ "v-milk": 2 });
    orderId = await place({ status: "succeeded", providerReference: "mih-9" }, "UPI");
  });

  it("allows partial refunds up to what was paid", async () => {
    const { payu } = fakePayU();
    const total = (await db.doc(`orders/${orderId}`).get()).get("totalPaise") as number;
    await createRefund(fin, { orderId }, { amountPaise: 1000, reason: "Missing item" }, payu);
    await expect(
      createRefund(fin, { orderId }, { amountPaise: total, reason: "Again" }, payu),
    ).rejects.toThrow("can still be refunded");
    await createRefund(fin, { orderId }, { amountPaise: total - 1000, reason: "Rest" }, payu);
    await expect(createRefund(fin, { orderId }, { amountPaise: 1, reason: "More" }, payu)).rejects.toThrow(
      "Already fully refunded",
    );
  });

  it("gives the amount back when PayU refuses", async () => {
    const { payu } = fakePayU("refused");
    const { status } = await createRefund(fin, { orderId }, { amountPaise: 500, reason: "Damaged" }, payu);
    expect(status).toBe("failed");
    const order = (await db.doc(`orders/${orderId}`).get()).data()!;
    expect(order).toMatchObject({ refundedPaise: 0, refundStatus: "failed" });
  });

  it("retries with the same token when PayU was unreachable, then confirms", async () => {
    const down = fakePayU("down");
    const { refundId, status } = await createRefund(fin, { orderId }, { amountPaise: 500, reason: "Damaged" }, down.payu);
    expect(status).toBe("requesting");
    const up = fakePayU("ok", "succeeded");
    expect(await refreshRefund(refundId, up.payu)).toBe("requested");
    expect(up.calls[0].token).toBe(refundId);
    expect(await refreshRefund(refundId, up.payu)).toBe("succeeded");
    expect((await db.doc(`orders/${orderId}`).get()).get("refundStatus")).toBe("succeeded");
  });

  it("refuses cash orders", async () => {
    await resetData({ "v-milk": 1 });
    const cod = await place();
    await expect(
      createRefund(fin, { orderId: cod }, { amountPaise: 100, reason: "Test" }, fakePayU().payu),
    ).rejects.toThrow("Only online payments");
  });
});

describe("needs-review payments", () => {
  beforeEach(async () => {
    await resetData();
    await db.doc("paymentIntents/zT").set({
      userId: UID, amountPaise: 20000, status: "needs_review", transactionId: "mih-r", orderId: null,
    });
  });

  it("refunds the whole amount and never becomes an order afterwards", async () => {
    const { payu, calls } = fakePayU();
    await resolveIntent(fin, { intentId: "zT", action: "refund" }, payu);
    expect(calls[0]).toMatchObject({ mihpayid: "mih-r", amountPaise: 20000 });
    expect((await db.doc("paymentIntents/zT").get()).get("status")).toBe("refunded");
    let verified = false;
    const res = await settleIntent("zT", async () => {
      verified = true;
      return { state: "paid", mihpayid: "mih-r", amountPaise: 20000 };
    });
    expect(res.state).toBe("needs_review");
    expect(verified).toBe(false);
  });

  it("dismisses only with a note", async () => {
    await expect(resolveIntent(fin, { intentId: "zT", action: "dismiss" })).rejects.toThrow("Add a note");
    await resolveIntent(fin, { intentId: "zT", action: "dismiss", note: "Refunded from PayU dashboard" });
    expect((await db.doc("paymentIntents/zT").get()).data()).toMatchObject({
      status: "dismissed",
      resolvedBy: "fin-1",
    });
  });
});
