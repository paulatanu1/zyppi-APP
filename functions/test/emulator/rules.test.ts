import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  RulesTestEnvironment,
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc, updateDoc, getDocs, collection } from "firebase/firestore";
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
});
