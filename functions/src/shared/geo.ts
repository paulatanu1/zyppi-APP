/** Great-circle distance in metres (same formula as the old
 * `haversine_meters` SQL function and lib/core/utils/haversine.dart). */
export function haversineMeters(
  lat1: number,
  lng1: number,
  lat2: number,
  lng2: number,
): number {
  const r = 6371000;
  const toRad = (deg: number) => (deg * Math.PI) / 180;
  const dLat = toRad(lat2 - lat1);
  const dLng = toRad(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) ** 2 +
    Math.cos(toRad(lat1)) * Math.cos(toRad(lat2)) * Math.sin(dLng / 2) ** 2;
  return 2 * r * Math.asin(Math.sqrt(a));
}

export interface AreaLike {
  id: string;
  isActive: boolean;
  centerLat: number | null;
  centerLng: number | null;
  radiusMeters: number | null;
}

/** The nearest active area whose radius covers the point, or null. */
export function findServiceableArea<T extends AreaLike>(
  areas: T[],
  lat: number,
  lng: number,
): T | null {
  let best: T | null = null;
  let bestDistance = Infinity;
  for (const area of areas) {
    if (
      !area.isActive ||
      area.centerLat == null ||
      area.centerLng == null ||
      area.radiusMeters == null
    ) {
      continue;
    }
    const distance = haversineMeters(lat, lng, area.centerLat, area.centerLng);
    if (distance <= area.radiusMeters && distance < bestDistance) {
      best = area;
      bestDistance = distance;
    }
  }
  return best;
}
