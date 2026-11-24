import { randomUUID } from "node:crypto";
import { HttpsError } from "firebase-functions/https";
import { MAX_BRAND, type ProductDetails, readDetails } from "./details";
import { isCanonicalGtin, parseGtin } from "./gtin";

/**
 * Catalog shapes shared by the admin callables, the import and the
 * keywords trigger. Field names match what the app reads
 * (lib/core/data/firebase_catalog_repository_impl.dart). Money is int paise.
 */
export const PRODUCTS = "products";
export const CATEGORIES = "categories";
/** barcodes/{gtin14} → {productId, variantId}: one GTIN, one variant (docs/BARCODES.md). */
export const BARCODES = "barcodes";
/** Server-only cache of Open Food Facts answers (expireAt TTL). */
export const BARCODE_LOOKUPS = "barcodeLookups";

export const MAX_VARIANTS = 20;
export const MAX_NAME = 120;
export const MAX_DESCRIPTION = 2000;
export const MAX_LABEL = 40;
/** ₹1,00,000 — anything above is almost certainly a typo in paise/rupees. */
export const MAX_PRICE_PAISE = 10_000_000;

export interface VariantInput {
  id?: string | null;
  label: string;
  pricePaise: number;
  mrpPaise: number;
  /** Canonical GTIN-14; null clears it; undefined keeps what is stored. */
  gtin?: string | null;
}

export interface Variant {
  id: string;
  label: string;
  pricePaise: number;
  mrpPaise: number;
  /** Present only when the variant has a barcode. */
  gtin?: string;
}

export interface ProductInput {
  name: string;
  description: string;
  categoryId: string;
  subcategoryId: string | null;
  imageUrl: string | null;
  isActive: boolean;
  variants: VariantInput[];
  /** undefined keeps what is stored (import, older clients); null clears. */
  brand?: string | null;
  details?: ProductDetails | null;
}

/**
 * A client-sent barcode: undefined (not sent), null (clear) or the
 * canonical GTIN-14 of a valid code; anything else stays as sent so
 * productProblems reports it.
 */
export function readGtinField(v: unknown): string | null | undefined {
  if (v === undefined) return undefined;
  if (v === null || v === "") return null;
  const r = parseGtin(v);
  return r.ok ? r.gtin : String(v).slice(0, 32);
}

/** Brand: undefined (keep), null (clear) or trimmed text. */
export function readBrandField(v: unknown): string | null | undefined {
  if (v === undefined) return undefined;
  if (typeof v !== "string" || !v.trim()) return null;
  return v.replace(/\s+/g, " ").trim();
}

/** Details: undefined (keep), or the sanitized map plus its problems. */
export function readDetailsField(v: unknown): { details: ProductDetails | null | undefined; problems: string[] } {
  if (v === undefined) return { details: undefined, problems: [] };
  return readDetails(v);
}

/** Field-level problems, so the import can report every one per row. */
export function productProblems(p: Partial<ProductInput>): string[] {
  const out: string[] = [];
  const name = typeof p.name === "string" ? p.name.trim() : "";
  if (name.length < 2 || name.length > MAX_NAME) out.push(`Name must be 2–${MAX_NAME} characters`);
  if (typeof p.description === "string" && p.description.length > MAX_DESCRIPTION) {
    out.push(`Description is over ${MAX_DESCRIPTION} characters`);
  }
  if (typeof p.categoryId !== "string" || !p.categoryId) out.push("Category is required");
  if (p.imageUrl != null && !isHttpsUrl(p.imageUrl)) out.push("Image must be an https:// URL");

  const variants = Array.isArray(p.variants) ? p.variants : [];
  if (variants.length === 0) out.push("Add at least one variant");
  if (variants.length > MAX_VARIANTS) out.push(`At most ${MAX_VARIANTS} variants`);
  if (typeof p.brand === "string" && p.brand.length > MAX_BRAND) out.push(`Brand is over ${MAX_BRAND} characters`);
  const labels = new Set<string>();
  const gtins = new Set<string>();
  variants.forEach((v, i) => {
    const n = `Variant ${i + 1}`;
    const label = typeof v?.label === "string" ? v.label.trim() : "";
    if (!label || label.length > MAX_LABEL) out.push(`${n}: size/label is required (≤ ${MAX_LABEL})`);
    else if (labels.has(label.toLowerCase())) out.push(`${n}: “${label}” is listed twice`);
    labels.add(label.toLowerCase());
    if (!isPaise(v?.pricePaise) || v.pricePaise <= 0) out.push(`${n}: price must be more than ₹0`);
    if (!isPaise(v?.mrpPaise) || v.mrpPaise <= 0) out.push(`${n}: MRP must be more than ₹0`);
    else if (isPaise(v?.pricePaise) && v.mrpPaise < v.pricePaise) {
      out.push(`${n}: MRP can’t be below the selling price`);
    }
    if (v?.gtin != null) {
      if (!isCanonicalGtin(v.gtin)) out.push(`${n}: barcode is not a valid EAN / UPC`);
      else if (gtins.has(v.gtin)) out.push(`${n}: barcode is on two pack sizes`);
      gtins.add(v.gtin);
    }
  });
  return out;
}

function isPaise(v: unknown): v is number {
  return Number.isInteger(v) && (v as number) >= 0 && (v as number) <= MAX_PRICE_PAISE;
}

export function isHttpsUrl(v: unknown): v is string {
  if (typeof v !== "string" || v.length > 2048) return false;
  try {
    return new URL(v).protocol === "https:";
  } catch {
    return false;
  }
}

/** Throws `invalid-argument` listing every problem. */
export function assertProduct(p: Partial<ProductInput>): void {
  const problems = productProblems(p);
  if (problems.length) throw new HttpsError("invalid-argument", problems.join("; "));
}

/**
 * Keeps existing variant ids (inventory rows and carts point at them):
 * an input variant keeps its id if it already belongs to this product, or
 * else matches an existing variant by label; anything new gets a UUID.
 * With `keepUnlisted`, existing variants not in the input stay (import).
 */
export function mergeVariants(
  existing: Variant[],
  input: VariantInput[],
  keepUnlisted = false,
): Variant[] {
  const byId = new Map(existing.map((v) => [v.id, v]));
  const byLabel = new Map(existing.map((v) => [v.label.trim().toLowerCase(), v]));
  const used = new Set<string>();
  const out = input.map((v) => {
    const label = v.label.trim();
    const match =
      (v.id && byId.get(v.id)) || byLabel.get(label.toLowerCase()) || undefined;
    const owned = match && !used.has(match.id) ? match : undefined;
    const id = owned ? owned.id : randomUUID();
    used.add(id);
    // A barcode stays with its variant unless the input sets or clears it.
    const gtin = v.gtin === undefined ? owned?.gtin : v.gtin;
    return { id, label, pricePaise: v.pricePaise, mrpPaise: v.mrpPaise, ...(gtin ? { gtin } : {}) };
  });
  if (keepUnlisted) {
    for (const v of existing) if (!used.has(v.id)) out.push(v);
  }
  return out;
}

export interface CategoryInput {
  name: string;
  parentId: string | null;
  imageUrl: string | null;
  colorHex: string | null;
  borderColorHex: string | null;
}

/** ARGB like the seed ("1A53B175"), or RGB ("53B175", treated as opaque). */
export function normalizeColor(v: unknown): string | null {
  if (v == null || v === "") return null;
  if (typeof v !== "string") throw new HttpsError("invalid-argument", "Invalid colour");
  const hex = v.replace(/^#/, "").toUpperCase();
  if (/^[0-9A-F]{6}$/.test(hex)) return `FF${hex}`;
  if (/^[0-9A-F]{8}$/.test(hex)) return hex;
  throw new HttpsError("invalid-argument", "Colours must be hex, e.g. 53B175");
}

/** Summary kept in the audit log (not the whole doc: keywords are noise). */
export function productAuditView(p: Record<string, unknown> | undefined) {
  if (!p) return null;
  return {
    name: p.name,
    isActive: p.isActive,
    categoryId: p.categoryId,
    subcategoryId: p.subcategoryId ?? null,
    imageUrl: p.imageUrl ?? null,
    brand: p.brand ?? null,
    variants: ((p.variants as Variant[] | undefined) ?? []).map(
      (v) => `${v.label}: ${v.pricePaise}/${v.mrpPaise}${v.gtin ? ` #${v.gtin}` : ""}`,
    ),
  };
}
