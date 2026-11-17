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
