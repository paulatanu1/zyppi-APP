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
