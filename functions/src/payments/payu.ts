import { createHash, createHmac, randomInt } from "node:crypto";
import { logger } from "firebase-functions";
import { defineSecret, defineString } from "firebase-functions/params";

// PayU CheckoutPro. The salt never reaches the client; the merchant key is
// sent to the app (the SDK needs it) but is useless without the salt.
//   firebase functions:secrets:set PAYU_MERCHANT_KEY
//   firebase functions:secrets:set PAYU_SALT
export const PAYU_MERCHANT_KEY = defineSecret("PAYU_MERCHANT_KEY");
export const PAYU_SALT = defineSecret("PAYU_SALT");
/** TEST or PRODUCTION (functions/.env.<project> or prompted on deploy). */
export const PAYU_ENV = defineString("PAYU_ENV", { default: "TEST" });

export const PAYU_SECRETS = [PAYU_MERCHANT_KEY, PAYU_SALT];

// Trimmed: a secret pasted or piped with a trailing newline would
// otherwise never match the key the SDK puts in its hash strings.
export const merchantKey = () => PAYU_MERCHANT_KEY.value().trim();
export const merchantSalt = () => PAYU_SALT.value().trim();

export const isPayUProd = () => PAYU_ENV.value() === "PRODUCTION";

/** CheckoutPro's `environment` param: "0" production, "1" test. */
export const payUSdkEnvironment = () => (isPayUProd() ? "0" : "1");

const payUBase = () => (isPayUProd() ? "https://info.payu.in" : "https://test.payu.in");

export const sha512 = (value: string) => createHash("sha512").update(value).digest("hex");

/** Paise → PayU's rupee string with two decimals, e.g. 47700 → "477.00". */
export function amountString(paise: number): string {
  return `${Math.trunc(paise / 100)}.${String(paise % 100).padStart(2, "0")}`;
}

/** PayU's rupee string → paise; NaN for anything that isn't an amount. */
export function amountToPaise(value: unknown): number {
  const text = String(value ?? "").trim();
  if (!/^\d+(\.\d{1,2})?$/.test(text)) return Number.NaN;
  const [rupees, fraction = ""] = text.split(".");
  return Number(rupees) * 100 + Number(fraction.padEnd(2, "0"));
}

const TXNID_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

/** PayU txnids are limited to 25 characters: "z" + 24 random. */
export function newTxnId(): string {
  let id = "z";
  for (let i = 0; i < 24; i++) id += TXNID_CHARS[randomInt(TXNID_CHARS.length)];
  return id;
}

export const TXNID_PATTERN = /\bz[A-Za-z0-9]{24}\b/g;

/**
 * Read-only PayU commands CheckoutPro asks the merchant to sign (payment
 * options, offers, EMI, BIN / VPA checks). Everything else — refunds,
 * captures, cancellations, saved cards, settlement — is refused, so the app can't
 * use this server to authorise PayU admin calls.
 */
export const SIGNABLE_COMMANDS = new Set([
  "payment_related_details_for_mobile_sdk",
  "vas_for_mobile_sdk",
  "get_eligible_payment_options",
  "get_checkout_details",
  "get_sdk_configuration",
  "getEmiAmountAccordingToInterest",
  "eligibleBinsForEMI",
  "check_offer_status",
  "get_all_offer_details",
  "check_offer_details",
  "check_isDomestic",
  "getBinInfo",
  "validateVPA",
  "get_payment_instrument",
]);

/** What the SDK sent to `generateHash`. */
export interface HashRequest {
  hashName: string;
  hashString: string;
  hashType?: string | null;
  postSalt?: string | null;
}

/** An open payment intent of the caller, looked up by txnid. */
export interface OwnIntent {
  txnid: string;
  amountPaise: number;
}

export type HashDecision =
  | { kind: "command" }
  | { kind: "payment"; txnid: string; amountPaise: number }
  | { kind: "v2"; txnids: string[] }
  | { kind: "reject"; reason: string };

/**
 * Classifies a hash request before anything is signed. A V1 string is
 * `key|<field2>|…`: field2 is either an allow-listed command or one of
 * our txnids (which never look like a command), in which case field3 is
 * its amount and must match the intent (checked by the caller). V2
 * (HMAC) strings are only signed when they name the caller's own txnid.
 */
export function classifyHash(request: HashRequest, merchantKey: string): HashDecision {
  const { hashName, hashString } = request;
  if (!hashName || typeof hashString !== "string" || hashString.length > 20000) {
    return { kind: "reject", reason: "malformed" };
  }
  if (hashName === "mcpLookup") return { kind: "reject", reason: "mcp not enabled" };

  if (request.hashType === "V2") {
    const txnids = [...new Set(hashString.match(TXNID_PATTERN) ?? [])];
    return txnids.length > 0
      ? { kind: "v2", txnids }
      : { kind: "reject", reason: "v2 without txnid" };
  }

  const parts = hashString.split("|");
  if (parts[0] !== merchantKey || parts.length < 3) {
    // Shape only — never the string itself (it can hold the payer's
    // email / phone).
    return {
      kind: "reject",
      reason:
        `wrong key (parts=${parts.length}, field1Len=${parts[0].length}, ` +
        `keyAt=${hashString.indexOf(merchantKey)}, field2=${describeField(parts[1])})`,
    };
  }
  const field2 = parts[1];
  if (SIGNABLE_COMMANDS.has(field2)) return { kind: "command" };
  if (/^z[A-Za-z0-9]{24}$/.test(field2)) {
    const amountPaise = amountToPaise(parts[2]);
    if (Number.isNaN(amountPaise)) return { kind: "reject", reason: "bad amount" };
    return { kind: "payment", txnid: field2, amountPaise };
  }
  return { kind: "reject", reason: `command ${field2} not allowed` };
}

/** A hash-string field for logs: command names as-is, anything else by shape. */
function describeField(value: string | undefined): string {
  if (value === undefined) return "none";
  if (/^[A-Za-z_]{1,64}$/.test(value)) return value;
  if (/^z[A-Za-z0-9]{24}$/.test(value)) return "txnid";
  return `other(len=${value.length})`;
}

/** PayU's documented hash recipe for CheckoutPro's `generateHash`. */
export function signHash(request: HashRequest, salt: string): string {
  if (request.hashType === "V2") {
    return createHmac("sha256", salt).update(request.hashString).digest("base64");
  }
  return sha512(request.hashString + salt + (request.postSalt ?? ""));
}

export type PayUOutcome =
  | { state: "paid"; mihpayid: string; amountPaise: number }
  | { state: "pending" }
  | { state: "failed"; reason: string };

/**
 * Maps one `transaction_details[txnid]` entry of verify_payment. Only
 * `success` + `captured` is money in the bank; `auth` / `pending` /
 * `in progress` settle later. "Not Found" / `initiated` mean the
 * checkout opened but no payment was submitted (verify only runs once
 * the SDK has closed) — failed, though the intent stays re-checkable.
 */
export function mapVerifyResult(detail: Record<string, unknown> | undefined): PayUOutcome {
  if (!detail) return { state: "pending" };
  const status = String(detail.status ?? "").toLowerCase();
  const unmapped = String(detail.unmappedstatus ?? "").toLowerCase();

  if (status === "success" && (unmapped === "captured" || unmapped === "")) {
    const mihpayid = String(detail.mihpayid ?? "");
    const amountPaise = amountToPaise(detail.transaction_amount ?? detail.amt);
    if (!mihpayid || Number.isNaN(amountPaise)) return { state: "pending" };
    return { state: "paid", mihpayid, amountPaise };
  }
  if (status === "not found") return { state: "failed", reason: "NOT_FOUND" };
  if (
    status === "failure" ||
    ["failed", "bounced", "dropped", "usercancelled", "cancelled", "initiated"].includes(unmapped)
  ) {
    return { state: "failed", reason: unmapped || status };
  }
  return { state: "pending" };
}

/** Server-to-server verify_payment for one txnid. */
export async function verifyPayUTxn(txnid: string): Promise<PayUOutcome> {
  const key = merchantKey();
  const command = "verify_payment";
  const response = await fetch(`${payUBase()}/merchant/postservice.php?form=2`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      key,
      command,
      var1: txnid,
      hash: sha512(`${key}|${command}|${txnid}|${merchantSalt()}`),
    }),
  });
  if (!response.ok) throw new Error(`PayU verify HTTP ${response.status}`);
  const data = (await response.json()) as {
    status?: unknown;
    msg?: unknown;
    transaction_details?: Record<string, Record<string, unknown>>;
  };
  const detail = data.transaction_details?.[txnid];
  const outcome = mapVerifyResult(detail);
  // Statuses only — the detail also holds the payer's name/email/phone.
  logger.info("PayU verify", {
    txnid,
    apiStatus: data.status,
    msg: data.msg,
    status: detail?.status,
    unmappedstatus: detail?.unmappedstatus,
    outcome: outcome.state,
  });
  return outcome;
}
