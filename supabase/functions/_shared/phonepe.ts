// PhonePe Standard Checkout v2 helpers shared by create-phonepe-order and
// verify-phonepe-payment. Secrets (PHONEPE_CLIENT_ID/SECRET/VERSION,
// PHONEPE_MERCHANT_ID, PHONEPE_ENV) never reach the client.

const SANDBOX_BASE = "https://api-preprod.phonepe.com/apis/pg-sandbox";
const SANDBOX_OAUTH = "https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token";
const PROD_BASE = "https://api.phonepe.com/apis/pg";
const PROD_OAUTH = "https://api.phonepe.com/apis/identity-manager/v1/oauth/token";

export const phonePeEnv = () => Deno.env.get("PHONEPE_ENV") ?? "SANDBOX";
export const phonePeBase = () =>
  phonePeEnv() === "PRODUCTION" ? PROD_BASE : SANDBOX_BASE;

export async function getPhonePeAccessToken(): Promise<string> {
  const response = await fetch(
    phonePeEnv() === "PRODUCTION" ? PROD_OAUTH : SANDBOX_OAUTH,
    {
      method: "POST",
      headers: { "Content-Type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({
        client_id: Deno.env.get("PHONEPE_CLIENT_ID")!,
        client_secret: Deno.env.get("PHONEPE_CLIENT_SECRET")!,
        client_version: Deno.env.get("PHONEPE_CLIENT_VERSION")!,
        grant_type: "client_credentials",
      }),
    },
  );

  const data = await response.json();
  if (!response.ok) {
    throw new Error(`PhonePe auth failed: ${JSON.stringify(data)}`);
  }
  return data.access_token as string;
}
