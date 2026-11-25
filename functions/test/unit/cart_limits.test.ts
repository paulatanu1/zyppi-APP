import { describe, expect, it } from "vitest";
import {
  MAX_QTY_PER_ITEM,
  MAX_TIP_PAISE,
  MAX_UNITS_PER_ORDER,
  quantityLimitProblem,
} from "../../src/orders/quote";

const names: Record<string, string> = { "p-bread": "Brown Bread", "p-oil": "Sunflower Oil" };
const nameOf = (id: string) => names[id] ?? "item";
const line = (variantId: string, quantity: number, productId = "p-bread") => ({ variantId, productId, quantity });

describe("cart limits (match the app's CartNotifier)", () => {
  it("are 5 per item, 50 per order and a ₹100 tip", () => {
    expect(MAX_QTY_PER_ITEM).toBe(5);
    expect(MAX_UNITS_PER_ORDER).toBe(50);
    expect(MAX_TIP_PAISE).toBe(10000);
  });

  it("allows exactly 5 of an item", () => {
    expect(quantityLimitProblem([line("v-bread", 5)], nameOf)).toBeNull();
  });

  it("refuses 6 of an item, naming it", () => {
    expect(quantityLimitProblem([line("v-bread", 6)], nameOf)).toBe("MAX_PER_ITEM:5:Brown Bread");
  });

  it("adds up one item across sellers' lines", () => {
    expect(quantityLimitProblem([line("v-bread", 3), line("v-bread", 3)], nameOf)).toBe(
      "MAX_PER_ITEM:5:Brown Bread",
    );
  });

  it("allows 50 units in an order and refuses 51", () => {
    const fifty = Array.from({ length: 10 }, (_, i) => line(`v${i}`, 5, "p-oil"));
    expect(quantityLimitProblem(fifty, nameOf)).toBeNull();
    expect(quantityLimitProblem([...fifty, line("v-extra", 1, "p-oil")], nameOf)).toBe("MAX_UNITS_PER_ORDER:50");
  });
});
