import { HttpsError } from "firebase-functions/https";

/**
 * Per-caller call limits for customer-facing callables (coupon guessing,
 * Places API spend, checkout spam). Kept in each function instance's
 * memory: free (no Firestore reads/writes) and good enough because every
 * function runs on a handful of instances at most (shared/scaling.ts), so
 * the real ceiling is at most limit × instances. Not a security boundary on
 * its own: App Check and the server-side checks still apply.
 */

export const RATE_LIMITED = "RATE_LIMITED";

/** Calls per minute per caller for each limited callable. */
export const LIMITS = {
  placesProxy: 30,
  checkCoupon: 20,
  placeOrder: 10,
  createPayUOrder: 10,
  verifyPayUPayment: 30,
  signPayUHash: 60,
  cancelMyOrder: 10,
  reportOrderIssue: 10,
  openSupportChat: 10,
  requestSupportAgent: 10,
  trackBannerClick: 60,
  trackCampaignOpen: 60,
  rateRider: 10,
  rateSellers: 10,
  logSearch: 60,
} as const;
export type LimitedCall = keyof typeof LIMITS;

const WINDOW_MS = 60_000;
/** Callers remembered per instance; the oldest are forgotten first. */
const MAX_KEYS = 20_000;

interface Window {
  start: number;
  count: number;
}

export class RateLimiter {
  private readonly windows = new Map<string, Window>();

  /** True if this call is allowed (and counts it). */
  take(key: string, perMinute: number, nowMs: number): boolean {
    const w = this.windows.get(key);
    if (!w || nowMs - w.start >= WINDOW_MS) {
      this.windows.delete(key);
      this.windows.set(key, { start: nowMs, count: 1 });
      if (this.windows.size > MAX_KEYS) this.windows.delete(this.windows.keys().next().value!);
      return true;
    }
    w.count += 1;
    return w.count <= perMinute;
  }

  get size(): number {
    return this.windows.size;
  }
}

const shared = new RateLimiter();

/** Throws resource-exhausted RATE_LIMITED when `caller` calls `call` too often. */
export function rateLimit(call: LimitedCall, caller: string, nowMs = Date.now(), limiter = shared): void {
  if (!limiter.take(`${call}:${caller}`, LIMITS[call], nowMs)) {
    throw new HttpsError("resource-exhausted", RATE_LIMITED);
  }
}
