import { FieldValue, type Transaction } from "firebase-admin/firestore";
import { db } from "../shared/firebase";
import {
  COUPONS,
  type CouponProblem,
  type CouponTerms,
  REDEMPTIONS,
  couponProblem,
  parseCoupon,
} from "./model";

/** Statuses that make a customer no longer "new" for first-order coupons. */
const LIVE_ORDER_STATUSES = ["placed", "packed", "out_for_delivery", "delivered"];

export interface CouponLookup {
  code: string;
  terms: CouponTerms | null;
  userRedemptions: number;
  hasPastOrder: boolean;
}

/**
 * Everything needed to judge a coupon for one customer, read inside [tx]
 * (reads only, so quoteOrder can call it before its writes).
 */
export async function lookupCoupon(tx: Transaction, code: string, uid: string): Promise<CouponLookup> {
  const ref = db.collection(COUPONS).doc(code);
  const [coupon, redemption] = await tx.getAll(ref, ref.collection(REDEMPTIONS).doc(uid));
  const terms = coupon.exists ? parseCoupon(code, coupon.data()!) : null;
  let hasPastOrder = false;
  if (terms?.firstOrderOnly) {
    const past = await tx.get(
      db
        .collection("orders")
        .where("userId", "==", uid)
        .where("status", "in", LIVE_ORDER_STATUSES)
        .limit(1),
    );
    hasPastOrder = !past.empty;
  }
  return {
    code,
    terms,
    userRedemptions: Math.max(Number(redemption.get("count")) || 0, 0),
    hasPastOrder,
  };
}

export function problemOf(l: CouponLookup, serviceAreaId: string | null): CouponProblem | null {
  return couponProblem(l.terms, {
    nowMs: Date.now(),
    userRedemptions: l.userRedemptions,
    hasPastOrder: l.hasPastOrder,
    serviceAreaId,
  });
}

/** Counts one use (inside the order's transaction, after its reads). */
export function recordRedemption(
  tx: Transaction,
  code: string,
  uid: string,
  orderId: string,
  discountPaise: number,
): void {
  const ref = db.collection(COUPONS).doc(code);
  const now = FieldValue.serverTimestamp();
  tx.update(ref, {
    usedCount: FieldValue.increment(1),
    totalDiscountPaise: FieldValue.increment(discountPaise),
    lastUsedAt: now,
  });
  tx.set(
    ref.collection(REDEMPTIONS).doc(uid),
    { count: FieldValue.increment(1), lastOrderId: orderId, lastUsedAt: now },
    { merge: true },
  );
}

/** Gives a cancelled order's use back (no reads, so it fits anywhere in a transaction). */
export function releaseRedemption(
  tx: Transaction,
  code: string,
  uid: string,
  discountPaise: number,
): void {
  const ref = db.collection(COUPONS).doc(code);
  tx.set(
    ref,
    {
      usedCount: FieldValue.increment(-1),
      totalDiscountPaise: FieldValue.increment(-discountPaise),
    },
    { merge: true },
  );
  tx.set(ref.collection(REDEMPTIONS).doc(uid), { count: FieldValue.increment(-1) }, { merge: true });
}
