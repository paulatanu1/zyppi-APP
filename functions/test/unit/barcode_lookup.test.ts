import { readFileSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import {
  type CacheEntry,
  type CatalogHit,
  FOUND_TTL_MS,
  type LookupDeps,
  NOT_FOUND_TTL_MS,
  OFF_CALLS_PER_MINUTE,
  catalogHitFrom,
  lookupBarcode,
} from "../../src/catalog/barcode_lookup";
import type { OffResult } from "../../src/catalog/off_client";
import { RateLimiter, rateLimit } from "../../src/shared/rate_limit";

const nutella = JSON.parse(readFileSync(join(__dirname, "fixtures/off/nutella.json"), "utf8")).product;
const G = "03017620422003";
const CODE = "3017620422003";

function setup(opts: { hit?: CatalogHit; pending?: boolean; cache?: CacheEntry; off?: OffResult | (() => Promise<OffResult>) } = {}) {
  const cache = new Map<string, CacheEntry>(opts.cache ? [[G, opts.cache]] : []);
  let offCalls = 0;
  let now = 1_000_000;
  const deps: LookupDeps = {
    store: {
      catalogHit: async () => opts.hit ?? null,
      pendingRequest: async () => opts.pending ?? false,
      cacheGet: async (g) => cache.get(g) ?? null,
      cachePut: async (g, e) => void cache.set(g, e),
    },
    off: async () => {
      offCalls++;
      const o = opts.off ?? { kind: "found", product: nutella, host: "world.openfoodfacts.org" };
      return typeof o === "function" ? o() : o;
    },
    now: () => now,
    budget: new RateLimiter(),
  };
  return { deps, cache, offCalls: () => offCalls, tick: (ms: number) => (now += ms) };
}

const hit: CatalogHit = { productId: "p1", variantId: "v1", name: "Nutella", brand: "Ferrero", imageUrl: null, variantLabel: "400 g", isActive: true };

describe("barcode lookup order", () => {
  it("1. the Zyppi catalogue wins; no external call", async () => {
    const s = setup({ hit });
    expect(await lookupBarcode(G, CODE, s.deps)).toEqual({ outcome: "zyppi", product: hit });
    expect(s.offCalls()).toBe(0);
  });

  it("2. a pending request for the barcode", async () => {
    const s = setup({ pending: true });
    expect(await lookupBarcode(G, CODE, s.deps)).toEqual({ outcome: "pending" });
    expect(s.offCalls()).toBe(0);
  });

  it("3./4. Open Food Facts, then cached for 30 days", async () => {
    const s = setup();
    const r = await lookupBarcode(G, CODE, s.deps);
    expect(r).toMatchObject({ outcome: "external", product: { brand: "Ferrero", gtin: G } });
    expect(s.cache.get(G)).toMatchObject({ status: "found", expireAtMs: 1_000_000 + FOUND_TTL_MS });
    expect(await lookupBarcode(G, CODE, s.deps)).toEqual(r);
    expect(s.offCalls()).toBe(1);
  });

  it("an expired cache entry is fetched again", async () => {
    const s = setup({ cache: { status: "not_found", product: null, expireAtMs: 999_999 } });
    expect(await lookupBarcode(G, CODE, s.deps)).toMatchObject({ outcome: "external" });
    expect(s.offCalls()).toBe(1);
  });

  it("not found is cached for a day only", async () => {
    const s = setup({ off: { kind: "not_found" } });
    expect(await lookupBarcode(G, CODE, s.deps)).toEqual({ outcome: "not_found" });
    expect(s.cache.get(G)).toMatchObject({ status: "not_found", expireAtMs: 1_000_000 + NOT_FOUND_TTL_MS });
    s.tick(NOT_FOUND_TTL_MS - 1);
    await lookupBarcode(G, CODE, s.deps);
    expect(s.offCalls()).toBe(1);
    s.tick(2);
    await lookupBarcode(G, CODE, s.deps);
    expect(s.offCalls()).toBe(2);
  });

  it("an OFF record with no name or brand counts as not found", async () => {
    const s = setup({ off: { kind: "found", product: { categories_tags: ["en:snacks"] }, host: "world.openfoodfacts.org" } });
    expect(await lookupBarcode(G, CODE, s.deps)).toEqual({ outcome: "not_found" });
  });

  for (const reason of ["rate_limited", "outage", "timeout", "network", "bad_response"] as const) {
    it(`${reason} is reported as unavailable and never cached`, async () => {
      const s = setup({ off: { kind: "unavailable", reason } });
      expect(await lookupBarcode(G, CODE, s.deps)).toEqual({ outcome: "unavailable", reason });
      expect(s.cache.size).toBe(0);
    });
  }

  it("concurrent lookups of one barcode share a single OFF call", async () => {
    let release!: (r: OffResult) => void;
    const s = setup({ off: () => new Promise<OffResult>((r) => (release = r)) });
    const all = Promise.all([lookupBarcode(G, CODE, s.deps), lookupBarcode(G, CODE, s.deps), lookupBarcode(G, CODE, s.deps)]);
    await new Promise((r) => setTimeout(r, 0));
    release({ kind: "not_found" });
    const results = await all;
    expect(results.every((r) => r.outcome === "not_found")).toBe(true);
    expect(s.offCalls()).toBe(1);
  });

  it("stays under the per-instance OFF budget, then says busy", async () => {
    const s = setup({ off: { kind: "unavailable", reason: "outage" } });
    for (let i = 0; i < OFF_CALLS_PER_MINUTE; i++) await lookupBarcode(G, CODE, s.deps);
    expect(await lookupBarcode(G, CODE, s.deps)).toEqual({ outcome: "unavailable", reason: "busy" });
    expect(s.offCalls()).toBe(OFF_CALLS_PER_MINUTE);
    s.tick(60_000);
    await lookupBarcode(G, CODE, s.deps);
    expect(s.offCalls()).toBe(OFF_CALLS_PER_MINUTE + 1);
  });

  it("per-user call limit", () => {
    const limiter = new RateLimiter();
    for (let i = 0; i < 20; i++) rateLimit("sellerLookupBarcode", "u1", 0, limiter);
    expect(() => rateLimit("sellerLookupBarcode", "u1", 0, limiter)).toThrow("RATE_LIMITED");
    expect(() => rateLimit("sellerLookupBarcode", "u2", 0, limiter)).not.toThrow();
  });
});

describe("catalogue reservation → product", () => {
  const product = { name: "Nutella", brand: "Ferrero", isActive: true, variants: [{ id: "v1", label: "400 g", gtin: G }, { id: "v2", label: "750 g" }] };
  it("finds the variant carrying the barcode", () => {
    expect(catalogHitFrom(G, "p1", product)).toEqual(hit);
  });
  it("a stale reservation (product gone or barcode moved) is no hit", () => {
    expect(catalogHitFrom(G, "p1", undefined)).toBeNull();
    expect(catalogHitFrom(G, "p1", { ...product, variants: [{ id: "v1", label: "400 g" }] })).toBeNull();
  });
});
