/**
 * Seller money (docs/MARKETPLACE.md → Order, fulfilment and settlement;
 * Subscriptions). Pure, for the tests; settlement.ts does the I/O.
 *
 * Balances on sellers/{id} (int paise):
 *   heldPaise             delivered, inside the return window
 *   earningsBalancePaise  available to pay out
 *   duesPaise             subscription fees not paid yet
 *   earnedTotalPaise, paidOutTotalPaise   lifetime
 */

export interface SettlementConfig {
  /** Days a delivered order's earning is held (returns, disputes). */
  holdDays: number;
  /** GST TCS (CGST Act s.52), percent of the seller's supply value, sellers with a GSTIN. */
  tcsPercent: number;
  /** Income-tax TDS (s.194-O), percent of the seller's supply value. */
  tdsPercent: number;
  /** Days a subscription may stay unpaid after a period starts. */
  graceDays: number;
  minPayoutPaise: number;
}

/**
 * Defaults. The tax rates were the statutory ones when this was written
 * (TCS 0.5 %, TDS 0.1 %); confirm them with the CA and set
 * config/marketplace.settlement if they differ.
 */
export const DEFAULT_SETTLEMENT: SettlementConfig = {
  holdDays: 7,
  tcsPercent: 0.5,
  tdsPercent: 0.1,
  graceDays: 3,
  minPayoutPaise: 10000,
};

const num = (v: unknown, min: number, max: number, d: number) =>
  typeof v === "number" && Number.isFinite(v) && v >= min && v <= max ? v : d;

export function settlementConfigFrom(raw: Record<string, unknown> | undefined): SettlementConfig {
  const d = DEFAULT_SETTLEMENT;
  const r = (raw?.settlement ?? {}) as Record<string, unknown>;
  return {
    holdDays: Math.round(num(r.holdDays, 0, 60, d.holdDays)),
    tcsPercent: num(r.tcsPercent, 0, 5, d.tcsPercent),
    tdsPercent: num(r.tdsPercent, 0, 5, d.tdsPercent),
    graceDays: Math.round(num(r.graceDays, 0, 30, d.graceDays)),
    minPayoutPaise: Math.round(num(r.minPayoutPaise, 0, 10_000_000, d.minPayoutPaise)),
  };
}

/** Percent of paise, rounded half up to a paisa. */
export const percentOf = (paise: number, percent: number) =>
  Math.floor((paise * Math.round(percent * 100) + 5000) / 10000);

export interface SellerCredit {
  /** What the customer paid for this seller's items. */
  grossPaise: number;
  /** The seller's price for them (their supply value). */
  payoutPaise: number;
  tcsPaise: number;
  tdsPaise: number;
  /** Credited to the seller: payout − TCS − TDS. */
  netPaise: number;
}

/** A delivered order's credit for one seller (from orders/{id}.sellerTotals). */
export function sellerCredit(
  totals: { itemTotalPaise?: number; payoutPaise?: number } | undefined,
  hasGstin: boolean,
  cfg: SettlementConfig,
): SellerCredit {
  const grossPaise = Math.max(0, Math.round(totals?.itemTotalPaise ?? 0));
  const payoutPaise = Math.max(0, Math.round(totals?.payoutPaise ?? 0));
  const tcsPaise = hasGstin ? percentOf(payoutPaise, cfg.tcsPercent) : 0;
  const tdsPaise = percentOf(payoutPaise, cfg.tdsPercent);
  return { grossPaise, payoutPaise, tcsPaise, tdsPaise, netPaise: payoutPaise - tcsPaise - tdsPaise };
}

/**
 * A payout request: dues come off first, the rest is paid. Null when what
 * is left is below the minimum.
 */
export function payoutSplit(
  balancePaise: number,
  duesPaise: number,
  minPaise: number,
): { duesDeductedPaise: number; payablePaise: number } | null {
  const balance = Math.max(0, balancePaise);
  const duesDeductedPaise = Math.min(Math.max(0, duesPaise), balance);
  const payablePaise = balance - duesDeductedPaise;
  if (payablePaise < minPaise) return null;
  return { duesDeductedPaise, payablePaise };
}

export interface Period {
  id: string;
  feePaise: number;
  paidPaise: number;
  startMs: number;
}

/**
 * Applies a fee payment (offline, or deducted from a payout) to the oldest
 * unpaid periods first. Returns each touched period's new paidPaise and
 * what was left over (nothing was owed for it).
 */
export function applyFeePayment(periods: Period[], amountPaise: number): { paid: Record<string, number>; leftPaise: number } {
  let left = Math.max(0, Math.round(amountPaise));
  const paid: Record<string, number> = {};
  for (const p of [...periods].sort((a, b) => a.startMs - b.startMs)) {
    if (left <= 0) break;
    const owed = p.feePaise - p.paidPaise;
    if (owed <= 0) continue;
    const take = Math.min(owed, left);
    paid[p.id] = p.paidPaise + take;
    left -= take;
  }
  return { paid, leftPaise: left };
}

export type SubscriptionStatus = "active" | "grace" | "expired";

/**
 * A subscription's status: paid up (or a free plan) = active; otherwise
 * grace for `graceDays` from the start of the period that's unpaid, then
 * expired (the seller's offers are hidden until the dues are paid).
 */
export function subscriptionStatus(
  oldestUnpaidStartMs: number | null,
  nowMs: number,
  graceDays: number,
): SubscriptionStatus {
  if (oldestUnpaidStartMs == null) return "active";
  return nowMs < oldestUnpaidStartMs + graceDays * 86_400_000 ? "grace" : "expired";
}

/** Adds whole months (period ends), clamping to the month's last day. */
export function addMonths(ms: number, months: number): number {
  const d = new Date(ms);
  const day = d.getUTCDate();
  const t = new Date(Date.UTC(d.getUTCFullYear(), d.getUTCMonth() + months, 1, d.getUTCHours(), d.getUTCMinutes()));
  const last = new Date(Date.UTC(t.getUTCFullYear(), t.getUTCMonth() + 1, 0)).getUTCDate();
  t.setUTCDate(Math.min(day, last));
  return t.getTime();
}

/** Reminder thresholds (days before the period ends) that are due now and not yet sent. */
export function remindersDue(periodEndMs: number, nowMs: number, sent: number[]): number[] {
  const daysLeft = (periodEndMs - nowMs) / 86_400_000;
  return [7, 3, 1].filter((d) => daysLeft <= d && daysLeft > 0 && !sent.includes(d));
}

/**
 * A returned or damaged line the seller is responsible for: the share of
 * that line's credit to take back (payout, TCS and TDS for those units).
 */
export function returnDebit(
  line: { pricePaise?: number; payoutPaise?: number; quantity?: number },
  quantity: number,
  hasGstin: boolean,
  cfg: SettlementConfig,
): SellerCredit {
  const units = Math.max(0, Math.min(Math.floor(quantity), Math.floor(line.quantity ?? 0)));
  return sellerCredit(
    { itemTotalPaise: (line.pricePaise ?? 0) * units, payoutPaise: (line.payoutPaise ?? 0) * units },
    hasGstin,
    cfg,
  );
}
