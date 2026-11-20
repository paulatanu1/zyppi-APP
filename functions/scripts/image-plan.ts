/** What optimize-images.ts does with one Storage object (pure, unit-tested). */

/** Longest side kept, per top-level folder (the admin uploads at 1000). */
export const MAX_SIDE: Record<string, number> = {
  banners: 1200,
  catalog: 1000,
  notifications: 1000,
};

/** Already small enough to leave alone (bytes). */
export const SMALL_ENOUGH = 200 * 1024;

export const CACHE_CONTROL = "public,max-age=31536000";

export interface ObjectInfo {
  name: string;
  contentType?: string;
  size: number;
  cacheControl?: string;
}

export type Plan =
  | { action: "skip"; reason: string }
  | { action: "cache-header" }
  | { action: "reencode"; maxSide: number };

export function planFor(o: ObjectInfo): Plan {
  if (o.name.startsWith("_originals/")) return { action: "skip", reason: "backup" };
  const folder = o.name.split("/")[0];
  const maxSide = MAX_SIDE[folder];
  if (!maxSide) return { action: "skip", reason: "not a catalogue folder" };
  const type = (o.contentType ?? "").toLowerCase();
  if (!type.startsWith("image/")) return { action: "skip", reason: "not an image" };
  if (type === "image/svg+xml" || type === "image/gif") return { action: "skip", reason: type };
  if (type === "image/webp" && o.size <= SMALL_ENOUGH) {
    return o.cacheControl ? { action: "skip", reason: "already optimised" } : { action: "cache-header" };
  }
  return { action: "reencode", maxSide };
}

/** Keep the new file only if it's meaningfully smaller (10%+). */
export function worthReplacing(oldBytes: number, newBytes: number): boolean {
  return newBytes < oldBytes * 0.9;
}

/** True for an https URL that isn't on Firebase Storage (can't be optimised here). */
export function isExternalImage(url: unknown): boolean {
  if (typeof url !== "string" || !url.startsWith("https://")) return false;
  try {
    const host = new URL(url).hostname;
    return host !== "firebasestorage.googleapis.com" && host !== "storage.googleapis.com";
  } catch {
    return false;
  }
}
