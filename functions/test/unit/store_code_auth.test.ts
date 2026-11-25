import { describe, expect, it } from "vitest";
import {
  LOCK_MINUTES,
  MAX_FAILS,
  STORE_MAX_FAILS,
  callerKey,
  nextLockState,
  nextStoreWindow,
  readStoreSignIn,
} from "../../src/marketplace/store_code_auth";

describe("Store ID sign-in", () => {
  it("reads and normalises the Store ID", () => {
    expect(readStoreSignIn({ storeId: " zs 123456 ", password: "secret1" })).toEqual({ code: "ZS123456", password: "secret1" });
    expect(() => readStoreSignIn({ storeId: "123456", password: "secret1" })).toThrow("STORE_ID_INVALID");
    expect(() => readStoreSignIn({ storeId: "ZS123456", password: "123" })).toThrow("WRONG_PASSWORD");
  });

  it("locks after too many wrong passwords and resets on success", () => {
    let state = { failCount: 0, lockedUntil: null as number | null };
    for (let i = 1; i < MAX_FAILS; i++) {
      state = nextLockState(state, false, 1000);
      expect(state).toEqual({ failCount: i, lockedUntil: null });
    }
    state = nextLockState(state, false, 1000);
    expect(state).toEqual({ failCount: 0, lockedUntil: 1000 + LOCK_MINUTES * 60_000 });
    expect(nextLockState({ failCount: 3 }, true, 1000)).toEqual({ failCount: 0, lockedUntil: null });
  });
});

describe("lockout is per caller, with a shop-wide ceiling (audit SEC-A02)", () => {
  it("hashes the caller's IP, preferring the first forwarded address", () => {
    const a = callerKey({ headers: { "x-forwarded-for": "1.2.3.4, 10.0.0.1" }, ip: "10.0.0.1" });
    expect(a).toBe(callerKey({ ip: "1.2.3.4" }));
    expect(a).not.toBe(callerKey({ ip: "5.6.7.8" }));
    expect(a).toMatch(/^[0-9a-f]{32}$/); // never the IP itself
  });

  it("locks the Store ID only after STORE_MAX_FAILS failures within an hour", () => {
    let w = nextStoreWindow({}, 0);
    for (let i = 1; i < STORE_MAX_FAILS - 1; i++) w = nextStoreWindow(w, i * 1000);
    expect(w.lock).toBe(false);
    expect(nextStoreWindow(w, 60_000).lock).toBe(true);
  });

  it("starts a new window after an hour", () => {
    const w = nextStoreWindow({ windowStart: 0, fails: STORE_MAX_FAILS - 1 }, 61 * 60_000);
    expect(w).toEqual({ windowStart: 61 * 60_000, fails: 1, lock: false });
  });
});
