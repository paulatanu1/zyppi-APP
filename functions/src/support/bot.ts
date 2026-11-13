import { FieldValue, Timestamp, type DocumentReference, type Firestore } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { onDocumentCreated } from "firebase-functions/firestore";
import { getFeatures } from "../shared/features";
import { db } from "../shared/firebase";
import { COPY } from "./copy";
import { embed, type Embedder } from "./kb/embed";
import { loadRetriever } from "./kb/store";
import { detectLang, isLang, type Lang } from "./lang";
import {
  AGENT_REPLY_ID,
  composeReply,
  handoffMessage,
  type OrderSummary,
  type OutMessage,
} from "./reply";

export const CHATS = "supportChats";

/** Messages per customer per minute before the bot stops answering. */
export const RATE_LIMIT_PER_MINUTE = 10;

/**
 * Writes bot/system messages after the customer's, in order, and updates
 * the chat summary. `createdAt` is spaced a millisecond apart so the
 * app's orderBy keeps them in sequence.
 */
export async function postMessages(
  chatRef: DocumentReference,
  messages: OutMessage[],
  extra: Record<string, unknown> = {},
): Promise<void> {
  if (messages.length === 0 && Object.keys(extra).length === 0) return;
  const batch = chatRef.firestore.batch();
  const base = Date.now();
  messages.forEach((m, i) => {
    batch.create(chatRef.collection("messages").doc(), {
      ...m,
      createdAt: Timestamp.fromMillis(base + i),
    });
  });
  const last = messages[messages.length - 1];
  batch.update(chatRef, {
    ...(last ? { lastMessage: last.text, unreadByUser: FieldValue.increment(messages.length) } : {}),
    updatedAt: FieldValue.serverTimestamp(),
    ...extra,
  });
  await batch.commit();
}

/** The chat's order, or the customer's latest — only ever their own. */
async function findOrder(firestore: Firestore, userId: string, orderId: unknown): Promise<OrderSummary | null> {
  const toSummary = (id: string, d: FirebaseFirestore.DocumentData): OrderSummary => ({
    id,
    status: (d.status as string) ?? "placed",
    placedAtMs: d.placedAt instanceof Timestamp ? d.placedAt.toMillis() : null,
    etaMinutes: typeof d.etaMinutes === "number" ? d.etaMinutes : null,
  });
  if (typeof orderId === "string" && orderId) {
    const snap = await firestore.collection("orders").doc(orderId).get();
    if (snap.exists && snap.get("userId") === userId) return toSummary(snap.id, snap.data()!);
  }
  const latest = await firestore
    .collection("orders")
    .where("userId", "==", userId)
    .orderBy("placedAt", "desc")
    .limit(1)
    .get();
  return latest.empty ? null : toSummary(latest.docs[0].id, latest.docs[0].data());
}

/**
 * Handles one customer message: bookkeeping and rate limit in a
 * transaction, then — while the bot owns the chat — a reply.
 * Exported for the emulator tests, which pass a fake [embedder].
 */
export async function handleUserMessage(
  chatRef: DocumentReference,
  message: { text: string; quickReplyId?: string | null },
  embedder: Embedder = embed,
  nowMs = Date.now(),
): Promise<void> {
  const firestore = chatRef.firestore;
  const text = message.text.trim();

  const state = await firestore.runTransaction(async (tx) => {
    const chat = await tx.get(chatRef);
    if (!chat.exists) return null;
    const d = chat.data()!;
    const lang: Lang = detectLang(text, isLang(d.lang) ? d.lang : "en");
    const windowStart = typeof d.rateWindowStart === "number" ? d.rateWindowStart : 0;
    const fresh = nowMs - windowStart >= 60_000;
    const count = fresh ? 1 : ((d.rateCount as number) ?? 0) + 1;
    tx.update(chatRef, {
      lang,
      lastMessage: text,
      updatedAt: FieldValue.serverTimestamp(),
      rateWindowStart: fresh ? nowMs : windowStart,
      rateCount: count,
      ...(d.status === "bot" ? {} : { unreadByAgent: FieldValue.increment(1) }),
    });
    return { status: d.status as string, userId: d.userId as string, orderId: d.orderId, lang, count };
  });
  if (!state || state.status !== "bot") return; // agent's turn (Phase 2 inbox)

  const { lang } = state;
  // Bot switched off in Settings → Services: straight to the team, without
  // loading the model.
  if (!(await getFeatures(nowMs)).supportBot) {
    await postMessages(chatRef, [handoffMessage(lang)], {
      status: "waiting_agent",
      handoffAt: FieldValue.serverTimestamp(),
    });
    return;
  }
  if (state.count > RATE_LIMIT_PER_MINUTE) {
    // Say it once per window, then stay quiet.
    if (state.count === RATE_LIMIT_PER_MINUTE + 1) {
      await postMessages(chatRef, [{ from: "bot", text: COPY[lang].rateLimited }]);
    }
    return;
  }

  try {
    const needsSearch = !message.quickReplyId;
    const [retriever, order, queryVector] = await Promise.all([
      loadRetriever(firestore, nowMs),
      findOrder(firestore, state.userId, state.orderId),
      needsSearch
        ? embedder([text], "query")
            .then(([v]) => v ?? null)
            .catch((error) => {
              // Model failed to load: fall back to BM25 only.
              logger.error("Support embedding failed", { error });
              return null;
            })
        : Promise.resolve(null),
    ]);
    const reply = composeReply({
      text,
      quickReplyId: message.quickReplyId,
      lang,
      order,
      nowMs,
      retriever,
      queryVector,
    });
    logger.info("Support bot reply", { chatId: chatRef.id, topic: reply.topic, handoff: reply.handoff });
    await postMessages(
      chatRef,
      reply.messages,
      reply.handoff ? { status: "waiting_agent", handoffAt: FieldValue.serverTimestamp() } : {},
    );
  } catch (error) {
    logger.error("Support bot failed", { chatId: chatRef.id, error });
    await postMessages(chatRef, [
      {
        from: "bot",
        text: COPY[lang].error,
        quickReplies: [{ id: AGENT_REPLY_ID, label: COPY[lang].talkToPerson }],
      },
    ]);
  }
}

/**
 * The support bot: answers each customer message in supportChats/{chatId}
 * while the chat's status is `bot`. 1 GiB for the embedding model.
 */
export const onSupportMessageCreated = onDocumentCreated(
  { document: `${CHATS}/{chatId}/messages/{messageId}`, memory: "1GiB", timeoutSeconds: 120 },
  async (event) => {
    const data = event.data?.data();
    if (!data || data.from !== "user" || typeof data.text !== "string") return;
    await handleUserMessage(db.collection(CHATS).doc(event.params.chatId), {
      text: data.text,
      quickReplyId: typeof data.quickReplyId === "string" ? data.quickReplyId : null,
    });
  },
);
