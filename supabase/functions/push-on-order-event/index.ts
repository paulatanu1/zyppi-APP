// Sends an FCM push when an order_events row is inserted (triggered by
// the on_order_event_notify Postgres trigger - see
// supabase/migrations/20261015120800_push_on_order_event.sql). Deep
// links into order tracking via the `orderId` data field.
//
// Requires the Edge Function secret FCM_SERVICE_ACCOUNT_JSON: the full
// JSON key for a Firebase service account with the
// "Firebase Cloud Messaging API" role (Firebase Console > Project
// Settings > Service Accounts > Generate new private key).
// `supabase secrets set FCM_SERVICE_ACCOUNT_JSON="$(cat key.json)"`.
//
// SUPABASE_URL / SUPABASE_SERVICE_ROLE_KEY are auto-injected by Supabase.
//
// Request body: {"orderId": string, "status": string}

import { createClient } from "jsr:@supabase/supabase-js@2";

const STATUS_COPY: Record<string, { title: string; body: string }> = {
  placed: { title: "Order placed", body: "We've got your order!" },
  packed: { title: "Order packed", body: "Your order is packed and ready." },
  out_for_delivery: {
    title: "Out for delivery",
    body: "Your order is on its way.",
  },
  delivered: { title: "Delivered", body: "Your order has been delivered." },
  cancelled: { title: "Order cancelled", body: "Your order was cancelled." },
};

async function getAccessToken(serviceAccountJson: string): Promise<string> {
  const serviceAccount = JSON.parse(serviceAccountJson);
  const now = Math.floor(Date.now() / 1000);

  const header = { alg: "RS256", typ: "JWT" };
  const claims = {
    iss: serviceAccount.client_email,
    scope: "https://www.googleapis.com/auth/firebase.messaging",
    aud: "https://oauth2.googleapis.com/token",
    iat: now,
    exp: now + 3600,
  };

  const base64url = (input: Uint8Array | string) =>
    btoa(typeof input === "string" ? input : new TextDecoder().decode(input))
      .replace(/\+/g, "-")
      .replace(/\//g, "_")
      .replace(/=+$/, "");

  const unsigned = `${base64url(JSON.stringify(header))}.${base64url(JSON.stringify(claims))}`;

  const pemBody = serviceAccount.private_key
    .replace(/-----BEGIN PRIVATE KEY-----/, "")
    .replace(/-----END PRIVATE KEY-----/, "")
    .replace(/\s/g, "");
  const keyData = Uint8Array.from(atob(pemBody), (c) => c.charCodeAt(0));

  const key = await crypto.subtle.importKey(
    "pkcs8",
    keyData,
    { name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
    false,
    ["sign"],
  );
  const signature = await crypto.subtle.sign(
    "RSASSA-PKCS1-v1_5",
    key,
    new TextEncoder().encode(unsigned),
  );
  const jwt = `${unsigned}.${base64url(new Uint8Array(signature))}`;

  const tokenResponse = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  });
  const tokenData = await tokenResponse.json();
  if (!tokenResponse.ok) {
    throw new Error(`OAuth token request failed: ${JSON.stringify(tokenData)}`);
  }

  return tokenData.access_token;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const serviceAccountJson = Deno.env.get("FCM_SERVICE_ACCOUNT_JSON");
  if (!serviceAccountJson) {
    return Response.json(
      { error: "FCM_SERVICE_ACCOUNT_JSON not configured" },
      { status: 500 },
    );
  }

  let body: { orderId?: string; status?: string };
  try {
    body = await req.json();
  } catch {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }
  if (!body.orderId || !body.status) {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }

  const supabase = createClient(
    Deno.env.get("SUPABASE_URL")!,
    Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
  );

  const { data: order, error: orderError } = await supabase
    .from("orders")
    .select("user_id")
    .eq("id", body.orderId)
    .single();
  if (orderError || !order) {
    return Response.json({ error: "Order not found" }, { status: 404 });
  }

  const { data: profile } = await supabase
    .from("profiles")
    .select("fcm_token, notify_order_updates")
    .eq("id", order.user_id)
    .single();
  if (!profile?.fcm_token) {
    return Response.json({ skipped: "No fcm_token for user" });
  }
  // Account → Notification preferences.
  if (profile.notify_order_updates === false) {
    return Response.json({ skipped: "Order updates turned off by user" });
  }

  const copy = STATUS_COPY[body.status] ?? {
    title: "Order update",
    body: `Your order is now ${body.status}.`,
  };

  const serviceAccount = JSON.parse(serviceAccountJson);
  const accessToken = await getAccessToken(serviceAccountJson);

  const fcmResponse = await fetch(
    `https://fcm.googleapis.com/v1/projects/${serviceAccount.project_id}/messages:send`,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${accessToken}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        message: {
          token: profile.fcm_token,
          notification: { title: copy.title, body: copy.body },
          data: { orderId: body.orderId, status: body.status },
        },
      }),
    },
  );
  const fcmData = await fcmResponse.json();

  return Response.json(fcmData, { status: fcmResponse.status });
});
