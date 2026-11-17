import { type DocumentReference, FieldValue } from "firebase-admin/firestore";
import type { MulticastMessage } from "firebase-admin/messaging";
import { logger } from "firebase-functions";
import { messaging } from "../shared/firebase";

/**
 * Push tokens of one customer or rider: `pushTokens` (every signed-in
 * device, newest last, at most [MAX_DEVICES]) plus the legacy single
 * `fcmToken` older app versions still write.
 */
export const MAX_DEVICES = 5;

/** FCM's limit per multicast call. */
export const FCM_BATCH = 500;

export const DEAD_TOKEN_CODES = [
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
];

const isToken = (t: unknown): t is string => typeof t === "string" && t.length > 0 && t.length <= 4096;

/** Every distinct token on a users/{uid} or riders/{uid} doc. */
export function tokensOf(d: Record<string, unknown> | undefined | null): string[] {
  if (!d) return [];
  const list = Array.isArray(d.pushTokens) ? d.pushTokens.filter(isToken) : [];
  if (isToken(d.fcmToken)) list.push(d.fcmToken);
  return [...new Set(list)];
}

/** Adds [token] as the newest device, keeping the latest [max]. */
export function withToken(existing: unknown, token: string, max = MAX_DEVICES): string[] {
  const list = Array.isArray(existing) ? existing.filter((t): t is string => isToken(t) && t !== token) : [];
  return [...list, token].slice(-max);
}

/** A token a device may register (real FCM tokens are ~150+ characters). */
export function isValidToken(t: unknown): t is string {
  return isToken(t) && t.length >= 20;
}

/** Fields that forget [dead] tokens on the owner's doc. */
export function forgetTokens(d: Record<string, unknown> | undefined, dead: string[]): Record<string, unknown> {
  if (!dead.length) return {};
  const out: Record<string, unknown> = { pushTokens: FieldValue.arrayRemove(...dead) };
  if (typeof d?.fcmToken === "string" && dead.includes(d.fcmToken)) out.fcmToken = null;
  return out;
}

export interface MulticastSender {
  sendEachForMulticast(m: MulticastMessage): Promise<{
    successCount: number;
    failureCount: number;
    responses: { success: boolean; error?: { code: string } }[];
  }>;
}

/** Tokens FCM says are gone (uninstalled app, rotated token). */
export function deadTokens(tokens: string[], responses: { success: boolean; error?: { code: string } }[]): string[] {
  return tokens.filter((_, i) => {
    const r = responses[i];
    return r && !r.success && !!r.error && DEAD_TOKEN_CODES.includes(r.error.code);
  });
}

/**
 * Sends [message] to every device on [ref]'s doc ([data] is that doc) and
 * forgets dead tokens. Returns how many devices accepted it.
 */
export async function pushToDevices(
  ref: DocumentReference,
  data: Record<string, unknown> | undefined,
  message: Omit<MulticastMessage, "tokens">,
  sender: MulticastSender = messaging,
): Promise<number> {
  const tokens = tokensOf(data);
  if (!tokens.length) return 0;
  try {
    const res = await sender.sendEachForMulticast({ ...message, tokens });
    const dead = deadTokens(tokens, res.responses);
    if (dead.length) await ref.update(forgetTokens(data, dead));
    return res.successCount;
  } catch (error) {
    logger.error("Push failed", { path: ref.path, error });
    return 0;
  }
}
