import { Timestamp } from "firebase-admin/firestore";
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
import { UID, resetData } from "./fixtures";

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
