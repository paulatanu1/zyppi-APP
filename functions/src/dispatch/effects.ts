import { type DocumentReference, type DocumentSnapshot, FieldValue, Timestamp, type Transaction } from "firebase-admin/firestore";
import { db } from "../shared/firebase";
import { RIDERS } from "../riders/model";
import { OFFERS } from "./model";
import { cashToCollect } from "../wallet/model";

/**
 * Order side-effects shared by ops (adminUpdateOrderStatus) and riders
 * (rider callables), so both paths count deliveries, cash and presence the
 * same way. All are writes: call them after the transaction's reads.
 */

const riderRef = (uid: string) => db.collection(RIDERS).doc(uid);

/**
 * On delivery: delivered / on-time counters, COD cash in hand (+ ledger
 * row), and frees the rider for the next order. `extra` lets the caller add
 * fields to the same rider update (e.g. earnings).
 */
export function creditRiderDelivery(
  tx: Transaction,
  orderRef: DocumentReference,
  order: Record<string, unknown>,
  rider: DocumentSnapshot,
  byUid: string,
  extra: Record<string, unknown> = {},
): void {
  const cod = (order.payment as { method?: string } | undefined)?.method === "Cash on delivery";
  const placed = (order.placedAt as Timestamp | undefined)?.toMillis() ?? Date.now();
  const onTime = Date.now() - placed <= ((order.etaMinutes as number | null) ?? 30) * 60_000;
  // Cash actually taken at the door: the wallet may have paid part of it.
  const total = cashToCollect(order);
  tx.update(rider.ref, {
    deliveredCount: FieldValue.increment(1),
    ...(onTime ? { onTimeCount: FieldValue.increment(1) } : {}),
    ...(cod ? { codBalancePaise: FieldValue.increment(total) } : {}),
    lastDeliveredAt: FieldValue.serverTimestamp(),
    ...(rider.get("presence.activeOrderId") === orderRef.id
      ? { "presence.activeOrderId": null, "presence.idleSince": FieldValue.serverTimestamp() }
      : {}),
    ...extra,
  });
  if (cod) {
    tx.create(rider.ref.collection("cash").doc(), {
      type: "collected",
      amountPaise: total,
      balanceAfterPaise: ((rider.get("codBalancePaise") as number) ?? 0) + total,
      orderId: orderRef.id,
      note: null,
      by: byUid,
      at: FieldValue.serverTimestamp(),
    });
  }
}

/** Frees a rider whose order was unassigned, cancelled or reassigned. */
export function releaseRider(tx: Transaction, uid: string): void {
  tx.set(
    riderRef(uid),
    { presence: { activeOrderId: null, idleSince: FieldValue.serverTimestamp() } },
    { merge: true },
  );
}

/** Makes `uid` the order's rider (accepted offer or ops assignment). */
export function bindRider(tx: Transaction, orderId: string, uid: string): void {
  tx.set(
    riderRef(uid),
    { presence: { activeOrderId: orderId, offerOrderId: null } },
    { merge: true },
  );
  tx.delete(riderRef(uid).collection(OFFERS).doc(orderId));
}

/** Withdraws an open offer from a rider (taken by someone else, cancelled…). */
export function withdrawOffer(tx: Transaction, orderId: string, uid: string): void {
  tx.set(riderRef(uid), { presence: { offerOrderId: null } }, { merge: true });
  tx.delete(riderRef(uid).collection(OFFERS).doc(orderId));
}
