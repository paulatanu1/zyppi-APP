import { createHash, createHmac } from "node:crypto";
import { describe, expect, it } from "vitest";
import {
  amountString,
  amountToPaise,
  classifyHash,
  describeBody,
  mapVerifyResult,
  newTxnId,
  signHash,
} from "../../src/payments/payu";

const KEY = "testKey";
const SALT = "testSalt";
const TXN = "zAbCdEfGhIjKlMnOpQrStUvWx";

describe("amounts", () => {
  it("formats paise as PayU rupees", () => {
    expect(amountString(47700)).toBe("477.00");
    expect(amountString(47705)).toBe("477.05");
    expect(amountString(5)).toBe("0.05");
  });

  it("parses PayU rupees back to paise", () => {
    expect(amountToPaise("477.00")).toBe(47700);
    expect(amountToPaise("477.5")).toBe(47750);
    expect(amountToPaise("477")).toBe(47700);
    expect(amountToPaise(477)).toBe(47700);
    expect(amountToPaise("-1")).toBeNaN();
    expect(amountToPaise("4.777")).toBeNaN();
    expect(amountToPaise(undefined)).toBeNaN();
  });
});

describe("newTxnId", () => {
  it("fits PayU's 25-character limit and our txnid pattern", () => {
    const id = newTxnId();
    expect(id).toMatch(/^z[A-Za-z0-9]{24}$/);
    expect(newTxnId()).not.toBe(id);
  });
});

describe("classifyHash", () => {
  const paymentString = `${KEY}|${TXN}|477.00|Zyppi order|Asha|a@b.in|||||||||||`;

  it("treats our txnid in field 2 as a payment for that amount", () => {
    expect(classifyHash({ hashName: "payment", hashString: paymentString }, KEY)).toEqual({
      kind: "payment",
      txnid: TXN,
      amountPaise: 47700,
    });
  });

  it("allows read-only SDK commands", () => {
    const hashString = `${KEY}|payment_related_details_for_mobile_sdk|${KEY}:uid|`;
    expect(classifyHash({ hashName: "x", hashString }, KEY)).toEqual({ kind: "command" });
  });

  it("refuses admin commands such as refunds", () => {
    for (const command of ["cancel_refund_transaction", "verify_payment", "capture_transaction"]) {
      const hashString = `${KEY}|${command}|123|`;
      expect(classifyHash({ hashName: "x", hashString }, KEY).kind).toBe("reject");
    }
  });

  it("refuses another merchant key, bad amounts and MCP", () => {
    expect(
      classifyHash({ hashName: "payment", hashString: `other|${TXN}|1.00|` }, KEY).kind,
    ).toBe("reject");
    expect(
      classifyHash({ hashName: "payment", hashString: `${KEY}|${TXN}|abc|` }, KEY).kind,
    ).toBe("reject");
    expect(classifyHash({ hashName: "mcpLookup", hashString: "x" }, KEY).kind).toBe("reject");
  });

  it("only allows V2 strings that name a txnid", () => {
    expect(
      classifyHash({ hashName: "payment", hashString: `{"txnid":"${TXN}"}|date|`, hashType: "V2" }, KEY),
    ).toEqual({ kind: "v2", txnids: [TXN] });
    expect(
      classifyHash({ hashName: "payment", hashString: "{}|date|", hashType: "V2" }, KEY).kind,
    ).toBe("reject");
  });
});

describe("SDK event hashes (offers / quick-pay)", () => {
  const now = Date.parse("Fri, 06 Nov 2026 20:06:04 GMT");
  const date = "Fri, 06 Nov 2026 20:06:04 GMT";

  it("accepts a fresh body|date| string for the allow-listed names", () => {
    expect(
      classifyHash({ hashName: "get_all_offer_details", hashString: `{"a":1,"b":2}|${date}|` }, KEY, now),
    ).toEqual({ kind: "sdkEvent", bodyShape: "json{a,b}" });
    expect(
      classifyHash({ hashName: "quickPayEvent", hashString: `x|${date}|` }, KEY, now).kind,
    ).toBe("sdkEvent");
  });

  it("refuses stale or future dates", () => {
    const stale = "Fri, 06 Nov 2026 19:50:00 GMT";
    expect(
      classifyHash({ hashName: "quickPayEvent", hashString: `{}|${stale}|` }, KEY, now).kind,
    ).toBe("reject");
    expect(
      classifyHash({ hashName: "quickPayEvent", hashString: "{}|not a date|" }, KEY, now).kind,
    ).toBe("reject");
  });

  it("refuses other shapes and other names", () => {
    expect(
      classifyHash({ hashName: "quickPayEvent", hashString: `{}|${date}|extra` }, KEY, now).kind,
    ).toBe("reject");
    expect(
      classifyHash({ hashName: "refund", hashString: `{}|${date}|` }, KEY, now).kind,
    ).toBe("reject");
  });

  it("describes bodies by field names only", () => {
    expect(describeBody('{"phone":"9999999999","key":"k"}')).toBe("json{key,phone}");
    expect(describeBody("plain")).toBe("text(len=5)");
  });
});

describe("signHash", () => {
  it("follows PayU's V1 recipe: sha512(hashString + salt + postSalt)", () => {
    const hashString = `${KEY}|${TXN}|477.00|`;
    expect(signHash({ hashName: "payment", hashString }, SALT)).toBe(
      createHash("sha512").update(hashString + SALT).digest("hex"),
    );
    expect(signHash({ hashName: "payment", hashString, postSalt: "PS" }, SALT)).toBe(
      createHash("sha512").update(hashString + SALT + "PS").digest("hex"),
    );
  });

  it("follows PayU's V2 recipe: base64 HMAC-SHA256 keyed by the salt", () => {
    const hashString = "body|date|";
    expect(signHash({ hashName: "payment", hashString, hashType: "V2" }, SALT)).toBe(
      createHmac("sha256", SALT).update(hashString).digest("base64"),
    );
  });
});

describe("mapVerifyResult", () => {
  it("is paid only when captured", () => {
    expect(
      mapVerifyResult({ status: "success", unmappedstatus: "captured", mihpayid: "403993715", transaction_amount: "477.00" }),
    ).toEqual({ state: "paid", mihpayid: "403993715", amountPaise: 47700 });
    expect(mapVerifyResult({ status: "success", unmappedstatus: "auth", mihpayid: "1" }).state).toBe(
      "pending",
    );
  });

  it("stays pending while PayU is still settling", () => {
    expect(mapVerifyResult(undefined).state).toBe("pending");
    expect(mapVerifyResult({ status: "pending", unmappedstatus: "in progress" }).state).toBe("pending");
    expect(mapVerifyResult({ status: "success", unmappedstatus: "captured" }).state).toBe("pending");
  });

  it("fails cancelled, bounced and unknown transactions", () => {
    expect(mapVerifyResult({ status: "failure", unmappedstatus: "failed" }).state).toBe("failed");
    expect(mapVerifyResult({ status: "pending", unmappedstatus: "userCancelled" }).state).toBe("failed");
    expect(mapVerifyResult({ status: "pending", unmappedstatus: "bounced" }).state).toBe("failed");
    expect(mapVerifyResult({ status: "pending", unmappedstatus: "initiated" }).state).toBe("failed");
    expect(mapVerifyResult({ status: "Not Found", mihpayid: "Not Found" })).toEqual({
      state: "failed",
      reason: "NOT_FOUND",
    });
  });
});
