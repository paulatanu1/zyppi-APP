import { describe, expect, it } from "vitest";
import {
  SELFIE_FAILS_PER_DAY,
  SELFIE_MAX_AGE_MS,
  SELFIE_MIN_SCORE,
  judgeSelfie,
  readSelfie,
} from "../../src/dispatch/selfie";

const now = Date.UTC(2026, 10, 24, 6);
const ok = { path: "riders/u1/duty/1764000000000.jpg", score: 0.9, noReference: false };

describe("readSelfie", () => {
  it("takes the rider's own duty selfie", () => {
    expect(readSelfie("u1", ok)).toEqual(ok);
    expect(readSelfie("u1", { path: ok.path, noReference: true })).toEqual({
      path: ok.path,
      score: null,
      noReference: true,
    });
  });

  it("refuses missing, foreign or odd paths and missing scores", () => {
    expect(readSelfie("u1", undefined)).toBeNull();
    expect(readSelfie("u1", { ...ok, path: "riders/u2/duty/1.jpg" })).toBeNull();
    expect(readSelfie("u1", { ...ok, path: "riders/u1/kyc/selfie.jpg" })).toBeNull();
    expect(readSelfie("u1", { ...ok, path: "riders/u1/duty/../kyc/a.jpg" })).toBeNull();
    expect(readSelfie("u1", { path: ok.path, score: "0.9" })).toBeNull();
    expect(readSelfie("u1", { path: ok.path, score: Number.NaN })).toBeNull();
  });
});

describe("judgeSelfie", () => {
  const fresh = { uploadedMs: now - 30_000, nowMs: now, failsToday: 0 };

  it("passes a fresh selfie at or above the score", () => {
    expect(judgeSelfie(ok, fresh)).toBe("ok");
    expect(judgeSelfie({ ...ok, score: SELFIE_MIN_SCORE }, fresh)).toBe("ok");
  });

  it("refuses a low score", () => {
    expect(judgeSelfie({ ...ok, score: SELFIE_MIN_SCORE - 0.01 }, fresh)).toBe("SELFIE_MISMATCH");
  });

  it("lets liveness-only (no reference) through", () => {
    expect(judgeSelfie({ ...ok, score: null, noReference: true }, fresh)).toBe("ok");
  });

  it("needs a selfie uploaded in the last few minutes", () => {
    expect(judgeSelfie(null, fresh)).toBe("SELFIE_REQUIRED");
    expect(judgeSelfie(ok, { ...fresh, uploadedMs: null })).toBe("SELFIE_REQUIRED");
    expect(judgeSelfie(ok, { ...fresh, uploadedMs: now - SELFIE_MAX_AGE_MS - 1 })).toBe("SELFIE_REQUIRED");
  });

  it("locks after too many failures in a day", () => {
    expect(judgeSelfie(ok, { ...fresh, failsToday: SELFIE_FAILS_PER_DAY })).toBe("SELFIE_LOCKED");
    expect(judgeSelfie(ok, { ...fresh, failsToday: SELFIE_FAILS_PER_DAY - 1 })).toBe("ok");
  });
});
