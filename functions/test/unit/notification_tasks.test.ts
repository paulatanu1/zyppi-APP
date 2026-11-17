import { describe, expect, it, vi } from "vitest";
import { campaignDue, planChunks, type Recipient } from "../../src/notifications/model";
import { expireAt, inboxDoc } from "../../src/notifications/inbox";
import { deadTokens, forgetTokens, isValidToken, tokensOf, withToken } from "../../src/notifications/tokens";
import { MAX_TASK_AHEAD_MS, enqueueSafely, scheduleFor, taskId } from "../../src/shared/tasks";

const NOW = Date.UTC(2026, 10, 17, 6);
const person = (uid: string, tokens: string[], lang: Recipient["lang"] = "en"): Recipient => ({
  uid,
  tokens,
  lang,
  serviceAreaId: null,
  orderCount: 0,
  totalSpentPaise: 0,
  lastOrderAtMs: null,
});

describe("tokensOf", () => {
  it("merges every device with the legacy token, without duplicates", () => {
    expect(tokensOf({ pushTokens: ["a", "b"], fcmToken: "b" })).toEqual(["a", "b"]);
    expect(tokensOf({ fcmToken: "x" })).toEqual(["x"]);
    expect(tokensOf({ pushTokens: [1, "", null, "c"], fcmToken: null })).toEqual(["c"]);
    expect(tokensOf(undefined)).toEqual([]);
  });
});

describe("withToken", () => {
  it("adds the device as newest and keeps the latest five", () => {
    expect(withToken(["a", "b"], "a")).toEqual(["b", "a"]);
    expect(withToken(["1", "2", "3", "4", "5"], "6")).toEqual(["2", "3", "4", "5", "6"]);
    expect(withToken(undefined, "z")).toEqual(["z"]);
  });

  it("only accepts token-shaped strings at registration", () => {
    expect(isValidToken("x".repeat(160))).toBe(true);
    expect(isValidToken("short")).toBe(false);
    expect(isValidToken(42)).toBe(false);
  });
});

describe("dead tokens", () => {
  it("picks only tokens FCM says are gone", () => {
    const responses = [
      { success: true },
      { success: false, error: { code: "messaging/registration-token-not-registered" } },
      { success: false, error: { code: "messaging/internal-error" } },
    ];
    expect(deadTokens(["a", "b", "c"], responses)).toEqual(["b"]);
  });

  it("clears the legacy field only when it is one of them", () => {
    expect(forgetTokens({ fcmToken: "b" }, ["b"])).toHaveProperty("fcmToken", null);
    expect(forgetTokens({ fcmToken: "a" }, ["b"])).not.toHaveProperty("fcmToken");
    expect(forgetTokens({}, [])).toEqual({});
  });
});

describe("planChunks", () => {
  it("never puts more than the FCM limit in one batch, and keeps languages apart", () => {
    const people = [
      ...Array.from({ length: 7 }, (_, i) => person(`e${i}`, [`t${i}a`, `t${i}b`])),
      person("b1", ["tb"], "bn"),
    ];
    const chunks = planChunks(people, 5);
    expect(chunks.every((c) => c.recipients.reduce((n, r) => n + r.tokens.length, 0) <= 5)).toBe(true);
    expect(chunks.filter((c) => c.lang === "bn")).toHaveLength(1);
    expect(chunks.flatMap((c) => c.recipients).length).toBe(8);
  });

  it("returns nothing for an empty audience", () => {
    expect(planChunks([])).toEqual([]);
  });
});

describe("campaignDue", () => {
  const c = { status: "scheduled", taskVersion: 2, sendAtMs: NOW };
  it("sends when the current version's time has come", () => {
    expect(campaignDue(c, 2, NOW)).toBe("send");
    expect(campaignDue(c, 2, NOW - 30_000)).toBe("send"); // a little early is fine
  });
  it("ignores rescheduled, cancelled or already sent campaigns", () => {
    expect(campaignDue(c, 1, NOW)).toBe("skip");
    expect(campaignDue({ ...c, status: "cancelled" }, 2, NOW)).toBe("skip");
    expect(campaignDue({ ...c, status: "sent" }, 2, NOW)).toBe("skip");
  });
  it("queues again when it arrived far too early", () => {
    expect(campaignDue(c, 2, NOW - 3_600_000)).toBe("requeue");
  });
});

describe("tasks", () => {
  it("builds ids Cloud Tasks accepts", () => {
    expect(taskId("price", "s1_a/b_v1", 123)).toBe("price-s1_a-b_v1-123");
    expect(taskId("x".repeat(600)).length).toBe(500);
  });

  it("runs past times now and refuses times beyond the 30-day limit", () => {
    expect(scheduleFor(NOW - 1000, NOW)?.getTime()).toBe(NOW);
    expect(scheduleFor(NOW + 60_000, NOW)?.getTime()).toBe(NOW + 60_000);
    expect(scheduleFor(NOW + MAX_TASK_AHEAD_MS + 1, NOW)).toBeNull();
  });

  it("never fails the caller when a task can't be queued", async () => {
    const client = { enqueue: vi.fn().mockRejectedValue(new Error("down")), delete: vi.fn() };
    await expect(enqueueSafely("q", {}, { id: "a" }, client)).resolves.toBe(false);
    client.enqueue.mockResolvedValue(undefined);
    await expect(enqueueSafely("q", {}, { id: "a" }, client)).resolves.toBe(true);
  });
});

describe("inbox entries", () => {
  it("are unread and expire after 30 days", () => {
    const d = inboxDoc({ kind: "order", title: "Delivered", body: "x".repeat(900), data: { orderId: "o1" } }, NOW);
    expect(d.read).toBe(false);
    expect(d.body).toHaveLength(500);
    expect(d.expireAt.toMillis()).toBe(NOW + 30 * 86_400_000);
    expect(expireAt(NOW, 90).toMillis()).toBe(NOW + 90 * 86_400_000);
  });
});
