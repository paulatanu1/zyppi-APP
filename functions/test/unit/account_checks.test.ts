import { HttpsError } from "firebase-functions/https";
import { describe, expect, it } from "vitest";
import { hasContactPhone } from "../../src/shared/account_checks";
import { isGuestToken, requireAccount } from "../../src/shared/callable";

type Req = Parameters<typeof requireAccount>[0];
const call = (token?: object) =>
  ({ auth: token ? { uid: "u1", token } : undefined, app: { appId: "a" }, rawRequest: { path: "/" } }) as unknown as Req;

describe("isGuestToken", () => {
  it("spots anonymous sign-ins only", () => {
    expect(isGuestToken({ firebase: { sign_in_provider: "anonymous" } })).toBe(true);
    expect(isGuestToken({ firebase: { sign_in_provider: "google.com" } })).toBe(false);
    expect(isGuestToken({ firebase: { sign_in_provider: "password" } })).toBe(false);
    expect(isGuestToken(undefined)).toBe(false);
  });
});

describe("requireAccount", () => {
  it("returns the uid of a Google or email account", () => {
    expect(requireAccount(call({ firebase: { sign_in_provider: "password" } }))).toBe("u1");
  });

  it("refuses guests with ACCOUNT_REQUIRED", () => {
    expect(() => requireAccount(call({ firebase: { sign_in_provider: "anonymous" } }))).toThrowError(
      new HttpsError("failed-precondition", "ACCOUNT_REQUIRED"),
    );
  });

  it("refuses signed-out callers", () => {
    expect(() => requireAccount(call())).toThrowError(HttpsError);
  });
});

describe("hasContactPhone", () => {
  it("accepts E.164 and plain 10-digit numbers", () => {
    expect(hasContactPhone("+919876543210")).toBe(true);
    expect(hasContactPhone("9876543210")).toBe(true);
  });

  it("rejects missing, blank and junk values", () => {
    expect(hasContactPhone(undefined)).toBe(false);
    expect(hasContactPhone("")).toBe(false);
    expect(hasContactPhone("  ")).toBe(false);
    expect(hasContactPhone("call me")).toBe(false);
    expect(hasContactPhone(9876543210)).toBe(false);
  });
});
