import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  RulesTestEnvironment,
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  addDoc,
  collection,
  doc,
  getDoc,
  getDocs,
  serverTimestamp,
  setDoc,
  updateDoc,
} from "firebase/firestore";
import { afterAll, beforeAll, beforeEach, describe, it } from "vitest";

let env: RulesTestEnvironment;

beforeAll(async () => {
  const [host, port] = process.env.FIRESTORE_EMULATOR_HOST!.split(":");
  env = await initializeTestEnvironment({
    projectId: "demo-zyppi-rules",
    firestore: {
      rules: readFileSync(join(__dirname, "..", "..", "..", "firestore.rules"), "utf8"),
      host,
      port: Number(port),
    },
  });
});

afterAll(() => env.cleanup());

beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (ctx) => {
    const db = ctx.firestore();
    await setDoc(doc(db, "products/p1"), { name: "Milk", isActive: true });
    await setDoc(doc(db, "coupons/ON"), { isActive: true, expiresAt: null });
    await setDoc(doc(db, "coupons/OFF"), { isActive: false, expiresAt: null });
    await setDoc(doc(db, "orders/o1"), { userId: "alice", totalPaise: 100 });
    await setDoc(doc(db, "inventory/s_v"), { quantity: 5 });
    await setDoc(doc(db, "supportChats/c1"), { userId: "alice", status: "bot", unreadByUser: 2 });
    await setDoc(doc(db, "supportChats/c2"), { userId: "alice", status: "closed", unreadByUser: 0 });
    await setDoc(doc(db, "supportKb/k1"), { topic: "refund" });
  });
});

describe("firestore.rules", () => {
  it("lets anyone read the catalog but only admins write it", async () => {
    const anon = env.unauthenticatedContext().firestore();
    await assertSucceeds(getDoc(doc(anon, "products/p1")));
    const alice = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(alice, "products/p1"), { name: "Free" }));
    const admin = env.authenticatedContext("boss", { admin: true }).firestore();
    await assertSucceeds(updateDoc(doc(admin, "products/p1"), { name: "Milk 1L" }));
  });

  it("lets anyone read the delivery config but only admins write it", async () => {
    const anon = env.unauthenticatedContext().firestore();
    await assertSucceeds(getDoc(doc(anon, "config/delivery")));
    const alice = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(alice, "config/delivery"), { feePaise: 0 }));
    await assertFails(getDoc(doc(alice, "config/secret")));
    const admin = env.authenticatedContext("boss", { admin: true }).firestore();
    await assertSucceeds(setDoc(doc(admin, "config/delivery"), { feePaise: 2500 }));
  });

  it("hides inactive coupons and the coupon list", async () => {
    const alice = env.authenticatedContext("alice").firestore();
    await assertSucceeds(getDoc(doc(alice, "coupons/ON")));
    await assertFails(getDoc(doc(alice, "coupons/OFF")));
    await assertFails(getDocs(collection(alice, "coupons")));
  });

  it("keeps each user's data private", async () => {
    const alice = env.authenticatedContext("alice").firestore();
    const bob = env.authenticatedContext("bob").firestore();
    await assertSucceeds(setDoc(doc(alice, "users/alice"), { fullName: "Alice" }));
    await assertFails(getDoc(doc(bob, "users/alice")));
    await assertFails(setDoc(doc(alice, "users/alice"), { isAdmin: true }));
    await assertSucceeds(setDoc(doc(alice, "users/alice/cart/v1"), { productId: "p1", quantity: 2 }));
    await assertFails(setDoc(doc(alice, "users/alice/cart/v1"), { productId: "p1", quantity: 0 }));
    await assertFails(setDoc(doc(bob, "users/alice/cart/v1"), { productId: "p1", quantity: 1 }));
  });

  it("lets owners read orders but never write them", async () => {
    const alice = env.authenticatedContext("alice").firestore();
    const bob = env.authenticatedContext("bob").firestore();
    await assertSucceeds(getDoc(doc(alice, "orders/o1")));
    await assertFails(getDoc(doc(bob, "orders/o1")));
    await assertFails(updateDoc(doc(alice, "orders/o1"), { totalPaise: 1 }));
    await assertFails(setDoc(doc(alice, "orders/o2"), { userId: "alice" }));
  });

  it("keeps stock levels admin-only", async () => {
    const alice = env.authenticatedContext("alice").firestore();
    await assertFails(getDoc(doc(alice, "inventory/s_v")));
  });

  describe("support chat", () => {
    const userMessage = (text = "Where is my order?") => ({
      from: "user",
      text,
      createdAt: serverTimestamp(),
    });

    it("lets only the owner read a chat and its messages", async () => {
      const alice = env.authenticatedContext("alice").firestore();
      const bob = env.authenticatedContext("bob").firestore();
      await assertSucceeds(getDoc(doc(alice, "supportChats/c1")));
      await assertSucceeds(getDocs(collection(alice, "supportChats/c1/messages")));
      await assertFails(getDoc(doc(bob, "supportChats/c1")));
      await assertFails(getDocs(collection(bob, "supportChats/c1/messages")));
    });

    it("lets the owner send text messages only as the user", async () => {
      const alice = env.authenticatedContext("alice").firestore();
      const bob = env.authenticatedContext("bob").firestore();
      const messages = collection(alice, "supportChats/c1/messages");
      await assertSucceeds(addDoc(messages, userMessage()));
      await assertFails(addDoc(messages, { ...userMessage(), from: "agent" }));
      await assertSucceeds(addDoc(messages, { ...userMessage(), quickReplyId: "kb:refund" }));
      await assertFails(addDoc(messages, { ...userMessage(), quickReplies: [] }));
      await assertFails(addDoc(messages, userMessage("")));
      await assertFails(addDoc(messages, userMessage("x".repeat(1001))));
      await assertFails(addDoc(collection(bob, "supportChats/c1/messages"), userMessage()));
      await assertFails(addDoc(collection(alice, "supportChats/c2/messages"), userMessage()));
    });

    it("lets the owner clear unread but not change status or create chats", async () => {
      const alice = env.authenticatedContext("alice").firestore();
      await assertSucceeds(updateDoc(doc(alice, "supportChats/c1"), { unreadByUser: 0 }));
      await assertFails(updateDoc(doc(alice, "supportChats/c1"), { status: "agent" }));
      await assertFails(updateDoc(doc(alice, "supportChats/c1"), { unreadByUser: 5 }));
      await assertFails(setDoc(doc(alice, "supportChats/c3"), { userId: "alice", status: "bot" }));
    });

    it("keeps the knowledge base server-only", async () => {
      const alice = env.authenticatedContext("alice").firestore();
      await assertFails(getDoc(doc(alice, "supportKb/k1")));
    });
  });
});
