// Creates a PhonePe Standard Checkout order server-side
// (PHONEPE_CLIENT_SECRET never reaches the client - mirrors the old
// create-razorpay-order). The client opens the PhonePe SDK's PAY_PAGE
// with the returned order id/token, then calls verify-phonepe-payment
// before place_order().
//
// Requires Edge Function secrets: PHONEPE_CLIENT_ID, PHONEPE_CLIENT_SECRET,
// PHONEPE_CLIENT_VERSION, PHONEPE_MERCHANT_ID, PHONEPE_ENV (SANDBOX or
// PRODUCTION):
// `supabase secrets set PHONEPE_CLIENT_ID=... PHONEPE_CLIENT_SECRET=... \
//   PHONEPE_CLIENT_VERSION=... PHONEPE_MERCHANT_ID=... PHONEPE_ENV=SANDBOX`.
//
// Request body: {"amountPaise": number, "paymentMethod": "UPI" | "Credit or debit card"}

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

function paymentModeConfig(paymentMethod: string) {
  if (paymentMethod === "Credit or debit card") {
    return {
      enabledPaymentModes: [
        { type: "CARD", cardTypes: ["DEBIT_CARD", "CREDIT_CARD"] },
      ],
    };
  }
  return {
    enabledPaymentModes: [
      { type: "UPI_INTENT" },
      { type: "UPI_COLLECT" },
      { type: "UPI_QR" },
    ],
  };
}

Deno.serve(async (req) => {
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const merchantId = Deno.env.get("PHONEPE_MERCHANT_ID");
  const env = Deno.env.get("PHONEPE_ENV") ?? "SANDBOX";
  if (!merchantId) {
    return Response.json(
      { error: "PhonePe keys not configured" },
      { status: 500 },
    );
  }

  let body: { amountPaise?: number; paymentMethod?: string };
  try {
    body = await req.json();
  } catch {
    return Response.json({ error: "Invalid request" }, { status: 400 });
  }

  if (!body.amountPaise || body.amountPaise <= 0) {
    return Response.json({ error: "Invalid amountPaise" }, { status: 400 });
  }

  const merchantOrderId = `zyppi-${Date.now()}`;

  let accessToken: string;
  try {
    accessToken = await getAccessToken(env);
  } catch (error) {
    return Response.json({ error: String(error) }, { status: 502 });
  }

  const response = await fetch(
    `${env === "PRODUCTION" ? PROD_BASE : SANDBOX_BASE}/checkout/v2/sdk/order`,
    {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Authorization: `O-Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        merchantOrderId,
        amount: body.amountPaise,
        paymentFlow: {
          type: "PG_CHECKOUT",
          paymentModeConfig: paymentModeConfig(body.paymentMethod ?? "UPI"),
        },
      }),
    },
  );

  const data = await response.json();
  if (!response.ok) {
    return Response.json(data, { status: response.status });
  }

  return Response.json({
    merchantOrderId,
    orderId: data.orderId,
    token: data.token,
    merchantId,
  });
});
