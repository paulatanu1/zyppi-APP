import { Timestamp } from "firebase-admin/firestore";
import { describe, expect, it } from "vitest";
import { campaignMessage } from "../../src/notifications/campaigns";
import {
  type Recipient,
  type Segment,
  copyFor,
  matchesSegment,
  toRecipient,
  validateCampaign,
  validateSegment,
} from "../../src/notifications/model";

const NOW = Date.UTC(2026, 10, 14);
const DAY = 86_400_000;
const person = (over: Partial<Recipient> = {}): Recipient => ({
  uid: "u1",
  token: "t1",
  lang: "en",
  serviceAreaId: "a1",
  orderCount: 2,
  totalSpentPaise: 90000,
  lastOrderAtMs: NOW - 10 * DAY,
  ...over,
});
const seg = (over: Partial<Segment> = {}): Segment => ({
  serviceAreaIds: [],
  langs: [],
  behaviour: "any",
  value: null,
  ...over,
});
const valid = {
  name: "Weekend fruit",
  copy: { title: "Fresh mangoes are in", body: "20% off till Sunday" },
  linkType: "product",
  linkTarget: "p1",
  segment: { behaviour: "any" },
};

describe("toRecipient", () => {
  it("takes only opted-in, unblocked users with a device", () => {
    const d = { notifyOffers: true, fcmToken: "t", lang: "bn", orderCount: 3, lastOrderAt: Timestamp.fromMillis(NOW) };
    expect(toRecipient("u", d)).toMatchObject({ lang: "bn", orderCount: 3, lastOrderAtMs: NOW });
    expect(toRecipient("u", { ...d, notifyOffers: false })).toBeNull();
    expect(toRecipient("u", { ...d, blocked: true })).toBeNull();
    expect(toRecipient("u", { ...d, fcmToken: null })).toBeNull();
  });

  it("defaults unknown languages to English and missing counters to zero", () => {
    expect(toRecipient("u", { notifyOffers: true, fcmToken: "t", lang: "fr" })).toMatchObject({
      lang: "en",
      orderCount: 0,
      lastOrderAtMs: null,
    });
  });
});

describe("matchesSegment", () => {
  it("filters by area and language", () => {
    expect(matchesSegment(person(), seg({ serviceAreaIds: ["a2"] }), NOW)).toBe(false);
    expect(matchesSegment(person({ serviceAreaId: null }), seg({ serviceAreaIds: ["a1"] }), NOW)).toBe(false);
    expect(matchesSegment(person({ lang: "hi" }), seg({ langs: ["hi", "bn"] }), NOW)).toBe(true);
  });

  it("splits by order behaviour", () => {
    expect(matchesSegment(person({ orderCount: 0 }), seg({ behaviour: "never_ordered" }), NOW)).toBe(true);
    expect(matchesSegment(person(), seg({ behaviour: "ordered_within_days", value: 7 }), NOW)).toBe(false);
    expect(matchesSegment(person(), seg({ behaviour: "ordered_within_days", value: 30 }), NOW)).toBe(true);
    expect(matchesSegment(person(), seg({ behaviour: "inactive_days", value: 7 }), NOW)).toBe(true);
    expect(matchesSegment(person({ lastOrderAtMs: null }), seg({ behaviour: "inactive_days", value: 7 }), NOW)).toBe(false);
    expect(matchesSegment(person(), seg({ behaviour: "min_orders", value: 3 }), NOW)).toBe(false);
    expect(matchesSegment(person(), seg({ behaviour: "min_spent", value: 90000 }), NOW)).toBe(true);
  });
});

describe("validateCampaign", () => {
  it("keeps only filled-in translations and upper-cases coupon links", () => {
    const c = validateCampaign({
      ...valid,
      translations: { bn: { title: "আম এসে গেছে", body: "রবিবার পর্যন্ত ২০% ছাড়" }, hi: { title: "", body: "" } },
      linkType: "coupon",
      linkTarget: "fresh20",
    });
    expect(Object.keys(c.translations)).toEqual(["bn"]);
    expect(c.linkTarget).toBe("FRESH20");
  });

  it("rejects missing copy, half-filled translations and bad links", () => {
    expect(() => validateCampaign({ ...valid, copy: { title: "Hi" } })).toThrow(/English: the message/);
    expect(() => validateCampaign({ ...valid, translations: { hi: { title: "Only title" } } })).toThrow(/Hindi/);
    expect(() => validateCampaign({ ...valid, linkType: "url", linkTarget: "http://x" })).toThrow(/https/);
    expect(() => validateCampaign({ ...valid, linkTarget: "" })).toThrow(/product/);
  });

  it("needs a number for behaviour segments", () => {
    expect(() => validateSegment({ behaviour: "inactive_days" })).toThrow(/days/);
    expect(validateSegment({ behaviour: "never_ordered", value: 9 }).value).toBeNull();
    expect(validateSegment({ langs: ["bn", "xx", "bn"] }).langs).toEqual(["bn"]);
  });
});

describe("copy and message", () => {
  const c = validateCampaign({
    ...valid,
    imageUrl: "https://x.y/a.webp",
    translations: { hi: { title: "आम आ गए", body: "रविवार तक 20% छूट" } },
  });

  it("uses the user's language, English otherwise", () => {
    expect(copyFor(c, "hi").title).toBe("आम आ गए");
    expect(copyFor(c, "pa").title).toBe("Fresh mangoes are in");
  });

  it("carries the deep link as string data and the image for Android", () => {
    const m = campaignMessage("c1", c, "en", ["t1", "t2"]);
    expect(m.tokens).toEqual(["t1", "t2"]);
    expect(m.data).toEqual({ campaignId: "c1", linkType: "product", linkTarget: "p1" });
    expect(m.notification).toMatchObject({ title: "Fresh mangoes are in", imageUrl: "https://x.y/a.webp" });
    expect(m.android?.notification?.imageUrl).toBe("https://x.y/a.webp");
  });
});
