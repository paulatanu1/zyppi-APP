import { db } from "./firebase";
import type { AreaLike } from "./geo";

/**
 * Service areas change a few times a year but every quote / checkout
 * needs all of them (the address decides the area). Keep them in the
 * instance's memory for a minute instead of reading the whole collection
 * on every call (an admin edit shows within a minute). Off under the
 * emulator, so tests see their own data.
 */
export const AREA_CACHE_MS = 60_000;

let cached: { at: number; areas: AreaLike[] } | null = null;

export function toArea(id: string, d: Record<string, unknown>): AreaLike {
  return {
    id,
    isActive: d.isActive === true,
    centerLat: (d.centerLat as number | undefined) ?? null,
    centerLng: (d.centerLng as number | undefined) ?? null,
    radiusMeters: (d.radiusMeters as number | undefined) ?? null,
  };
}

export async function serviceAreas(nowMs = Date.now()): Promise<AreaLike[]> {
  const useCache = !process.env.FIRESTORE_EMULATOR_HOST;
  if (useCache && cached && nowMs - cached.at < AREA_CACHE_MS) return cached.areas;
  const snap = await db.collection("serviceAreas").get();
  const areas = snap.docs.map((d) => toArea(d.id, d.data()));
  if (useCache) cached = { at: nowMs, areas };
  return areas;
}
