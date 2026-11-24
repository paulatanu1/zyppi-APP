import { describe, expect, it } from "vitest";
import { forEachLimit } from "../../src/shared/concurrency";

describe("forEachLimit", () => {
  it("never runs more than the limit at once, and runs every item", async () => {
    let running = 0;
    let peak = 0;
    const done: number[] = [];
    await forEachLimit([...Array(12).keys()], 3, async (n) => {
      running += 1;
      peak = Math.max(peak, running);
      await new Promise((r) => setTimeout(r, 5 + (n % 3)));
      running -= 1;
      done.push(n);
    });
    expect(peak).toBe(3);
    expect(done.sort((a, b) => a - b)).toEqual([...Array(12).keys()]);
  });

  it("keeps going past failures and reports them by index", async () => {
    const done: number[] = [];
    const errors = await forEachLimit([0, 1, 2, 3], 2, async (n) => {
      if (n === 1) throw new Error("boom");
      done.push(n);
    });
    expect(done.sort()).toEqual([0, 2, 3]);
    expect(errors.map((e) => e.index)).toEqual([1]);
  });

  it("handles an empty list", async () => {
    expect(await forEachLimit([], 5, async () => {})).toEqual([]);
  });
});
