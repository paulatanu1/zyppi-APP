import { Timestamp } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { HttpsError, onCall, type CallableRequest } from "firebase-functions/https";
import { defineString } from "firebase-functions/params";
import { PRODUCT_REQUESTS } from "../marketplace/product_requests";
import { requireSeller } from "../marketplace/sellers";
import { db } from "../shared/firebase";
import { checkAppCheck } from "../shared/hardening";
import { RateLimiter, rateLimit } from "../shared/rate_limit";
import { roleAllows, roleOf } from "../shared/roles";
import { type BarcodeFormat, parseGtin } from "./gtin";
import { BARCODES, BARCODE_LOOKUPS, PRODUCTS } from "./model";
import { type OffResult, type OffUnavailable, fetchOffProduct } from "./off_client";
import { type NormalizedProduct, mapOffProduct } from "./off_map";

/**
 * Seller app / catalog staff → scan a barcode (docs/BARCODES.md).
 *
 *   1. barcodes/{gtin}          the Zyppi catalogue already has it
 *   2. productRequests pending  another request is waiting for review
 *   3. barcodeLookups/{gtin}    cached Open Food Facts answer
 *   4. Open Food Facts          then cached (found 30 d, not found 1 d)
 *
 * Rate limiting, timeouts and outages are never cached and never shown as
 * "not found": the app offers manual entry. Nothing here writes the
 * catalogue; a person reviews and submits (sellerSubmitProduct).
 */

export const FOUND_TTL_MS = 30 * 24 * 3600_000;
export const NOT_FOUND_TTL_MS = 24 * 3600_000;
/** OFF allows 15 product reads/min per IP; stay under it per instance (≤ 2). */
export const OFF_CALLS_PER_MINUTE = 6; // × maxInstances 2 = 12

const OFF_CONTACT = defineString("OFF_CONTACT", {
  default: "https://zyppi.in",
  description: "Contact (email or URL) sent in the Open Food Facts User-Agent",
});
const USER_AGENT_APP = "ZyppiSeller/1.0";

export interface CatalogHit {
  productId: string;
  variantId: string;
  name: string;
  brand: string | null;
  imageUrl: string | null;
  variantLabel: string | null;
  isActive: boolean;
}

export type LookupResult =
  | { outcome: "zyppi"; product: CatalogHit }
  | { outcome: "pending" }
  | { outcome: "external"; product: NormalizedProduct }
  | { outcome: "not_found" }
  | { outcome: "unavailable"; reason: OffUnavailable | "busy" };

export interface CacheEntry {
  status: "found" | "not_found";
  product: NormalizedProduct | null;
  expireAtMs: number;
}

/** Storage the lookup needs; Firestore in production, a fake in tests. */
export interface LookupStore {
  catalogHit(gtin: string): Promise<CatalogHit | null>;
  pendingRequest(gtin: string): Promise<boolean>;
  cacheGet(gtin: string): Promise<CacheEntry | null>;
  cachePut(gtin: string, entry: CacheEntry): Promise<void>;
}

export interface LookupDeps {
  store: LookupStore;
  off: (offCode: string) => Promise<OffResult>;
  now: () => number;
  /** Shared OFF budget for this instance. */
  budget: RateLimiter;
}

/** Same-barcode calls on this instance share one lookup (a burst of scans). */
const inFlight = new Map<string, Promise<LookupResult>>();

export function lookupBarcode(gtin: string, offCode: string, deps: LookupDeps): Promise<LookupResult> {
  const running = inFlight.get(gtin);
  if (running) return running;
  const p = runLookup(gtin, offCode, deps).finally(() => inFlight.delete(gtin));
  inFlight.set(gtin, p);
  return p;
}

async function runLookup(gtin: string, offCode: string, deps: LookupDeps): Promise<LookupResult> {
  const hit = await deps.store.catalogHit(gtin);
  if (hit) return { outcome: "zyppi", product: hit };
  if (await deps.store.pendingRequest(gtin)) return { outcome: "pending" };

  const now = deps.now();
  const cached = await deps.store.cacheGet(gtin);
  if (cached && cached.expireAtMs > now) {
    return cached.status === "found" && cached.product
      ? { outcome: "external", product: cached.product }
      : { outcome: "not_found" };
  }

  if (!deps.budget.take("off", OFF_CALLS_PER_MINUTE, now)) {
    logger.warn("barcode lookup: OFF budget used up", { gtin });
    return { outcome: "unavailable", reason: "busy" };
  }
  const res = await deps.off(offCode);
  if (res.kind === "unavailable") {
    logger.warn("barcode lookup: OFF unavailable", { gtin, reason: res.reason, status: res.status ?? null });
    return { outcome: "unavailable", reason: res.reason };
  }
  if (res.kind === "not_found") {
    await deps.store.cachePut(gtin, { status: "not_found", product: null, expireAtMs: now + NOT_FOUND_TTL_MS });
    return { outcome: "not_found" };
  }
  const product = mapOffProduct(res.product, gtin, offCode, res.host);
  if (!product.name && !product.brand) {
    // An empty OFF record is as good as none; short TTL like not found.
    await deps.store.cachePut(gtin, { status: "not_found", product: null, expireAtMs: now + NOT_FOUND_TTL_MS });
    return { outcome: "not_found" };
  }
  await deps.store.cachePut(gtin, { status: "found", product, expireAtMs: now + FOUND_TTL_MS });
  return { outcome: "external", product };
}

/** The product a reservation points at, if it still carries that barcode. */
export function catalogHitFrom(
  gtin: string,
  productId: string,
  data: Record<string, unknown> | undefined,
): CatalogHit | null {
  if (!data) return null;
  const variants = Array.isArray(data.variants) ? (data.variants as Record<string, unknown>[]) : [];
  const v = variants.find((x) => x?.gtin === gtin);
  if (!v || typeof v.id !== "string") return null;
  return {
    productId,
    variantId: v.id,
    name: typeof data.name === "string" ? data.name : "",
    brand: typeof data.brand === "string" ? data.brand : null,
    imageUrl: typeof data.imageUrl === "string" ? data.imageUrl : null,
    variantLabel: typeof v.label === "string" ? v.label : null,
    isActive: data.isActive !== false,
  };
}

export const firestoreLookupStore: LookupStore = {
  async catalogHit(gtin) {
    const res = await db.collection(BARCODES).doc(gtin).get();
    const productId = res.get("productId");
    if (typeof productId !== "string") return null;
    const p = await db.collection(PRODUCTS).doc(productId).get();
    const hit = catalogHitFrom(gtin, productId, p.data());
    if (!hit) logger.warn("barcode lookup: stale reservation", { gtin, productId });
    return hit;
  },
  async pendingRequest(gtin) {
    const q = await db
      .collection(PRODUCT_REQUESTS)
      .where("gtins", "array-contains", gtin)
      .where("status", "==", "pending")
      .limit(1)
      .get();
    return !q.empty;
  },
  async cacheGet(gtin) {
    const s = await db.collection(BARCODE_LOOKUPS).doc(gtin).get();
    if (!s.exists) return null;
    const status = s.get("status");
    const expireAt = s.get("expireAt");
    if ((status !== "found" && status !== "not_found") || !(expireAt instanceof Timestamp)) return null;
    return { status, product: (s.get("product") as NormalizedProduct | null) ?? null, expireAtMs: expireAt.toMillis() };
  },
  async cachePut(gtin, entry) {
    await db.collection(BARCODE_LOOKUPS).doc(gtin).set({
      status: entry.status,
      product: entry.product,
      fetchedAt: Timestamp.now(),
      expireAt: Timestamp.fromMillis(entry.expireAtMs),
    });
  },
};

const offBudget = new RateLimiter();

/** Approved sellers, or catalog staff (admin panel). Returns the uid. */
async function lookupCaller(request: CallableRequest): Promise<string> {
  const role = roleOf(request.auth?.token as Record<string, unknown> | undefined);
  if (request.auth?.uid && roleAllows(role, ["catalog"])) {
    checkAppCheck(request, undefined, "web");
    return request.auth.uid;
  }
  return (await requireSeller(request)).uid;
}

const FORMATS: readonly BarcodeFormat[] = ["ean13", "ean8", "upca", "upce", "unknown"];

/**
 * Request: {code, format?}. Response: LookupResult. Invalid codes fail with
 * invalid-argument "INVALID_BARCODE" and details {problem}.
 */
export const sellerLookupBarcode = onCall({ timeoutSeconds: 20 }, async (request): Promise<LookupResult> => {
  const uid = await lookupCaller(request);
  rateLimit("sellerLookupBarcode", uid);
  const raw = request.data?.code;
  const format = FORMATS.includes(request.data?.format) ? (request.data.format as BarcodeFormat) : "unknown";
  if (typeof raw !== "string" || raw.length > 32) {
    throw new HttpsError("invalid-argument", "INVALID_BARCODE", { problem: "invalid_format" });
  }
  const parsed = parseGtin(raw, format);
  if (!parsed.ok) throw new HttpsError("invalid-argument", "INVALID_BARCODE", { problem: parsed.problem });

  const userAgent = `${USER_AGENT_APP} (${OFF_CONTACT.value()})`;
  return lookupBarcode(parsed.gtin, parsed.offCode, {
    store: firestoreLookupStore,
    off: (code) => fetchOffProduct(code, { userAgent }),
    now: Date.now,
    budget: offBudget,
  });
});
