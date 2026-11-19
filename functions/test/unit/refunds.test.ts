import { describe, expect, it } from "vitest";
import { mapRefundRequest, mapRefundStatus } from "../../src/payments/payu";
import { TRANSITIONS } from "../../src/admin/orders";

describe("mapRefundRequest", () => {
  it("accepts a queued refund with a request id", () => {
    expect(
      mapRefundRequest({ status: 1, msg: "Refund Request Queued", request_id: 130423233, error_code: 102 }),
    ).toEqual({ ok: true, requestId: "130423233" });
  });

  it("reports PayU's message when refused", () => {
    expect(mapRefundRequest({ status: 0, msg: "Token already used" })).toEqual({
      ok: false,
      reason: "Token already used",
    });
    expect(mapRefundRequest({ status: 1 })).toMatchObject({ ok: false });
  });
});

describe("mapRefundStatus", () => {
  const body = (status: string) => ({
    status: 1,
    transaction_details: { "77": { "4039937": { status, action: "refund" } } },
  });
  it("maps PayU statuses", () => {
    expect(mapRefundStatus(body("success"), "77")).toBe("succeeded");
    expect(mapRefundStatus(body("failure"), "77")).toBe("failed");
    expect(mapRefundStatus(body("queued"), "77")).toBe("pending");
    expect(mapRefundStatus({ status: 0 }, "77")).toBe("pending");
  });
});

describe("TRANSITIONS", () => {
  it("only moves forward and ends at delivered or cancelled", () => {
    expect(TRANSITIONS.placed).toEqual(["packed", "cancelled"]);
    expect(TRANSITIONS.delivered).toEqual([]);
    expect(TRANSITIONS.cancelled).toEqual([]);
  });
});

describe("cancel refund is recorded with the cancel", async () => {
  const { vi } = await import("vitest");
  const { queueCancelRefund } = await import("../../src/admin/orders");
  const actor = { uid: "ops1", role: "ops" as const, email: "ops@example.com" };
  const fakeTx = () => ({ create: vi.fn(), update: vi.fn(), set: vi.fn() });
  const paid = (over: Record<string, unknown> = {}) => ({
    userId: "u1",
    payment: { method: "UPI", status: "succeeded", amountPaise: 50_000, providerReference: "403993715" },
    ...over,
  });

  it("creates a requesting refund for what's left and reserves it on the order update", () => {
    const tx = fakeTx();
    const update: Record<string, unknown> = {};
    const q = queueCancelRefund(tx as never, actor, "o1", paid({ refundedPaise: 10_000 }), "Out of stock", update);
    expect(q).toMatchObject({ mihpayid: "403993715", amountPaise: 40_000 });
    const refundRow = tx.create.mock.calls.find((c) => (c[0] as { path: string }).path.startsWith("refunds/"));
    expect(refundRow?.[1]).toMatchObject({ orderId: "o1", status: "requesting", amountPaise: 40_000 });
    expect(update.refundStatus).toBe("requesting");
    expect(update.refundedPaise).toBeDefined();
    expect(tx.update).not.toHaveBeenCalled(); // merged into the order's single write
  });

  it("does nothing for cash, unpaid or fully refunded orders", () => {
    const tx = fakeTx();
    const cash = paid({ payment: { method: "Cash on delivery", status: "pending", amountPaise: 50_000 } });
    expect(queueCancelRefund(tx as never, actor, "o1", cash, "x y z", {})).toBeNull();
    expect(queueCancelRefund(tx as never, actor, "o1", paid({ refundedPaise: 50_000 }), "x y z", {})).toBeNull();
    expect(tx.create).not.toHaveBeenCalled();
  });

  it("leaves it pending for finance when the PayU id is missing", () => {
    const tx = fakeTx();
    const update: Record<string, unknown> = {};
    const noId = paid({ payment: { method: "UPI", status: "succeeded", amountPaise: 50_000 } });
    expect(queueCancelRefund(tx as never, actor, "o1", noId, "x y z", update)).toBeNull();
    expect(update.refundStatus).toBe("pending");
    expect(tx.create).not.toHaveBeenCalled();
  });
});
