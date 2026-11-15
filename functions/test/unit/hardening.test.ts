import { HttpsError } from "firebase-functions/https";
import { describe, expect, it } from "vitest";
import { checkAppCheck, hardeningEnv } from "../../src/shared/hardening";

const monitor = { appCheckEnforce: false };
const strict = { appCheckEnforce: true };
const req = (app?: object) => ({ app, rawRequest: { path: "/" } }) as Parameters<typeof checkAppCheck>[0];

describe("hardeningEnv", () => {
  it("is off unless switched on explicitly", () => {
    expect(hardeningEnv({})).toEqual(monitor);
    expect(hardeningEnv({ APP_CHECK_ENFORCE: "1" })).toEqual(monitor);
    expect(hardeningEnv({ APP_CHECK_ENFORCE: "true" })).toEqual(strict);
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
