import { describe, expect, it } from "vitest";
import { claimRecovery } from "../../src/wallet/recovery";

const plan = (refundPaise: number, walletPaise = 0) => ({
  resolution: "original" as const,
  walletPaise,
  refundPaise,
  note: "",
  sellerAtFault: false,
});

describe("stuck claim recovery", () => {
  it("reopens when nothing was paid", () => {
    expect(claimRecovery({ kind: "wallet", plan: null, refundFound: false, replacementFound: false })).toBe("reopen");
    expect(claimRecovery({ kind: "original", plan: plan(5000), refundFound: false, replacementFound: false })).toBe("reopen");
    expect(claimRecovery({ kind: "replacement", plan: null, refundFound: false, replacementFound: false })).toBe("reopen");
  });

  it("finishes from what was already paid (never pays twice)", () => {
    expect(claimRecovery({ kind: "original", plan: plan(5000), refundFound: true, replacementFound: false })).toBe("finish");
    // Wallet-only: the credit happens in the finishing step (fixed entry id).
    expect(claimRecovery({ kind: "wallet", plan: plan(0, 3000), refundFound: false, replacementFound: false })).toBe("finish");
    expect(claimRecovery({ kind: "replacement", plan: null, refundFound: false, replacementFound: true })).toBe("finish");
  });
});
