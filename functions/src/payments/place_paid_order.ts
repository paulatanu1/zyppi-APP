import { FieldValue } from "firebase-admin/firestore";
import { logger } from "firebase-functions";
import { db } from "../shared/firebase";
import { OrderError, placeOrderInTx } from "../orders/quote";

/** Intent statuses a person has taken over: no order is ever made from them. */
export const CLOSED_BY_ADMIN = ["needs_review", "refunded", "dismissed"];

/**
 * Turns a verified PayU payment into an order (port of
 * `place_paid_order`). Idempotent: a repeat call returns the order already
 * created. Returns null — with the intent marked `needs_review` — when the
 * customer has paid but no order can be made (amount differs, stock ran
 * out, cart changed, payment reused), so support can refund or fulfil it.
 */
export async function placePaidOrder(
  /** The PayU txnid, which is also the paymentIntents doc id. */
  merchantOrderId: string,
  /** PayU's mihpayid. */
  transactionId: string,
  paidAmountPaise: number,
): Promise<string | null> {
  const intentRef = db.collection("paymentIntents").doc(merchantOrderId);
  // One real payment can never back two orders.
  const referenceRef = db.collection("paymentReferences").doc(transactionId);

  try {
    return await db.runTransaction(async (tx) => {
      const [intentSnap, referenceSnap] = await tx.getAll(intentRef, referenceRef);
      const intent = intentSnap.data();
      if (!intent) throw new Error("Unknown payment");
      if (intent.orderId) return intent.orderId as string;
      if (CLOSED_BY_ADMIN.includes(intent.status)) return null;
      if (referenceSnap.exists) {
        throw new OrderError("Payment reference already used");
      }

      if (paidAmountPaise !== intent.amountPaise) {
        tx.update(intentRef, {
          status: "needs_review",
          transactionId,
          failureReason: "Paid amount differs from quote",
          updatedAt: FieldValue.serverTimestamp(),
        });
        return null;
      }

      const orderId = await placeOrderInTx(
        tx,
        {
          uid: intent.userId,
          addressId: intent.addressId,
          deliverySlotId: intent.deliverySlotId,
          couponCode: intent.couponCode,
          honourCoupon: true,
          tipPaise: intent.tipPaise,
          paymentMethod: intent.paymentMethod,
        },
        { status: "succeeded", providerReference: transactionId },
        intent.amountPaise,
      );
      tx.create(referenceRef, { merchantOrderId, orderId });
      tx.update(intentRef, {
        status: "completed",
        transactionId,
        orderId,
        updatedAt: FieldValue.serverTimestamp(),
      });
      return orderId;
    });
  } catch (error) {
    if (!(error instanceof OrderError)) throw error;

    // Paid but not placeable: keep the evidence for a refund/manual order.
    logger.warn("Paid order needs review", { merchantOrderId, reason: error.message });
    await db.runTransaction(async (tx) => {
      const snap = await tx.get(intentRef);
      if (snap.get("orderId")) return;
      tx.update(intentRef, {
        status: "needs_review",
        transactionId,
        failureReason: error.message,
        updatedAt: FieldValue.serverTimestamp(),
      });
    });
    return null;
  }
}
