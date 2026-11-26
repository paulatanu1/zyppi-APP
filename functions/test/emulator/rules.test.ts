import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  RulesTestEnvironment,
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import {
  Timestamp,
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
  it("lets anyone read the catalog; only the admin callables write it", async () => {
    const anon = env.unauthenticatedContext().firestore();
    await assertSucceeds(getDoc(doc(anon, "products/p1")));
    const alice = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(alice, "products/p1"), { name: "Free" }));
    const admin = env.authenticatedContext("boss", { admin: true }).firestore();
    await assertFails(updateDoc(doc(admin, "products/p1"), { name: "Milk 1L" }));
  });

  it("lets anyone read the delivery and app config, and nobody write them", async () => {
    const anon = env.unauthenticatedContext().firestore();
    await assertSucceeds(getDoc(doc(anon, "config/delivery")));
    const alice = env.authenticatedContext("alice").firestore();
    await assertFails(setDoc(doc(alice, "config/delivery"), { feePaise: 0 }));
    await assertFails(getDoc(doc(alice, "config/secret")));
    await assertSucceeds(getDoc(doc(anon, "config/app")));
    const admin = env.authenticatedContext("boss", { admin: true }).firestore();
    await assertFails(setDoc(doc(admin, "config/delivery"), { feePaise: 2500 }));
    await assertFails(setDoc(doc(admin, "config/app"), { supportPhone: "+919830012345" }));
  });

  it("keeps coupons staff-only (customers use checkCoupon)", async () => {
    const alice = env.authenticatedContext("alice").firestore();
    await assertFails(getDoc(doc(alice, "coupons/ON")));
    await assertFails(getDoc(doc(alice, "coupons/OFF")));
    await assertFails(getDocs(collection(alice, "coupons")));
    const admin = env.authenticatedContext("boss", { admin: true }).firestore();
    await assertSucceeds(getDoc(doc(admin, "coupons/ON")));
    await assertSucceeds(getDocs(collection(admin, "coupons")));
  });

  it("accepts the profile writes the app makes, and nothing oversized or mistyped", async () => {
    const alice = env.authenticatedContext("alice").firestore();
    const me = doc(alice, "users/alice");
    // savePhone, updateProfile, updatePreferences, push token (merge writes).
    await assertSucceeds(setDoc(me, { phone: "+919830012345", fullName: "Alice", email: "a@x.in", updatedAt: serverTimestamp() }, { merge: true }));
    await assertSucceeds(setDoc(me, { fullName: null, email: null, dob: "1990-04-02", gender: "Female", updatedAt: serverTimestamp() }, { merge: true }));
    await assertSucceeds(setDoc(me, { preferredPaymentMethod: "UPI", notifyOrderUpdates: true, notifyOffers: false, updatedAt: serverTimestamp() }, { merge: true }));
    await assertSucceeds(setDoc(me, { fcmToken: "t".repeat(300), lang: "bn" }, { merge: true }));
    await assertSucceeds(setDoc(me, { fcmToken: null }, { merge: true }));

    await assertFails(setDoc(me, { fullName: "x".repeat(101) }, { merge: true }));
    await assertFails(setDoc(me, { fcmToken: "t".repeat(4097) }, { merge: true }));
    await assertFails(setDoc(me, { phone: 9830012345 }, { merge: true }));
    // Set once: the same number again is fine, a different one isn't (SEC-A03).
    await assertSucceeds(setDoc(me, { phone: "+919830012345" }, { merge: true }));
    await assertFails(setDoc(me, { phone: "+919999999999" }, { merge: true }));
    await assertFails(setDoc(me, { phone: null }, { merge: true }));
    await assertFails(setDoc(me, { notifyOffers: "yes" }, { merge: true }));
    await assertFails(setDoc(me, { updatedAt: "now" }, { merge: true }));
    await assertFails(setDoc(doc(env.authenticatedContext("bob").firestore(), "users/bob"), { gender: "g".repeat(31) }));
  });

  it("still lets an older profile with an odd value be edited", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "users/old"), { fullName: "n".repeat(500), lang: "en" });
    });
    const old = env.authenticatedContext("old").firestore();
    await assertSucceeds(updateDoc(doc(old, "users/old"), { lang: "hi" }));
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

  it("lets a rider read an order only while holding it (and 2 h after)", async () => {
    const hour = 60 * 60 * 1000;
    await env.withSecurityRulesDisabled(async (ctx) => {
      const db = ctx.firestore();
      await setDoc(doc(db, "orders/open"), { userId: "alice", riderId: "ravi", status: "out_for_delivery" });
      await setDoc(doc(db, "orders/just"), {
        userId: "alice", riderId: "ravi", status: "delivered", deliveredAt: Timestamp.fromMillis(Date.now() - hour),
      });
      await setDoc(doc(db, "orders/old"), {
        userId: "alice", riderId: "ravi", status: "delivered", deliveredAt: Timestamp.fromMillis(Date.now() - 3 * hour),
      });
      await setDoc(doc(db, "riders/ravi/trips/old"), { status: "delivered" });
    });
    const ravi = env.authenticatedContext("ravi", { rider: true }).firestore();
    await assertSucceeds(getDoc(doc(ravi, "orders/open")));
    await assertSucceeds(getDoc(doc(ravi, "orders/just")));
    await assertFails(getDoc(doc(ravi, "orders/old")));
    await assertSucceeds(getDoc(doc(ravi, "riders/ravi/trips/old")));
    const bob = env.authenticatedContext("bob").firestore();
    await assertFails(getDoc(doc(bob, "riders/ravi/trips/old")));
  });

  it("keeps rider settings from customers", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "riders/applicant"), { status: "pending" });
    });
    const alice = env.authenticatedContext("alice").firestore();
    await assertFails(getDoc(doc(alice, "config/riders")));
    await assertSucceeds(getDoc(doc(env.authenticatedContext("ravi", { rider: true }).firestore(), "config/riders")));
    await assertSucceeds(getDoc(doc(env.authenticatedContext("applicant").firestore(), "config/riders")));
  });

  it("accepts only the address fields the app writes", async () => {
    const alice = env.authenticatedContext("alice").firestore();
    const ok = { label: "Home", line1: "12 Station Rd", landmark: null, lat: 23.3, lng: 86.3, isDefault: true };
    await assertSucceeds(setDoc(doc(alice, "users/alice/addresses/a1"), ok));
    await assertFails(setDoc(doc(alice, "users/alice/addresses/a2"), { ...ok, verified: true }));
    await assertFails(setDoc(doc(alice, "users/alice/addresses/a3"), { ...ok, line1: "x".repeat(301) }));
    await assertSucceeds(updateDoc(doc(alice, "users/alice/addresses/a1"), { label: "Work" }));
    await assertFails(updateDoc(doc(alice, "users/alice/addresses/a1"), { serviceAreaIdOverride: "x" }));
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
