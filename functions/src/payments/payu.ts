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
]);

/**
 * Saved-card commands CheckoutPro runs for the customer's PayU user
 * credential (`<key>:<uid>`, var1). Signed only when var1 is the caller's
 * own credential, so nobody can list or delete another customer's cards.
 */
export const USER_COMMANDS = new Set([
  "get_user_cards",
  "save_user_card",
  "edit_user_card",
  "delete_user_card",
  "get_payment_instrument",
  "save_payment_instrument",
  "delete_payment_instrument",
  "get_payment_details",
]);

/** The PayU user credential for a customer. */
export const userCredential = (merchantKey: string, uid: string) => `${merchantKey}:${uid}`;

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

/**
 * Optional CheckoutPro features (offers, quick-pay) that ask for PayU's
 * API-style signature, `body|date|` + salt. Such a signature isn't tied
 * to one command, so it's only given for these names, for a fresh date,
 * and (checked by the caller) during the user's own open checkout.
 */
export const SDK_EVENT_HASHES = new Set(["get_all_offer_details", "quickPayEvent", "binBaseDetails"]);

/**
 * The JSON fields each SDK event body may carry, as CheckoutPro 1.5.0
 * sends them (from the audit log). null would mean "any object".
 */
const SDK_EVENT_FIELDS: Record<string, ReadonlySet<string> | null> = {
  get_all_offer_details: new Set(["amount"]),
  quickPayEvent: new Set([
    "amount",
    "deviceId",
    "phone",
    "requestId",
    "requestType",
    "userToken",
    "userCredential",
  ]),
  binBaseDetails: new Set([
    "amount",
    "cardNumber",
    "disableConvFeeCompounding",
    "isPricingCFEnable",
    "isSITxn",
    "merchantKey",
    "source",
    "txnId",
  ]),
};

/** How far an SDK event's date may be from the server clock. */
export const SDK_EVENT_MAX_SKEW_MS = 5 * 60 * 1000;

export type HashDecision =
  | { kind: "command" }
  | { kind: "userCommand"; credential: string }
  | {
      kind: "sdkEvent";
      bodyShape: string;
      /** Each, when present, must be the caller's own (checked by the caller). */
      amountPaise: number | null;
      txnid: string | null;
      credential: string | null;
    }
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
export function classifyHash(
  request: HashRequest,
  merchantKey: string,
  now: number = Date.now(),
): HashDecision {
  const { hashName, hashString } = request;
  if (!hashName || typeof hashString !== "string" || hashString.length > 20000) {
    return { kind: "reject", reason: "malformed" };
  }
  if (hashName === "mcpLookup") return { kind: "reject", reason: "mcp not enabled" };

  if (SDK_EVENT_HASHES.has(hashName) && request.hashType !== "V2") {
    return classifySdkEvent(hashName, hashString, now);
  }

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
  if (USER_COMMANDS.has(field2)) return { kind: "userCommand", credential: parts[2] };
  if (/^z[A-Za-z0-9]{24}$/.test(field2)) {
    const amountPaise = amountToPaise(parts[2]);
    if (Number.isNaN(amountPaise)) return { kind: "reject", reason: "bad amount" };
    return { kind: "payment", txnid: field2, amountPaise };
  }
  return { kind: "reject", reason: `command ${field2} not allowed` };
}

function classifySdkEvent(hashName: string, hashString: string, now: number): HashDecision {
  const parts = hashString.split("|");
  if (parts.length !== 3 || parts[2] !== "" || parts[0].length > 4000) {
    return { kind: "reject", reason: `sdk event shape (parts=${parts.length})` };
  }
  const date = Date.parse(parts[1]);
  if (!/^[A-Z][a-z]{2}, \d{2} [A-Z][a-z]{2} \d{4} \d{2}:\d{2}:\d{2} GMT$/.test(parts[1]) ||
      Number.isNaN(date) ||
      Math.abs(now - date) > SDK_EVENT_MAX_SKEW_MS) {
    return { kind: "reject", reason: "sdk event date" };
  }

  let body: unknown;
  try {
    body = JSON.parse(parts[0]);
  } catch {
    return { kind: "reject", reason: "sdk event body not json" };
  }
  if (!body || typeof body !== "object" || Array.isArray(body)) {
    return { kind: "reject", reason: "sdk event body not an object" };
  }
  const fields = Object.keys(body);
  const allowed = SDK_EVENT_FIELDS[hashName];
  const extra = allowed ? fields.filter((field) => !allowed.has(field)) : [];
  if (extra.length > 0) {
    return { kind: "reject", reason: `sdk event fields ${extra.sort().join(",")}` };
  }

  // Amount, txnid and credential must be the caller's own checkout's
  // (checked by the caller).
  const record = body as Record<string, unknown>;
  let amountPaise: number | null = null;
  if ("amount" in record) {
    amountPaise = amountToPaise(record.amount);
    if (Number.isNaN(amountPaise)) return { kind: "reject", reason: "sdk event amount" };
  }
  const text = (field: string) => (field in record ? String(record[field] ?? "") : null);
  return {
    kind: "sdkEvent",
    bodyShape: describeBody(parts[0]),
    amountPaise,
    txnid: text("txnId"),
    credential: text("userCredential"),
  };
}

/** A body's field names (never values), for the audit log. */
export function describeBody(body: string): string {
  try {
    const parsed: unknown = JSON.parse(body);
    if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) {
      return `json{${Object.keys(parsed).sort().join(",")}}`;
    }
    return `json(${Array.isArray(parsed) ? "array" : typeof parsed})`;
  } catch {
    return `text(len=${body.length})`;
  }
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

// ---------------------------------------------------------------------------
// Refunds (admin panel). Server-only: these commands are never signed for the
// app (see SIGNABLE_COMMANDS).
// ---------------------------------------------------------------------------

export type RefundRequestResult =
  | { ok: true; requestId: string }
  | { ok: false; reason: string };

export type RefundState = "succeeded" | "failed" | "pending";

/** PayU's answer to cancel_refund_transaction. */
export function mapRefundRequest(data: Record<string, unknown>): RefundRequestResult {
  const requestId = data.request_id != null ? String(data.request_id) : "";
  if (Number(data.status) === 1 && requestId) return { ok: true, requestId };
  return { ok: false, reason: String(data.msg ?? data.error_code ?? "Refund refused by PayU") };
}

/**
 * PayU's answer to check_action_status for one request id:
 * transaction_details[requestId][mihpayid].status.
 */
export function mapRefundStatus(data: Record<string, unknown>, requestId: string): RefundState {
  const details = (data.transaction_details ?? {}) as Record<string, unknown>;
  const byPayment = (details[requestId] ?? {}) as Record<string, Record<string, unknown>>;
  const entry = Object.values(byPayment)[0];
  const status = String(entry?.status ?? "").toLowerCase();
  if (status === "success") return "succeeded";
  if (status === "failure" || status === "failed") return "failed";
  return "pending";
}

async function postService(command: string, vars: Record<string, string>) {
  const key = merchantKey();
  const response = await fetch(`${payUBase()}/merchant/postservice.php?form=2`, {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      key,
      command,
      ...vars,
      hash: sha512(`${key}|${command}|${vars.var1}|${merchantSalt()}`),
    }),
  });
  if (!response.ok) throw new Error(`PayU ${command} HTTP ${response.status}`);
  return (await response.json()) as Record<string, unknown>;
}

/** Full or partial refund of a captured payment. `token` must be unique per refund. */
export async function requestPayURefund(
  mihpayid: string,
  token: string,
  amountPaise: number,
): Promise<RefundRequestResult> {
  const data = await postService("cancel_refund_transaction", {
    var1: mihpayid,
    var2: token,
    var3: amountString(amountPaise),
  });
  const result = mapRefundRequest(data);
  logger.info("PayU refund request", { mihpayid, token, ok: result.ok, msg: data.msg });
  return result;
}

export async function checkPayURefund(requestId: string): Promise<RefundState> {
  const data = await postService("check_action_status", { var1: requestId });
  return mapRefundStatus(data, requestId);
}

/** Swappable in tests. */
export interface PayURefunds {
  request: typeof requestPayURefund;
  check: typeof checkPayURefund;
}

export const payURefunds: PayURefunds = { request: requestPayURefund, check: checkPayURefund };
