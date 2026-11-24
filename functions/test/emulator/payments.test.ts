import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { db } from "../../src/shared/firebase";
import type { PayUOutcome } from "../../src/payments/payu";
import {
  RECONCILE_MAX_AGE_MS,
  RECONCILE_MIN_AGE_MS,
  reconcileAction,
  reconcileOpenIntents,
} from "../../src/payments/reconcile";
import { settleIntent } from "../../src/payments/settle";
import { quoteOrder } from "../../src/orders/quote";
import { clearPriorHolds, readPriorHolds, writeStockHold } from "../../src/payments/stock_hold";
import { SLOT, STORE_A, STORE_B, UID, params, resetData } from "./fixtures";

const NOW = Date.parse("2026-11-09T12:00:00Z");
const MIN = 60 * 1000;
const AMOUNT = 2 * 6400 + 500; // the fixture cart + handling fee

async function intent(id: string, ageMs: number, status = "created") {
  await db.doc(`paymentIntents/${id}`).set({
    userId: UID, amountPaise: AMOUNT, paymentMethod: "UPI", addressId: "home",
    deliverySlotId: "slot-1", couponCode: null, tipPaise: 0, status, orderId: null,
    transactionId: null, failureReason: null, createdAt: Timestamp.fromMillis(NOW - ageMs),
  });
}

/** A stand-in for PayU's verify_payment: one fixed answer per txnid. */
function payu(answers: Record<string, PayUOutcome>) {
  const asked: string[] = [];
  const verify = async (txnid: string) => {
    asked.push(txnid);
    const answer = answers[txnid];
    if (!answer) throw new Error("PayU down");
    return answer;
  };
  return { verify, asked };
}

const paid = (mihpayid: string): PayUOutcome => ({ state: "paid", mihpayid, amountPaise: AMOUNT });
const statusOf = async (id: string) => (await db.doc(`paymentIntents/${id}`).get()).get("status");

describe("reconcileAction", () => {
  it("skips fresh intents, settles the window and expires old ones", () => {
    expect(reconcileAction(RECONCILE_MIN_AGE_MS - 1)).toBe("skip");
    expect(reconcileAction(RECONCILE_MIN_AGE_MS)).toBe("settle");
    expect(reconcileAction(RECONCILE_MAX_AGE_MS)).toBe("settle");
    expect(reconcileAction(RECONCILE_MAX_AGE_MS + 1)).toBe("expire");
  });
});

describe("settleIntent", () => {
  beforeEach(() => resetData());

  it("places the order for a captured payment, once", async () => {
    await intent("z1", 10 * MIN);
    const { verify } = payu({ z1: paid("M1") });
    const first = await settleIntent("z1", verify);
    expect(first.state).toBe("completed");
    expect(await settleIntent("z1", verify)).toEqual(first);
    expect((await db.collection("orders").get()).size).toBe(1);
  });

  it("marks a failed payment failed, and leaves a pending one open", async () => {
    await intent("z2", 10 * MIN);
    await intent("z3", 10 * MIN);
    const { verify } = payu({
      z2: { state: "failed", reason: "bounced" },
      z3: { state: "pending" },
    });
    expect((await settleIntent("z2", verify)).state).toBe("failed");
    expect(await statusOf("z2")).toBe("failed");
    expect((await settleIntent("z3", verify)).state).toBe("pending");
    expect(await statusOf("z3")).toBe("created");
  });

  it("sends a late capture to review once the cart is gone", async () => {
    await resetData({});
    await intent("z4", 10 * MIN, "expired");
    const { verify } = payu({ z4: paid("M4") });
    expect((await settleIntent("z4", verify)).state).toBe("needs_review");
    expect((await db.collection("orders").get()).empty).toBe(true);
  });
});

describe("reconcileOpenIntents", () => {
  beforeEach(() => resetData());

  it("settles the window, expires stale intents and skips fresh ones", async () => {
    await intent("fresh", 2 * MIN);
    await intent("late", 30 * MIN);
    await intent("stuck", 30 * MIN);
    await intent("stale", RECONCILE_MAX_AGE_MS + MIN);
    await intent("done", 30 * MIN, "failed");
    const { verify, asked } = payu({
      late: paid("M5"),
      stuck: { state: "pending" },
      stale: { state: "pending" },
    });

    const summary = await reconcileOpenIntents(NOW, verify);

    expect(asked.sort()).toEqual(["late", "stale", "stuck"]);
    expect(summary).toEqual({ settled: { completed: 1, pending: 1 }, expired: 1, errors: 0 });
    expect(await statusOf("late")).toBe("completed");
    expect(await statusOf("stuck")).toBe("created");
    expect(await statusOf("stale")).toBe("expired");
    expect(await statusOf("fresh")).toBe("created");
  });

  it("checks intents in parallel, so a slow PayU answer doesn't hold up the rest", async () => {
    // Oldest first, so a one-at-a-time loop would wait on "slow" forever.
    await intent("slow", 31 * MIN);
    await intent("quick", 30 * MIN);
    let quickAsked!: () => void;
    const quickSeen = new Promise<void>((r) => (quickAsked = r));
    // "slow" answers only once "quick" has been asked: a one-at-a-time
    // reconciler would never get there.
    const verify = async (txnid: string): Promise<PayUOutcome> => {
      if (txnid === "slow") {
        await quickSeen;
        return { state: "pending" };
      }
      quickAsked();
      return { state: "failed", reason: "bounced" };
    };
    const summary = await reconcileOpenIntents(NOW, verify);
    expect(summary.errors).toBe(0);
    expect(await statusOf("quick")).toBe("failed");
    expect(await statusOf("slow")).toBe("created");
  });

  it("keeps going when PayU can't be reached for one intent", async () => {
    await intent("down", 30 * MIN);
    await intent("ok", 30 * MIN);
    const { verify } = payu({ ok: { state: "failed", reason: "bounced" } });

    const summary = await reconcileOpenIntents(NOW, verify);

    expect(summary.errors).toBe(1);
    expect(await statusOf("down")).toBe("created");
    expect(await statusOf("ok")).toBe("failed");
  });
});

describe("one stock hold per customer (createPayUOrder's transaction)", () => {
  beforeEach(() => resetData());

  /** The stock part of createPayUOrder: same calls, same order. */
  const checkout = (txnid: string) =>
    db.runTransaction(async (tx) => {
      const prior = await readPriorHolds(tx, UID);
      const quote = await quoteOrder(tx, { ...params({ paymentMethod: "UPI" }), heldUnits: prior.held } as never);
      const stockHold = writeStockHold(tx, quote, prior.held);
      clearPriorHolds(tx, prior, txnid);
      tx.create(db.doc(`paymentIntents/${txnid}`), {
        userId: UID, amountPaise: quote.totalPaise, walletPaise: 0, totalPaise: quote.totalPaise,
        paymentMethod: "UPI", addressId: "home", deliverySlotId: SLOT, couponCode: null, tipPaise: 0,
        status: "created", orderId: null, transactionId: null, failureReason: null, stockHold,
        createdAt: FieldValue.serverTimestamp(),
      });
    });

  const milk = async () => {
    const docs = await Promise.all(
      [`inventory/${STORE_A}_v-milk`, `inventory/${STORE_B}_v-milk`].map((p) => db.doc(p).get()),
    );
    const sum = (f: string) => docs.reduce((n, d) => n + ((d.get(f) as number | undefined) ?? 0), 0);
    return { quantity: sum("quantity"), reserved: sum("reserved") };
  };

  it("a retried checkout holds one cart, not two", async () => {
    await checkout("h1");
    await checkout("h2");
    expect(await milk()).toEqual({ quantity: 3, reserved: 2 });
    const first = (await db.doc("paymentIntents/h1").get()).data()!;
    expect(first.status).toBe("created");
    expect(first.stockHold).toEqual([]);
    expect(first.stockReleasedFor).toBe("h2");
    expect((await db.doc("paymentIntents/h2").get()).get("stockHold")).not.toEqual([]);
  });

  it("a retry of a cart holding the last units still succeeds", async () => {
    await resetData({ "v-milk": 5 });
    await checkout("h1");
    expect(await milk()).toEqual({ quantity: 0, reserved: 5 });
    await checkout("h2");
    expect(await milk()).toEqual({ quantity: 0, reserved: 5 });
  });

  it("gives back units the new cart no longer has", async () => {
    await checkout("h1");
    await db.doc(`users/${UID}/cart/v-milk`).delete();
    await db.doc(`users/${UID}/cart/v-rice`).set({ productId: "p-rice", quantity: 1 });
    await checkout("h2");
    expect(await milk()).toEqual({ quantity: 5, reserved: 0 });
  });

  it("a late capture of the earlier checkout still becomes an order", async () => {
    await checkout("h1");
    await checkout("h2");
    const { verify } = payu({ h1: paid("M9") });
    expect((await settleIntent("h1", verify)).state).toBe("completed");
    // h1's order came from live stock; h2 still holds its cart.
    expect(await milk()).toEqual({ quantity: 1, reserved: 4 });
  });
});
