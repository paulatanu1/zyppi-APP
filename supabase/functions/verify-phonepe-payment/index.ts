// Confirms a PhonePe order's status server-side (PHONEPE_CLIENT_SECRET
// never reaches the client, mirrors the old verify-razorpay-payment). The
// client calls this after the SDK's startTransaction returns SUCCESS, and
// only proceeds to place_order() if {"verified": true} comes back.
//
// Request body: {"merchantOrderId": string}

const SANDBOX_BASE = "https://api-preprod.phonepe.com/apis/pg-sandbox";
const SANDBOX_OAUTH = "https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token";
const PROD_BASE = "https://api.phonepe.com/apis/pg";
const PROD_OAUTH = "https://api.phonepe.com/apis/identity-manager/v1/oauth/token";

async function getAccessToken(env: string): Promise<string> {
  const clientId = Deno.env.get("PHONEPE_CLIENT_ID")!;
  const clientSecret = Deno.env.get("PHONEPE_CLIENT_SECRET")!;
  const clientVersion = Deno.env.get("PHONEPE_CLIENT_VERSION")!;

  const response = await fetch(env === "PRODUCTION" ? PROD_OAUTH : SANDBOX_OAUTH, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: clientId,
      client_secret: clientSecret,
      client_version: clientVersion,
      grant_type: "client_credentials",
    }),
  });

  const data = await response.json();
  if (!response.ok) {
    throw new Error(`PhonePe auth failed: ${JSON.stringify(data)}`);
  }
  return data.access_token as string;
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const env = Deno.env.get("PHONEPE_ENV") ?? "SANDBOX";

  let body: { merchantOrderId?: string };
  try {
    body = await req.json();
  } catch {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }

  const { merchantOrderId } = body;
  if (!merchantOrderId) {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }

  let accessToken: string;
  try {
    accessToken = await getAccessToken(env);
  } catch (error) {
    return Response.json({ error: String(error) }, { status: 502 });
  }

  const response = await fetch(
    `${env === "PRODUCTION" ? PROD_BASE : SANDBOX_BASE}/checkout/v2/order/${merchantOrderId}/status?details=true`,
    {
      headers: { Authorization: `O-Bearer ${accessToken}` },
    },
  );

  const data = await response.json();
  if (!response.ok) {
    return Response.json(data, { status: response.status });
  }

  return Response.json({
    verified: data.state === "COMPLETED",
    transactionId: data.paymentDetails?.[0]?.transactionId ?? null,
  });
});
