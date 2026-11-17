import { readFileSync } from "node:fs";
import { join } from "node:path";
import { initializeTestEnvironment, assertFails, assertSucceeds, type RulesTestEnvironment } from "@firebase/rules-unit-testing";
import { doc, getDoc } from "firebase/firestore";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import { updateOrderStatus } from "../../src/admin/orders";
import { placeOrderInTx } from "../../src/orders/quote";
import { reviewRider, saveApplication, settleRiderCash } from "../../src/riders/riders";
import { auth, db } from "../../src/shared/firebase";
import type { Actor } from "../../src/shared/roles";
import { AREA, params, resetData } from "./fixtures";

const ops: Actor = { uid: "ops-1", role: "ops", email: "ops@zyppi.test" };
const fin: Actor = { uid: "fin-1", role: "finance", email: "fin@zyppi.test" };
const now = new Date(Date.UTC(2026, 10, 14));

const application = (uid: string, over: Record<string, unknown> = {}) => ({
  fullName: "Raju Mahato",
  phone: "9800011111",
  dob: "1998-05-20",
  address: "Ward 5, Station Road, Purulia",
  serviceAreaId: AREA,
  vehicleType: "bike",
  vehicleNumber: "WB 56 AB 1234",
  drivingLicenceNumber: "WB5620190001234",
  docs: Object.fromEntries(
    ["aadhaarFront", "aadhaarBack", "selfie", "drivingLicence", "rc"].map((k) => [k, `riders/${uid}/kyc/${k}.jpg`]),
  ),
  payout: { method: "bank", accountName: "Raju Mahato", accountNumber: "123456789012", ifsc: "SBIN0001234" },
  ...over,
});

async function resetAuth() {
  await fetch(
    `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/emulator/v1/projects/${process.env.GCLOUD_PROJECT}/accounts`,
    { method: "DELETE" },
  );
}

async function approvedRider(): Promise<string> {
  const u = await auth.createUser({ email: `r${Math.random()}@zyppi.test` });
  await saveApplication(u.uid, "+919800011111", { ...application(u.uid), submit: true }, now);
  await reviewRider(ops, { uid: u.uid, action: "approve", checklist: { idMatches: true } });
  return u.uid;
}

beforeEach(async () => {
  await resetData({ "v-milk": 2 });
  await resetAuth();
});

describe("rider application", () => {
  it("saves a draft, then submits; bank details stay private", async () => {
    await saveApplication("u1", null, { fullName: "Raju", vehicleType: "bike" }, now);
    expect((await db.doc("riders/u1").get()).get("status")).toBe("draft");
    await expect(saveApplication("u1", null, { submit: true }, now)).rejects.toThrow("Full name is required");
    await saveApplication("u1", "+919800099999", { ...application("u1"), submit: true }, now);
    const r = (await db.doc("riders/u1").get()).data()!;
    expect(r).toMatchObject({ status: "submitted", phone: "+919800099999", codBalancePaise: 0 });
    expect(r.payout).toEqual({ method: "bank", upiId: null, accountLast4: "9012", ifsc: "SBIN0001234" });
    expect((await db.doc("riders/u1/private/payout").get()).get("accountNumber")).toBe("123456789012");
    await expect(saveApplication("u1", null, application("u1"), now)).rejects.toThrow("being reviewed");
  });

  it("refuses closed areas", async () => {
    await db.doc(`serviceAreas/${AREA}`).update({ isActive: false });
    await expect(saveApplication("u1", null, application("u1"), now)).rejects.toThrow("isn’t open for riders");
  });
});

describe("reviewRider", () => {
  it("approves with the rider claim, suspends and reinstates", async () => {
    const uid = await approvedRider();
    expect((await auth.getUser(uid)).customClaims).toMatchObject({ rider: true });
    expect((await db.doc(`riders/${uid}`).get()).data()).toMatchObject({ status: "approved", checklist: { idMatches: true } });
    await expect(reviewRider(ops, { uid, action: "suspend" })).rejects.toThrow("why");
    await reviewRider(ops, { uid, action: "suspend", reason: "Customer complaints" });
    expect((await auth.getUser(uid)).customClaims?.rider).toBeUndefined();
    await reviewRider(ops, { uid, action: "reinstate" });
    expect((await auth.getUser(uid)).customClaims?.rider).toBe(true);
    const events = (await db.collection(`riders/${uid}/events`).get()).docs.map((d) => d.get("type"));
    expect(events.sort()).toEqual(["approve", "reinstate", "submitted", "suspend"]);
  });

  it("asks for changes and lets the rider resubmit", async () => {
    await saveApplication("u2", null, { ...application("u2"), submit: true }, now);
    await reviewRider(ops, { uid: "u2", action: "request_changes", reason: "Selfie is blurry" });
    expect((await db.doc("riders/u2").get()).data()).toMatchObject({ status: "changes_requested", reviewNote: "Selfie is blurry" });
    await saveApplication("u2", null, { ...application("u2"), submit: true }, now);
    expect((await db.doc("riders/u2").get()).data()).toMatchObject({ status: "submitted", reviewNote: null });
    await expect(reviewRider(ops, { uid: "u2", action: "reinstate" })).rejects.toThrow("Can’t reinstate");
  });
});

describe("riders on orders", () => {
  it("assigns only approved riders and counts the delivery and cash", async () => {
    const orderId = await db.runTransaction((tx) =>
      placeOrderInTx(tx, params() as never, { status: "pending", providerReference: null }),
    );
    await saveApplication("pending", null, { ...application("pending"), submit: true }, now);
    await expect(updateOrderStatus(ops, { orderId, status: "placed", riderId: "pending" })).rejects.toThrow(
      "Only approved riders",
    );
    const uid = await approvedRider();
    await updateOrderStatus(ops, { orderId, status: "placed", riderId: uid });
    expect((await db.doc(`orders/${orderId}`).get()).data()).toMatchObject({
      riderId: uid, riderName: "Raju Mahato", riderPhone: "+919800011111",
    });
    for (const s of ["packed", "out_for_delivery", "delivered"]) await updateOrderStatus(ops, { orderId, status: s });
    const total = (await db.doc(`orders/${orderId}`).get()).get("totalPaise");
    const rider = (await db.doc(`riders/${uid}`).get()).data()!;
    expect(rider).toMatchObject({ deliveredCount: 1, onTimeCount: 1, codBalancePaise: total });
    const ledger = (await db.collection(`riders/${uid}/cash`).get()).docs.map((d) => d.data());
    expect(ledger).toEqual([expect.objectContaining({ type: "collected", amountPaise: total, orderId })]);

    await expect(settleRiderCash(fin, { uid, amountPaise: total + 1 })).rejects.toThrow("only holds");
    await settleRiderCash(fin, { uid, amountPaise: total, note: "Handed to store" });
    expect((await db.doc(`riders/${uid}`).get()).get("codBalancePaise")).toBe(0);
    await expect(updateOrderStatus(ops, { orderId, status: "delivered", riderId: null })).rejects.toThrow("closed");
  });
});

describe("rider rules", () => {
  let env: RulesTestEnvironment;
  beforeAll(async () => {
    const [host, port] = process.env.FIRESTORE_EMULATOR_HOST!.split(":");
    env = await initializeTestEnvironment({
      projectId: "demo-zyppi-riders",
      firestore: { rules: readFileSync(join(__dirname, "..", "..", "..", "firestore.rules"), "utf8"), host, port: Number(port) },
    });
    await env.withSecurityRulesDisabled(async (ctx) => {
      const { setDoc } = await import("firebase/firestore");
      await setDoc(doc(ctx.firestore(), "riders/r1"), { status: "submitted" });
      await setDoc(doc(ctx.firestore(), "riders/r1/private/payout"), { accountNumber: "1" });
    });
  });
  afterAll(() => env.cleanup());

  it("lets the rider and ops read the application; payout only to rider and finance", async () => {
    const as = (uid: string, claims = {}) => env.authenticatedContext(uid, claims).firestore();
    await assertSucceeds(getDoc(doc(as("r1"), "riders/r1")));
    await assertFails(getDoc(doc(as("r2"), "riders/r1")));
    await assertSucceeds(getDoc(doc(as("o", { role: "ops" }), "riders/r1")));
    await assertFails(getDoc(doc(as("c", { role: "catalog" }), "riders/r1")));
    await assertSucceeds(getDoc(doc(as("r1"), "riders/r1/private/payout")));
    await assertFails(getDoc(doc(as("o", { role: "ops" }), "riders/r1/private/payout")));
    await assertSucceeds(getDoc(doc(as("f", { role: "finance" }), "riders/r1/private/payout")));
  });
});
