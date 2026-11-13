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
