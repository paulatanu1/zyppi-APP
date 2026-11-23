import { readFileSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { type FetchLike, OFF_FIELDS, fetchOffProduct, offProductUrl } from "../../src/catalog/off_client";
import { mapOffProduct, readNutrition, readQuantity, readableTags } from "../../src/catalog/off_map";

const fixture = (name: string) => readFileSync(join(__dirname, "fixtures/off", `${name}.json`), "utf8");

function respond(status: number, body: string, url = ""): FetchLike {
  return async () => {
    const res = new Response(body, { status });
    if (url) Object.defineProperty(res, "url", { value: url });
    return res;
  };
}

const ua = "ZyppiSeller/1.0 (https://zyppi.in)";

describe("Open Food Facts client (v3)", () => {
  it("asks only for the fields it maps, across all four databases, with our User-Agent", async () => {
    let seen: { url: string; init: RequestInit; timeout: number } | null = null;
    await fetchOffProduct("3017620422003", {
      userAgent: ua,
      fetch: async (url, init, timeout) => {
        seen = { url, init, timeout };
        return new Response(fixture("nutella"), { status: 200 });
      },
    });
    expect(seen!.url).toBe(offProductUrl("3017620422003"));
    expect(seen!.url).toContain("/api/v3/product/3017620422003?product_type=all&fields=");
    expect(seen!.url).toContain(OFF_FIELDS);
    expect((seen!.init.headers as Record<string, string>)["User-Agent"]).toBe(ua);
    expect(seen!.timeout).toBe(6000);
  });

  it("found", async () => {
    const r = await fetchOffProduct("3017620422003", { userAgent: ua, fetch: respond(200, fixture("nutella")) });
    expect(r.kind).toBe("found");
  });

  it("404 with product_not_found is not found", async () => {
    expect(await fetchOffProduct("8901234567892", { userAgent: ua, fetch: respond(404, fixture("notfound")) })).toEqual({ kind: "not_found" });
  });

  it("429 / 503 / 5xx are rate limiting or outage, never not found", async () => {
    expect(await fetchOffProduct("1", { userAgent: ua, fetch: respond(429, "") })).toEqual({ kind: "unavailable", reason: "rate_limited", status: 429 });
    expect(await fetchOffProduct("1", { userAgent: ua, fetch: respond(503, "<html>") })).toEqual({ kind: "unavailable", reason: "outage", status: 503 });
    expect(await fetchOffProduct("1", { userAgent: ua, fetch: respond(502, "") })).toMatchObject({ reason: "outage" });
  });

  it("a bare 404 page or non-JSON body is a fault, not 'not found'", async () => {
    expect(await fetchOffProduct("1", { userAgent: ua, fetch: respond(404, "<html>nope</html>") })).toMatchObject({ kind: "unavailable", reason: "bad_response" });
    expect(await fetchOffProduct("1", { userAgent: ua, fetch: respond(200, "{bad") })).toMatchObject({ kind: "unavailable", reason: "bad_response" });
    expect(await fetchOffProduct("1", { userAgent: ua, fetch: respond(200, "{}") })).toMatchObject({ kind: "unavailable", reason: "bad_response" });
  });

  it("timeouts and network errors", async () => {
    const timeout: FetchLike = async () => {
      throw Object.assign(new Error("t"), { name: "TimeoutError" });
    };
    const offline: FetchLike = async () => {
      throw new TypeError("fetch failed");
    };
    expect(await fetchOffProduct("1", { userAgent: ua, fetch: timeout })).toEqual({ kind: "unavailable", reason: "timeout" });
    expect(await fetchOffProduct("1", { userAgent: ua, fetch: offline })).toEqual({ kind: "unavailable", reason: "network" });
  });

  it("remembers which database answered (redirect to a sister site)", async () => {
    const r = await fetchOffProduct("3560070791460", {
      userAgent: ua,
      fetch: respond(200, JSON.stringify({ product: { product_name: "Shampoo" } }), "https://world.openbeautyfacts.org/api/v3/product/3560070791460"),
    });
    expect(r).toMatchObject({ kind: "found", host: "world.openbeautyfacts.org" });
    const p = mapOffProduct((r as { product: Record<string, unknown> }).product, "03560070791460", "3560070791460", "world.openbeautyfacts.org");
    expect(p.provider).toBe("openbeautyfacts");
    expect(p.sourceUrl).toBe("https://world.openbeautyfacts.org/product/3560070791460");
  });
});

describe("mapping to the normalized product", () => {
  it("Nutella (recorded response)", () => {
    const p = mapOffProduct(JSON.parse(fixture("nutella")).product, "03017620422003", "3017620422003", "world.openfoodfacts.org");
    expect(p).toMatchObject({
      gtin: "03017620422003",
      provider: "openfoodfacts",
      sourceUrl: "https://world.openfoodfacts.org/product/3017620422003",
      brand: "Ferrero",
      genericName: "Hazelnut And Cocoa Spread",
      quantity: { value: 400, unit: "g" },
      allergens: ["milk", "nuts", "soybeans"],
    });
    expect(p.imageUrl).toMatch(/^https:\/\/images\.openfoodfacts\.org\//);
    expect(p.nutrition).toEqual({
      basis: "per100g",
      energyKcal: 539,
      energyKj: 2252,
      fat: 30.9,
      saturatedFat: 10.6,
      carbohydrates: 57.5,
      sugars: 56.3,
      fibre: 0,
      protein: 6.3,
      salt: 0.11,
    });
  });

  it("Maggi, an Indian 890 product (no numeric quantity)", () => {
    const p = mapOffProduct(JSON.parse(fixture("maggi")).product, "08901058851298", "8901058851298", "world.openfoodfacts.org");
    expect(p.brand).toBe("Maggi");
    expect(p.quantity).toBeNull();
    expect(p.quantityText).toBe("1 unit");
    expect(p.ingredients).not.toMatch(/[\r\n]/);
    // OFF has 437 kcal but 1545 kJ (≈ 369 kcal): kJ is dropped, kcal kept for review.
    expect(p.nutrition).toMatchObject({ basis: "per100g", energyKcal: 437, fat: 15.7, salt: 3.08 });
    expect(p.nutrition?.energyKj).toBeUndefined();
  });

  it("a sparse / null record keeps nulls and empty lists, never guesses", () => {
    const p = mapOffProduct({ product_name: null, brands: 7, nutriments: "x", allergens_tags: [1, "bad tag", "en:milk"] }, "0", "0", "world.openfoodfacts.org");
    expect(p).toMatchObject({
      name: null,
      brand: null,
      genericName: null,
      imageUrl: null,
      quantity: null,
      nutrition: null,
      origin: null,
      allergens: ["milk"],
      labels: [],
      categoryHints: [],
    });
  });

  it("strips markup and control characters; caps lengths", () => {
    const p = mapOffProduct(
      { product_name: "<b>Tea</b>\u0007 Leaves", ingredients_text: "x".repeat(5000), image_front_url: "https://evil.example/a.jpg" },
      "0",
      "0",
      "world.openfoodfacts.org",
    );
    expect(p.name).toBe("Tea Leaves");
    expect(p.ingredients).toHaveLength(3000);
    expect(p.imageUrl).toBeNull();
  });

  it("quantity: numeric fields first, else text; cl → ml", () => {
    expect(readQuantity({ product_quantity: "500", product_quantity_unit: "ml" })).toEqual({ value: 500, unit: "ml" });
    expect(readQuantity({ quantity: "1.5 L" })).toEqual({ value: 1.5, unit: "l" });
    expect(readQuantity({ quantity: "33 cl" })).toEqual({ value: 330, unit: "ml" });
    expect(readQuantity({ quantity: "a box" })).toBeNull();
  });

  it("nutrition: per 100 ml for drinks, per serving with its size, drops bad values", () => {
    expect(readNutrition({ nutriments: { "sugars_100g": 10.6, "carbohydrates_100g": 10.6 } }, true)).toEqual({ basis: "per100ml", sugars: 10.6, carbohydrates: 10.6 });
    expect(readNutrition({ nutriments: { "fat_serving": 4 }, serving_size: "30 g" }, false)).toEqual({ basis: "perServing", servingSize: "30 g", fat: 4 });
    expect(readNutrition({ nutriments: { "fat_serving": 4 } }, false)).toBeNull(); // per serving without the size
    expect(readNutrition({ nutriments: { "fat_100g": 140, "protein_100g": 3, "proteins_100g": 3 } }, false)).toEqual({ basis: "per100g", protein: 3 });
    // inconsistent pairs: the less trustworthy value goes
    expect(readNutrition({ nutriments: { "energy-kcal_100g": 100, "energy-kj_100g": 2000 } }, false)).toEqual({ basis: "per100g", energyKcal: 100 });
    expect(readNutrition({ nutriments: { "sugars_100g": 50, "carbohydrates_100g": 10 } }, false)).toEqual({ basis: "per100g", carbohydrates: 10 });
    // macros over 100 g per 100 g: the table is unusable
    expect(readNutrition({ nutriments: { "fat_100g": 60, "carbohydrates_100g": 60 } }, false)).toBeNull();
  });

  it("tags read as plain words", () => {
    expect(readableTags(["en:gluten-free", "fr:triman", "en:gluten-free", "<script>"])).toEqual(["gluten free", "triman"]);
  });
});
