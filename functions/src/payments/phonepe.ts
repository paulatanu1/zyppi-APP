import { defineSecret, defineString } from "firebase-functions/params";

// PhonePe Standard Checkout v2. Secrets never reach the client:
//   firebase functions:secrets:set PHONEPE_CLIENT_ID   (… and the others)
export const PHONEPE_CLIENT_ID = defineSecret("PHONEPE_CLIENT_ID");
export const PHONEPE_CLIENT_SECRET = defineSecret("PHONEPE_CLIENT_SECRET");
export const PHONEPE_CLIENT_VERSION = defineSecret("PHONEPE_CLIENT_VERSION");
export const PHONEPE_MERCHANT_ID = defineSecret("PHONEPE_MERCHANT_ID");
/** SANDBOX or PRODUCTION (functions/.env.<project> or prompted on deploy). */
export const PHONEPE_ENV = defineString("PHONEPE_ENV", { default: "SANDBOX" });

export const PHONEPE_SECRETS = [
  PHONEPE_CLIENT_ID,
  PHONEPE_CLIENT_SECRET,
  PHONEPE_CLIENT_VERSION,
  PHONEPE_MERCHANT_ID,
];

const isProd = () => PHONEPE_ENV.value() === "PRODUCTION";

export const phonePeBase = () =>
  isProd() ? "https://api.phonepe.com/apis/pg" : "https://api-preprod.phonepe.com/apis/pg-sandbox";

export async function getPhonePeAccessToken(): Promise<string> {
  const url = isProd()
    ? "https://api.phonepe.com/apis/identity-manager/v1/oauth/token"
    : "https://api-preprod.phonepe.com/apis/pg-sandbox/v1/oauth/token";
  const response = await fetch(url, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: PHONEPE_CLIENT_ID.value(),
      client_secret: PHONEPE_CLIENT_SECRET.value(),
      client_version: PHONEPE_CLIENT_VERSION.value(),
      grant_type: "client_credentials",
    }),
  });
  const data = (await response.json()) as { access_token?: string };
  if (!response.ok || !data.access_token) {
    throw new Error(`PhonePe auth failed: ${JSON.stringify(data)}`);
  }
  return data.access_token;
}

export function paymentModeConfig(paymentMethod: string) {
  if (paymentMethod === "Credit or debit card") {
    return { enabledPaymentModes: [{ type: "CARD", cardTypes: ["DEBIT_CARD", "CREDIT_CARD"] }] };
  }
  return {
    enabledPaymentModes: [{ type: "UPI_INTENT" }, { type: "UPI_COLLECT" }, { type: "UPI_QR" }],
  };
}
