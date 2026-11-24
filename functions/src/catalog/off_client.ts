import { fetchWithTimeout } from "../shared/http";

/**
 * Open Food Facts product read, API v3 (docs/BARCODES.md).
 *
 * v3 is the current, recommended API (v2 is deprecated). A missing product
 * is HTTP 404 with result.id "product_not_found". `product_type=all` makes
 * world.openfoodfacts.org redirect to Open Beauty / Pet Food / Products
 * Facts when the barcode lives there, so one call covers all four.
 *
 * 429 and 503 are rate limiting / outage, never "not found". Reads only:
 * no account, but their terms require a User-Agent "App/Version (contact)".
 */

export const OFF_BASE = "https://world.openfoodfacts.org";
export const OFF_TIMEOUT_MS = 6_000;
/** Bodies over this are not a product (or something is wrong): ignore. */
const MAX_BODY_BYTES = 1_000_000;

export const OFF_FIELDS = [
  "code",
  "product_name",
  "product_name_en",
  "generic_name",
  "generic_name_en",
  "brands",
  "image_front_url",
  "categories_tags",
  "quantity",
  "product_quantity",
  "product_quantity_unit",
  "packaging",
  "packaging_text",
  "ingredients_text",
  "ingredients_text_en",
  "allergens_tags",
  "nutriments",
  "nutrition_data_per",
  "serving_size",
  "origins",
  "labels_tags",
  "product_type",
].join(",");

export type OffUnavailable = "rate_limited" | "outage" | "timeout" | "network" | "bad_response";

export type OffResult =
  | { kind: "found"; product: Record<string, unknown>; host: string }
  | { kind: "not_found" }
  | { kind: "unavailable"; reason: OffUnavailable; status?: number };

export type FetchLike = (url: string, init: RequestInit, timeoutMs: number) => Promise<Response>;

export interface OffClientOptions {
  userAgent: string;
  fetch?: FetchLike;
  timeoutMs?: number;
  base?: string;
}

export function offProductUrl(code: string, base = OFF_BASE): string {
  return `${base}/api/v3/product/${encodeURIComponent(code)}?product_type=all&fields=${OFF_FIELDS}`;
}

/** One product read. Never throws. */
export async function fetchOffProduct(code: string, opts: OffClientOptions): Promise<OffResult> {
  const doFetch = opts.fetch ?? fetchWithTimeout;
  let res: Response;
  try {
    res = await doFetch(
      offProductUrl(code, opts.base),
      { headers: { "User-Agent": opts.userAgent, Accept: "application/json" }, redirect: "follow" },
      opts.timeoutMs ?? OFF_TIMEOUT_MS,
    );
  } catch (e) {
    const name = (e as { name?: string })?.name;
    return { kind: "unavailable", reason: name === "TimeoutError" || name === "AbortError" ? "timeout" : "network" };
  }

  if (res.status === 429) return { kind: "unavailable", reason: "rate_limited", status: 429 };
  if (res.status >= 500) return { kind: "unavailable", reason: "outage", status: res.status };

  let body: Record<string, unknown> | null = null;
  try {
    const text = await res.text();
    if (text.length <= MAX_BODY_BYTES) body = JSON.parse(text) as Record<string, unknown>;
  } catch {
    body = null;
  }
  if (!body || typeof body !== "object") return { kind: "unavailable", reason: "bad_response", status: res.status };

  const resultId = (body.result as { id?: unknown } | undefined)?.id;
  if (res.status === 404) {
    // Only OFF's own JSON "not found" counts; a bare 404 page is a fault.
    return resultId === "product_not_found" || body.status === "failure"
      ? { kind: "not_found" }
      : { kind: "unavailable", reason: "bad_response", status: 404 };
  }
  if (res.status !== 200) return { kind: "unavailable", reason: "bad_response", status: res.status };
  const product = body.product;
  if (!product || typeof product !== "object" || Array.isArray(product)) {
    return resultId === "product_not_found" ? { kind: "not_found" } : { kind: "unavailable", reason: "bad_response", status: 200 };
  }
  let host = "world.openfoodfacts.org";
  try {
    if (res.url) host = new URL(res.url).hostname;
  } catch {
    // keep the default
  }
  return { kind: "found", product: product as Record<string, unknown>, host };
}
