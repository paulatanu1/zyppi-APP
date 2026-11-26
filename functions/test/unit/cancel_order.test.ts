import { describe, expect, it } from "vitest";
import { customerActor, customerCancelProblem } from "../../src/orders/cancel_order";

describe("customerCancelProblem", () => {
  const order = (over: Record<string, unknown> = {}) => ({ userId: "u1", status: "placed", ...over });

  it("lets the customer cancel their own placed order before pickup", () => {
    expect(customerCancelProblem(order(), "u1")).toBeNull();
    expect(customerCancelProblem(order({ riderStage: "accepted" }), "u1")).toBeNull();
    expect(customerCancelProblem(order({ riderStage: "at_store" }), "u1")).toBeNull();
  });

  it("refuses someone else's order", () => {
    expect(customerCancelProblem(order(), "u2")).toBe("NOT_YOUR_ORDER");
  });

  it("refuses once packed, picked up, delivered or cancelled", () => {
    expect(customerCancelProblem(order({ status: "packed" }), "u1")).toBe("TOO_LATE_TO_CANCEL");
    expect(customerCancelProblem(order({ status: "out_for_delivery" }), "u1")).toBe("TOO_LATE_TO_CANCEL");
    expect(customerCancelProblem(order({ status: "delivered" }), "u1")).toBe("TOO_LATE_TO_CANCEL");
    expect(customerCancelProblem(order({ riderStage: "picked_up" }), "u1")).toBe("TOO_LATE_TO_CANCEL");
    expect(customerCancelProblem(order({ status: "cancelled" }), "u1")).toBe("ALREADY_CANCELLED");
  });

  it("refuses once a shop has packed its part (audit S6), not just accepted", () => {
    expect(customerCancelProblem(order({ sellerStatus: { s1: "accepted" } }), "u1")).toBeNull();
    expect(customerCancelProblem(order({ sellerStatus: { s1: "accepted", s2: "ready" } }), "u1")).toBe("SHOP_PACKED");
    expect(customerCancelProblem(order({ pickups: { st1: { status: "ready" } } }), "u1")).toBe("SHOP_PACKED");
    expect(customerCancelProblem(order({ pickups: { st1: { status: "pending" } } }), "u1")).toBeNull();
  });

  it("records the customer, not a staff member, as the canceller", () => {
    expect(customerActor("u1")).toEqual({ uid: "customer:u1", role: "ops", email: null });
  });
});
