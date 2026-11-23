import { readFileSync } from "node:fs";
import { join } from "node:path";
import { type RulesTestEnvironment, assertFails, assertSucceeds, initializeTestEnvironment } from "@firebase/rules-unit-testing";
import { doc, getDoc, setDoc } from "firebase/firestore";
import { afterAll, beforeAll, beforeEach, describe, expect, it } from "vitest";
import { firestoreLookupStore } from "../../src/catalog/barcode_lookup";
import { saveProduct } from "../../src/catalog/products";
import { db } from "../../src/shared/firebase";
import type { Actor } from "../../src/shared/roles";
import { resetData } from "./fixtures";

/**
 * Barcode uniqueness and the barcode rules (docs/BARCODES.md). Runs on the
 * Auth + Firestore emulators: `npm --prefix functions test`.
 */

const riya: Actor = { uid: "riya", role: "catalog", email: "riya@zyppi.test" };
const G = "03017620422003";

const product = (gtin: string | null, name = "Nutella") => ({
  name,
  description: "",
  categoryId: "c1",
  subcategoryId: null,
  imageUrl: null,
  isActive: true,
  brand: "Ferrero",
  variants: [{ label: "400 g", pricePaise: 39900, mrpPaise: 39900, gtin }],
});

beforeEach(async () => {
  await resetData();
  await db.doc("categories/c1").set({ name: "Spreads", parentId: null, sortOrder: 0 });
  const old = await db.collection("barcodes").get();
  await Promise.all(old.docs.map((d) => d.ref.delete()));
});

describe("saveProduct barcode reservations", () => {
  it("reserves the GTIN for the variant, releases it when cleared", async () => {
    const { id } = await saveProduct(riya, product(G));
    const p = (await db.doc(`products/${id}`).get()).data()!;
    expect((await db.doc(`barcodes/${G}`).get()).data()).toMatchObject({ productId: id, variantId: p.variants[0].id });
    expect(await firestoreLookupStore.catalogHit(G)).toMatchObject({ productId: id, name: "Nutella", brand: "Ferrero" });

    await saveProduct(riya, { ...product(null), id, variants: [{ id: p.variants[0].id, label: "400 g", pricePaise: 39900, mrpPaise: 39900, gtin: null }] });
    expect((await db.doc(`barcodes/${G}`).get()).exists).toBe(false);
  });

  it("an admin edit that doesn't send barcodes keeps them", async () => {
    const { id } = await saveProduct(riya, product(G));
    await saveProduct(riya, { ...product(G), id, variants: [{ label: "400 g", pricePaise: 35000, mrpPaise: 39900 }] });
    const p = (await db.doc(`products/${id}`).get()).data()!;
    expect(p.variants[0].gtin).toBe(G);
    expect((await db.doc(`barcodes/${G}`).get()).get("productId")).toBe(id);
  });

  it("a second product can't take the same barcode", async () => {
    const { id } = await saveProduct(riya, product(G));
    await expect(saveProduct(riya, product(G, "Nutella copy"))).rejects.toMatchObject({
      code: "already-exists",
      message: "DUPLICATE_BARCODE",
      details: { gtin: G, productId: id },
    });
  });

  it("two simultaneous creations: exactly one wins", async () => {
    const results = await Promise.allSettled([saveProduct(riya, product(G, "A")), saveProduct(riya, product(G, "B"))]);
    expect(results.filter((r) => r.status === "fulfilled")).toHaveLength(1);
    expect(results.filter((r) => r.status === "rejected")).toHaveLength(1);
    const owners = await db.collection("products").where("variants", "!=", null).get();
    const withG = owners.docs.filter((d) => (d.get("variants") as { gtin?: string }[]).some((v) => v.gtin === G));
    expect(withG).toHaveLength(1);
  });

  it("a stale reservation (barcode no longer on that product) can be taken over", async () => {
    await db.doc(`barcodes/${G}`).set({ productId: "gone", variantId: "v" });
    await expect(saveProduct(riya, product(G))).resolves.toMatchObject({ created: true });
  });
});

describe("barcode rules", () => {
  let env: RulesTestEnvironment;

  beforeAll(async () => {
    const [host, port] = process.env.FIRESTORE_EMULATOR_HOST!.split(":");
    env = await initializeTestEnvironment({
      projectId: "demo-zyppi-barcodes",
      firestore: { rules: readFileSync(join(__dirname, "..", "..", "..", "firestore.rules"), "utf8"), host, port: Number(port) },
    });
  });
  afterAll(() => env.cleanup());

  beforeEach(async () => {
    await env.clearFirestore();
    await env.withSecurityRulesDisabled(async (ctx) => {
      await setDoc(doc(ctx.firestore(), `barcodes/${G}`), { productId: "p1", variantId: "v1" });
      await setDoc(doc(ctx.firestore(), `barcodeLookups/${G}`), { status: "found" });
      await setDoc(doc(ctx.firestore(), "products/p1"), { name: "Nutella" });
    });
  });

  const roles = {
    guest: () => env.unauthenticatedContext().firestore(),
    buyer: () => env.authenticatedContext("buyer").firestore(),
    seller: () => env.authenticatedContext("seller", { sellerId: "s1", sellerRole: "owner" }).firestore(),
    catalog: () => env.authenticatedContext("staff", { role: "catalog" }).firestore(),
    superAdmin: () => env.authenticatedContext("boss", { role: "super_admin" }).firestore(),
  };

  for (const [name, ctx] of Object.entries(roles)) {
    it(`${name}: reads the barcode index, never writes it, products or the OFF cache`, async () => {
      const db = ctx();
      await assertSucceeds(getDoc(doc(db, `barcodes/${G}`)));
      await assertFails(setDoc(doc(db, `barcodes/${G}`), { productId: "mine", variantId: "v" }));
      await assertFails(setDoc(doc(db, "barcodes/08901058851298"), { productId: "mine", variantId: "v" }));
      await assertFails(getDoc(doc(db, `barcodeLookups/${G}`)));
      await assertFails(setDoc(doc(db, `barcodeLookups/${G}`), { status: "found" }));
      await assertFails(setDoc(doc(db, "products/p2"), { name: "Fake", variants: [{ gtin: G }] }));
      await assertFails(setDoc(doc(db, "productRequests/r1"), { sellerId: "s1", status: "approved", gtins: [G] }));
    });
  }
});
