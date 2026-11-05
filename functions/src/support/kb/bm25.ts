/**
 * Function words that match everything and so only add noise: English,
 * romanised Hindi/Bengali, and the commonest Hindi / Bengali / Punjabi
 * particles and pronouns.
 */
const STOPWORDS = new Set(
  (
    "a an the is am are was were be been do does did can could will would should " +
    "i me my mine you your we our it its this that there here to of in on at for " +
    "with and or but not no so if what whats when where which who why how any some " +
    "s t ve ll re d m please pls hai ka ki ke ko se me mera meri mujhe kya ho " +
    "है हैं का की के को से में मेरा मेरी मुझे क्या हो " +
    "আমার আমি কি কী এর এটা হয় হবে " +
    "ਹੈ ਹਨ ਦਾ ਦੀ ਦੇ ਨੂੰ ਤੋਂ ਵਿੱਚ ਮੇਰਾ ਮੇਰੀ ਮੈਨੂੰ ਕੀ"
  ).split(" "),
);

/**
 * Lower-cased word tokens for any of the app's scripts. Splits on
 * anything that isn't a letter, combining mark or digit, so Bengali,
 * Devanagari and Gurmukhi words keep their vowel signs.
 */
export function tokenize(text: string): string[] {
  return (text.toLowerCase().match(/[\p{L}\p{M}\p{N}]+/gu) ?? []).filter(
    (t) => !STOPWORDS.has(t) && (t.length > 1 || /\p{N}/u.test(t)),
  );
}

/**
 * Okapi BM25 over a small in-memory corpus (the support knowledge base:
 * one document per entry). Good at exact words the embedding model can
 * blur together — "COD", "UPI", "PhonePe", an order number.
 */
export class Bm25 {
  private readonly docs: Map<string, number>[];
  private readonly lengths: number[];
  private readonly avgLength: number;
  private readonly docFreq = new Map<string, number>();

  constructor(
    documents: string[][],
    private readonly k1 = 1.2,
    private readonly b = 0.75,
  ) {
    this.docs = documents.map((tokens) => {
      const tf = new Map<string, number>();
      for (const t of tokens) tf.set(t, (tf.get(t) ?? 0) + 1);
      return tf;
    });
    this.lengths = documents.map((d) => d.length);
    this.avgLength = this.lengths.reduce((a, b) => a + b, 0) / Math.max(1, documents.length);
    for (const tf of this.docs) {
      for (const term of tf.keys()) this.docFreq.set(term, (this.docFreq.get(term) ?? 0) + 1);
    }
  }

  /** One score per document, in corpus order; 0 = no shared terms. */
  scores(query: string[]): number[] {
    const n = this.docs.length;
    const terms = [...new Set(query)];
    return this.docs.map((tf, i) => {
      let score = 0;
      for (const term of terms) {
        const f = tf.get(term);
        if (!f) continue;
        const df = this.docFreq.get(term) ?? 0;
        const idf = Math.log(1 + (n - df + 0.5) / (df + 0.5));
        const norm = this.k1 * (1 - this.b + (this.b * this.lengths[i]) / (this.avgLength || 1));
        score += (idf * f * (this.k1 + 1)) / (f + norm);
      }
      return score;
    });
  }
}

/**
 * Reciprocal Rank Fusion: combines several rankings (each a list of
 * document indices, best first) without having to calibrate their
 * scores against each other. Returns indices, best first.
 */
export function reciprocalRankFusion(rankings: number[][], k = 60): number[] {
  const fused = new Map<number, number>();
  for (const ranking of rankings) {
    ranking.forEach((doc, rank) => fused.set(doc, (fused.get(doc) ?? 0) + 1 / (k + rank + 1)));
  }
  return [...fused.entries()].sort((a, b) => b[1] - a[1]).map(([doc]) => doc);
}

/** Indices of [scores] above [min], best first. */
export function rankBy(scores: number[], min = 0): number[] {
  return scores
    .map((score, i) => [score, i] as const)
    .filter(([score]) => score > min)
    .sort((a, b) => b[0] - a[0])
    .map(([, i]) => i);
}
