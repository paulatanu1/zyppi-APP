import { describe, expect, it } from "vitest";
import { productKeywords } from "../../src/shared/keywords";

describe("productKeywords", () => {
  it("indexes prefixes of the whole name and of each word", () => {
    const k = productKeywords("Toned Milk");
    expect(k).toContain("to");
    expect(k).toContain("toned m");
    expect(k).toContain("mil");
    expect(k).toContain("milk");
    expect(k).not.toContain("m");
  });

  it("lower-cases and strips punctuation", () => {
    const k = productKeywords("Atta, Rice & Dals");
    expect(k).toContain("rice");
    expect(k).toContain("dals");
    expect(k.every((w) => w === w.toLowerCase())).toBe(true);
  });
});
