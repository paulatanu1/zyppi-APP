/**
 * Zyppi wallet and "Report a problem" claims (docs/WALLET.md).
 *
 * The wallet is closed-loop store credit: it is filled only by refunds,
 * approved claims and staff credits, spent only on Zyppi orders, and can't
 * be topped up, transferred or withdrawn. Refunded money never expires.
 *
 *   users/{uid}.walletPaise          spendable balance (never below 0)
 *   users/{uid}/wallet/{entryId}     history, fixed ids so a retry can't
 *                                    credit or debit twice:
 *     order_{orderId}    spend on a cash / wallet-only order
 *     pay_{txnid}        spend reserved for a PayU payment (held → spent | released)
 *     release_{txnid}    that reservation given back (payment failed / expired)
 *     cancel_{orderId}   wallet part of a cancelled order given back
 *     claim_{issueId}    approved claim credited
 *     admin_{requestId}  staff credit (finance)
 *
 * Every function here is pure, so the money rules are unit tested.
 */

export const WALLET = "wallet";
export const ORDER_ISSUES = "orderIssues";

/** The payment method of an order paid fully from the wallet. */
export const WALLET_METHOD = "Wallet";
/** The payment method of a free replacement order. */
export const REPLACEMENT_METHOD = "Replacement";

/** A claim can be reported this long after delivery. */
export const CLAIM_WINDOW_MS = 2 * 60 * 60 * 1000;
export const CLAIM_KINDS = ["missing", "wrong", "damaged", "expired"] as const;
export type ClaimKind = (typeof CLAIM_KINDS)[number];
/** What the customer asks for. `original` is offered on online-paid orders only. */
export const RESOLUTIONS = ["wallet", "original", "replacement"] as const;
export type Resolution = (typeof RESOLUTIONS)[number];
export const MAX_CLAIM_PHOTOS = 3;
export const MAX_CLAIM_NOTE = 500;
/** One staff credit can't exceed ₹5,000. */
export const MAX_STAFF_CREDIT_PAISE = 500_000;

/** Error codes the app maps to messages (checkout_errors / claim screen). */
export const WALLET_BALANCE_CHANGED = "WALLET_BALANCE_CHANGED";
export const WALLET_COVERS_ORDER = "WALLET_COVERS_ORDER";

const int = (v: unknown) => (typeof v === "number" && Number.isFinite(v) ? Math.round(v) : 0);

/** The spendable balance on a users/{uid} doc. */
export function walletBalanceOf(user: Record<string, unknown> | undefined | null): number {
  return Math.max(0, int(user?.walletPaise));
}

/**
 * How much of the wallet an order uses: as much as it can, up to the total.
 * The balance is always the one read in the order's own transaction, never
 * the number the app showed.
 */
export function walletToApply(balancePaise: number, totalPaise: number, useWallet: boolean): number {
  if (!useWallet) return 0;
  return Math.max(0, Math.min(Math.floor(balancePaise), Math.floor(totalPaise)));
}

export type WalletCheck =
  | { ok: true; walletPaise: number; payablePaise: number; method: string }
  | { ok: false; code: string };

/**
 * The checks before a cash or wallet-only order is created:
 * - the wallet amount the customer confirmed must still be what the
 *   balance gives (else WALLET_BALANCE_CHANGED: the app reloads and asks
 *   again);
 * - a wallet-only order needs the balance to cover the whole total;
 * - a cash order the wallet now covers in full becomes a wallet order.
 */
export function checkWalletOrder(input: {
  method: string;
  useWallet: boolean;
  balancePaise: number;
  totalPaise: number;
  /** The wallet amount the app showed, if it sent one. */
  expectedWalletPaise?: number | null;
}): WalletCheck {
  const wantsWallet = input.useWallet || input.method === WALLET_METHOD;
  const walletPaise = walletToApply(input.balancePaise, input.totalPaise, wantsWallet);
  if (input.expectedWalletPaise != null && input.expectedWalletPaise !== walletPaise) {
    return { ok: false, code: WALLET_BALANCE_CHANGED };
  }
  const payablePaise = input.totalPaise - walletPaise;
  if (input.method === WALLET_METHOD && payablePaise > 0) return { ok: false, code: WALLET_BALANCE_CHANGED };
  return { ok: true, walletPaise, payablePaise, method: payablePaise === 0 && walletPaise > 0 ? WALLET_METHOD : input.method };
}

/** Cash the rider collects at the door: what's left after the wallet. */
export function cashToCollect(order: Record<string, unknown>): number {
  const payment = (order.payment ?? {}) as Record<string, unknown>;
  if (payment.method !== "Cash on delivery") return 0;
  // Older orders: payment.amountPaise was always the full total.
  return Math.max(0, int(payment.amountPaise ?? order.totalPaise));
}

/** Online part of an order (UPI / card through PayU) still refundable. */
export function onlineRefundable(order: Record<string, unknown>): number {
  const payment = (order.payment ?? {}) as Record<string, unknown>;
  const online = typeof payment.method === "string" && ["UPI", "Credit or debit card"].includes(payment.method);
  if (!online || payment.status !== "succeeded") return 0;
  return Math.max(0, int(payment.amountPaise) - int(order.refundedPaise));
}

// ------------------------------------------------------------------ claims

export interface OrderLineLite {
  productId?: string;
  variantId?: string;
  offerId?: string | null;
  sellerId?: string;
  name?: string;
  quantity?: number;
  pricePaise?: number;
}

export interface ClaimLineInput {
  index: number;
  quantity: number;
  kind: ClaimKind;
}

export interface ClaimLine extends ClaimLineInput {
  productId: string;
  variantId: string;
  offerId: string | null;
  sellerId: string;
  name: string;
  /** What these units are worth to the customer after the coupon. */
  amountPaise: number;
}

/**
 * What [quantity] units of [line] cost the customer: the item price less
 * that line's share of the coupon discount (rounded down, so refunds can
 * never add up to more than was paid).
 */
export function lineRefundPaise(
  line: OrderLineLite,
  quantity: number,
  order: { itemTotalPaise?: number; discountPaise?: number },
): number {
  const gross = int(line.pricePaise) * Math.max(0, Math.floor(quantity));
  const itemTotal = int(order.itemTotalPaise);
  const discount = Math.min(int(order.discountPaise), itemTotal);
  if (itemTotal <= 0 || discount <= 0) return gross;
  return Math.floor((gross * (itemTotal - discount)) / itemTotal);
}

/** Total the customer paid for the order (wallet + online + cash). */
export function orderPaidPaise(order: Record<string, unknown>): number {
  return Math.max(0, int(order.totalPaise));
}

/**
 * Validates a claim against its order. Returns the priced lines, or the
 * first problem as an error code the app translates.
 */
export function validateClaim(input: {
  order: Record<string, unknown>;
  uid: string;
  nowMs: number;
  lines: unknown;
  photos: unknown;
  note: unknown;
  resolution: unknown;
  photoPrefix: string;
}):
  | { ok: true; lines: ClaimLine[]; photos: string[]; note: string; resolution: Resolution; amountPaise: number }
  | { ok: false; code: string } {
  const { order } = input;
  if (order.userId !== input.uid) return { ok: false, code: "NOT_YOUR_ORDER" };
  if (order.status !== "delivered") return { ok: false, code: "NOT_DELIVERED" };
  if (order.paymentMethod === REPLACEMENT_METHOD || order.replacementOf) {
    return { ok: false, code: "REPLACEMENT_ORDER" };
  }
  const deliveredMs = millis(order.deliveredAt);
  if (deliveredMs == null || input.nowMs - deliveredMs > CLAIM_WINDOW_MS) return { ok: false, code: "CLAIM_WINDOW_OVER" };
  if (typeof order.openIssueId === "string" && order.openIssueId) return { ok: false, code: "CLAIM_OPEN" };

  if (!(RESOLUTIONS as readonly string[]).includes(input.resolution as string)) return { ok: false, code: "INVALID_RESOLUTION" };
  const resolution = input.resolution as Resolution;
  if (resolution === "original" && onlineRefundable(order) <= 0) return { ok: false, code: "INVALID_RESOLUTION" };

  const items = (order.items ?? []) as OrderLineLite[];
  const claimed = (order.claimedQty ?? {}) as Record<string, number>;
  const returned = (order.returns ?? {}) as Record<string, number>;
  if (!Array.isArray(input.lines) || input.lines.length === 0 || input.lines.length > items.length) {
    return { ok: false, code: "INVALID_LINES" };
  }
  const seen = new Set<number>();
  const lines: ClaimLine[] = [];
  for (const raw of input.lines as Record<string, unknown>[]) {
    const index = Number(raw?.index);
    const quantity = Number(raw?.quantity);
    const kind = raw?.kind as ClaimKind;
    if (!Number.isInteger(index) || index < 0 || index >= items.length || seen.has(index)) {
      return { ok: false, code: "INVALID_LINES" };
    }
    if (!(CLAIM_KINDS as readonly string[]).includes(kind)) return { ok: false, code: "INVALID_LINES" };
    const item = items[index];
    // Claimed units (open or approved) and ops' returns overlap when an
    // approved claim charged the seller (that also counts a return).
    const left = int(item.quantity) - Math.max(int(claimed[String(index)]), int(returned[String(index)]));
    if (!Number.isInteger(quantity) || quantity < 1 || quantity > left) return { ok: false, code: "TOO_MANY_UNITS" };
    seen.add(index);
    lines.push({
      index,
      quantity,
      kind,
      productId: item.productId ?? "",
      variantId: item.variantId ?? "",
      offerId: item.offerId ?? null,
      sellerId: item.sellerId ?? "zyppi",
      name: item.name ?? "item",
      amountPaise: lineRefundPaise(item, quantity, order as { itemTotalPaise?: number; discountPaise?: number }),
    });
  }

  const photos = Array.isArray(input.photos) ? input.photos : [];
  if (photos.length > MAX_CLAIM_PHOTOS) return { ok: false, code: "TOO_MANY_PHOTOS" };
  for (const p of photos) {
    if (typeof p !== "string" || !p.startsWith(input.photoPrefix) || p.includes("..") || p.length > 300) {
      return { ok: false, code: "INVALID_PHOTO" };
    }
  }
  // Wrong, damaged or expired: show us. Missing: nothing to photograph.
  if (lines.some((l) => l.kind !== "missing") && photos.length === 0) return { ok: false, code: "PHOTO_REQUIRED" };

  const note = typeof input.note === "string" ? input.note.trim().slice(0, MAX_CLAIM_NOTE) : "";
  const amountPaise = lines.reduce((a, l) => a + l.amountPaise, 0);
  return { ok: true, lines, photos: photos as string[], note, resolution, amountPaise };
}

/**
 * How an approved money claim is paid: back to the online payment as far
 * as it goes (when asked for), the rest to the wallet. Never more than the
 * order's remaining refundable total.
 */
export function splitClaimPayout(input: {
  amountPaise: number;
  resolution: "wallet" | "original";
  onlineRefundablePaise: number;
  /** Order total minus everything already given back (claims and refunds). */
  orderRemainingPaise: number;
}): { onlinePaise: number; walletPaise: number } {
  const amount = Math.max(0, Math.min(Math.floor(input.amountPaise), Math.floor(input.orderRemainingPaise)));
  const onlinePaise = input.resolution === "original" ? Math.min(amount, Math.max(0, input.onlineRefundablePaise)) : 0;
  return { onlinePaise, walletPaise: amount - onlinePaise };
}

/**
 * What's left to give back on an order: its total less what claims put in
 * the wallet (`claimWalletPaise`) and what went back to the online payment
 * (`refundedPaise`, cancellations and claims alike).
 */
export function orderRemaining(order: Record<string, unknown>): number {
  return Math.max(0, orderPaidPaise(order) - int(order.claimWalletPaise) - int(order.refundedPaise));
}

/**
 * Offers for a replacement, best first: the original seller's offer if it
 * still has stock, then the rest by rank. Out-of-stock and inactive offers
 * are left out.
 */
export function replacementCandidates(
  offers: { id: string; sellerId: string; inStock: boolean; isActive: boolean; rankScore: number }[],
  originalSellerId: string,
): string[] {
  const live = offers.filter((o) => o.isActive && o.inStock);
  const same = live.filter((o) => o.sellerId === originalSellerId);
  const rest = live.filter((o) => o.sellerId !== originalSellerId).sort((a, b) => b.rankScore - a.rankScore);
  return [...same, ...rest].map((o) => o.id);
}

function millis(v: unknown): number | null {
  if (v && typeof (v as { toMillis?: unknown }).toMillis === "function") return (v as { toMillis: () => number }).toMillis();
  return null;
}
