// Proxies Google Places Autocomplete + Place Details so the client never
// carries a key usable for Places (PLAN.md Phase 4). The response shapes
// are passed through unchanged from Google, matching what
// lib/features/search_address/domain/{place_prediction,place_details}.dart
// already deserialize.
//
// Requires the Edge Function secret GOOGLE_PLACES_API_KEY (a server-side
// key restricted to the Places API, separate from the client's Maps SDK
// key): `supabase secrets set GOOGLE_PLACES_API_KEY=...`.
//
// Request body: {"action": "autocomplete", "input": string}
//            or {"action": "details", "placeId": string}

const GOOGLE_PLACES_BASE = "https://maps.googleapis.com/maps/api/place";

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const apiKey = Deno.env.get("GOOGLE_PLACES_API_KEY");
  if (!apiKey) {
    return Response.json(
      { status: "ERROR", error_message: "GOOGLE_PLACES_API_KEY not configured" },
      { status: 500 },
    );
  }

  let body: { action?: string; input?: string; placeId?: string };
  try {
    body = await req.json();
  } catch {
    return Response.json({ status: "INVALID_REQUEST" }, { status: 400 });
  }

  let url: URL;
  if (body.action === "autocomplete" && body.input) {
    url = new URL(`${GOOGLE_PLACES_BASE}/autocomplete/json`);
    url.searchParams.set("input", body.input);
    url.searchParams.set("language", "en");
    url.searchParams.set("types", "geocode");
  } else if (body.action === "details" && body.placeId) {
    url = new URL(`${GOOGLE_PLACES_BASE}/details/json`);
    url.searchParams.set("placeid", body.placeId);
  } else {
    return Response.json({ status: "INVALID_REQUEST" }, { status: 400 });
  }
  url.searchParams.set("key", apiKey);

  const googleResponse = await fetch(url);
  const data = await googleResponse.json();

  return Response.json(data, { status: googleResponse.status });
});
