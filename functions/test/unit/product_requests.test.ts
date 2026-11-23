import { describe, expect, it } from "vitest";
import { ZYPPI_SELLER, sellerCanSell } from "../../src/marketplace/offers";
import { readProductRequest, sellerImageOk } from "../../src/marketplace/product_requests";

const img = (seller: string) =>
  `https://firebasestorage.googleapis.com/v0/b/zippy-app-2024.appspot.com/o/sellers%2F${seller}%2Fproducts%2Fp1.jpg?alt=media&token=x`;

describe("seller product requests", () => {
  it("accepts only photos from the seller's own upload folder", () => {
    expect(sellerImageOk(img("u1"), "u1")).toBe(true);
    expect(sellerImageOk(img("u2"), "u1")).toBe(false);
    expect(sellerImageOk("https://evil.example/sellers/u1/products/x.jpg", "u1")).toBe(false);
    expect(sellerImageOk("http://firebasestorage.googleapis.com/o/sellers%2Fu1%2Fproducts%2Fx", "u1")).toBe(false);
  });

  it("prices master variants at MRP (the seller's price is their listing)", () => {
    const { input, problems } = readProductRequest(
      { name: "Hand-made Pickle", categoryId: "c1", imageUrl: img("u1"), variants: [{ label: "250 g", mrpPaise: 12000 }] },
      "u1",
    );
    expect(problems).toEqual([]);
    expect(input.product.variants).toEqual([{ id: null, label: "250 g", pricePaise: 12000, mrpPaise: 12000 }]);
    expect(input.productId).toBeNull();
  });

  it("lists every problem", () => {
    const { problems } = readProductRequest({ name: "x", imageUrl: img("u2"), variants: [] }, "u1");
    expect(problems).toEqual(expect.arrayContaining(["Category is required", "Add at least one variant", "Upload the photo from the app"]));
  });
});

describe("online / offline", () => {
  const shop = { ...ZYPPI_SELLER, model: "subscription", fulfilment: "seller_shop" };
  it("a seller's own shop sells only while online; supply stock always", () => {
    expect(sellerCanSell({ ...shop, online: false })).toBe(false);
    expect(sellerCanSell({ ...shop, online: true })).toBe(true);
    expect(sellerCanSell({ ...shop, fulfilment: "zyppi_store", online: false })).toBe(true);
  });
});

describe("seller requests with barcodes", () => {
  it("normalizes the barcode and lists the request's gtins", () => {
    const { input, problems } = readProductRequest(
      { name: "Nutella", brand: " Ferrero ", categoryId: "c1", imageUrl: img("u1"), variants: [{ label: "400 g", mrpPaise: 39900, gtin: "3017620422003" }] },
      "u1",
    );
    expect(problems).toEqual([]);
    expect(input.product.variants[0].gtin).toBe("03017620422003");
    expect(input.product.brand).toBe("Ferrero");
    expect(input.gtins).toEqual(["03017620422003"]);
  });

  it("rejects bad and in-store barcodes", () => {
    const { problems } = readProductRequest(
      {
        name: "Loose dal",
        categoryId: "c1",
        variants: [
          { label: "1 kg", mrpPaise: 100, gtin: "3017620422004" },
          { label: "2 kg", mrpPaise: 100, gtin: "2012345001003" },
        ],
      },
      "u1",
    );
    expect(problems).toEqual(expect.arrayContaining(["Variant 1: barcode is not a valid EAN / UPC", "Variant 2: barcode is not a valid EAN / UPC"]));
  });

  it("leaves gtin out (not undefined) when a variant has none, so Firestore can store it", () => {
    const { input } = readProductRequest({ name: "Pickle", categoryId: "c1", variants: [{ label: "250 g", mrpPaise: 100 }] }, "u1");
    expect("gtin" in input.product.variants[0]).toBe(false);
    expect("brand" in input.product).toBe(false);
    expect("details" in input.product).toBe(false);
    expect(input.gtins).toEqual([]);
  });

  it("reports detail problems with the rest", () => {
    const { problems } = readProductRequest(
      { name: "Chips", categoryId: "c1", variants: [{ label: "50 g", mrpPaise: 100 }], details: { nutrition: { basis: "per100g", fat: 500 } } },
      "u1",
    );
    expect(problems).toContain("Nutrition: fat is out of range");
  });
});
