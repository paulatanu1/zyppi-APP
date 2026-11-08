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
 * Confidence thresholds on the best cosine similarity. multilingual-e5
 * scores sit in a narrow band (unrelated text still scores ~0.75), so
 * these are tuned on the seed questions — see test/unit/support_*.test.ts
 * and scripts/support-smoke.ts before changing them.
 */
export const THRESHOLDS = {
  /** Answer directly at or above this… */
  answer: 0.88,
  /** …if the runner-up entry is at least this much lower (or BM25 agrees). */
  margin: 0.015,
  /** Below this, nothing is a plausible match… */
  suggest: 0.84,
  /** …unless BM25 finds real shared words (stopwords excluded). */
  suggestBm25: 2.5,
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
    const bm25 = this.bm25.scores(tokenize(text));
    const cos = this.entries.map(({ vectors }) =>
      queryVector && vectors.length
        ? Math.max(...vectors.map((v) => cosine(queryVector, v)))
        : 0,
    );
    const fused = reciprocalRankFusion([rankBy(bm25), rankBy(cos)]);
    return fused.map((index) => ({ index, cosine: cos[index], bm25: bm25[index] }));
  }

  decide(text: string, queryVector: Float32Array | null): Decision {
    const results = this.search(text, queryVector);
    if (results.length === 0) return { kind: "unknown", confidence: 0 };

    const top = results[0];
    const bestCosine = Math.max(...results.map((r) => r.cosine));
    const runnerUp = Math.max(0, ...results.slice(1).map((r) => r.cosine));
    const bestBm25 = Math.max(...results.map((r) => r.bm25));
    const bm25Agrees = top.bm25 > 0 && top.bm25 === bestBm25;
    const confident =
      top.cosine >= THRESHOLDS.answer &&
      (top.cosine - runnerUp >= THRESHOLDS.margin || bm25Agrees);

    // Without the model (it failed to load), strong word matches still answer.
    const wordsOnly = queryVector === null && bm25Agrees && results.filter((r) => r.bm25 > 0).length === 1;

    if (confident || wordsOnly) {
      return { kind: "answer", entry: this.entries[top.index].entry, confidence: top.cosine };
    }
    if (bestCosine >= THRESHOLDS.suggest || bestBm25 >= THRESHOLDS.suggestBm25) {
      const entries = results
        .map((r) => this.entries[r.index].entry)
        .filter((e) => !e.hidden)
        .slice(0, 3);
      if (entries.length) return { kind: "suggest", entries, confidence: bestCosine };
    }
    return { kind: "unknown", confidence: bestCosine };
  }
}
