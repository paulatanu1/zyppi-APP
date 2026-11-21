import { describe, expect, it } from "vitest";
import { LOCK_MINUTES, MAX_FAILS, nextLockState, readStoreSignIn } from "../../src/marketplace/store_code_auth";

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
