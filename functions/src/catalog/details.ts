/**
 * Optional product details (docs/BARCODES.md): pack quantity, ingredients,
 * allergens, nutrition, origin, labels, plus per-field provenance and the
 * Open Food Facts attribution. Everything here is reviewed by a person
 * before it is stored; none of it is trusted as "verified".
 *
 * Shared by the admin editor (adminSaveProduct), seller requests
 * (sellerSubmitProduct) and the OFF mapper (off_map.ts).
 */

export const QUANTITY_UNITS = ["g", "kg", "ml", "l", "pcs"] as const;
export type QuantityUnit = (typeof QUANTITY_UNITS)[number];

export const NUTRITION_BASES = ["per100g", "per100ml", "perServing"] as const;
export type NutritionBasis = (typeof NUTRITION_BASES)[number];

/** Grams (energy in kcal / kJ) for the basis. */
export const NUTRIENTS = [
  "energyKcal",
  "energyKj",
  "fat",
  "saturatedFat",
  "carbohydrates",
  "sugars",
  "fibre",
  "protein",
  "salt",
] as const;
export type Nutrient = (typeof NUTRIENTS)[number];

export interface Nutrition extends Partial<Record<Nutrient, number>> {
  basis: NutritionBasis;
  servingSize?: string;
}

export const DETAIL_FIELDS = [
  "name",
  "brand",
  "genericName",
  "quantity",
  "packaging",
  "ingredients",
  "allergens",
  "nutrition",
  "origin",
  "labels",
  "image",
] as const;
export type DetailField = (typeof DETAIL_FIELDS)[number];

/** off: as Open Food Facts gave it; off_edited: corrected by a person; manual: typed in. */
export const PROVENANCE = ["off", "off_edited", "manual"] as const;
export type Provenance = (typeof PROVENANCE)[number];

export const PROVIDERS = ["openfoodfacts", "openbeautyfacts", "openpetfoodfacts", "openproductsfacts"] as const;
export type Provider = (typeof PROVIDERS)[number];

export interface DetailsSource {
  provider: Provider;
  url: string;
  fetchedAt: string;
}

export interface ProductDetails {
  genericName?: string;
  quantity?: { value: number; unit: QuantityUnit };
  packaging?: string;
  ingredients?: string;
  allergens?: string[];
  nutrition?: Nutrition;
  origin?: string;
  labels?: string[];
  provenance?: Partial<Record<DetailField, Provenance>>;
  source?: DetailsSource;
}

export const MAX_BRAND = 60;
const MAX_SHORT = 120;
const MAX_INGREDIENTS = 3000;
const MAX_TAGS = 20;
const MAX_TAG = 40;

/** Upper bounds per 100 g / ml (energy in kcal / kJ); per serving uses ×10. */
const LIMIT_100: Record<Nutrient, number> = {
  energyKcal: 900,
  energyKj: 3800,
  fat: 100,
  saturatedFat: 100,
  carbohydrates: 100,
  sugars: 100,
  fibre: 100,
  protein: 100,
  salt: 100,
};

/** Plain text: no tags or control characters, single-spaced, capped. Null if empty. */
export function cleanText(v: unknown, max: number): string | null {
  if (typeof v !== "string") return null;
  const s = v
    .replace(/<[^>]*>/g, " ")
    // eslint-disable-next-line no-control-regex
    .replace(/[\u0000-\u001f\u007f]/g, " ")
    .replace(/\s+/g, " ")
    .trim();
  if (!s) return null;
  return s.length > max ? s.slice(0, max).trim() : s;
}

function cleanTags(v: unknown): string[] | null {
  if (!Array.isArray(v)) return null;
  const out: string[] = [];
  for (const t of v) {
    const s = cleanText(t, MAX_TAG);
    if (s && !out.some((o) => o.toLowerCase() === s.toLowerCase())) out.push(s);
    if (out.length >= MAX_TAGS) break;
  }
  return out;
}

const isNum = (v: unknown): v is number => typeof v === "number" && Number.isFinite(v);
const round = (v: number) => Math.round(v * 100) / 100;

/** Field-level problems for nutrition (unit, basis, ranges, consistency). */
export function nutritionProblems(n: Nutrition): string[] {
  const out: string[] = [];
  const scale = n.basis === "perServing" ? 10 : 1;
  for (const k of NUTRIENTS) {
    const v = n[k];
    if (v === undefined) continue;
    if (!isNum(v) || v < 0 || v > LIMIT_100[k] * scale) out.push(`Nutrition: ${k} is out of range`);
  }
  if (n.basis !== "perServing") {
    const macros = (n.fat ?? 0) + (n.carbohydrates ?? 0) + (n.protein ?? 0) + (n.fibre ?? 0) + (n.salt ?? 0);
    if (macros > 105) out.push("Nutrition: fat + carbohydrates + protein + fibre + salt is over 100 g");
  }
  if (n.saturatedFat !== undefined && n.fat !== undefined && n.saturatedFat > n.fat + 0.1) {
    out.push("Nutrition: saturated fat can't be more than fat");
  }
  if (n.sugars !== undefined && n.carbohydrates !== undefined && n.sugars > n.carbohydrates + 0.1) {
    out.push("Nutrition: sugars can't be more than carbohydrates");
  }
  if (isNum(n.energyKcal) && isNum(n.energyKj) && n.energyKcal > 0) {
    const ratio = n.energyKj / n.energyKcal;
    if (ratio < 4.184 * 0.85 || ratio > 4.184 * 1.15) out.push("Nutrition: kcal and kJ don't match");
  }
  return out;
}

/**
 * Reads client-sent details into the stored shape, dropping unknown keys.
 * Returns the problems a person must fix (bad numbers aren't silently kept).
 */
export function readDetails(raw: unknown): { details: ProductDetails | null; problems: string[] } {
  if (raw == null) return { details: null, problems: [] };
  if (typeof raw !== "object" || Array.isArray(raw)) return { details: null, problems: ["Details are invalid"] };
  const r = raw as Record<string, unknown>;
  const problems: string[] = [];
  const d: ProductDetails = {};

  const genericName = cleanText(r.genericName, MAX_SHORT);
  if (genericName) d.genericName = genericName;
  const packaging = cleanText(r.packaging, MAX_SHORT);
  if (packaging) d.packaging = packaging;
  const origin = cleanText(r.origin, MAX_SHORT);
  if (origin) d.origin = origin;
  if (typeof r.ingredients === "string" && r.ingredients.length > MAX_INGREDIENTS * 2) {
    problems.push(`Ingredients are over ${MAX_INGREDIENTS} characters`);
  }
  const ingredients = cleanText(r.ingredients, MAX_INGREDIENTS);
  if (ingredients) d.ingredients = ingredients;
  const allergens = cleanTags(r.allergens);
  if (allergens?.length) d.allergens = allergens;
  const labels = cleanTags(r.labels);
  if (labels?.length) d.labels = labels;

  if (r.quantity != null) {
    const q = r.quantity as Record<string, unknown>;
    const unit = q?.unit as QuantityUnit;
    if (!isNum(q?.value) || q.value <= 0 || q.value > 100_000 || !QUANTITY_UNITS.includes(unit)) {
      problems.push("Quantity needs a number and a unit (g, kg, ml, l, pcs)");
    } else {
      d.quantity = { value: round(q.value), unit };
    }
  }

  if (r.nutrition != null) {
    const n = r.nutrition as Record<string, unknown>;
    const basis = n?.basis as NutritionBasis;
    if (!NUTRITION_BASES.includes(basis)) {
      problems.push("Nutrition needs a basis (per 100 g, per 100 ml or per serving)");
    } else {
      const out: Nutrition = { basis };
      for (const k of NUTRIENTS) {
        const v = n[k];
        if (v == null || v === "") continue;
        if (!isNum(v)) problems.push(`Nutrition: ${k} must be a number`);
        else out[k] = round(v);
      }
      const serving = cleanText(n.servingSize, 40);
      if (serving) out.servingSize = serving;
      if (basis === "perServing" && !serving) problems.push("Nutrition per serving needs the serving size");
      problems.push(...nutritionProblems(out));
      if (NUTRIENTS.some((k) => out[k] !== undefined)) d.nutrition = out;
    }
  }

  if (r.provenance != null && typeof r.provenance === "object") {
    const prov: Partial<Record<DetailField, Provenance>> = {};
    for (const f of DETAIL_FIELDS) {
      const p = (r.provenance as Record<string, unknown>)[f] as Provenance;
      if (PROVENANCE.includes(p)) prov[f] = p;
    }
    if (Object.keys(prov).length) d.provenance = prov;
  }

  if (r.source != null) {
    const s = r.source as Record<string, unknown>;
    const provider = s?.provider as Provider;
    const fetchedAt = cleanText(s?.fetchedAt, 40);
    if (PROVIDERS.includes(provider) && isProviderUrl(s?.url) && fetchedAt) {
      d.source = { provider, url: s.url as string, fetchedAt };
    } else {
      problems.push("Data source is invalid");
    }
  }

  return { details: Object.keys(d).length ? d : null, problems };
}

/** https on one of the Open Food Facts family's own hosts. */
export function isProviderUrl(v: unknown): v is string {
  if (typeof v !== "string" || v.length > 300) return false;
  try {
    const u = new URL(v);
    return u.protocol === "https:" && /^(world|[a-z]{2}|images|static)\.open(food|beauty|petfood|products)facts\.org$/.test(u.hostname);
  } catch {
    return false;
  }
}

/** Drops OFF provenance and attribution (when the lookup can't be confirmed). */
export function withoutOffClaims(d: ProductDetails | null): ProductDetails | null {
  if (!d) return d;
  const { source: _source, provenance, ...rest } = d;
  void _source;
  const prov: Partial<Record<DetailField, Provenance>> = {};
  for (const k of Object.keys(provenance ?? {})) prov[k as DetailField] = "manual";
  const out: ProductDetails = { ...rest, ...(Object.keys(prov).length ? { provenance: prov } : {}) };
  return Object.keys(out).length ? out : null;
}
