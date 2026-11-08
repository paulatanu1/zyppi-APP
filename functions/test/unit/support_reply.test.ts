import { describe, expect, it } from "vitest";
import { orderStatusText, shortOrderId } from "../../src/support/copy";
import { Retriever } from "../../src/support/kb/retrieve";
import { KB_SEED } from "../../src/support/kb/seed";
import { AGENT_REPLY_ID, composeReply, type OrderSummary } from "../../src/support/reply";

const DIMS = 16;
function axis(i: number, strength = 1): Float32Array {
  const v = new Float32Array(DIMS).fill(Math.sqrt((1 - strength ** 2) / (DIMS - 1)));
  v[i] = strength;
  return v;
}
const retriever = new Retriever(KB_SEED.map((entry, i) => ({ entry, vectors: [axis(i)] })));
const vectorFor = (id: string) => axis(KB_SEED.findIndex((e) => e.id === id), 0.95);

const NOW = Date.UTC(2026, 10, 6, 12, 0);
const order: OrderSummary = {
  id: "3f2a9c1b-0000-4000-8000-000000000000",
  status: "out_for_delivery",
  placedAtMs: NOW - 5 * 60000,
  etaMinutes: 12,
};

const reply = (over: Partial<Parameters<typeof composeReply>[0]>) =>
  composeReply({
    text: "x",
    lang: "en",
    order,
    nowMs: NOW,
    retriever,
    queryVector: null,
    ...over,
  });

describe("orderStatusText", () => {
  it("adds the remaining time, or says it's late", () => {
    expect(shortOrderId(order.id)).toBe("3F2A9C1B");
    expect(orderStatusText("en", order, NOW)).toBe(
      "Order #3F2A9C1B is on its way to you. It should reach you in about 7 min.",
    );
    expect(orderStatusText("en", order, NOW + 20 * 60000)).toContain("taking longer than expected");
    expect(orderStatusText("en", { ...order, status: "delivered" }, NOW)).toBe(
      "Order #3F2A9C1B has been delivered.",
    );
    expect(orderStatusText("hi", order, NOW)).toContain("7 मिनट");
  });
});

describe("composeReply", () => {
  it("answers order questions with the live status", () => {
    const r = reply({ queryVector: vectorFor("where_is_order") });
    expect(r.handoff).toBe(false);
    expect(r.messages[0].text).toContain("Order #3F2A9C1B is on its way");
    expect(r.messages[0].quickReplies?.at(-1)?.id).toBe(AGENT_REPLY_ID);
  });

  it("says so when there is no order", () => {
    const r = reply({ queryVector: vectorFor("where_is_order"), order: null });
    expect(r.messages[0].text).toBe("I can't find a recent order on your account.");
  });

  it("answers in the customer's language", () => {
    const r = reply({ queryVector: vectorFor("delivery_fee"), lang: "bn" });
    expect(r.messages[0].text).toBe(KB_SEED.find((e) => e.id === "delivery_fee")!.answers.bn);
    expect(r.messages[0].quickReplies?.at(-1)?.label).toBe("কারও সঙ্গে কথা বলুন");
  });

  it("hands refunds to the team with contact options", () => {
    const r = reply({ queryVector: vectorFor("refund") });
    expect(r.handoff).toBe(true);
    expect(r.messages.map((m) => m.from)).toEqual(["bot", "system"]);
    expect(r.messages[1].action).toBe("contact_options");
  });

  it("answers a tapped topic chip without searching", () => {
    const r = reply({ quickReplyId: "kb:payment_methods" });
    expect(r.topic).toBe("payment_methods");
    expect(r.messages[0].text).toContain("cash on delivery");
  });

  it("hands off on the Talk to a person chip", () => {
    const r = reply({ quickReplyId: AGENT_REPLY_ID });
    expect(r.handoff).toBe(true);
    expect(r.messages).toHaveLength(1);
  });

  it("offers a person and starter topics when it doesn't know", () => {
    const r = reply({ text: "weather forecast", queryVector: axis(0, 0.2) });
    expect(r.handoff).toBe(false);
    expect(r.messages[0].quickReplies?.[0].id).toBe(AGENT_REPLY_ID);
    expect(r.messages[0].quickReplies?.map((q) => q.id)).toContain("kb:refund");
  });
});
