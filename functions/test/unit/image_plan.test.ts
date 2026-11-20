import { describe, expect, it } from "vitest";
import { SMALL_ENOUGH, isExternalImage, planFor, worthReplacing } from "../../scripts/image-plan";

describe("planFor", () => {
  it("re-encodes big or non-WebP catalogue images", () => {
    expect(planFor({ name: "banners/a.jpg", contentType: "image/jpeg", size: 900_000 })).toEqual({
      action: "reencode",
      maxSide: 1200,
    });
    expect(planFor({ name: "catalog/products/b.png", contentType: "image/png", size: 50_000 })).toEqual({
      action: "reencode",
      maxSide: 1000,
    });
    expect(
      planFor({ name: "catalog/x.webp", contentType: "image/webp", size: SMALL_ENOUGH + 1 }).action,
    ).toBe("reencode");
  });

  it("only adds the cache header to small WebP files without one", () => {
    expect(planFor({ name: "banners/a.webp", contentType: "image/webp", size: 80_000 })).toEqual({
      action: "cache-header",
    });
    expect(
      planFor({ name: "banners/a.webp", contentType: "image/webp", size: 80_000, cacheControl: "public" })
        .action,
    ).toBe("skip");
  });

  it("leaves backups, other folders, SVG/GIF and non-images alone", () => {
    expect(planFor({ name: "_originals/banners/a.jpg", contentType: "image/jpeg", size: 1e6 }).action).toBe("skip");
    expect(planFor({ name: "riders/doc.jpg", contentType: "image/jpeg", size: 1e6 }).action).toBe("skip");
    expect(planFor({ name: "banners/a.gif", contentType: "image/gif", size: 1e6 }).action).toBe("skip");
    expect(planFor({ name: "catalog/a.pdf", contentType: "application/pdf", size: 1e6 }).action).toBe("skip");
  });
});

describe("worthReplacing", () => {
  it("needs at least 10% saved", () => {
    expect(worthReplacing(100_000, 80_000)).toBe(true);
    expect(worthReplacing(100_000, 95_000)).toBe(false);
  });
});

describe("isExternalImage", () => {
  it("flags https images not on Firebase Storage", () => {
    expect(isExternalImage("https://example.com/a.jpg")).toBe(true);
    expect(isExternalImage("https://firebasestorage.googleapis.com/v0/b/x/o/a")).toBe(false);
    expect(isExternalImage("https://storage.googleapis.com/x/a")).toBe(false);
    expect(isExternalImage(null)).toBe(false);
    expect(isExternalImage("http://insecure.com/a.jpg")).toBe(false);
  });
});
