import { describe, expect, it } from "vitest";
import { mergeVariants, normalizeColor, productProblems } from "../../src/catalog/model";
import { categoryProblem, searchFieldsPatch } from "../../src/catalog/products";

const valid = {
  name: "Toned Milk",
  description: "",
  categoryId: "c1",
  subcategoryId: null,
  imageUrl: null,
  isActive: true,
  variants: [{ label: "1 L", pricePaise: 6400, mrpPaise: 6800 }],
};

describe("productProblems", () => {
  it("accepts a valid product", () => {
    expect(productProblems(valid)).toEqual([]);
  });

  it("lists every problem with the variant number", () => {
    const problems = productProblems({
      ...valid,
      name: "M",
      imageUrl: "http://x/y.png",
      variants: [
        { label: "1 L", pricePaise: 7000, mrpPaise: 6800 },
        { label: "1 l", pricePaise: 0, mrpPaise: 100 },
      ],
    });
    expect(problems).toEqual([
      "Name must be 2–120 characters",
      "Image must be an https:// URL",
      "Variant 1: MRP can’t be below the selling price",
      "Variant 2: “1 l” is listed twice",
      "Variant 2: price must be more than ₹0",
    ]);
  });

  it("rejects fractional paise and no variants", () => {
    expect(productProblems({ ...valid, variants: [] })).toContain("Add at least one variant");
    expect(
      productProblems({ ...valid, variants: [{ label: "x", pricePaise: 10.5, mrpPaise: 20 }] }),
    ).toContain("Variant 1: price must be more than ₹0");
  });
});

describe("mergeVariants", () => {
  const existing = [
    { id: "v1", label: "500 g", pricePaise: 100, mrpPaise: 120 },
    { id: "v2", label: "1 kg", pricePaise: 190, mrpPaise: 220 },
  ];

  it("keeps ids by id or by label and creates new ones", () => {
    const out = mergeVariants(existing, [
      { id: "v2", label: "1 kg pack", pricePaise: 180, mrpPaise: 220 },
      { label: "500 G", pricePaise: 90, mrpPaise: 120 },
      { label: "2 kg", pricePaise: 350, mrpPaise: 400 },
    ]);
    expect(out.map((v) => v.id).slice(0, 2)).toEqual(["v2", "v1"]);
    expect(out[2].id).toMatch(/^[0-9a-f-]{36}$/);
    expect(out[0]).toMatchObject({ label: "1 kg pack", pricePaise: 180 });
  });

  it("drops unlisted variants unless asked to keep them", () => {
    const one = [{ label: "1 kg", pricePaise: 200, mrpPaise: 220 }];
    expect(mergeVariants(existing, one).map((v) => v.id)).toEqual(["v2"]);
    expect(mergeVariants(existing, one, true).map((v) => v.id)).toEqual(["v2", "v1"]);
  });
});

describe("categoryProblem", () => {
  const cats = [
    { id: "c1", name: "Fruits", parentId: null },
    { id: "c2", name: "Dairy", parentId: null },
    { id: "s1", name: "Apples", parentId: "c1" },
  ];
  it("needs a top-level category and a matching sub-category", () => {
    expect(categoryProblem(cats, "c1", "s1")).toBeNull();
    expect(categoryProblem(cats, "s1", null)).toMatch(/top-level/);
    expect(categoryProblem(cats, "c2", "s1")).toMatch(/another category/);
    expect(categoryProblem(cats, "nope", null)).toBe("Category not found");
  });
});

describe("normalizeColor", () => {
  it("accepts RGB (made opaque) and ARGB", () => {
    expect(normalizeColor("#53b175")).toBe("FF53B175");
    expect(normalizeColor("1A53B175")).toBe("1A53B175");
    expect(normalizeColor("")).toBeNull();
    expect(() => normalizeColor("green")).toThrow();
  });
});

describe("searchFieldsPatch", () => {
  it("fixes stale keywords and variant ids, and is a no-op when in step", () => {
    const data = { name: "Toned Milk", variants: [{ id: "v1" }], keywords: ["old"], variantIds: [] };
    const patch = searchFieldsPatch(data)!;
    expect(patch.keywords).toContain("mil");
    expect(patch.variantIds).toEqual(["v1"]);
    expect(searchFieldsPatch({ ...data, ...patch })).toBeNull();
  });
});

describe("barcodes on variants", () => {
  const G1 = "03017620422003";
  const G2 = "08901058851298";

  it("validates canonical GTINs and one barcode per pack size", async () => {
    const { productProblems } = await import("../../src/catalog/model");
    expect(productProblems({ ...valid, variants: [{ label: "1 L", pricePaise: 1, mrpPaise: 1, gtin: G1 }] })).toEqual([]);
    expect(productProblems({ ...valid, variants: [{ label: "1 L", pricePaise: 1, mrpPaise: 1, gtin: "3017620422003" }] })).toEqual([
      "Variant 1: barcode is not a valid EAN / UPC",
    ]);
    expect(
      productProblems({
        ...valid,
        variants: [
          { label: "1 L", pricePaise: 1, mrpPaise: 1, gtin: G1 },
          { label: "2 L", pricePaise: 1, mrpPaise: 1, gtin: G1 },
        ],
      }),
    ).toEqual(["Variant 2: barcode is on two pack sizes"]);
  });

  it("an edit that doesn't send gtin keeps it; null clears; a new value replaces", () => {
    const existing = [{ id: "v1", label: "1 L", pricePaise: 1, mrpPaise: 1, gtin: G1 }];
    expect(mergeVariants(existing, [{ label: "1 L", pricePaise: 2, mrpPaise: 2 }])[0]).toEqual({ id: "v1", label: "1 L", pricePaise: 2, mrpPaise: 2, gtin: G1 });
    expect(mergeVariants(existing, [{ id: "v1", label: "1 L", pricePaise: 2, mrpPaise: 2, gtin: null }])[0]).toEqual({ id: "v1", label: "1 L", pricePaise: 2, mrpPaise: 2 });
    expect(mergeVariants(existing, [{ id: "v1", label: "1 L", pricePaise: 2, mrpPaise: 2, gtin: G2 }])[0].gtin).toBe(G2);
    // A brand-new variant never inherits a barcode.
    expect(mergeVariants(existing, [{ label: "5 L", pricePaise: 2, mrpPaise: 2 }])[0].gtin).toBeUndefined();
  });

  it("plans which reservations to add, re-point and release", async () => {
    const { planBarcodeChanges } = await import("../../src/catalog/products");
    expect(planBarcodeChanges([], [{ id: "v1", gtin: G1 }, { id: "v2" }])).toEqual({ add: [{ gtin: G1, variantId: "v1" }], remove: [] });
    expect(planBarcodeChanges([{ id: "v1", gtin: G1 }], [{ id: "v1", gtin: G1 }])).toEqual({ add: [], remove: [] });
    expect(planBarcodeChanges([{ id: "v1", gtin: G1 }], [{ id: "v2", gtin: G1 }])).toEqual({ add: [{ gtin: G1, variantId: "v2" }], remove: [] });
    expect(planBarcodeChanges([{ id: "v1", gtin: G1 }], [{ id: "v1", gtin: G2 }])).toEqual({ add: [{ gtin: G2, variantId: "v1" }], remove: [G1] });
  });

  it("brand words are searchable and survive the keywords safety net", async () => {
    const { productDoc, brandWords } = await import("../../src/catalog/products");
    expect(brandWords("Haldiram's")).toEqual(["haldiram"]);
    const doc = productDoc({ ...valid, brand: "Amul" }, []);
    expect(doc.keywords).toContain("amu");
    expect(doc.brand).toBe("Amul");
    expect(searchFieldsPatch({ ...doc })).toBeNull();
    // Without brand in the input (import), the stored brand isn't touched.
    expect("brand" in productDoc(valid, [])).toBe(false);
    expect("details" in productDoc(valid, [])).toBe(false);
  });
});

describe("product details", () => {
  it("keeps known fields, drops unknown, validates nutrition with its basis", async () => {
    const { readDetails } = await import("../../src/catalog/details");
    const { details, problems } = readDetails({
      genericName: " Noodles ",
      quantity: { value: 70, unit: "g" },
      allergens: ["gluten", "gluten", 5],
      nutrition: { basis: "per100g", energyKcal: 437, fat: 15.7, protein: "x" },
      provenance: { name: "off", brand: "off_edited", ingredients: "verified" },
      source: { provider: "openfoodfacts", url: "https://world.openfoodfacts.org/product/8901058851298", fetchedAt: "2026-11-24" },
      hack: true,
    });
    expect(problems).toEqual(["Nutrition: protein must be a number"]);
    expect(details).toEqual({
      genericName: "Noodles",
      quantity: { value: 70, unit: "g" },
      allergens: ["gluten"],
      nutrition: { basis: "per100g", energyKcal: 437, fat: 15.7 },
      provenance: { name: "off", brand: "off_edited" },
      source: { provider: "openfoodfacts", url: "https://world.openfoodfacts.org/product/8901058851298", fetchedAt: "2026-11-24" },
    });
  });

  it("rejects impossible nutrition and unknown sources", async () => {
    const { readDetails } = await import("../../src/catalog/details");
    expect(readDetails({ nutrition: { basis: "per100g", fat: 120 } }).problems).toContain("Nutrition: fat is out of range");
    expect(readDetails({ nutrition: { basis: "per100g", fat: 60, carbohydrates: 60 } }).problems[0]).toMatch(/over 100 g/);
    expect(readDetails({ nutrition: { basis: "per100g", energyKcal: 100, energyKj: 900 } }).problems).toContain("Nutrition: kcal and kJ don't match");
    expect(readDetails({ nutrition: { basis: "perServing", fat: 4 } }).problems).toContain("Nutrition per serving needs the serving size");
    expect(readDetails({ nutrition: { fat: 4 } }).problems[0]).toMatch(/basis/);
    expect(readDetails({ quantity: { value: -1, unit: "g" } }).problems[0]).toMatch(/Quantity/);
    expect(readDetails({ source: { provider: "openfoodfacts", url: "https://evil.example/p", fetchedAt: "x" } }).problems).toEqual(["Data source is invalid"]);
  });

  it("unconfirmed OFF claims become manual", async () => {
    const { withoutOffClaims } = await import("../../src/catalog/details");
    expect(
      withoutOffClaims({ origin: "India", provenance: { origin: "off" }, source: { provider: "openfoodfacts", url: "https://world.openfoodfacts.org/product/1", fetchedAt: "x" } }),
    ).toEqual({ origin: "India", provenance: { origin: "manual" } });
  });
});
