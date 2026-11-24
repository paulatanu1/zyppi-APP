import { HttpsError, onCall } from "firebase-functions/https";
import { defineSecret } from "firebase-functions/params";
import { logger } from "firebase-functions";
import { requireUid } from "./shared/callable";
import { getFeatures } from "./shared/features";
import { HOT } from "./shared/scaling";
import { rateLimit } from "./shared/rate_limit";
import { fetchWithTimeout } from "./shared/http";

// Server-side key restricted to "Places API (New)"; never shipped in the app.
//   firebase functions:secrets:set GOOGLE_PLACES_API_KEY
const GOOGLE_PLACES_API_KEY = defineSecret("GOOGLE_PLACES_API_KEY");
const BASE = "https://places.googleapis.com/v1";

/**
 * Address search through Google Places API (New), so the app never holds a
 * Places key. Responses are converted to the shape the app's PlacePrediction
 * / PlaceDetails models read (camelCase: `placeId`, `addressComponents[]
 * .longName`, `result.geometry.location`).
 *
 * Request: {action: "autocomplete", input} | {action: "details", placeId}
 * Response: autocomplete → {status, predictions: [{description, placeId,
 *           structuredFormatting: {mainText, secondaryText}, types}]}
 *           details → {status, result: {placeId, name, formattedAddress,
 *           geometry: {location: {lat, lng}}, addressComponents: [...]}}
 * `status` is "OK", "ZERO_RESULTS" or "ERROR" (the app then falls back to
 * the phone's geocoder for search).
 */
export const placesProxy = onCall({ ...HOT, secrets: [GOOGLE_PLACES_API_KEY] }, async (request) => {
  rateLimit("placesProxy", requireUid(request));
  // Switched off in Settings → Services: the app falls back to the phone's
  // geocoder exactly as it does on any Places error, and nothing is billed.
  if (!(await getFeatures()).placesSearch) return { status: "ERROR", disabled: true };
  const data = (request.data ?? {}) as {
    action?: string;
    input?: string;
    placeId?: string;
    near?: { lat?: unknown; lng?: unknown };
  };
  const key = GOOGLE_PLACES_API_KEY.value();

  if (data.action === "autocomplete" && data.input) {
    let response: Response;
    let body: unknown;
    try {
      response = await fetchWithTimeout(`${BASE}/places:autocomplete`, {
        method: "POST",
        headers: { "Content-Type": "application/json", "X-Goog-Api-Key": key },
        body: JSON.stringify({
          input: data.input.slice(0, 200),
          // Delivery is India-only.
          includedRegionCodes: ["in"],
          languageCode: "en",
          // Prefer places near the map's point, so "youth club" finds the
          // one in this village before others in the state.
          ...locationBias(data.near),
        }),
      });
      body = await response.json();
    } catch (error) {
      // Timeout / network: the app falls back to the phone's geocoder.
      logger.warn("Places autocomplete unreachable", { error: String(error) });
      return { status: "ERROR", predictions: [] };
    }
    if (!response.ok) {
      logger.warn("Places autocomplete failed", { status: response.status, body });
      return { status: "ERROR", predictions: [] };
    }
    return toPredictions(body as AutocompleteResponse);
  }

  if (data.action === "details" && data.placeId) {
    let response: Response;
    let body: unknown;
    try {
      response = await fetchWithTimeout(`${BASE}/places/${encodeURIComponent(data.placeId)}`, {
        headers: {
          "X-Goog-Api-Key": key,
          "X-Goog-FieldMask": "id,displayName,formattedAddress,location,addressComponents",
        },
      });
      body = await response.json();
    } catch (error) {
      logger.warn("Places details unreachable", { error: String(error) });
      throw new HttpsError("unavailable", "Place details unavailable");
    }
    if (!response.ok) {
      logger.warn("Places details failed", { status: response.status, body });
      throw new HttpsError("unavailable", "Place details unavailable");
    }
    return toDetails(body as PlaceResponse);
  }

  throw new HttpsError("invalid-argument", "INVALID_REQUEST");
});

/** Bias radius around the app's map point (rural towns are spread out). */
export const BIAS_RADIUS_M = 30_000;

/** A Places `locationBias` circle for a valid point in India, else nothing. */
export function locationBias(near: { lat?: unknown; lng?: unknown } | undefined) {
  const lat = near?.lat;
  const lng = near?.lng;
  if (typeof lat !== "number" || typeof lng !== "number") return {};
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) return {};
  // Roughly India's bounding box; anything else is junk or (0, 0).
  if (lat < 6 || lat > 38 || lng < 68 || lng > 98) return {};
  return {
    locationBias: { circle: { center: { latitude: lat, longitude: lng }, radius: BIAS_RADIUS_M } },
  };
}

// --- Places API (New) response shapes (only the fields used) ---------------

interface Text {
  text?: string;
}

export interface AutocompleteResponse {
  suggestions?: {
    placePrediction?: {
      placeId?: string;
      text?: Text;
      structuredFormat?: { mainText?: Text; secondaryText?: Text };
      types?: string[];
    };
  }[];
}

export interface PlaceResponse {
  id?: string;
  displayName?: Text;
  formattedAddress?: string;
  location?: { latitude?: number; longitude?: number };
  addressComponents?: { longText?: string; shortText?: string; types?: string[] }[];
}

export function toPredictions(body: AutocompleteResponse) {
  const predictions = (body.suggestions ?? [])
    .map((s) => s.placePrediction)
    .filter((p): p is NonNullable<typeof p> => !!p?.placeId)
    .map((p) => ({
      description: p.text?.text ?? "",
      placeId: p.placeId,
      structuredFormatting: {
        mainText: p.structuredFormat?.mainText?.text ?? p.text?.text ?? "",
        secondaryText: p.structuredFormat?.secondaryText?.text ?? "",
      },
      types: p.types ?? [],
    }));
  return { status: predictions.length ? "OK" : "ZERO_RESULTS", predictions };
}

export function toDetails(body: PlaceResponse) {
  const hasLocation =
    typeof body.location?.latitude === "number" && typeof body.location?.longitude === "number";
  return {
    status: hasLocation ? "OK" : "ZERO_RESULTS",
    result: {
      placeId: body.id ?? null,
      name: body.displayName?.text ?? null,
      formattedAddress: body.formattedAddress ?? null,
      geometry: hasLocation
        ? { location: { lat: body.location!.latitude, lng: body.location!.longitude } }
        : null,
      addressComponents: (body.addressComponents ?? []).map((c) => ({
        longName: c.longText ?? "",
        shortName: c.shortText ?? "",
        types: c.types ?? [],
      })),
    },
  };
}
