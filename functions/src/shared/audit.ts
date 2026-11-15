import { FieldValue, type Transaction } from "firebase-admin/firestore";
import { db } from "./firebase";
import type { Actor } from "./roles";

export const AUDIT_LOGS = "auditLogs";

export interface AuditEntry {
  action: string;
  /** What was changed, e.g. "config/features" or "staff/<uid>". */
  target: string;
  before?: unknown;
  after?: unknown;
}

/**
 * Appends one row to auditLogs (super_admin read-only; nobody can edit
 * it). Pass `tx` to commit it with the change it describes.
 */
export function writeAudit(actor: Actor, entry: AuditEntry, tx?: Transaction): void | Promise<unknown> {
  const ref = db.collection(AUDIT_LOGS).doc();
  const row = {
    actorUid: actor.uid,
    actorEmail: actor.email,
    role: actor.role,
    action: entry.action,
    target: entry.target,
    before: clean(entry.before ?? null),
    after: clean(entry.after ?? null),
    at: FieldValue.serverTimestamp(),
  };
  if (tx) {
    tx.create(ref, row);
    return;
  }
  return ref.create(row);
}

/** Drops `undefined` (Firestore rejects it) from plain data. */
function clean(value: unknown): unknown {
  if (Array.isArray(value)) return value.map(clean);
  if (value && typeof value === "object" && Object.getPrototypeOf(value) === Object.prototype) {
    return Object.fromEntries(
      Object.entries(value as Record<string, unknown>)
        .filter(([, v]) => v !== undefined)
        .map(([k, v]) => [k, clean(v)]),
    );
  }
  return value;
}
