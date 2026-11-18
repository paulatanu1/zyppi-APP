import { describe, expect, it } from "vitest";
import {
  CLAIM_WINDOW_MS,
  WALLET_BALANCE_CHANGED,
  WALLET_METHOD,
  cashToCollect,
  checkWalletOrder,
  lineRefundPaise,
  onlineRefundable,
  orderRemaining,
  replacementCandidates,
  splitClaimPayout,
  validateClaim,
  walletBalanceOf,
  walletToApply,
} from "../../src/wallet/model";
import { methodKey } from "../../src/stats/model";

const COD = "Cash on delivery";
const ts = (ms: number) => ({ toMillis: () => ms });

describe("wallet at checkout", () => {
  it("uses as much of the balance as the total needs, never more", () => {
    expect(walletToApply(10000, 25000, true)).toBe(10000);
    expect(walletToApply(30000, 25000, true)).toBe(25000);
    expect(walletToApply(30000, 25000, false)).toBe(0);
    expect(walletToApply(-500, 25000, true)).toBe(0);
  });

  it("reads a missing or bad balance as zero", () => {
    expect(walletBalanceOf(undefined)).toBe(0);
    expect(walletBalanceOf({ walletPaise: "100" })).toBe(0);
    expect(walletBalanceOf({ walletPaise: -50 })).toBe(0);
    expect(walletBalanceOf({ walletPaise: 1234 })).toBe(1234);
  });

  it("cash + wallet: cash covers the rest", () => {
    expect(checkWalletOrder({ method: COD, useWallet: true, balancePaise: 10000, totalPaise: 25000, expectedWalletPaise: 10000 })).toEqual({
      ok: true,
      walletPaise: 10000,
      payablePaise: 15000,
      method: COD,
    });
  });

  it("refuses when the balance dropped since the customer saw it", () => {
    // Showed ₹100 from the wallet; another order spent ₹40 meanwhile.
    expect(checkWalletOrder({ method: COD, useWallet: true, balancePaise: 6000, totalPaise: 25000, expectedWalletPaise: 10000 })).toEqual({
      ok: false,
      code: WALLET_BALANCE_CHANGED,
    });
    // Went up (a refund landed): still refused, so the customer sees the new total.
    expect(checkWalletOrder({ method: COD, useWallet: true, balancePaise: 20000, totalPaise: 25000, expectedWalletPaise: 10000 }).ok).toBe(false);
  });

  it("wallet-only needs the balance to cover everything", () => {
    expect(checkWalletOrder({ method: WALLET_METHOD, useWallet: true, balancePaise: 24999, totalPaise: 25000 })).toEqual({
      ok: false,
      code: WALLET_BALANCE_CHANGED,
    });
    expect(checkWalletOrder({ method: WALLET_METHOD, useWallet: false, balancePaise: 30000, totalPaise: 25000 })).toEqual({
      ok: true,
      walletPaise: 25000,
      payablePaise: 0,
      method: WALLET_METHOD,
    });
  });

  it("a cash order the wallet fully covers becomes a wallet order (no ₹0 cash collection)", () => {
    const c = checkWalletOrder({ method: COD, useWallet: true, balancePaise: 30000, totalPaise: 25000 });
    expect(c).toEqual({ ok: true, walletPaise: 25000, payablePaise: 0, method: WALLET_METHOD });
  });

  it("without the wallet nothing changes", () => {
    expect(checkWalletOrder({ method: COD, useWallet: false, balancePaise: 30000, totalPaise: 25000 })).toEqual({
      ok: true,
      walletPaise: 0,
      payablePaise: 25000,
      method: COD,
    });
  });

  it("two orders at once: the second sees the lower balance and is refused", () => {
    // Firestore retries the later transaction with fresh reads.
    const first = checkWalletOrder({ method: COD, useWallet: true, balancePaise: 10000, totalPaise: 25000, expectedWalletPaise: 10000 });
    expect(first.ok).toBe(true);
    const after = 10000 - (first.ok ? first.walletPaise : 0);
    expect(checkWalletOrder({ method: COD, useWallet: true, balancePaise: after, totalPaise: 20000, expectedWalletPaise: 10000 }).ok).toBe(false);
  });
});

describe("cash at the door", () => {
  it("is what the wallet didn't pay", () => {
    expect(cashToCollect({ totalPaise: 25000, payment: { method: COD, amountPaise: 15000 } })).toBe(15000);
  });
  it("older orders: the whole total", () => {
    expect(cashToCollect({ totalPaise: 25000, payment: { method: COD } })).toBe(25000);
  });
  it("online and wallet orders: nothing", () => {
    expect(cashToCollect({ totalPaise: 25000, payment: { method: "UPI", amountPaise: 25000 } })).toBe(0);
    expect(cashToCollect({ totalPaise: 25000, payment: { method: WALLET_METHOD, amountPaise: 0 } })).toBe(0);
  });
  it("stats keep wallet and replacement orders apart", () => {
    expect(methodKey("Wallet")).toBe("wallet");
    expect(methodKey("Replacement")).toBe("replacement");
  });
});

describe("claim value", () => {
  it("is the item price less its share of the coupon", () => {
    const order = { itemTotalPaise: 20000, discountPaise: 2000 };
    // 2 × ₹50 = ₹100, 10% off → ₹90.
    expect(lineRefundPaise({ pricePaise: 5000 }, 2, order)).toBe(9000);
    expect(lineRefundPaise({ pricePaise: 5000 }, 2, { itemTotalPaise: 20000, discountPaise: 0 })).toBe(10000);
    // Rounded down so refunds never add up to more than was paid.
    expect(lineRefundPaise({ pricePaise: 333 }, 1, { itemTotalPaise: 1000, discountPaise: 100 })).toBe(299);
  });

  it("online refundable is the PayU part not refunded yet", () => {
    expect(onlineRefundable({ payment: { method: "UPI", status: "succeeded", amountPaise: 15000 }, refundedPaise: 5000 })).toBe(10000);
    expect(onlineRefundable({ payment: { method: COD, status: "succeeded", amountPaise: 15000 } })).toBe(0);
    expect(onlineRefundable({ payment: { method: "UPI", status: "pending", amountPaise: 15000 } })).toBe(0);
  });

  it("splits back to the online payment first when asked, the rest to the wallet", () => {
    // ₹250 order: ₹100 wallet + ₹150 UPI. Claim ₹200 back to original.
    expect(splitClaimPayout({ amountPaise: 20000, resolution: "original", onlineRefundablePaise: 15000, orderRemainingPaise: 25000 })).toEqual({
      onlinePaise: 15000,
      walletPaise: 5000,
    });
    expect(splitClaimPayout({ amountPaise: 20000, resolution: "wallet", onlineRefundablePaise: 15000, orderRemainingPaise: 25000 })).toEqual({
      onlinePaise: 0,
      walletPaise: 20000,
    });
  });

  it("never gives back more than is left on the order", () => {
    expect(splitClaimPayout({ amountPaise: 20000, resolution: "wallet", onlineRefundablePaise: 0, orderRemainingPaise: 5000 })).toEqual({
      onlinePaise: 0,
      walletPaise: 5000,
    });
    expect(orderRemaining({ totalPaise: 25000, claimWalletPaise: 5000, refundedPaise: 15000 })).toBe(5000);
    expect(orderRemaining({ totalPaise: 25000, claimWalletPaise: 30000 })).toBe(0);
  });
});

describe("reporting a problem", () => {
  const delivered = 1_000_000_000;
  const order = {
    userId: "u1",
    status: "delivered",
    paymentMethod: COD,
    payment: { method: COD, status: "succeeded", amountPaise: 25000 },
    deliveredAt: ts(delivered),
    itemTotalPaise: 20000,
    discountPaise: 0,
    totalPaise: 25000,
    items: [
      { productId: "p1", variantId: "v1", offerId: "o1", sellerId: "s1", name: "Milk", quantity: 2, pricePaise: 5000 },
      { productId: "p2", variantId: "v2", offerId: "o2", sellerId: "zyppi", name: "Eggs", quantity: 1, pricePaise: 10000 },
    ],
  };
  const base = {
    order,
    uid: "u1",
    nowMs: delivered + 30 * 60_000,
    lines: [{ index: 0, quantity: 1, kind: "damaged" }],
    photos: ["users/u1/claims/o-1/a.jpg"],
    note: " leaking ",
    resolution: "wallet",
    photoPrefix: "users/u1/claims/o-1/",
  };

  it("accepts a valid claim and prices it", () => {
    const v = validateClaim(base);
    expect(v.ok).toBe(true);
    if (!v.ok) return;
    expect(v.amountPaise).toBe(5000);
    expect(v.note).toBe("leaking");
    expect(v.lines[0]).toMatchObject({ index: 0, quantity: 1, kind: "damaged", sellerId: "s1", offerId: "o1", amountPaise: 5000 });
  });

  it("only the customer, only delivered orders, only within 2 hours", () => {
    expect(validateClaim({ ...base, uid: "u2" })).toEqual({ ok: false, code: "NOT_YOUR_ORDER" });
    expect(validateClaim({ ...base, order: { ...order, status: "out_for_delivery" } })).toEqual({ ok: false, code: "NOT_DELIVERED" });
    expect(validateClaim({ ...base, nowMs: delivered + CLAIM_WINDOW_MS + 1 })).toEqual({ ok: false, code: "CLAIM_WINDOW_OVER" });
    expect(validateClaim({ ...base, nowMs: delivered + CLAIM_WINDOW_MS }).ok).toBe(true);
  });

  it("one open claim per order; replacements can't be claimed again", () => {
    expect(validateClaim({ ...base, order: { ...order, openIssueId: "i1" } })).toEqual({ ok: false, code: "CLAIM_OPEN" });
    expect(validateClaim({ ...base, order: { ...order, replacementOf: "o0" } })).toEqual({ ok: false, code: "REPLACEMENT_ORDER" });
  });

  it("can't claim more units than were delivered and not yet claimed", () => {
    expect(validateClaim({ ...base, lines: [{ index: 0, quantity: 3, kind: "missing" }] })).toEqual({ ok: false, code: "TOO_MANY_UNITS" });
    expect(validateClaim({ ...base, order: { ...order, claimedQty: { "0": 2 } } })).toEqual({ ok: false, code: "TOO_MANY_UNITS" });
    expect(validateClaim({ ...base, order: { ...order, claimedQty: { "0": 1 }, returns: { "0": 1 } } }).ok).toBe(true);
    expect(validateClaim({ ...base, lines: [{ index: 0, quantity: 1, kind: "damaged" }, { index: 0, quantity: 1, kind: "damaged" }] })).toEqual({
      ok: false,
      code: "INVALID_LINES",
    });
  });

  it("needs a photo unless the item is missing", () => {
    expect(validateClaim({ ...base, photos: [] })).toEqual({ ok: false, code: "PHOTO_REQUIRED" });
    expect(validateClaim({ ...base, photos: [], lines: [{ index: 1, quantity: 1, kind: "missing" }] }).ok).toBe(true);
  });

  it("photos must be in the customer's own claim folder", () => {
    expect(validateClaim({ ...base, photos: ["users/u2/claims/o-1/a.jpg"] })).toEqual({ ok: false, code: "INVALID_PHOTO" });
    expect(validateClaim({ ...base, photos: ["users/u1/claims/o-1/../../x.jpg"] })).toEqual({ ok: false, code: "INVALID_PHOTO" });
    expect(validateClaim({ ...base, photos: ["a", "b", "c", "d"].map((x) => `users/u1/claims/o-1/${x}`) })).toEqual({
      ok: false,
      code: "TOO_MANY_PHOTOS",
    });
  });

  it("back to original payment only for online-paid orders", () => {
    expect(validateClaim({ ...base, resolution: "original" })).toEqual({ ok: false, code: "INVALID_RESOLUTION" });
    const upi = { ...order, paymentMethod: "UPI", payment: { method: "UPI", status: "succeeded", amountPaise: 25000 } };
    expect(validateClaim({ ...base, order: upi, resolution: "original" }).ok).toBe(true);
    expect(validateClaim({ ...base, resolution: "replacement" }).ok).toBe(true);
    expect(validateClaim({ ...base, resolution: "cash" })).toEqual({ ok: false, code: "INVALID_RESOLUTION" });
  });
});

describe("replacement seller", () => {
  const offers = [
    { id: "a", sellerId: "s2", inStock: true, isActive: true, rankScore: 0.9 },
    { id: "b", sellerId: "s1", inStock: true, isActive: true, rankScore: 0.5 },
    { id: "c", sellerId: "s3", inStock: false, isActive: true, rankScore: 1 },
    { id: "d", sellerId: "s4", inStock: true, isActive: true, rankScore: 0.7 },
  ];
  it("same seller first, then the best ranked in stock", () => {
    expect(replacementCandidates(offers, "s1")).toEqual(["b", "a", "d"]);
  });
  it("the same seller out of stock: best ranked", () => {
    expect(replacementCandidates(offers, "s3")).toEqual(["a", "d", "b"]);
  });
});
