import { Timestamp } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { db } from "../../src/shared/firebase";
import { REPAIR_LOOKBACK_MS, creditSeller, repairSellerCredits, reverseSeller } from "../../src/marketplace/settlement";

const NOW = Date.parse("2026-11-20T06:00:00Z");
const HOUR = 3600_000;
const totals = { itemTotalPaise: 20_000, payoutPaise: 18_000 };

async function wipe() {
  const host = process.env.FIRESTORE_EMULATOR_HOST;
  await fetch(`http://${host}/emulator/v1/projects/${process.env.GCLOUD_PROJECT}/databases/(default)/documents`, { method: "DELETE" });
}

async function order(id: string, updatedAtMs: number, status = "delivered") {
  await db.doc(`orders/${id}`).set({ status, sellerTotals: { s1: totals }, updatedAt: Timestamp.fromMillis(updatedAtMs) });
}

const credit = (orderId: string) => db.doc(`sellers/s1/earnings/${orderId}_order`).get();

describe("seller settlement retries and repair (DA-03)", () => {
  beforeEach(async () => {
    await wipe();
    await db.doc("sellers/s1").set({ name: "Shop", gstin: null });
  });

  it("counts a seller-fault cancel once, however often the event is retried", async () => {
    await reverseSeller("s1", "o1", true, "evt-1");
    await reverseSeller("s1", "o1", true, "evt-1");
    expect((await db.doc("sellers/s1").get()).get("stats.cancelled")).toBe(1);
    // A different cancel event (another order) still counts.
    await reverseSeller("s1", "o2", true, "evt-2");
    expect((await db.doc("sellers/s1").get()).get("stats.cancelled")).toBe(2);
  });

  it("reverses a credit once on retry", async () => {
    await creditSeller("s1", "o3", totals);
    await reverseSeller("s1", "o3", false, "evt-3");
    await reverseSeller("s1", "o3", false, "evt-3");
    const rows = await db.collection("sellers/s1/earnings").where("orderId", "==", "o3").get();
    expect(rows.docs.map((d) => d.id).sort()).toEqual(["o3_order", "o3_reversal"]);
  });

  it("credits delivered orders the trigger missed, once", async () => {
    await order("missed", NOW - 2 * HOUR);
    await order("credited", NOW - 2 * HOUR);
    await creditSeller("s1", "credited", totals);
    await order("fresh", NOW - 60_000); // left to the trigger
    await order("old", NOW - REPAIR_LOOKBACK_MS - HOUR);
    await order("open", NOW - 2 * HOUR, "packed");

    expect(await repairSellerCredits(NOW)).toBe(1);
    expect((await credit("missed")).exists).toBe(true);
    expect((await credit("fresh")).exists).toBe(false);
    expect((await credit("old")).exists).toBe(false);
    expect((await credit("open")).exists).toBe(false);
    expect(await repairSellerCredits(NOW)).toBe(0);
  });

  it("skips sellers that no longer exist", async () => {
    await db.doc("orders/gone").set({ status: "delivered", sellerTotals: { ghost: totals }, updatedAt: Timestamp.fromMillis(NOW - HOUR) });
    expect(await repairSellerCredits(NOW)).toBe(0);
  });
});
