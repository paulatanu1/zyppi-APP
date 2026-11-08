import { COPY, orderStatusText } from "./copy";
import type { Lang } from "./lang";
import type { Retriever } from "./kb/retrieve";
import type { KbEntry } from "./kb/types";

/** Chip under a bot message. `kb:<entryId>` answers that topic; `agent` hands off. */
export interface QuickReply {
  id: string;
  label: string;
}

export const AGENT_REPLY_ID = "agent";

export interface OutMessage {
  from: "bot" | "system";
  text: string;
  quickReplies?: QuickReply[];
  /** `contact_options`: the app shows WhatsApp / Call buttons under it. */
  action?: "contact_options";
}

export interface OrderSummary {
  id: string;
  status: string;
  placedAtMs: number | null;
  etaMinutes: number | null;
}

export interface BotReply {
  messages: OutMessage[];
  handoff: boolean;
  /** Matched topic, for logs. */
  topic: string | null;
}

/** Topics offered when the bot has no idea what was asked. */
const STARTER_TOPICS = ["where_is_order", "refund", "delivery_fee"];

function chip(entry: KbEntry, lang: Lang): QuickReply {
  return { id: `kb:${entry.id}`, label: entry.title[lang] };
}

function personChip(lang: Lang): QuickReply {
  return { id: AGENT_REPLY_ID, label: COPY[lang].talkToPerson };
}

/** The system message that ends the bot's part of the chat. */
export function handoffMessage(lang: Lang): OutMessage {
  return { from: "system", text: COPY[lang].handoff, action: "contact_options" };
}

/**
 * What the bot says to one customer message. Pure: Firestore reads and
 * the embedding happen in bot.ts, so this is unit-tested directly.
 */
export function composeReply(input: {
  text: string;
  quickReplyId?: string | null;
  lang: Lang;
  order: OrderSummary | null;
  nowMs: number;
  retriever: Retriever;
  queryVector: Float32Array | null;
}): BotReply {
  const { lang, retriever } = input;
  const copy = COPY[lang];

  if (input.quickReplyId === AGENT_REPLY_ID) {
    return { messages: [handoffMessage(lang)], handoff: true, topic: "talk_to_person" };
  }

  const tapped = input.quickReplyId?.startsWith("kb:")
    ? retriever.byId(input.quickReplyId.slice(3))
    : undefined;
  const decision = tapped
    ? ({ kind: "answer", entry: tapped, confidence: 1 } as const)
    : retriever.decide(input.text, input.queryVector);

  if (decision.kind === "suggest") {
    return {
      messages: [
        {
          from: "bot",
          text: copy.didYouMean,
          quickReplies: [...decision.entries.map((e) => chip(e, lang)), personChip(lang)],
        },
      ],
      handoff: false,
      topic: null,
    };
  }

  if (decision.kind === "unknown") {
    const starters = STARTER_TOPICS.map((id) => retriever.byId(id)).filter(
      (e): e is KbEntry => !!e,
    );
    return {
      messages: [
        {
          from: "bot",
          text: copy.unknown,
          quickReplies: [personChip(lang), ...starters.map((e) => chip(e, lang))],
        },
      ],
      handoff: false,
      topic: null,
    };
  }

  const entry = decision.entry;
  const answer = entry.answers[lang] || entry.answers.en;
  const related = (entry.related ?? [])
    .map((id) => retriever.byId(id))
    .filter((e): e is KbEntry => !!e && !e.hidden)
    .map((e) => chip(e, lang));

  if (entry.action === "handoff") {
    const messages: OutMessage[] = answer ? [{ from: "bot", text: answer }] : [];
    messages.push(handoffMessage(lang));
    return { messages, handoff: true, topic: entry.id };
  }

  let text = answer;
  if (entry.action === "order_status") {
    const status = input.order ? orderStatusText(lang, input.order, input.nowMs) : copy.noOrder;
    text = answer ? `${status}\n\n${answer}` : status;
  }
  return {
    messages: [{ from: "bot", text, quickReplies: [...related, personChip(lang)] }],
    handoff: false,
    topic: entry.id,
  };
}
