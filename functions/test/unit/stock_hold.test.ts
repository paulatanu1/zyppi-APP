import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { describe, expect, it, vi } from "vitest";
import { holdExpired } from "../../src/payments/reconcile";
import { STOCK_HOLD_MS, heldUnitsOf, holdRowsFrom, releaseStockHold, writeStockHold } from "../../src/payments/stock_hold";
import { db } from "../../src/shared/firebase";

const ref = (id: string) => db.collection("inventory").doc(id);
const quote = {
  lines: [
    { allocations: [{ ref: ref("s1_v1"), storeId: "s1", take: 2, current: 5 }] },
    { allocations: [{ ref: ref("s1_v2"), storeId: "s1", take: 1, current: 1 }, { ref: ref("s2_v2"), storeId: "s2", take: 3, current: 9 }] },
  ],
} as never;

describe("PayU stock hold", () => {
  it("takes the quoted units off sale and records them per inventory doc", () => {
    const tx = { update: vi.fn() };
    const rows = writeStockHold(tx as never, quote);
    expect(rows).toEqual([
      { path: "inventory/s1_v1", units: 2 },
      { path: "inventory/s1_v2", units: 1 },
      { path: "inventory/s2_v2", units: 3 },
    ]);
    expect(tx.update).toHaveBeenCalledTimes(3);
    expect(tx.update.mock.calls[0][1]).toMatchObject({ quantity: 3 });
    expect(holdRowsFrom(quote)).toEqual(rows);
  });

  it("moves an earlier checkout's hold instead of reserving twice", () => {
    const tx = { update: vi.fn() };
    // inventory/s1_v1: 2 held before (already in `current` via heldUnits);
    // inventory/old: held before, not in this cart.
    const prior = new Map([["inventory/s1_v1", 2], ["inventory/old", 4]]);
    writeStockHold(tx as never, quote, prior);
    const byPath = new Map(tx.update.mock.calls.map(([r, f]) => [(r as { path: string }).path, f as Record<string, unknown>]));
    expect(byPath.size).toBe(4);
    expect(byPath.get("inventory/s1_v1")).toMatchObject({ quantity: 3, reserved: FieldValue.increment(0) });
    expect(byPath.get("inventory/s1_v2")).toMatchObject({ quantity: 0, reserved: FieldValue.increment(1) });
    expect(byPath.get("inventory/old")).toMatchObject({
      quantity: FieldValue.increment(4),
      reserved: FieldValue.increment(-4),
    });
  });

  it("with no earlier hold, reserves exactly what it takes", () => {
    const tx = { update: vi.fn() };
    writeStockHold(tx as never, quote);
    expect(tx.update.mock.calls.map(([, f]) => (f as Record<string, unknown>).reserved)).toEqual([
      FieldValue.increment(2),
      FieldValue.increment(1),
      FieldValue.increment(3),
    ]);
  });

  it("reads only well-formed held rows", () => {
    const held = heldUnitsOf({
      stockHold: [
        { path: "inventory/a", units: 2 },
        { path: "inventory/a", units: 1 },
        { path: "orders/x", units: 5 },
        { path: "inventory/b", units: 0 },
        { path: "inventory/c", units: 1.5 },
      ],
    });
    expect([...held]).toEqual([["inventory/a", 3]]);
    expect(heldUnitsOf(undefined).size).toBe(0);
    expect(heldUnitsOf({ stockHold: [] }).size).toBe(0);
  });

  it("releases once: back on sale, and the intent's hold cleared", () => {
    const tx = { update: vi.fn() };
    const fields = releaseStockHold(tx as never, { stockHold: [{ path: "inventory/a", units: 2 }] });
    expect(tx.update).toHaveBeenCalledTimes(1);
    expect((tx.update.mock.calls[0][0] as { path: string }).path).toBe("inventory/a");
    expect(fields.stockHold).toEqual([]);
    // Already released (or an intent from before holds): nothing to do.
    expect(releaseStockHold(tx as never, { stockHold: [] })).toEqual({});
    expect(tx.update).toHaveBeenCalledTimes(1);
  });

  it("expires a hold after the window", () => {
    const now = Date.UTC(2026, 10, 19, 10, 0);
    expect(holdExpired(Timestamp.fromMillis(now - STOCK_HOLD_MS + 1000), now)).toBe(false);
    expect(holdExpired(Timestamp.fromMillis(now - STOCK_HOLD_MS), now)).toBe(true);
    expect(holdExpired(undefined, now)).toBe(true);
  });
});
