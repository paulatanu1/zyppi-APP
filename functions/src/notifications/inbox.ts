import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { db } from "../shared/firebase";

/**
 * The in-app notification list: users/{uid}/notifications/{id}. Written
 * only by functions; the app reads it and may set `read: true`.
 * `expireAt` drives the Firestore TTL policy (firestore.indexes.json), so
 * old entries delete themselves. Seller and rider inboxes use the same
 * `expireAt` field.
 */
export const NOTIFICATIONS = "notifications";

/** How long an entry stays in the list. */
export const KEEP_DAYS = 30;

export type InboxKind = "order" | "offer" | "support" | "account";

export interface InboxEntry {
  kind: InboxKind;
  title: string;
  body: string;
  /** String fields the app turns into a destination (push_destination.dart). */
  data: Record<string, string>;
  imageUrl?: string | null;
}

export function expireAt(nowMs = Date.now(), days = KEEP_DAYS): Timestamp {
  return Timestamp.fromMillis(nowMs + days * 86_400_000);
}

/** The document an entry is stored as. */
export function inboxDoc(e: InboxEntry, nowMs = Date.now()) {
  return {
    kind: e.kind,
    title: e.title.slice(0, 120),
    body: e.body.slice(0, 500),
    data: e.data,
    imageUrl: e.imageUrl ?? null,
    read: false,
    at: FieldValue.serverTimestamp(),
    expireAt: expireAt(nowMs),
  };
}

/**
 * Adds an entry to a customer's list. A fixed [id] makes retries
 * harmless (the same order status, the same campaign, never twice).
 */
export async function addToInbox(uid: string, e: InboxEntry, id?: string): Promise<void> {
  const col = db.collection("users").doc(uid).collection(NOTIFICATIONS);
  await (id ? col.doc(id).set(inboxDoc(e)) : col.add(inboxDoc(e)));
}
