import { HttpsError, onCall } from "firebase-functions/https";
import { defineSecret } from "firebase-functions/params";
import { requireUid } from "./shared/callable";

// Server-side key restricted to the Places API; never shipped in the app.
//   firebase functions:secrets:set GOOGLE_PLACES_API_KEY
const GOOGLE_PLACES_API_KEY = defineSecret("GOOGLE_PLACES_API_KEY");
const BASE = "https://maps.googleapis.com/maps/api/place";

/**
 * Proxies Google Places Autocomplete + Details. Google's response is
 * returned unchanged (the app's PlacePrediction / PlaceDetails parse it).
 *
 * Request: {action: "autocomplete", input} | {action: "details", placeId}
 */
export const placesProxy = onCall({ secrets: [GOOGLE_PLACES_API_KEY] }, async (request) => {
  requireUid(request);
  const data = (request.data ?? {}) as { action?: string; input?: string; placeId?: string };

  let url: URL;
  if (data.action === "autocomplete" && data.input) {
    url = new URL(`${BASE}/autocomplete/json`);
    url.searchParams.set("input", data.input.slice(0, 200));
    url.searchParams.set("language", "en");
    url.searchParams.set("types", "geocode");
    // Delivery is India-only.
    url.searchParams.set("components", "country:in");
  } else if (data.action === "details" && data.placeId) {
    url = new URL(`${BASE}/details/json`);
    url.searchParams.set("placeid", data.placeId);
  } else {
    throw new HttpsError("invalid-argument", "INVALID_REQUEST");
  }
  url.searchParams.set("key", GOOGLE_PLACES_API_KEY.value());

  const response = await fetch(url);
  if (!response.ok) throw new HttpsError("unavailable", `Places HTTP ${response.status}`);
  return (await response.json()) as Record<string, unknown>;
});
