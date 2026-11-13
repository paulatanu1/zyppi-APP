import { readFileSync } from "node:fs";
import { join } from "node:path";
import {
  RulesTestEnvironment,
  assertFails,
  assertSucceeds,
  initializeTestEnvironment,
} from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc, updateDoc } from "firebase/firestore";
import { afterAll, beforeAll, beforeEach, describe, it } from "vitest";

let env: RulesTestEnvironment;

beforeAll(async () => {
  const [host, port] = process.env.FIRESTORE_EMULATOR_HOST!.split(":");
  env = await initializeTestEnvironment({
    projectId: "demo-zyppi-rules-roles",
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
    await setDoc(doc(db, "products/p1"), { name: "Milk" });
    await setDoc(doc(db, "stores/s1"), { name: "A" });
    await setDoc(doc(db, "inventory/s_v"), { quantity: 5 });
    await setDoc(doc(db, "coupons/ON"), { isActive: true, expiresAt: null });
    await setDoc(doc(db, "config/features"), { placesSearch: true });
    await setDoc(doc(db, "staff/u1"), { role: "ops" });
    await setDoc(doc(db, "auditLogs/a1"), { action: "x" });
    await setDoc(doc(db, "supportKb/k1"), { topic: "refund" });
    await setDoc(doc(db, "inventoryMovements/m1"), { delta: 1 });
  });
});

const as = (claims: Record<string, unknown>) =>
  env.authenticatedContext("staff-1", claims).firestore();

describe("staff roles in firestore.rules", () => {
  it("gives each role only its own collections", async () => {
    const catalog = as({ role: "catalog" });
    await assertFails(updateDoc(doc(catalog, "stores/s1"), { name: "B" }));

    const ops = as({ role: "ops" });
    await assertSucceeds(updateDoc(doc(ops, "stores/s1"), { name: "B" }));

    const finance = as({ role: "finance" });
    await assertSucceeds(updateDoc(doc(finance, "coupons/ON"), { isActive: false }));
    await assertSucceeds(getDoc(doc(finance, "inventory/s_v")));
  });

  it("routes product, category and stock writes through the callables", async () => {
    for (const claims of [{ role: "catalog" }, { role: "ops" }, { role: "super_admin" }]) {
      const db = as(claims);
      await assertFails(updateDoc(doc(db, "products/p1"), { name: "x" }));
      await assertFails(setDoc(doc(db, "categories/c1"), { name: "x" }));
      await assertFails(updateDoc(doc(db, "inventory/s_v"), { quantity: 9 }));
    }
  });

  it("shows stock history to ops and catalog only", async () => {
    await assertSucceeds(getDoc(doc(as({ role: "ops" }), "inventoryMovements/m1")));
    await assertSucceeds(getDoc(doc(as({ role: "catalog" }), "inventoryMovements/m1")));
    await assertFails(getDoc(doc(as({ role: "support" }), "inventoryMovements/m1")));
    await assertFails(setDoc(doc(as({ role: "ops" }), "inventoryMovements/m2"), { delta: 1 }));
  });

  it("treats super_admin and the legacy admin claim as everything", async () => {
    for (const claims of [{ role: "super_admin" }, { admin: true }]) {
      const db = as(claims);
      await assertSucceeds(updateDoc(doc(db, "stores/s1"), { name: "y" }));
      await assertSucceeds(getDoc(doc(db, "auditLogs/a1")));
    }
  });

  it("ignores unknown role values", async () => {
    const rider = as({ role: "rider" });
    await assertFails(getDoc(doc(rider, "inventory/s_v")));
    await assertFails(getDoc(doc(rider, "staff/u1")));
  });

  it("makes feature switches public to read and function-only to write", async () => {
    await assertSucceeds(getDoc(doc(env.unauthenticatedContext().firestore(), "config/features")));
    await assertFails(
      setDoc(doc(as({ role: "super_admin" }), "config/features"), { placesSearch: false }),
    );
  });

  it("lets staff read the staff list; only super_admin reads the audit log", async () => {
    await assertSucceeds(getDoc(doc(as({ role: "support" }), "staff/u1")));
    await assertFails(getDoc(doc(env.authenticatedContext("alice").firestore(), "staff/u1")));
    await assertFails(getDoc(doc(as({ role: "ops" }), "auditLogs/a1")));
    await assertFails(setDoc(doc(as({ role: "super_admin" }), "auditLogs/a2"), { action: "fake" }));
    await assertFails(setDoc(doc(as({ role: "super_admin" }), "staff/u2"), { role: "ops" }));
  });

  it("gives the knowledge base to support only", async () => {
    await assertSucceeds(getDoc(doc(as({ role: "support" }), "supportKb/k1")));
    await assertFails(getDoc(doc(as({ role: "catalog" }), "supportKb/k1")));
  });
});

describe("refunds in firestore.rules", () => {
  it("are readable by finance and ops, writable by nobody", async () => {
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), "refunds/r1"), { amountPaise: 100 });
    });
    await assertSucceeds(getDoc(doc(as({ role: "finance" }), "refunds/r1")));
    await assertSucceeds(getDoc(doc(as({ role: "ops" }), "refunds/r1")));
    await assertFails(getDoc(doc(as({ role: "catalog" }), "refunds/r1")));
    await assertFails(setDoc(doc(as({ role: "finance" }), "refunds/r2"), { amountPaise: 1 }));
  });
});
