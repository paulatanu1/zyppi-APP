import { Timestamp } from "firebase-admin/firestore";
import { describe, expect, it } from "vitest";
import { bannerItem, validateBanner } from "../../src/home/home";

const base = {
  title: "Fresh fruits, flat 20% off",
  ctaText: "Shop now",
  linkType: "category",
  linkTarget: "cat-1",
  imageUrl: "https://example.com/a.webp",
};

describe("validateBanner", () => {
  it("accepts a full banner and defaults to on, everywhere, always", () => {
    expect(validateBanner(base, 1)).toMatchObject({
      title: base.title,
      linkType: "category",
      linkTarget: "cat-1",
      startAtMs: null,
      endAtMs: null,
      serviceAreaIds: [],
      isActive: true,
    });
  });

  it("names the banner in its errors", () => {
    expect(() => validateBanner({ ...base, title: "x" }, 3)).toThrow(/^Banner 3: the headline/);
  });

  it("needs a target unless it opens nothing", () => {
    expect(() => validateBanner({ ...base, linkTarget: "" }, 1)).toThrow(/choose the category/);
    expect(validateBanner({ ...base, linkType: "none", linkTarget: "cat-1" }, 1).linkTarget).toBe(
      null,
    );
    expect(() => validateBanner({ ...base, linkType: "url", linkTarget: "http://x.y" }, 1)).toThrow(
      /https/,
    );
  });

  it("refuses plain-http images outside the emulator", () => {
    expect(() => validateBanner({ ...base, imageUrl: "http://127.0.0.1:9199/a.png" }, 1)).toThrow(
      /image/,
    );
  });

  it("checks the schedule order and de-duplicates areas", () => {
    expect(() => validateBanner({ ...base, startAtMs: 2000, endAtMs: 1000 }, 1)).toThrow(
      /end must be after/,
    );
    expect(validateBanner({ ...base, serviceAreaIds: ["a", "a", "b", 3] }, 1).serviceAreaIds).toEqual([
      "a",
      "b",
    ]);
  });
});

describe("bannerItem", () => {
  it("stores the app's snake_case data keys and timestamps", () => {
    const item = bannerItem({
      ...validateBanner({ ...base, id: "b1", startAtMs: 1000, endAtMs: 5000 }, 1),
    });
    expect(item).toMatchObject({
      id: "b1",
      data: {
        title: base.title,
        cta_text: "Shop now",
        link_type: "category",
        link_target: "cat-1",
        image_url: base.imageUrl,
      },
      serviceAreaIds: [],
      isActive: true,
    });
    expect((item.startAt as Timestamp).toMillis()).toBe(1000);
    expect((item.endAt as Timestamp).toMillis()).toBe(5000);
  });

  it("stores no link type for banners that open nothing, and makes an id for new ones", () => {
    const item = bannerItem(validateBanner({ ...base, linkType: "none" }, 1));
    expect(item.data.link_type).toBeNull();
    expect(item.id).toMatch(/^[\w-]{36}$/);
  });
});
