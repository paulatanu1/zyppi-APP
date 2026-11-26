import { HttpsError } from "firebase-functions/https";
import { logger } from "firebase-functions";
import { afterEach, describe, expect, it, vi } from "vitest";
import { APP_CHECK_LOG_SAMPLE, appCheckLogSampler, checkAppCheck, hardeningEnv } from "../../src/shared/hardening";

const monitor = { appCheckEnforce: false, appCheckEnforceWeb: false, appCheckEnforcePartner: false };
const strict = { appCheckEnforce: true, appCheckEnforceWeb: true, appCheckEnforcePartner: false };
const appsOnly = { appCheckEnforce: true, appCheckEnforceWeb: false, appCheckEnforcePartner: false };
const req = (app?: object) => ({ app, rawRequest: { path: "/" } }) as Parameters<typeof checkAppCheck>[0];

describe("hardeningEnv", () => {
  it("is off unless switched on explicitly", () => {
    expect(hardeningEnv({})).toEqual(monitor);
    expect(hardeningEnv({ APP_CHECK_ENFORCE: "1" })).toEqual(monitor);
    expect(hardeningEnv({ APP_CHECK_ENFORCE: "true" })).toEqual(appsOnly);
    expect(hardeningEnv({ APP_CHECK_ENFORCE: "true", APP_CHECK_ENFORCE_WEB: "true" })).toEqual(strict);
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

  it("enforces the apps and the web separately", () => {
    expect(() => checkAppCheck(req(), appsOnly, "app")).toThrow(HttpsError);
    expect(() => checkAppCheck(req(), appsOnly, "web")).not.toThrow();
  });
});

describe("monitor-mode logging", () => {
  afterEach(() => vi.restoreAllMocks());

  it("logs only the sampled share of tokenless calls, with the rate", () => {
    const info = vi.spyOn(logger, "info").mockImplementation(() => {});
    vi.spyOn(appCheckLogSampler, "pick").mockReturnValueOnce(false).mockReturnValueOnce(true);
    checkAppCheck(req(), monitor);
    expect(info).not.toHaveBeenCalled();
    checkAppCheck(req(), monitor);
    expect(info).toHaveBeenCalledWith("Callable without App Check", { caller: "app", path: "/", sampleRate: APP_CHECK_LOG_SAMPLE });
  });

  it("samples about 1%", () => {
    expect(APP_CHECK_LOG_SAMPLE).toBe(0.01);
  });

  it("enforces the customer app without locking out riders and sellers", () => {
    const tokenless = { app: undefined, rawRequest: { path: "/" } } as never;
    expect(() => checkAppCheck(tokenless, appsOnly, "app")).toThrow();
    expect(() => checkAppCheck(tokenless, appsOnly, "partner")).not.toThrow();
    expect(() => checkAppCheck(tokenless, { ...appsOnly, appCheckEnforcePartner: true }, "partner")).toThrow();
    expect(hardeningEnv({ APP_CHECK_ENFORCE_PARTNER: "true" } as never).appCheckEnforcePartner).toBe(true);
  });
});
