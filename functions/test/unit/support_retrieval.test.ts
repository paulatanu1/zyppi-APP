import { describe, expect, it } from "vitest";
import { Bm25, rankBy, reciprocalRankFusion, tokenize } from "../../src/support/kb/bm25";
import { decodeVector, encodeVector } from "../../src/support/kb/embed";
import { Retriever, THRESHOLDS, type IndexedEntry } from "../../src/support/kb/retrieve";
import { KB_SEED } from "../../src/support/kb/seed";
import { detectLang, langFromLocale, LANGS } from "../../src/support/lang";

/** Unit vector pointing mostly along axis [i] (cosine to its own axis = [strength]). */
function axis(i: number, strength = 1, dims = 16): Float32Array {
  const v = new Float32Array(dims).fill(Math.sqrt((1 - strength ** 2) / (dims - 1)));
  v[i] = strength;
  return v;
}

/** The seed, with entry i's questions all embedded on axis i. */
function seedIndex(): IndexedEntry[] {
  return KB_SEED.map((entry, i) => ({ entry, vectors: [axis(i)] }));
}

describe("tokenize", () => {
  it("keeps Indic vowel signs and drops stopwords", () => {
    expect(tokenize("Where is my COD order?")).toEqual(["cod", "order"]);
    expect(tokenize("টাকা ফেরত কবে পাব?")).toEqual(["টাকা", "ফেরত", "কবে", "পাব"]);
    expect(tokenize("मेरा ऑर्डर कहाँ है")).toEqual(["ऑर्डर", "कहाँ"]);
  });
});

describe("Bm25", () => {
  it("ranks the document sharing the rarest terms first", () => {
    const bm25 = new Bm25([
      tokenize("cash on delivery cod payment"),
      tokenize("refund payment money back"),
      tokenize("delivery areas purulia"),
    ]);
    expect(rankBy(bm25.scores(tokenize("cod payment")))[0]).toBe(0);
    expect(rankBy(bm25.scores(tokenize("refund")))).toEqual([1]);
    expect(bm25.scores(tokenize("weather"))).toEqual([0, 0, 0]);
  });
});

describe("reciprocalRankFusion", () => {
  it("prefers documents ranked well by both lists", () => {
    expect(reciprocalRankFusion([[0, 1, 2], [1, 0, 2]]).slice(0, 2).sort()).toEqual([0, 1]);
    expect(reciprocalRankFusion([[2, 1], [1, 3]])[0]).toBe(1);
  });
});

describe("vectors", () => {
  it("round-trip through base64", () => {
    const v = Float32Array.from([0.25, -1, 3.5]);
    expect(Array.from(decodeVector(encodeVector(v)))).toEqual([0.25, -1, 3.5]);
  });
});

describe("detectLang", () => {
  it("reads the script, else keeps the chat's language", () => {
    expect(detectLang("আমার অর্ডার কোথায়?")).toBe("bn");
    expect(detectLang("मेरा ऑर्डर कहाँ है?")).toBe("hi");
    expect(detectLang("ਮੇਰਾ ਆਰਡਰ ਕਿੱਥੇ ਹੈ?")).toBe("pa");
    expect(detectLang("refund kab milega", "hi")).toBe("hi");
    expect(detectLang("where is my order")).toBe("en");
    expect(langFromLocale("bn_BN")).toBe("bn");
    expect(langFromLocale("pa-Guru")).toBe("pa");
    expect(langFromLocale("fr")).toBe("en");
  });
});

describe("Retriever", () => {
  const retriever = new Retriever(seedIndex());
  const idx = (id: string) => KB_SEED.findIndex((e) => e.id === id);

  it("answers a clear semantic match", () => {
    const d = retriever.decide("anything", axis(idx("refund"), 0.95));
    expect(d.kind).toBe("answer");
    expect(d.kind === "answer" && d.entry.id).toBe("refund");
  });

  it("suggests visible topics when unsure", () => {
    const vector = axis(idx("coupons"), (THRESHOLDS.answer + THRESHOLDS.suggest) / 2);
    const d = retriever.decide("anything", vector);
    expect(d.kind).toBe("suggest");
    if (d.kind === "suggest") {
      expect(d.entries[0].id).toBe("coupons");
      expect(d.entries.every((e) => !e.hidden)).toBe(true);
    }
  });

  it("admits it doesn't know off-topic text", () => {
    const d = retriever.decide("weather forecast", axis(0, 0.2));
    expect(d.kind).toBe("unknown");
  });

  it("still answers exact words without the model", () => {
    const d = retriever.decide("purulia", null);
    expect(d.kind === "answer" && d.entry.id).toBe("delivery_areas");
  });
});

describe("seed", () => {
  it("has every language for every entry, and valid links", () => {
    const ids = new Set(KB_SEED.map((e) => e.id));
    expect(ids.size).toBe(KB_SEED.length);
    for (const entry of KB_SEED) {
      for (const lang of LANGS) {
        expect(entry.title[lang], `${entry.id}.title.${lang}`).toBeTruthy();
        expect(entry.questions[lang].length, `${entry.id}.questions.${lang}`).toBeGreaterThan(0);
        expect(typeof entry.answers[lang]).toBe("string");
        if (entry.action !== "order_status" && entry.id !== "talk_to_person") {
          expect(entry.answers[lang], `${entry.id}.answers.${lang}`).toBeTruthy();
        }
      }
      for (const related of entry.related ?? []) expect(ids.has(related), related).toBe(true);
    }
  });
});
