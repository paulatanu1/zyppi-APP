import {
  MAX_BRAND,
  NUTRIENTS,
  type Nutrient,
  type Nutrition,
  type Provider,
  type QuantityUnit,
  cleanText,
  nutritionProblems,
} from "./details";

/**
 * Open Food Facts product JSON → Zyppi's normalized lookup result. Every
 * field is optional upstream and may be wrong; this keeps only plain,
 * bounded values (null when missing) and never the raw JSON. The seller
 * reviews all of it before anything reaches the catalogue.
 */
export interface NormalizedProduct {
  gtin: string;
  provider: Provider;
  /** Attribution link (ODbL): the product page on the provider's site. */
  sourceUrl: string;
  name: string | null;
  genericName: string | null;
  brand: string | null;
  /** Reference only (CC BY-SA): never copied to Zyppi storage. */
  imageUrl: string | null;
  categoryHints: string[];
  quantity: { value: number; unit: QuantityUnit } | null;
  quantityText: string | null;
  packaging: string | null;
  ingredients: string | null;
  allergens: string[];
  nutrition: Nutrition | null;
  origin: string | null;
  labels: string[];
}

const HOST_PROVIDER: Record<string, Provider> = {
  openfoodfacts: "openfoodfacts",
  openbeautyfacts: "openbeautyfacts",
  openpetfoodfacts: "openpetfoodfacts",
  openproductsfacts: "openproductsfacts",
};

export function providerOf(host: string): Provider {
  const m = /(open(?:food|beauty|petfood|products)facts)\.org$/.exec(host);
  return (m && HOST_PROVIDER[m[1]]) || "openfoodfacts";
}

/** "en:gluten-free" → "gluten free"; keeps at most `max`. */
export function readableTags(v: unknown, max = 20): string[] {
  if (!Array.isArray(v)) return [];
  const out: string[] = [];
  for (const t of v) {
    if (typeof t !== "string" || !/^[a-z]{2,3}:[\p{L}\p{N}-]{1,60}$/u.test(t)) continue;
    const s = t.replace(/^[a-z]{2,3}:/, "").replace(/-/g, " ").trim();
    if (s && !out.includes(s)) out.push(s);
    if (out.length >= max) break;
  }
  return out;
}

function num(v: unknown): number | null {
  if (typeof v === "number" && Number.isFinite(v)) return v;
  if (typeof v === "string" && /^\d+(\.\d+)?$/.test(v.trim())) return Number(v);
  return null;
}

/** product_quantity + unit, else the "500 g" text. ml/l/g/kg only. */
export function readQuantity(p: Record<string, unknown>): { value: number; unit: QuantityUnit } | null {
  const units: Record<string, QuantityUnit> = { g: "g", gr: "g", kg: "kg", ml: "ml", l: "l", lt: "l", ltr: "l" };
  const fromText = (s: string) => {
    const m = /(\d+(?:[.,]\d+)?)\s*(kg|gr|g|ml|cl|ltr|lt|l)\b/i.exec(s);
    if (!m) return null;
    let value = Number(m[1].replace(",", "."));
    let unit = m[2].toLowerCase();
    if (unit === "cl") {
      value *= 10;
      unit = "ml";
    }
    return { value, unit: units[unit] };
  };
  const q = num(p.product_quantity);
  const u = typeof p.product_quantity_unit === "string" ? units[p.product_quantity_unit.toLowerCase()] : undefined;
  let out: { value: number; unit: QuantityUnit } | null = q && q > 0 ? { value: q, unit: u ?? "g" } : null;
  if (!out && typeof p.quantity === "string") out = fromText(p.quantity);
  if (!out || !(out.value > 0) || out.value > 100_000 || !out.unit) return null;
  return { value: Math.round(out.value * 100) / 100, unit: out.unit };
}

const OFF_KEYS: Record<Nutrient, string> = {
  energyKcal: "energy-kcal",
  energyKj: "energy-kj",
  fat: "fat",
  saturatedFat: "saturated-fat",
  carbohydrates: "carbohydrates",
  sugars: "sugars",
  fibre: "fiber",
  protein: "proteins",
  salt: "salt",
};

/**
 * Per 100 g / ml when OFF has it (its normalized figures), else per serving
 * with the serving size. Out-of-range values are dropped; if what is left
 * is still inconsistent (kcal vs kJ, sugars > carbs …) nothing is kept.
 */
export function readNutrition(p: Record<string, unknown>, liquid: boolean): Nutrition | null {
  const n = p.nutriments;
  if (!n || typeof n !== "object") return null;
  const nut = n as Record<string, unknown>;
  const pick = (suffix: string) => {
    const out: Partial<Record<Nutrient, number>> = {};
    for (const k of NUTRIENTS) {
      const v = num(nut[`${OFF_KEYS[k]}${suffix}`]);
      if (v !== null && v >= 0) out[k] = Math.round(v * 100) / 100;
    }
    if (out.energyKj === undefined && nut[`energy_unit`] === "kJ") {
      const e = num(nut[`energy${suffix}`]);
      if (e !== null && e >= 0) out.energyKj = Math.round(e * 100) / 100;
    }
    return out;
  };
  let values = pick("_100g");
  let result: Nutrition;
  if (Object.keys(values).length) {
    result = { basis: liquid ? "per100ml" : "per100g", ...values };
  } else {
    values = pick("_serving");
    const serving = cleanText(p.serving_size, 40);
    if (!Object.keys(values).length || !serving) return null;
    result = { basis: "perServing", servingSize: serving, ...values };
  }
  // Drop single values out of range, then the less trustworthy side of an
  // inconsistent pair (Indian labels print kcal; kJ is often derived).
  for (const k of NUTRIENTS) {
    if (result[k] !== undefined && nutritionProblems({ basis: result.basis, [k]: result[k] }).length) delete result[k];
  }
  if (result.energyKcal !== undefined && result.energyKj !== undefined) {
    if (nutritionProblems({ basis: result.basis, energyKcal: result.energyKcal, energyKj: result.energyKj }).length) delete result.energyKj;
  }
  if (result.sugars !== undefined && result.carbohydrates !== undefined && result.sugars > result.carbohydrates + 0.1) delete result.sugars;
  if (result.saturatedFat !== undefined && result.fat !== undefined && result.saturatedFat > result.fat + 0.1) delete result.saturatedFat;
  if (!NUTRIENTS.some((k) => result[k] !== undefined)) return null;
  // Whatever is still wrong (macros over 100 g) means the table is unusable.
  return nutritionProblems(result).length ? null : result;
}

function imageOk(v: unknown): string | null {
  if (typeof v !== "string" || v.length > 500) return null;
  try {
    const u = new URL(v);
    return u.protocol === "https:" && /^images\.open(food|beauty|petfood|products)facts\.org$/.test(u.hostname) ? v : null;
  } catch {
    return null;
  }
}

function firstBrand(v: unknown): string | null {
  if (typeof v !== "string") return null;
  return cleanText(v.split(",")[0], MAX_BRAND);
}

export function mapOffProduct(p: Record<string, unknown>, gtin: string, offCode: string, host: string): NormalizedProduct {
  const provider = providerOf(host);
  const quantity = readQuantity(p);
  const liquid = quantity?.unit === "ml" || quantity?.unit === "l";
  const site = `world.${provider}.org`;
  return {
    gtin,
    provider,
    sourceUrl: `https://${site}/product/${offCode}`,
    name: cleanText(p.product_name, 120) ?? cleanText(p.product_name_en, 120),
    genericName: cleanText(p.generic_name, 120) ?? cleanText(p.generic_name_en, 120),
    brand: firstBrand(p.brands),
    imageUrl: imageOk(p.image_front_url),
    // Most specific last in OFF; only a hint, staff/seller pick the category.
    categoryHints: readableTags(p.categories_tags, 50).slice(-5).reverse(),
    quantity,
    quantityText: cleanText(p.quantity, 40),
    packaging: cleanText(p.packaging_text, 120) ?? cleanText(p.packaging, 120),
    ingredients: cleanText(p.ingredients_text, 3000) ?? cleanText(p.ingredients_text_en, 3000),
    allergens: readableTags(p.allergens_tags),
    nutrition: readNutrition(p, liquid),
    origin: cleanText(p.origins, 120),
    labels: readableTags(p.labels_tags),
  };
}
