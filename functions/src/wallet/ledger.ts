import { type DocumentSnapshot, FieldValue, type Transaction } from "firebase-admin/firestore";
import { db } from "../shared/firebase";
import { WALLET } from "./model";

/**
 * Wallet writes. Every entry has a fixed id (wallet/model.ts) and is
 * created with `tx.create`, so the same credit or debit can never be
 * written twice: a retry fails the whole transaction instead. The balance
 * only changes in the same transaction as its history entry.
 */

export const userRef = (uid: string) => db.collection("users").doc(uid);
export const walletEntryRef = (uid: string, id: string) => userRef(uid).collection(WALLET).doc(id);

export type WalletEntryType = "spend" | "release" | "cancel" | "claim" | "credit";

export interface WalletEntryFields {
  type: WalletEntryType;
  /** Signed: what it did to the balance. */
  amountPaise: number;
  reason: string;
  orderId?: string | null;
  intentId?: string | null;
  issueId?: string | null;
  by?: string | null;
  status?: "held" | "spent" | "released" | "done";
}

function entry(f: WalletEntryFields) {
  return {
    type: f.type,
    amountPaise: f.amountPaise,
    reason: f.reason.slice(0, 300),
    orderId: f.orderId ?? null,
    intentId: f.intentId ?? null,
    issueId: f.issueId ?? null,
    by: f.by ?? null,
    status: f.status ?? "done",
    at: FieldValue.serverTimestamp(),
  };
}

/**
 * Adds a history entry and moves the balance by `amountPaise`. Callers
 * that take money out must have checked the balance read in this same
 * transaction (checkWalletOrder / reserve), so it never goes below zero.
 */
export function writeWalletEntry(tx: Transaction, uid: string, id: string, f: WalletEntryFields): void {
  if (!Number.isInteger(f.amountPaise) || f.amountPaise === 0) return;
  tx.create(walletEntryRef(uid, id), entry(f));
  tx.set(
    userRef(uid),
    { walletPaise: FieldValue.increment(f.amountPaise), walletUpdatedAt: FieldValue.serverTimestamp() },
    { merge: true },
  );
}

/** The reservation made for a PayU payment (pay_{txnid}). */
export const holdId = (txnid: string) => `pay_${txnid}`;

/**
 * Gives a PayU reservation back to the wallet (payment failed, expired or
 * paid-but-no-order). [hold] must have been read in this transaction.
 * Safe to call more than once: only a `held` reservation is released.
 */
export function releaseHold(tx: Transaction, uid: string, txnid: string, hold: DocumentSnapshot, reason: string): boolean {
  if (!hold.exists || hold.get("status") !== "held") return false;
  const amount = -((hold.get("amountPaise") as number) ?? 0);
  if (amount <= 0) return false;
  tx.update(hold.ref, { status: "released", releasedAt: FieldValue.serverTimestamp() });
  writeWalletEntry(tx, uid, `release_${txnid}`, { type: "release", amountPaise: amount, reason, intentId: txnid });
  return true;
}

/**
 * Inside an intent's transaction ([intent] read in it, no writes yet):
 * gives its reserved wallet part back. Intents without one: nothing.
 */
export async function giveBackWallet(tx: Transaction, intent: DocumentSnapshot, txnid: string, reason: string): Promise<void> {
  const uid = intent.get("userId");
  if (typeof uid !== "string" || !(((intent.get("walletPaise") as number | undefined) ?? 0) > 0)) return;
  const hold = await tx.get(walletEntryRef(uid, holdId(txnid)));
  releaseHold(tx, uid, txnid, hold, reason);
}
