import { Timestamp } from "firebase-admin/firestore";
import { beforeEach, describe, expect, it } from "vitest";
import { updateFeatures } from "../../src/admin/features";
import { setStaffRole } from "../../src/admin/staff";
import { quoteOrder } from "../../src/orders/quote";
import { auth, db } from "../../src/shared/firebase";
import { FEATURES_DOC, clearFeaturesCache, getFeatures } from "../../src/shared/features";
import type { Actor } from "../../src/shared/roles";
import { CHATS, handleUserMessage } from "../../src/support/bot";
import { AREA, UID, params, resetData } from "./fixtures";

const boss: Actor = { uid: "boss", role: "super_admin", email: "boss@zyppi.test" };

const audits = async () =>
  (await db.collection("auditLogs").get()).docs.map((d) => d.data());

async function resetAuth() {
  await fetch(
    `http://${process.env.FIREBASE_AUTH_EMULATOR_HOST}/emulator/v1/projects/${process.env.GCLOUD_PROJECT}/accounts`,
    { method: "DELETE" },
  );
}

beforeEach(async () => {
  await resetData();
  clearFeaturesCache();
});

describe("updateFeatures", () => {
  it("writes the merged switches and an audit row with before/after", async () => {
    const next = await updateFeatures(boss, { placesSearch: false, payments: { upi: false } });
    expect(next.placesSearch).toBe(false);
    expect(next.payments).toEqual({ upi: false, card: true });

    const doc = (await db.doc(FEATURES_DOC).get()).data()!;
    expect(doc.placesSearch).toBe(false);
    expect(doc.updatedBy).toBe("boss");

    const [row] = await audits();
    expect(row).toMatchObject({
      actorUid: "boss",
      action: "features.update",
      target: FEATURES_DOC,
      before: { placesSearch: true },
      after: { placesSearch: false, payments: { upi: false, card: true } },
    });
    // The writing instance sees the change at once.
    expect((await getFeatures()).placesSearch).toBe(false);
  });

  it("rejects a bad patch without writing anything", async () => {
    await expect(updateFeatures(boss, { placesSearch: "off" })).rejects.toThrow(
      "Invalid placesSearch",
    );
    expect((await db.doc(FEATURES_DOC).get()).exists).toBe(false);
    expect(await audits()).toEqual([]);
  });
});

describe("closed areas", () => {
  it("refuses new orders only in a paused area", async () => {
    const quote = (closedAreaIds: string[]) =>
      db.runTransaction((tx) => quoteOrder(tx, { ...params(), closedAreaIds } as never));
    await expect(quote([AREA])).rejects.toThrow("Ordering is paused in your area right now");
    await expect(quote(["other-area"])).resolves.toMatchObject({ itemTotalPaise: 12800 });
  });
});

describe("support bot switch", () => {
  it("hands the chat to the team without running the bot", async () => {
    const chatRef = db.collection(CHATS).doc(`${UID}_general`);
    await chatRef.set({
      userId: UID, orderId: null, status: "bot", lang: "en", unreadByUser: 0, unreadByAgent: 0,
    });
    await updateFeatures(boss, { supportBot: false });
    const embedder = async () => {
      throw new Error("model must not load");
    };
    await handleUserMessage(chatRef, { text: "where is my order" }, embedder);

    expect((await chatRef.get()).get("status")).toBe("waiting_agent");
    const msgs = (await chatRef.collection("messages").get()).docs.map((d) => d.data());
    expect(msgs).toHaveLength(1);
    expect(msgs[0].from).not.toBe("user");
  });
});

describe("setStaffRole", () => {
  beforeEach(resetAuth);

  it("grants a role, mirrors it in staff/ and drops the legacy claim", async () => {
    const u = await auth.createUser({ email: "ops@zyppi.test", password: "secret12" });
    await auth.setCustomUserClaims(u.uid, { admin: true, other: 1 });

    await setStaffRole(boss, { email: " OPS@zyppi.test ", role: "ops" });

    expect((await auth.getUser(u.uid)).customClaims).toEqual({ role: "ops", other: 1 });
    expect((await db.doc(`staff/${u.uid}`).get()).data()).toMatchObject({
      email: "ops@zyppi.test",
      role: "ops",
      updatedBy: "boss",
    });
    const [row] = await audits();
    expect(row).toMatchObject({
      action: "staff.setRole",
      before: { role: "super_admin" },
      after: { role: "ops" },
    });
  });

  it("removes a role, ends the session and deletes the mirror", async () => {
    const u = await auth.createUser({ email: "old@zyppi.test", password: "secret12" });
    await setStaffRole(boss, { email: "old@zyppi.test", role: "catalog" });
    const before = Timestamp.now().toMillis();
    await setStaffRole(boss, { email: "old@zyppi.test", role: null });

    const user = await auth.getUser(u.uid);
    expect(user.customClaims).toEqual({});
    expect(Date.parse(user.tokensValidAfterTime!)).toBeGreaterThanOrEqual(before - 1000);
    expect((await db.doc(`staff/${u.uid}`).get()).exists).toBe(false);
  });

  it("refuses bad input, unknown accounts and changing your own role", async () => {
    await auth.createUser({ uid: "boss", email: "boss@zyppi.test", password: "secret12" });
    await expect(setStaffRole(boss, { email: "x@zyppi.test", role: "rider" })).rejects.toThrow(
      "Invalid role",
    );
    await expect(setStaffRole(boss, { email: "nobody@zyppi.test", role: "ops" })).rejects.toThrow(
      "No account with that email",
    );
    await expect(setStaffRole(boss, { email: "boss@zyppi.test", role: null })).rejects.toThrow(
      "You can't change your own role",
    );
  });
});
