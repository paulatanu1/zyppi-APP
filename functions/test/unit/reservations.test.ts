import { describe, expect, it, vi } from "vitest";
import { inventoryIdFor } from "../../src/marketplace/model";
import {
  availableFromCount,
  releasePlan,
  releaseReservation,
  reservedStoresOf,
} from "../../src/catalog/reservations";

const order = {
  reservedStores: ["s1", "s2"],
  allocations: [
    { storeId: "s1", sellerId: null, productId: "p1", variantId: "v1", quantity: 2 },
    { storeId: "s1", sellerId: null, productId: "p2", variantId: "v2", quantity: 1 },
    { storeId: "s2", sellerId: "sel9", productId: "p1", variantId: "v1", quantity: 4 },
  ],
};

describe("stock reservations", () => {
  it("a shelf count leaves out units waiting for pickup", () => {
    // 10 on the shelf, 3 of them sold and not collected: 7 can be sold.
    expect(availableFromCount(10, 3)).toBe(7);
    expect(availableFromCount(2, 5)).toBe(0);
    expect(availableFromCount(10, undefined)).toBe(10);
    expect(availableFromCount(10, -4)).toBe(10);
  });

  it("releases only the stores asked for, and only once", () => {
    const plan = releasePlan(order, ["s1"]);
    expect([...plan.entries()]).toEqual([
      [inventoryIdFor("s1", null, "v1"), 2],
      [inventoryIdFor("s1", null, "v2"), 1],
    ]);
    // s1 already released: nothing more for it.
    expect(releasePlan({ ...order, reservedStores: ["s2"] }, ["s1"]).size).toBe(0);
  });

  it("orders from before reservations release nothing", () => {
    const { reservedStores: _, ...old } = order;
    expect(reservedStoresOf(old)).toEqual([]);
    expect(releasePlan(old, ["s1", "s2"]).size).toBe(0);
  });

  it("writes one decrement per inventory doc and returns what is still held", () => {
    const tx = { update: vi.fn() };
    expect(releaseReservation(tx as never, order, ["s2"])).toEqual(["s1"]);
    expect(tx.update).toHaveBeenCalledTimes(1);
    expect((tx.update.mock.calls[0][0] as { id: string }).id).toBe(inventoryIdFor("s2", "sel9", "v1"));
  });
});
