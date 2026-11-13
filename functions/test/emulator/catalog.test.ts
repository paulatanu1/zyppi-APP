import { beforeEach, describe, expect, it } from "vitest";
import { deleteCategory, reorderCategories, saveCategory } from "../../src/catalog/categories";
import { importProducts } from "../../src/catalog/import";
import { adjustStock } from "../../src/catalog/inventory";
import { saveProduct } from "../../src/catalog/products";
import { db } from "../../src/shared/firebase";
import type { Actor } from "../../src/shared/roles";
import { STORE_A, resetData } from "./fixtures";

const riya: Actor = { uid: "riya", role: "catalog", email: "riya@zyppi.test" };

const product = (over: Record<string, unknown> = {}) => ({
  name: "Amul Butter",
  description: "Salted",
  categoryId: "c1",
  subcategoryId: null,
  imageUrl: null,
  isActive: true,
  variants: [
    { label: "100 g", pricePaise: 5600, mrpPaise: 6000 },
    { label: "500 g", pricePaise: 27500, mrpPaise: 29000 },
  ],
  ...over,
});

const audits = async (action: string) =>
  (await db.collection("auditLogs").where("action", "==", action).get()).docs.map((d) => d.data());

beforeEach(async () => {
  await resetData();
  const b = db.batch();
  b.set(db.doc("categories/c1"), { name: "Dairy", parentId: null, sortOrder: 0 });
  b.set(db.doc("categories/c2"), { name: "Fruits", parentId: null, sortOrder: 1 });
  b.set(db.doc("categories/s1"), { name: "Butter & Cheese", parentId: "c1", sortOrder: 0 });
  b.set(db.doc("categories/s2"), { name: "Milk", parentId: "c1", sortOrder: 1 });
  await b.commit();
});

describe("saveProduct", () => {
  it("creates with search keywords, variant ids and an audit row", async () => {
    const { id, created } = await saveProduct(riya, product({ subcategoryId: "s1" }));
    expect(created).toBe(true);
    const doc = (await db.doc(`products/${id}`).get()).data()!;
    expect(doc.keywords).toEqual(expect.arrayContaining(["am", "amul b", "but"]));
    expect(doc.variantIds).toEqual(doc.variants.map((v: { id: string }) => v.id));
    expect(doc).toMatchObject({ subcategoryId: "s1", updatedBy: "riya", isActive: true });
    expect(await audits("product.create")).toHaveLength(1);
  });

  it("keeps variant ids on update so stock and carts stay linked", async () => {
    const { id } = await saveProduct(riya, product());
    const before = (await db.doc(`products/${id}`).get()).get("variants");
    await saveProduct(riya, {
      ...product({ name: "Amul Butter (Salted)" }),
      id,
      variants: [
        { id: before[1].id, label: "500 g", pricePaise: 26500, mrpPaise: 29000 },
        { label: "100 G", pricePaise: 5500, mrpPaise: 6000 },
      ],
    });
    const after = (await db.doc(`products/${id}`).get()).data()!;
    expect(after.variants.map((v: { id: string }) => v.id)).toEqual([before[1].id, before[0].id]);
    expect(after.keywords).toContain("salted");
    expect(await audits("product.update")).toHaveLength(1);
  });

  it("refuses bad prices and mismatched categories", async () => {
    await expect(
      saveProduct(riya, product({ variants: [{ label: "1", pricePaise: 900, mrpPaise: 800 }] })),
    ).rejects.toThrow("MRP can’t be below the selling price");
    await expect(saveProduct(riya, product({ categoryId: "c2", subcategoryId: "s1" }))).rejects.toThrow(
      "another category",
    );
    await expect(saveProduct(riya, { ...product(), id: "missing" })).rejects.toThrow(
      "Product not found",
    );
  });
});

describe("categories", () => {
  it("creates sub-categories at the end and blocks a third level", async () => {
    const { id } = await saveCategory(riya, { name: "Ghee", parentId: "c1", colorHex: "53B175" });
    const doc = (await db.doc(`categories/${id}`).get()).data()!;
    expect(doc).toMatchObject({ sortOrder: 2, colorHex: "FF53B175", parentId: "c1" });
    await expect(saveCategory(riya, { name: "Deep", parentId: "s1" })).rejects.toThrow(
      "Sub-categories can’t have children",
    );
    await expect(saveCategory(riya, { name: "milk", parentId: "c1" })).rejects.toThrow(
      "already exists",
    );
    await expect(saveCategory(riya, { id: "c1", name: "Dairy", parentId: "c2" })).rejects.toThrow(
      "has sub-categories",
    );
  });

  it("deletes only unused categories", async () => {
    await expect(deleteCategory(riya, "c1")).rejects.toThrow("sub-categories first");
    await saveProduct(riya, product({ subcategoryId: "s2" }));
    await expect(deleteCategory(riya, "s2")).rejects.toThrow("Products still use");
    await deleteCategory(riya, "s1");
    expect((await db.doc("categories/s1").get()).exists).toBe(false);
  });

  it("reorders one level and rejects a stale list", async () => {
    await reorderCategories(riya, "c1", ["s2", "s1"]);
    expect((await db.doc("categories/s2").get()).get("sortOrder")).toBe(0);
    await expect(reorderCategories(riya, "c1", ["s2"])).rejects.toThrow("list changed");
  });
});

describe("adjustStock", () => {
  it("adds and sets stock and records each movement", async () => {
    await adjustStock(riya, {
      reason: "restock",
      note: "Morning delivery",
      items: [
        { storeId: STORE_A, productId: "p-milk", variantId: "v-milk", mode: "add", value: 7 },
        { storeId: STORE_A, productId: "p-rice", variantId: "v-rice", mode: "set", value: 2 },
      ],
    });
    expect((await db.doc(`inventory/${STORE_A}_v-milk`).get()).get("quantity")).toBe(10);
    expect((await db.doc(`inventory/${STORE_A}_v-rice`).get()).get("quantity")).toBe(2);
    const moves = (await db.collection("inventoryMovements").get()).docs.map((d) => d.data());
    expect(moves).toEqual(
      expect.arrayContaining([
        expect.objectContaining({ variantId: "v-milk", before: 3, after: 10, delta: 7, reason: "restock" }),
        expect.objectContaining({ variantId: "v-rice", before: 10, after: 2, delta: -8 }),
      ]),
    );
  });

  it("never goes below zero and checks the variant belongs to the product", async () => {
    const row = { storeId: STORE_A, productId: "p-milk", variantId: "v-milk", mode: "add", value: -4 };
    await expect(adjustStock(riya, { reason: "damage", items: [row] })).rejects.toThrow(
      "below zero",
    );
    await expect(
      adjustStock(riya, { reason: "count", items: [{ ...row, productId: "p-rice", mode: "set", value: 1 }] }),
    ).rejects.toThrow("Product or variant not found");
    await expect(adjustStock(riya, { reason: "because", items: [row] })).rejects.toThrow("Pick a reason");
    expect((await db.doc(`inventory/${STORE_A}_v-milk`).get()).get("quantity")).toBe(3);
  });
});

describe("importProducts", () => {
  it("creates products grouped by key, resolving categories by name", async () => {
    const out = await importProducts(riya, [
      { row: 2, key: "ghee", name: "Amul Ghee", category: "dairy", subcategory: "Butter & cheese", variant: "500 ml", pricePaise: 32000, mrpPaise: 34000 },
      { row: 3, key: "ghee", variant: "1 L", pricePaise: 62000, mrpPaise: 65000 },
      { row: 4, name: "Banana", category: "Fruits", variant: "6 pcs", pricePaise: 4800 },
    ]);
    expect(out).toMatchObject({ created: 2, updated: 0, failedRows: 0 });
    const ghee = (await db.doc(`products/${out.results[0].productId}`).get()).data()!;
    expect(ghee).toMatchObject({ name: "Amul Ghee", categoryId: "c1", subcategoryId: "s1" });
    expect(ghee.variants.map((v: { label: string }) => v.label)).toEqual(["500 ml", "1 L"]);
    const banana = (await db.doc(`products/${out.results[2].productId}`).get()).data()!;
    expect(banana.variants[0].mrpPaise).toBe(4800); // MRP defaults to price
    expect(await audits("product.import")).toHaveLength(1);
  });

  it("updates by id, keeps unlisted variants and skips only the bad product", async () => {
    const { id } = await saveProduct(riya, product());
    const out = await importProducts(riya, [
      { row: 2, productId: id, variant: "100 g", pricePaise: 5000, mrpPaise: 6000 },
      { row: 3, name: "Bad", category: "Nope", variant: "1", pricePaise: 100 },
      { row: 4, name: "Cheap", category: "Dairy", variant: "1", pricePaise: 200, mrpPaise: 100 },
    ]);
    expect(out).toMatchObject({ created: 0, updated: 1, failedRows: 2 });
    expect(out.results[1].message).toBe("Unknown category “Nope”");
    expect(out.results[2].message).toContain("MRP can’t be below");
    const doc = (await db.doc(`products/${id}`).get()).data()!;
    expect(doc.name).toBe("Amul Butter");
    expect(doc.variants).toHaveLength(2);
    expect(doc.variants.find((v: { label: string }) => v.label === "100 g").pricePaise).toBe(5000);
  });

  it("caps the request size", async () => {
    await expect(importProducts(riya, [])).rejects.toThrow("Send 1–300 rows");
  });
});
