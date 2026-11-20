import { describe, expect, it } from "vitest";
import { MAX_TERM, indiaDay, mergeRows, normalizeTerm, statId } from "../../src/search/search_stats";

describe("normalizeTerm", () => {
  it("lower-cases, drops punctuation and squeezes spaces", () => {
    expect(normalizeTerm("  Amul   CHEESE, slice!! ")).toBe("amul cheese slice");
    expect(normalizeTerm("ghee/1 litre")).toBe("ghee 1 litre");
  });

  it("keeps Bengali, Hindi and Punjabi letters", () => {
    expect(normalizeTerm("দুধ")).toBe("দুধ");
    expect(normalizeTerm("आटा")).toBe("आटा");
    expect(normalizeTerm("ਦੁੱਧ")).toBe("ਦੁੱਧ");
  });

  it("drops empty, one-letter and non-string input", () => {
    expect(normalizeTerm("")).toBeNull();
    expect(normalizeTerm("a")).toBeNull();
    expect(normalizeTerm("!!!")).toBeNull();
    expect(normalizeTerm(42)).toBeNull();
  });

  it("cuts long searches", () => {
    expect(normalizeTerm("x".repeat(200))!.length).toBe(MAX_TERM);
  });
});

describe("indiaDay", () => {
  it("uses the India date, not UTC", () => {
    // 20 Nov 2026, 20:00 UTC is already 21 Nov in India.
    expect(indiaDay(new Date("2026-11-20T20:00:00Z"))).toBe("2026-11-21");
    expect(indiaDay(new Date("2026-11-20T10:00:00Z"))).toBe("2026-11-20");
  });
});

describe("statId", () => {
  it("never contains a slash", () => {
    expect(statId("2026-11-20", "a/b")).not.toContain("/");
    expect(statId("2026-11-20", "milk")).toBe("2026-11-20__milk");
  });
});

describe("mergeRows", () => {
  it("adds days together per term, most searched first", () => {
    const rows = mergeRows([
      { term: "milk", count: 3, zeroCount: 0 },
      { term: "kurkure", count: 2, zeroCount: 2 },
      { term: "milk", count: 4, zeroCount: 1 },
      { term: 7, count: 99 },
    ]);
    expect(rows).toEqual([
      { term: "milk", count: 7, zeroCount: 1 },
      { term: "kurkure", count: 2, zeroCount: 2 },
    ]);
  });
});
