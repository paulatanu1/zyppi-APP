import { describe, expect, it } from "vitest";
import { deletionBlocker } from "../../src/account";

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
