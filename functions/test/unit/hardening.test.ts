import { HttpsError } from "firebase-functions/https";
import { describe, expect, it } from "vitest";
import {
  checkAppCheck,
  checkSuperAdminMfa,
  hardeningEnv,
  secondFactorOf,
} from "../../src/shared/hardening";

const monitor = { appCheckEnforce: false, superAdminMfa: false };
const strict = { appCheckEnforce: true, superAdminMfa: true };
const req = (app?: object) => ({ app, rawRequest: { path: "/" } }) as Parameters<typeof checkAppCheck>[0];

describe("hardeningEnv", () => {
  it("is off unless switched on explicitly", () => {
    expect(hardeningEnv({})).toEqual(monitor);
    expect(hardeningEnv({ APP_CHECK_ENFORCE: "1", SUPER_ADMIN_MFA: "yes" })).toEqual(monitor);
    expect(hardeningEnv({ APP_CHECK_ENFORCE: "true", SUPER_ADMIN_MFA: "required" })).toEqual(strict);
  });
});

describe("checkAppCheck", () => {
  it("lets verified calls through in both modes", () => {
    expect(() => checkAppCheck(req({ appId: "x", token: {} }), strict)).not.toThrow();
  });

  it("only logs a missing token in monitor mode", () => {
    expect(() => checkAppCheck(req(), monitor)).not.toThrow();
  });

  it("rejects a missing token when enforced", () => {
    expect(() => checkAppCheck(req(), strict)).toThrow(HttpsError);
  });
});

describe("checkSuperAdminMfa", () => {
  const withTotp = { firebase: { sign_in_second_factor: "totp" } };

  it("reads the second factor from the ID token", () => {
    expect(secondFactorOf(withTotp)).toBe("totp");
    expect(secondFactorOf({ firebase: {} })).toBeNull();
    expect(secondFactorOf(undefined)).toBeNull();
  });

  it("needs the factor from super admins only, and only when required", () => {
    expect(() => checkSuperAdminMfa("super_admin", {}, strict)).toThrow(/MFA_REQUIRED/);
    expect(() => checkSuperAdminMfa("super_admin", withTotp, strict)).not.toThrow();
    expect(() => checkSuperAdminMfa("ops", {}, strict)).not.toThrow();
    expect(() => checkSuperAdminMfa("super_admin", {}, monitor)).not.toThrow();
  });
});
