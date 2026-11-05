import type { Lang } from "../lang";

/**
 * What the bot does after matching an entry:
 * - `none`: send the answer.
 * - `order_status`: send the order's live status (then the answer, if any).
 * - `handoff`: send the answer, then connect the customer to the team.
 */
export type KbAction = "none" | "order_status" | "handoff";

/** One support topic: ways people ask it, and the answer, per language. */
export interface KbEntry {
  id: string;
  /** Short label in each language, for "Did you mean…?" chips. */
  title: Record<Lang, string>;
  /** Example questions (any language may also hold romanised text). */
  questions: Record<Lang, string[]>;
  /** Extra BM25 keywords (spellings, brand names) not worth a full question. */
  keywords?: string[];
  /** Empty string = no text (e.g. `order_status` entries that only show the status). */
  answers: Record<Lang, string>;
  action: KbAction;
  /** Entry ids offered as follow-up chips. */
  related?: string[];
  /** Greetings / thanks: answered, but never suggested as a chip. */
  hidden?: boolean;
}
