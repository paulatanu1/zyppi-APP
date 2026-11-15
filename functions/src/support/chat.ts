import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/https";
import { requireString, requireUid } from "../shared/callable";
import { requireRole } from "../shared/roles";
import { db, messaging } from "../shared/firebase";
import { CHATS, postMessages } from "./bot";
import { COPY, shortOrderId } from "./copy";
import { langFromLocale, type Lang } from "./lang";
import { AGENT_REPLY_ID, handoffMessage, type OutMessage } from "./reply";

const STARTERS = ["where_is_order", "refund", "missing_item", "payment_methods"];

/** One chat per customer per order, plus one general chat. */
function chatIdFor(uid: string, orderId: string | null): string {
  return `${uid}_${orderId ?? "general"}`;
}

async function welcome(lang: Lang, orderId: string | null): Promise<OutMessage> {
  const titles = await Promise.all(
    STARTERS.map(async (id) => {
      const snap = await db.collection("supportKb").doc(id).get();
      const title = snap.get(`title.${lang}`) as string | undefined;
      return title ? { id: `kb:${id}`, label: title } : null;
    }),
  );
  return {
    from: "bot",
    text: orderId ? COPY[lang].welcomeOrder(shortOrderId(orderId)) : COPY[lang].welcome,
    quickReplies: [
      ...titles.filter((t): t is { id: string; label: string } => t !== null),
      { id: AGENT_REPLY_ID, label: COPY[lang].talkToPerson },
    ],
  };
}

/**
 * Opens (or reopens) the customer's support chat — one per order, plus
 * one general chat — and greets them. The bot takes it from there.
 *
 * Request: {orderId?, locale?}. Response: {chatId}.
 */
export const openSupportChat = onCall(async (request) => {
  const uid = requireUid(request);
  const rawOrderId = request.data?.orderId;
  const orderId = typeof rawOrderId === "string" && rawOrderId ? rawOrderId : null;
  if (orderId && !/^[\w-]{1,64}$/.test(orderId)) {
    throw new HttpsError("invalid-argument", "Invalid orderId");
  }
  if (orderId) {
    const order = await db.collection("orders").doc(orderId).get();
    if (!order.exists || order.get("userId") !== uid) {
      throw new HttpsError("not-found", "Order not found");
    }
  }
  const lang = langFromLocale(request.data?.locale);
  const chatRef = db.collection(CHATS).doc(chatIdFor(uid, orderId));

  const greet = await db.runTransaction(async (tx) => {
    const chat = await tx.get(chatRef);
    if (!chat.exists) {
      tx.create(chatRef, {
        userId: uid,
        orderId,
        status: "bot",
        lang,
        agentId: null,
        createdAt: FieldValue.serverTimestamp(),
        updatedAt: FieldValue.serverTimestamp(),
        lastMessage: null,
        unreadByUser: 0,
        unreadByAgent: 0,
      });
      return true;
    }
    if (chat.get("status") === "closed") {
      tx.update(chatRef, { status: "bot", agentId: null, lang, updatedAt: FieldValue.serverTimestamp() });
      return true;
    }
    return false;
  });
  if (greet) await postMessages(chatRef, [await welcome(lang, orderId)]);
  return { chatId: chatRef.id };
});

/**
 * "Talk to a person": hands the chat from the bot to the support team.
 * Request: {chatId}.
 */
export const requestSupportAgent = onCall(async (request) => {
  const uid = requireUid(request);
  const chatRef = db.collection(CHATS).doc(requireString(request.data?.chatId, "chatId"));
  const handedOff = await db.runTransaction(async (tx) => {
    const chat = await tx.get(chatRef);
    if (!chat.exists || chat.get("userId") !== uid) throw new HttpsError("not-found", "Chat not found");
    if (chat.get("status") !== "bot") return null;
    tx.update(chatRef, { status: "waiting_agent", handoffAt: FieldValue.serverTimestamp() });
    return (chat.get("lang") as Lang) ?? "en";
  });
  if (handedOff) await postMessages(chatRef, [handoffMessage(handedOff)]);
  return { ok: true };
});

async function pushToCustomer(
  userId: string,
  lang: Lang,
  chat: { id: string; orderId: string | null },
  text: string,
) {
  const profile = await db.collection("users").doc(userId).get();
  const token = profile.get("fcmToken") as string | null | undefined;
  if (!token || profile.get("notifyOrderUpdates") === false) return;
  try {
    await messaging.send({
      token,
      notification: { title: COPY[lang].agentReplyPush, body: text.slice(0, 140) },
      data: { chatId: chat.id, chatOrderId: chat.orderId ?? "" },
      android: { priority: "high" },
    });
  } catch (error) {
    if ((error as { code?: string }).code === "messaging/registration-token-not-registered") {
      await profile.ref.update({ fcmToken: null });
      return;
    }
    logger.error("Support push failed", { chatId: chat.id, error });
  }
}

/**
 * Support team reply (admin panel inbox, Phase 2). Takes the chat over
 * from the bot and pushes the customer.
 * Request: {chatId, text}.
 */
export const adminReplySupport = onCall(async (request) => {
  const agentId = requireRole(request, ["support", "ops"]).uid;
  const chatRef = db.collection(CHATS).doc(requireString(request.data?.chatId, "chatId"));
  const text = requireString(request.data?.text, "text").trim().slice(0, 2000);
  const chat = await chatRef.get();
  if (!chat.exists) throw new HttpsError("not-found", "Chat not found");

  const batch = db.batch();
  batch.create(chatRef.collection("messages").doc(), {
    from: "agent",
    text,
    agentId,
    createdAt: FieldValue.serverTimestamp(),
  });
  batch.update(chatRef, {
    status: "agent",
    agentId,
    lastMessage: text,
    unreadByUser: FieldValue.increment(1),
    unreadByAgent: 0,
    updatedAt: FieldValue.serverTimestamp(),
  });
  await batch.commit();
  await pushToCustomer(
    chat.get("userId"),
    (chat.get("lang") as Lang) ?? "en",
    { id: chatRef.id, orderId: (chat.get("orderId") as string | null) ?? null },
    text,
  );
  return { ok: true };
});

/** Closes a chat; the customer's next openSupportChat reopens it with the bot. */
export const adminCloseSupport = onCall(async (request) => {
  requireRole(request, ["support", "ops"]);
  const chatRef = db.collection(CHATS).doc(requireString(request.data?.chatId, "chatId"));
  if (!(await chatRef.get()).exists) throw new HttpsError("not-found", "Chat not found");
  await chatRef.update({ status: "closed", updatedAt: FieldValue.serverTimestamp() });
  return { ok: true };
});
