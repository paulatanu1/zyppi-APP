import { Timestamp } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { CHATS, RATE_LIMIT_PER_MINUTE, handleUserMessage } from "../../src/support/bot";
import type { Embedder } from "../../src/support/kb/embed";
import { KB_SEED } from "../../src/support/kb/seed";
import { clearRetrieverCache, ingest } from "../../src/support/kb/store";
import { db } from "../../src/shared/firebase";
import { UID, resetData } from "./fixtures";

/**
 * Fake embedder: every seed question of entry i maps to axis i, so a
 * seed question as a query is a perfect match and anything else is a
 * weak one. Keeps the tests free of the real model.
 */
const DIMS = KB_SEED.length + 1;
const axisOf = new Map<string, number>();
KB_SEED.forEach((e, i) => Object.values(e.questions).flat().forEach((q) => axisOf.set(q, i)));
const fakeEmbed: Embedder = async (texts) =>
  texts.map((t) => {
    const v = new Float32Array(DIMS);
    v[axisOf.get(t) ?? DIMS - 1] = 1;
    return v;
  });

const CHAT = `${UID}_general`;
const chatRef = () => db.collection(CHATS).doc(CHAT);
const messages = async () =>
  (await chatRef().collection("messages").orderBy("createdAt").get()).docs.map((d) => d.data());

async function send(text: string, quickReplyId: string | null = null, nowMs = Date.now()) {
  await chatRef().collection("messages").add({ from: "user", text, createdAt: Timestamp.now() });
  await handleUserMessage(chatRef(), { text, quickReplyId }, fakeEmbed, nowMs);
}

describe("support bot", () => {
  beforeEach(async () => {
    await resetData();
    clearRetrieverCache();
    await ingest(db, KB_SEED, fakeEmbed);
    await chatRef().set({
      userId: UID, orderId: null, status: "bot", lang: "en", unreadByUser: 0, unreadByAgent: 0,
    });
    await db.doc("orders/o-1").set({
      userId: UID, status: "out_for_delivery", placedAt: Timestamp.now(), etaMinutes: 12,
    });
    await db.doc("orders/o-other").set({
      userId: "someone-else", status: "delivered", placedAt: Timestamp.now(), etaMinutes: 12,
    });
  });

  it("answers order questions from the customer's own latest order", async () => {
    await send("Where is my order?");
    const bot = (await messages()).filter((m) => m.from === "bot");
    expect(bot).toHaveLength(1);
    expect(bot[0].text).toContain("Order #o-1 is on its way");
    expect((await chatRef().get()).get("unreadByUser")).toBe(1);
  });

  it("replies in the language the customer writes in", async () => {
    await send("ডেলিভারি চার্জ কত?");
    const bot = (await messages()).filter((m) => m.from === "bot");
    expect(bot[0].text).toBe(KB_SEED.find((e) => e.id === "delivery_fee")!.answers.bn);
    expect((await chatRef().get()).get("lang")).toBe("bn");
  });

  it("hands refunds to the team and then stays quiet", async () => {
    await send("I want a refund");
    const chat = await chatRef().get();
    expect(chat.get("status")).toBe("waiting_agent");
    const all = await messages();
    expect(all.at(-1)).toMatchObject({ from: "system", action: "contact_options" });

    await send("hello?");
    expect(await messages()).toHaveLength(all.length + 1); // only the customer's
    expect((await chatRef().get()).get("unreadByAgent")).toBe(1);
  });

  it("warns once, then ignores a flood of messages", async () => {
    const now = Date.now();
    for (let i = 0; i < RATE_LIMIT_PER_MINUTE + 3; i++) await send("Hi", null, now + i);
    const bot = (await messages()).filter((m) => m.from === "bot");
    expect(bot).toHaveLength(RATE_LIMIT_PER_MINUTE + 1);
    expect(bot.at(-1)!.text).toContain("very quickly");
  });
});
