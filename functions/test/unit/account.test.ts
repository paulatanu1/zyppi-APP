import { describe, expect, it } from "vitest";
import { deletionBlocker, signUpTime } from "../../src/account";

describe("account deletion", () => {
  const none = { orderStatuses: [], intentStatuses: [], issueStatuses: [] };
  it("allows it once everything is closed", () => {
    expect(deletionBlocker({ ...none, orderStatuses: ["delivered", "cancelled"], intentStatuses: ["completed", "failed"], issueStatuses: ["approved"] })).toBeNull();
  });
  it("waits for orders, payments and claims in flight", () => {
    expect(deletionBlocker({ ...none, orderStatuses: ["out_for_delivery"] })).toBe("ACTIVE_ORDERS");
    expect(deletionBlocker({ ...none, intentStatuses: ["created"] })).toBe("ACTIVE_ORDERS");
    expect(deletionBlocker({ ...none, issueStatuses: ["returning"] })).toBe("ACTIVE_ORDERS");
  });
});

describe("profile sign-up time", () => {
  const now = new Date("2026-11-21T10:00:00Z");
  it("uses the Auth account's creation time", () => {
    expect(signUpTime("Tue, 17 Nov 2026 08:30:00 GMT", now).toDate().toISOString()).toBe("2026-11-17T08:30:00.000Z");
  });
  it("falls back to now when Auth has none", () => {
    expect(signUpTime(undefined, now).toMillis()).toBe(now.getTime());
    expect(signUpTime("not a date", now).toMillis()).toBe(now.getTime());
  });
});

describe("rider and seller deletion checks", async () => {
  const { riderDeletionBlocker } = await import("../../src/riders/delete");
  const { sellerDeletionBlocker } = await import("../../src/marketplace/seller_delete");
  const { dropFieldsExcept } = await import("../../src/account");

  it("rider: deliveries, then cash, then payouts, then earnings", () => {
    const square = { activeDelivery: false, codBalancePaise: 0, payoutPending: false, earningsBalancePaise: 0 };
    expect(riderDeletionBlocker(square)).toBeNull();
    expect(riderDeletionBlocker({ ...square, activeDelivery: true, codBalancePaise: 1 })).toBe("ACTIVE_DELIVERY");
    expect(riderDeletionBlocker({ ...square, codBalancePaise: 1, earningsBalancePaise: 1 })).toBe("CASH_HELD");
    expect(riderDeletionBlocker({ ...square, payoutPending: true })).toBe("PAYOUT_PENDING");
    expect(riderDeletionBlocker({ ...square, earningsBalancePaise: 1 })).toBe("EARNINGS_UNPAID");
  });

  it("seller: orders, payouts, balances, dues", () => {
    const square = { openOrders: false, payoutPending: false, earningsBalancePaise: 0, heldPaise: 0, duesPaise: 0 };
    expect(sellerDeletionBlocker(square)).toBeNull();
    expect(sellerDeletionBlocker({ ...square, openOrders: true })).toBe("OPEN_ORDERS");
    expect(sellerDeletionBlocker({ ...square, payoutPending: true })).toBe("PAYOUT_PENDING");
    expect(sellerDeletionBlocker({ ...square, heldPaise: 1 })).toBe("BALANCE_UNPAID");
    expect(sellerDeletionBlocker({ ...square, duesPaise: 1 })).toBe("DUES_UNPAID");
  });

  it("drops every field not on the keep list", () => {
    expect(dropFieldsExcept({ status: "x", fullName: "y", newField: 1 }, ["status"])).toEqual(["fullName", "newField"]);
  });
});
