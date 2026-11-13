import { HttpsError, onCall } from "firebase-functions/https";
import { defineSecret } from "firebase-functions/params";
import { logger } from "firebase-functions";
import { requireUid } from "./shared/callable";
import { getFeatures } from "./shared/features";

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
export const placesProxy = onCall({ secrets: [GOOGLE_PLACES_API_KEY] }, async (request) => {
  requireUid(request);
  // Switched off in Settings → Services: the app falls back to the phone's
  // geocoder exactly as it does on any Places error, and nothing is billed.
  if (!(await getFeatures()).placesSearch) return { status: "ERROR", disabled: true };
  const data = (request.data ?? {}) as { action?: string; input?: string; placeId?: string };
  const key = GOOGLE_PLACES_API_KEY.value();

  if (data.action === "autocomplete" && data.input) {
    const response = await fetch(`${BASE}/places:autocomplete`, {
      method: "POST",
      headers: { "Content-Type": "application/json", "X-Goog-Api-Key": key },
      body: JSON.stringify({
        input: data.input.slice(0, 200),
        // Delivery is India-only.
        includedRegionCodes: ["in"],
        languageCode: "en",
      }),
    });
    const body = await response.json();
    if (!response.ok) {
      logger.warn("Places autocomplete failed", { status: response.status, body });
      return { status: "ERROR", predictions: [] };
    }
    return toPredictions(body as AutocompleteResponse);
  }

  if (data.action === "details" && data.placeId) {
    const response = await fetch(`${BASE}/places/${encodeURIComponent(data.placeId)}`, {
      headers: {
        "X-Goog-Api-Key": key,
        "X-Goog-FieldMask": "id,displayName,formattedAddress,location,addressComponents",
      },
    });
    const body = await response.json();
    if (!response.ok) {
      logger.warn("Places details failed", { status: response.status, body });
      throw new HttpsError("unavailable", "Place details unavailable");
    }
    return toDetails(body as PlaceResponse);
  }

  throw new HttpsError("invalid-argument", "INVALID_REQUEST");
});

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
