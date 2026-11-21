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
