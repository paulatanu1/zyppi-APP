import { describe, expect, it } from "vitest";
import {
  inventoryIdFor,
  isZyppiStore,
  listingIdFor,
  metresBetween,
  planProblems,
  readPlan,
  readSellerApplication,
  sellerApplicationProblems,
} from "../../src/marketplace/model";
import {
  PricingError,
  adjustmentPaise,
  isDiscountActive,
  priceListing,
  pricingProblems,
  readSpecialDiscount,
} from "../../src/marketplace/pricing";

const now = new Date(Date.UTC(2026, 10, 17, 6));

describe("priceListing — subscription", () => {
  it("customer pays seller price + fixed add-on; seller gets their price; Zyppi keeps the add-on", () => {
    const r = priceListing({ model: "subscription", mrpPaise: 6000, sellerPricePaise: 5000, addon: { type: "fixed", value: 500 } });
    expect(r).toMatchObject({ pricePaise: 5500, payoutPaise: 5000, marginPaise: 500, addonPaise: 500, discountPaise: 0 });
  });

  it("works with no add-on (Zyppi earns only the subscription fee)", () => {
    const r = priceListing({ model: "subscription", mrpPaise: 6000, sellerPricePaise: 5000 });
    expect(r).toMatchObject({ pricePaise: 5000, payoutPaise: 5000, marginPaise: 0 });
  });

  it("rounds a percent add-on half up to the paisa", () => {
    expect(adjustmentPaise(4999, { type: "percent", value: 10 })).toBe(500); // 499.9
    expect(adjustmentPaise(1005, { type: "percent", value: 5 })).toBe(50); // 50.25
    expect(adjustmentPaise(1010, { type: "percent", value: 5 })).toBe(51); // 50.5
    expect(adjustmentPaise(3333, { type: "percent", value: 12.5 })).toBe(417); // 416.625
  });

  it("a seller discount comes off the seller's payout and is passed to the customer; the add-on is kept", () => {
    const r = priceListing(
      {
        model: "subscription",
        mrpPaise: 6000,
        sellerPricePaise: 5000,
        addon: { type: "percent", value: 10 },
        specialDiscount: { type: "percent", value: 20, startsAt: null, endsAt: null },
      },
      now,
    );
    expect(r).toMatchObject({ regularPricePaise: 5500, discountPaise: 1000, pricePaise: 4500, payoutPaise: 4000, marginPaise: 500, discountActive: true });
  });

  it("refuses a customer price above MRP (add-on included)", () => {
    const problems = pricingProblems({ model: "subscription", mrpPaise: 5200, sellerPricePaise: 5000, addon: { type: "fixed", value: 500 } });
    expect(problems).toEqual(["Customer price ₹55 is above the MRP ₹52"]);
    expect(() => priceListing({ model: "subscription", mrpPaise: 5200, sellerPricePaise: 5000, addon: { type: "fixed", value: 500 } })).toThrow(PricingError);
  });

  it("refuses an add-on on a supply or own listing", () => {
    expect(pricingProblems({ model: "supply", mrpPaise: 6000, sellerPricePaise: 4000, zyppiPricePaise: 5000, addon: { type: "fixed", value: 100 } }))
      .toContain("An add-on applies only to subscription sellers");
  });
});

describe("priceListing — supply and own", () => {
  it("supply: Zyppi sets the price, pays the supply price, keeps the difference", () => {
    const r = priceListing({ model: "supply", mrpPaise: 6000, sellerPricePaise: 4200, zyppiPricePaise: 5000 });
    expect(r).toMatchObject({ pricePaise: 5000, payoutPaise: 4200, marginPaise: 800 });
  });

  it("supply: a price below the supply price needs an override", () => {
    const input = { model: "supply" as const, mrpPaise: 6000, sellerPricePaise: 5000, zyppiPricePaise: 4800 };
    expect(pricingProblems(input)).toEqual(["Selling price is below the supply price (Zyppi would lose money)"]);
    expect(priceListing({ ...input, allowNegativeMargin: true }).marginPaise).toBe(-200);
  });

  it("supply: a seller discount lowers both the payout and the price, margin unchanged", () => {
    const r = priceListing(
      { model: "supply", mrpPaise: 6000, sellerPricePaise: 4000, zyppiPricePaise: 5000, specialDiscount: { type: "fixed", value: 300, startsAt: null, endsAt: null } },
      now,
    );
    expect(r).toMatchObject({ pricePaise: 4700, payoutPaise: 3700, marginPaise: 1000 });
  });

  it("own: Zyppi keeps everything", () => {
    expect(priceListing({ model: "own", mrpPaise: 6000, sellerPricePaise: 0, zyppiPricePaise: 5500 })).toMatchObject({ pricePaise: 5500, payoutPaise: 0, marginPaise: 5500 });
  });
});

describe("special discount", () => {
  const d = { type: "fixed" as const, value: 100, startsAt: new Date(Date.UTC(2026, 10, 17)), endsAt: new Date(Date.UTC(2026, 10, 18)) };

  it("is active from start (inclusive) to end (exclusive)", () => {
    expect(isDiscountActive(d, new Date(Date.UTC(2026, 10, 16, 23)))).toBe(false);
    expect(isDiscountActive(d, d.startsAt)).toBe(true);
    expect(isDiscountActive(d, d.endsAt)).toBe(false);
  });

  it("doesn't apply outside its dates", () => {
    const r = priceListing({ model: "subscription", mrpPaise: 6000, sellerPricePaise: 5000, specialDiscount: d }, new Date(Date.UTC(2026, 10, 20)));
    expect(r).toMatchObject({ pricePaise: 5000, discountPaise: 0, discountActive: false });
  });

  it("must be smaller than the price and end after it starts", () => {
    expect(pricingProblems({ model: "subscription", mrpPaise: 6000, sellerPricePaise: 5000, specialDiscount: { type: "fixed", value: 5000, startsAt: null, endsAt: null } }))
      .toEqual(["Discount must be less than the price"]);
    expect(pricingProblems({ model: "subscription", mrpPaise: 6000, sellerPricePaise: 5000, specialDiscount: { ...d, endsAt: d.startsAt } }))
      .toEqual(["Discount must end after it starts"]);
    expect(pricingProblems({ model: "subscription", mrpPaise: 6000, sellerPricePaise: 5000, specialDiscount: { type: "percent", value: 95, startsAt: null, endsAt: null } }))
      .toEqual(["Discount must be 0.01–90%"]);
  });

  it("reads dates from ISO strings and drops empty input", () => {
    expect(readSpecialDiscount({ type: "percent", value: 10, startsAt: "2026-11-17T00:00:00Z", endsAt: "" })).toEqual({
      type: "percent",
      value: 10,
      startsAt: new Date("2026-11-17T00:00:00Z"),
      endsAt: null,
    });
    expect(readSpecialDiscount({ type: "fixed", value: 0 })).toBeNull();
    expect(readSpecialDiscount(null)).toBeNull();
  });
});

// Purulia: shop pin and a photo ~50 m away.
const pin = { lat: 23.3322, lng: 86.3616 };
const photo = (k: string, lat = pin.lat + 0.0004, lng = pin.lng) => ({ path: `sellers/u1/kyc/${k}.jpg`, lat, lng, takenAt: "2026-11-17T05:00:00Z" });
const full = (over: Record<string, unknown> = {}) =>
  readSellerApplication(
    {
      ownerName: "Sima Kumari",
      phone: "9800022222",
      email: "Sima@Example.com",
      pan: "abcde1234f",
      aadhaarLast4: "4321",
      shopName: "Sima General Store",
      shopCategory: "grocery",
      address: "Station Road, Purulia 723101",
      ...pin,
      serviceAreaId: "purulia",
      hours: { open: "08:00", close: "21:30" },
      gstin: "19ABCDE1234F1Z5",
      fssaiNo: "12345678901234",
      fssaiExpiry: "2028-03-31",
      model: "subscription",
      fulfilment: "seller_shop",
      planId: "p3",
      docs: {
        selfie: photo("selfie"),
        shopPhoto1: photo("shop1"),
        fssaiCertificate: "sellers/u1/kyc/fssai.jpg",
        signature: "sellers/u1/kyc/signature.png",
      },
      payout: { method: "upi", upiId: "sima@okaxis" },
      ...over,
    },
    "u1",
  );

describe("seller application", () => {
  it("accepts a complete application and normalises it", () => {
    const a = full();
    expect(sellerApplicationProblems(a, true, now)).toEqual([]);
    expect(a.pan).toBe("ABCDE1234F");
    expect(a.email).toBe("sima@example.com");
  });

  it("keeps only files in the applicant's own folder", () => {
    const a = readSellerApplication({ docs: { selfie: "sellers/u2/kyc/s.jpg", signature: "sellers/u1/kyc/../x", shopPhoto1: "sellers/u1/kyc/a.jpg" } }, "u1");
    expect(Object.keys(a.docs)).toEqual(["shopPhoto1"]);
  });

  it("lets a partial draft through but lists what's missing on submit", () => {
    const a = readSellerApplication({ shopName: "Sima" }, "u1");
    expect(sellerApplicationProblems(a, false, now)).toEqual([]);
    const problems = sellerApplicationProblems(a, true, now);
    expect(problems).toContain("Take a live selfie");
    expect(problems).toContain("Sign the seller agreement");
    expect(problems).toContain("Choose subscription or supply");
  });

  it("requires shop photos to be taken at the shop, with location on", () => {
    const far = full({ docs: { ...full().docs, shopPhoto1: photo("shop1", pin.lat + 0.01) } });
    expect(sellerApplicationProblems(far, true, now)).toEqual(["Shop photos must be taken at the shop"]);
    const noGps = full({ docs: { ...full().docs, shopPhoto1: { path: "sellers/u1/kyc/shop1.jpg" } } });
    expect(sellerApplicationProblems(noGps, true, now)).toEqual(["Shop photos must be taken with location on"]);
  });

  it("checks PAN, GSTIN against PAN and FSSAI", () => {
    expect(sellerApplicationProblems(full({ gstin: "19ZZZZZ9999Z1Z5" }), true, now)).toEqual(["GSTIN doesn't match the PAN"]);
    expect(sellerApplicationProblems(full({ fssaiExpiry: "2026-01-01" }), true, now)).toEqual(["Your FSSAI licence has expired"]);
    expect(sellerApplicationProblems(full({ pan: "1234" }), true, now)).toContain("PAN looks wrong (e.g. ABCDE1234F)");
  });

  it("doesn't need FSSAI for a stationery shop", () => {
    const a = full({ shopCategory: "stationery", fssaiNo: "", fssaiExpiry: "", docs: { ...full().docs, fssaiCertificate: undefined } });
    expect(sellerApplicationProblems(a, true, now)).toEqual([]);
  });

  it("needs a plan only for subscription sellers", () => {
    expect(sellerApplicationProblems(full({ planId: "" }), true, now)).toEqual(["Choose a subscription plan"]);
    expect(sellerApplicationProblems(full({ model: "supply", planId: "" }), true, now)).toEqual([]);
  });
});

describe("plans, ids, geo", () => {
  it("validates plans", () => {
    expect(planProblems(readPlan({ name: "Quarterly", months: 3, feePaise: 149900 }))).toEqual([]);
    expect(planProblems(readPlan({ name: "X", months: 2, feePaise: -1 }))).toEqual([
      "Plan name is required",
      "A plan is 1, 3 or 6 months",
      "Fee must be ₹0–₹1,00,000",
    ]);
  });

  it("builds listing and stock ids (Zyppi's stock rows keep their old ids)", () => {
    expect(listingIdFor("u1", "purulia", "v1")).toBe("u1_purulia_v1");
    expect(inventoryIdFor("s1", "zyppi", "v1")).toBe("s1_v1");
    expect(inventoryIdFor("s1", undefined, "v1")).toBe("s1_v1");
    expect(inventoryIdFor("seller_u1", "u1", "v1")).toBe("seller_u1_u1_v1");
  });

  it("treats stores without a seller as Zyppi's", () => {
    expect(isZyppiStore(undefined)).toBe(true);
    expect(isZyppiStore("zyppi")).toBe(true);
    expect(isZyppiStore("u1")).toBe(false);
  });

  it("measures distance", () => {
    expect(Math.round(metresBetween(pin, { lat: pin.lat + 0.0004, lng: pin.lng }))).toBe(44);
  });
});
