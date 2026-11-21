import { LANGS } from "../lang";
import { Bm25, rankBy, reciprocalRankFusion, tokenize } from "./bm25";
import { cosine } from "./embed";
import type { KbEntry } from "./types";

/** An entry plus the embeddings of all its example questions. */
export interface IndexedEntry {
  entry: KbEntry;
  vectors: Float32Array[];
}

/**
 * Confidence thresholds. multilingual-e5 scores sit in a narrow band: any
 * short text scores ~0.82–0.87 against every entry, so an absolute cosine
 * can't tell "?" from "track rider". What separates them is the *lift*: how
 * far an entry's cosine stands above the median over all entries (real
 * matches ≥ ~0.06, off-topic text ~0.02–0.04 on the 44-entry KB). Tuned
 * with a red-team set of ~160 messages — see test/unit/support_*.test.ts and
 * scripts/support-smoke.ts before changing them.
 */
export const THRESHOLDS = {
  /** Answer directly at or above this cosine… */
  answer: 0.88,
  /** …if the runner-up entry is at least this much lower (or BM25 agrees). */
  margin: 0.015,
  /** An entry is relevant when its cosine is this far above the median… */
  lift: 0.045,
  /** …or BM25 finds real shared words and the lift is at least this. */
  suggestBm25: 2.5,
  liftWithBm25: 0.04,
  /** Many rare shared words ("paisa kat gaya") count even at a small lift. */
  strongBm25: 8,
  liftWithStrongBm25: 0.02,
  /** A clear standout answers even below `answer`. */
  strongLift: 0.085,
  strongMargin: 0.02,
};

export type Decision =
  | { kind: "answer"; entry: KbEntry; confidence: number }
  | { kind: "suggest"; entries: KbEntry[]; confidence: number }
  | { kind: "unknown"; confidence: number };

interface Scored {
  index: number;
  cosine: number;
  bm25: number;
}

/**
 * Hybrid search over the knowledge base: BM25 on words + cosine on
 * multilingual embeddings, fused with Reciprocal Rank Fusion, then a
 * confidence gate decides whether to answer, offer choices, or admit it
 * doesn't know (the caller then offers a person).
 */
export class Retriever {
  private readonly bm25: Bm25;

  constructor(private readonly entries: IndexedEntry[]) {
    this.bm25 = new Bm25(
      entries.map(({ entry }) =>
        tokenize(
          [
            ...LANGS.flatMap((l) => entry.questions[l] ?? []),
            ...LANGS.map((l) => entry.title[l] ?? ""),
            ...(entry.keywords ?? []),
          ].join(" "),
        ),
      ),
    );
  }

  get size(): number {
    return this.entries.length;
  }

  byId(id: string): KbEntry | undefined {
    return this.entries.find((e) => e.entry.id === id)?.entry;
  }

  /** Entries best first, with both scores. */
  search(text: string, queryVector: Float32Array | null): Scored[] {
    return this.score(text, queryVector).results;
  }

  private score(text: string, queryVector: Float32Array | null): { results: Scored[]; median: number } {
    const bm25 = this.bm25.scores(tokenize(text));
    const cos = this.entries.map(({ vectors }) =>
      queryVector && vectors.length
        ? Math.max(...vectors.map((v) => cosine(queryVector, v)))
        : 0,
    );
    // Over every entry, not just the fused results (those drop zero scores).
    const sorted = [...cos].sort((a, b) => a - b);
    const median = sorted.length ? sorted[Math.floor(sorted.length / 2)] : 0;
    const fused = reciprocalRankFusion([rankBy(bm25), rankBy(cos)]);
    return { results: fused.map((index) => ({ index, cosine: cos[index], bm25: bm25[index] })), median };
  }

  decide(text: string, queryVector: Float32Array | null): Decision {
    const { results, median } = this.score(text, queryVector);
    if (results.length === 0) return { kind: "unknown", confidence: 0 };

    const entryOf = (r: Scored) => this.entries[r.index].entry;
    const bestBm25 = Math.max(...results.map((r) => r.bm25));

    // Without the model (it failed to load), only words count.
    if (queryVector === null) {
      const hits = results.filter((r) => r.bm25 >= THRESHOLDS.suggestBm25);
      const top = results[0];
      if (top.bm25 > 0 && top.bm25 === bestBm25 && results.filter((r) => r.bm25 > 0).length === 1) {
        return { kind: "answer", entry: entryOf(top), confidence: 0 };
      }
      const entries = hits.map(entryOf).filter((e) => !e.hidden).slice(0, 3);
      return entries.length ? { kind: "suggest", entries, confidence: 0 } : { kind: "unknown", confidence: 0 };
    }

    const lift = (r: Scored) => r.cosine - median;
    const relevant = (r: Scored) =>
      lift(r) >= THRESHOLDS.lift ||
      (r.bm25 >= THRESHOLDS.suggestBm25 && lift(r) >= THRESHOLDS.liftWithBm25) ||
      (r.bm25 >= THRESHOLDS.strongBm25 && lift(r) >= THRESHOLDS.liftWithStrongBm25);

    const byCosine = [...results].sort((a, b) => b.cosine - a.cosine);
    const best = byCosine[0];
    const runnerUp = byCosine[1]?.cosine ?? 0;
    const top = results[0];
    const bm25Agrees = top.bm25 > 0 && top.bm25 === bestBm25;

    const confident =
      relevant(top) &&
      top.cosine >= THRESHOLDS.answer &&
      (top.cosine - Math.max(0, ...results.slice(1).map((r) => r.cosine)) >= THRESHOLDS.margin || bm25Agrees);
    // One entry clearly stands out from the rest, even at a lower cosine.
    const standout =
      lift(best) >= THRESHOLDS.strongLift && best.cosine - runnerUp >= THRESHOLDS.strongMargin;

    if (confident) return { kind: "answer", entry: entryOf(top), confidence: top.cosine };
    if (standout) return { kind: "answer", entry: entryOf(best), confidence: best.cosine };

    const candidates = results.filter(relevant);
    if (candidates.length === 0) return { kind: "unknown", confidence: best.cosine };
    // Hidden entries (greetings, thanks…) are never chips; if one is the
    // best relevant match, answering it beats offering unrelated topics.
    const first = candidates[0];
    if (entryOf(first).hidden && (first === top || first === best)) {
      return { kind: "answer", entry: entryOf(first), confidence: first.cosine };
    }
    const visible = candidates.filter((c) => !entryOf(c).hidden);
    const entries = visible.map(entryOf).slice(0, 3);
    if (entries.length === 0) return { kind: "unknown", confidence: best.cosine };
    // The only plausible topic, and it shares words with the message: a
    // one-chip "did you mean" would just be an extra tap.
    if (visible.length === 1 && (visible[0].bm25 > 0 || lift(visible[0]) >= THRESHOLDS.strongLift)) {
      return { kind: "answer", entry: entries[0], confidence: visible[0].cosine };
    }
    return { kind: "suggest", entries, confidence: best.cosine };
  }
}
