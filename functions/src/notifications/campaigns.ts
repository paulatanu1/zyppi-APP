import { requireUid } from "../shared/callable";
import { FieldPath, FieldValue, type QueryDocumentSnapshot, Timestamp } from "firebase-admin/firestore";
import type { MulticastMessage } from "firebase-admin/messaging";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/https";
import { onSchedule } from "firebase-functions/scheduler";
import { onTaskDispatched } from "firebase-functions/tasks";
import { MAX_TASK_AHEAD_MS, type TaskQueueClient, enqueueSafely, firebaseTasks, scheduleFor, taskId } from "../shared/tasks";
import { NOTIFICATIONS, inboxDoc } from "./inbox";
import { FCM_BATCH, type MulticastSender, deadTokens, tokensOf } from "./tokens";
import { writeAudit } from "../shared/audit";
import { db, messaging } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import {
  CAMPAIGNS,
  type CampaignInput,
  type Chunk,
  campaignDue,
  planChunks,
  type CampaignStatus,
  type Lang,
  type Recipient,
  type Segment,
  TEMPLATES,
  copyFor,
  matchesSegment,
  pushData,
  toRecipient,
  validateCampaign,
  validateSegment,
} from "./model";
import { rateLimit } from "../shared/rate_limit";

const PAGE = 1000;
/** The users/{uid} fields toRecipient reads. */
const RECIPIENT_FIELDS = [
  "notifyOffers",
  "blocked",
  "fcmToken",
  "pushTokens",
  "lang",
  "serviceAreaId",
  "orderCount",
  "totalSpentPaise",
  "lastOrderAt",
];
const ROLES = ["catalog"] as const;

/**
 * Everyone who opted in and can receive a push, filtered by [segment].
 * Reads opted-in users a page at a time, only the fields a segment needs.
 */
export async function resolveAudience(segment: Segment, nowMs = Date.now()): Promise<Recipient[]> {
  const out: Recipient[] = [];
  let last: QueryDocumentSnapshot | null = null;
  for (;;) {
    let q = db
      .collection("users")
      .where("notifyOffers", "==", true)
      .select(...RECIPIENT_FIELDS)
      .orderBy(FieldPath.documentId())
      .limit(PAGE);
    if (last) q = q.startAfter(last);
    const snap = await q.get();
    for (const d of snap.docs) {
      const r = toRecipient(d.id, d.data());
      if (r && matchesSegment(r, segment, nowMs)) out.push(r);
    }
    if (snap.size < PAGE) return out;
    last = snap.docs[snap.docs.length - 1];
  }
}

function readCampaign(d: Record<string, unknown>): CampaignInput {
  return validateCampaign(d);
}

export async function saveCampaign(actor: Actor, raw: Record<string, unknown>) {
  const input = validateCampaign(raw);
  const id = typeof raw.id === "string" && raw.id ? raw.id : null;
  const ref = id ? db.collection(CAMPAIGNS).doc(id) : db.collection(CAMPAIGNS).doc();
  return db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    if (id && !snap.exists) throw new HttpsError("not-found", "Campaign not found");
    const status = (snap.get("status") as CampaignStatus | undefined) ?? "draft";
    if (status !== "draft" && status !== "scheduled") {
      throw new HttpsError("failed-precondition", "This campaign was already sent. Duplicate it instead");
    }
    tx.set(
      ref,
      {
        ...input,
        status,
        updatedAt: FieldValue.serverTimestamp(),
        updatedBy: actor.uid,
        ...(snap.exists
          ? {}
          : {
              sendAt: null,
              stats: { targeted: 0, sent: 0, failed: 0, opened: 0 },
              createdBy: actor.uid,
              createdByEmail: actor.email,
              createdAt: FieldValue.serverTimestamp(),
            }),
      },
      { merge: true },
    );
    writeAudit(
      actor,
      { action: snap.exists ? "campaign.update" : "campaign.create", target: ref.path, after: { name: input.name } },
      tx,
    );
    return { id: ref.id };
  });
}

/** Who would get it, by language (shown before sending). */
export async function estimateAudience(rawSegment: unknown) {
  const people = await resolveAudience(validateSegment(rawSegment));
  const byLang: Record<string, number> = {};
  for (const p of people) byLang[p.lang] = (byLang[p.lang] ?? 0) + 1;
  return { count: people.length, byLang };
}

/** The FCM sender (a fake in tests). */
export type PushSender = MulticastSender;

export function campaignMessage(id: string, c: CampaignInput, lang: Lang, tokens: string[]): MulticastMessage {
  const copy = copyFor(c, lang);
  return {
    tokens,
    notification: { title: copy.title, body: copy.body, ...(c.imageUrl ? { imageUrl: c.imageUrl } : {}) },
    data: pushData(id, c),
    android: {
      priority: "high",
      notification: { ...(c.imageUrl ? { imageUrl: c.imageUrl } : {}) },
    },
  };
}

/** Up to this many FCM batches are sent in the same call; more fan out as tasks. */
const INLINE_CHUNKS = 4;
const CHUNK_TASK = "sendCampaignChunk";
const DUE_TASK = "sendScheduledCampaign";

/**
 * Starts sending one campaign. The scheduled → sending switch happens in
 * a transaction, so a queued task, the safety net and "Send now" can
 * never all send it. Small audiences go out in this call; bigger ones as
 * one Cloud Task per FCM batch (sendCampaignChunk). Exported for tests.
 */
export async function sendCampaign(
  id: string,
  sender: PushSender = messaging,
  tasks: TaskQueueClient = firebaseTasks,
): Promise<{ sent: number; failed: number; skipped: boolean; queued: boolean; targeted: number }> {
  const ref = db.collection(CAMPAIGNS).doc(id);
  const claimed = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const status = snap.get("status") as CampaignStatus | undefined;
    if (status !== "scheduled" && status !== "draft") return null;
    tx.update(ref, { status: "sending", sendingAt: FieldValue.serverTimestamp() });
    return snap.data()!;
  });
  if (!claimed) return { sent: 0, failed: 0, skipped: true, queued: false, targeted: 0 };

  try {
    const c = readCampaign(claimed);
    const people = await resolveAudience(c.segment);
    const chunks = planChunks(people, FCM_BATCH);
    await ref.update({
      "stats.targeted": people.length,
      "stats.sent": 0,
      "stats.failed": 0,
      chunks: chunks.length,
      chunksDone: 0,
      ...(chunks.length ? {} : { status: "sent", sentAt: FieldValue.serverTimestamp() }),
    });
    if (chunks.length <= INLINE_CHUNKS) {
      let sent = 0;
      let failed = 0;
      for (let i = 0; i < chunks.length; i++) {
        const r = await sendChunk(id, i, chunks[i], sender);
        sent += r.sent;
        failed += r.failed;
      }
      return { sent, failed, skipped: false, queued: false, targeted: people.length };
    }
    for (let i = 0; i < chunks.length; i++) {
      await tasks.enqueue(CHUNK_TASK, { id, index: i, chunk: chunks[i] }, { id: taskId("campaign", id, "chunk", i) });
    }
    return { sent: 0, failed: 0, skipped: false, queued: true, targeted: people.length };
  } catch (error) {
    logger.error("Campaign failed", { id, error });
    await ref.update({
      status: "failed",
      failureReason: String((error as Error)?.message ?? error).slice(0, 300),
    });
    throw error;
  }
}

/**
 * Sends one FCM batch of a campaign, at most once (campaigns/{id}/chunks/{i}
 * is claimed first), adds it to each customer's notification list, forgets
 * dead tokens, and marks the campaign sent after the last batch.
 */
export async function sendChunk(id: string, index: number, chunk: Chunk, sender: PushSender = messaging) {
  const ref = db.collection(CAMPAIGNS).doc(id);
  const mark = ref.collection("chunks").doc(String(index));
  const campaign = await db.runTransaction(async (tx) => {
    const [c, m] = await tx.getAll(ref, mark);
    if (!c.exists || m.exists || c.get("status") !== "sending") return null;
    tx.create(mark, { at: FieldValue.serverTimestamp(), size: chunk.recipients.length });
    return c.data()!;
  });
  if (!campaign) return { sent: 0, failed: 0 };
  const c = readCampaign(campaign);
  const owner = new Map<string, string>();
  for (const r of chunk.recipients) for (const t of r.tokens) owner.set(t, r.uid);
  const tokens = [...owner.keys()];

  let sent = 0;
  let failed = tokens.length;
  let dead: string[] = [];
  try {
    const res = await sender.sendEachForMulticast(campaignMessage(id, c, chunk.lang, tokens));
    sent = res.successCount;
    failed = res.failureCount;
    dead = deadTokens(tokens, res.responses);
  } catch (error) {
    logger.error("Campaign batch failed", { id, index, error });
  }

  const copy = copyFor(c, chunk.lang);
  const writer = db.bulkWriter();
  for (const r of chunk.recipients) {
    writer.set(
      db.collection("users").doc(r.uid).collection(NOTIFICATIONS).doc(`c_${id}`),
      inboxDoc({ kind: "offer", title: copy.title, body: copy.body, data: pushData(id, c), imageUrl: c.imageUrl }),
    );
  }
  // Uninstalled apps: forget their tokens.
  const byUser = new Map<string, string[]>();
  for (const t of dead) byUser.set(owner.get(t)!, [...(byUser.get(owner.get(t)!) ?? []), t]);
  for (const [uid, list] of byUser) {
    writer.update(db.collection("users").doc(uid), {
      pushTokens: FieldValue.arrayRemove(...list),
    });
  }
  await writer.close().catch((error) => logger.warn("Campaign inbox write incomplete", { id, index, error }));
  await clearLegacyTokens(dead);

  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const done = ((snap.get("chunksDone") as number | undefined) ?? 0) + 1;
    const total = (snap.get("chunks") as number | undefined) ?? 0;
    tx.update(ref, {
      "stats.sent": FieldValue.increment(sent),
      "stats.failed": FieldValue.increment(failed),
      chunksDone: FieldValue.increment(1),
      ...(done >= total && snap.get("status") === "sending"
        ? { status: "sent", sentAt: FieldValue.serverTimestamp() }
        : {}),
    });
  });
  return { sent, failed };
}

/** Legacy `fcmToken` fields still holding a dead token. */
async function clearLegacyTokens(dead: string[]) {
  for (let i = 0; i < dead.length; i += 30) {
    const snap = await db.collection("users").where("fcmToken", "in", dead.slice(i, i + 30)).get();
    await Promise.all(snap.docs.map((d) => d.ref.update({ fcmToken: null })));
  }
}

/** Queues the "send at" task for a scheduled campaign (≤ 30 days ahead). */
async function queueDue(id: string, version: number, sendAtMs: number, tasks: TaskQueueClient): Promise<boolean> {
  const at = scheduleFor(sendAtMs);
  if (!at) return false;
  return enqueueSafely(DUE_TASK, { id, version }, { id: taskId("campaign", id, "v", version), scheduleTime: at }, tasks);
}

/** Send now (`sendAtMs` null) or at a time (at least a minute ahead). */
export async function scheduleCampaign(
  actor: Actor,
  id: unknown,
  sendAtMs: unknown,
  tasks: TaskQueueClient = firebaseTasks,
) {
  if (typeof id !== "string" || !id) throw new HttpsError("invalid-argument", "Invalid id");
  const ref = db.collection(CAMPAIGNS).doc(id);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Campaign not found");
  const status = snap.get("status") as CampaignStatus;
  if (status !== "draft" && status !== "scheduled") {
    throw new HttpsError("failed-precondition", "This campaign was already sent");
  }
  readCampaign(snap.data()!); // still valid
  const oldVersion = (snap.get("taskVersion") as number | undefined) ?? 0;

  if (sendAtMs == null) {
    await writeAudit(actor, { action: "campaign.send", target: ref.path, after: { when: "now" } });
    const res = await sendCampaign(id, messaging, tasks);
    if (oldVersion) await tasks.delete(DUE_TASK, taskId("campaign", id, "v", oldVersion)).catch(() => undefined);
    return { status: res.queued ? ("sending" as const) : ("sent" as const), ...res };
  }
  if (typeof sendAtMs !== "number" || !Number.isInteger(sendAtMs)) {
    throw new HttpsError("invalid-argument", "Invalid send time");
  }
  if (sendAtMs < Date.now() + 60_000) {
    throw new HttpsError("invalid-argument", "Pick a time at least a minute from now, or send now");
  }
  if (sendAtMs > Date.now() + 90 * 86_400_000) {
    throw new HttpsError("invalid-argument", "Schedule at most 90 days ahead");
  }
  // A new version per schedule: an older task that still fires does nothing.
  const version = oldVersion + 1;
  await ref.update({ status: "scheduled", sendAt: Timestamp.fromMillis(sendAtMs), taskVersion: version, queued: false });
  if (oldVersion) await tasks.delete(DUE_TASK, taskId("campaign", id, "v", oldVersion)).catch(() => undefined);
  if (await queueDue(id, version, sendAtMs, tasks)) await ref.update({ queued: true });
  await writeAudit(actor, {
    action: "campaign.schedule",
    target: ref.path,
    after: { sendAt: new Date(sendAtMs).toISOString() },
  });
  return { status: "scheduled" as const };
}

export async function cancelCampaign(actor: Actor, id: unknown, tasks: TaskQueueClient = firebaseTasks) {
  if (typeof id !== "string" || !id) throw new HttpsError("invalid-argument", "Invalid id");
  const ref = db.collection(CAMPAIGNS).doc(id);
  const version = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const status = snap.get("status") as CampaignStatus | undefined;
    if (status !== "scheduled" && status !== "draft") {
      throw new HttpsError("failed-precondition", "Only drafts and scheduled campaigns can be cancelled");
    }
    tx.update(ref, { status: "cancelled", sendAt: null, queued: false });
    writeAudit(actor, { action: "campaign.cancel", target: ref.path }, tx);
    return (snap.get("taskVersion") as number | undefined) ?? 0;
  });
  // Best effort: the task checks the status anyway.
  if (version) await tasks.delete(DUE_TASK, taskId("campaign", id, "v", version)).catch(() => undefined);
  return { ok: true };
}

/**
 * Sends the composer's current copy to one customer's phones (found by
 * phone number), whatever their opt-in, for checking before a real send.
 */
export async function testCampaign(actor: Actor, raw: Record<string, unknown>, sender: PushSender = messaging) {
  const c = validateCampaign(raw);
  const phone = typeof raw.phone === "string" ? raw.phone.replace(/[\s-]/g, "") : "";
  if (!/^\+?\d{10,13}$/.test(phone)) throw new HttpsError("invalid-argument", "Enter the test phone number");
  const full = phone.startsWith("+") ? phone : `+91${phone.slice(-10)}`;
  const users = await db.collection("users").where("phone", "==", full).limit(1).get();
  const user = users.docs[0];
  if (!user) throw new HttpsError("not-found", `No customer with ${full}. Sign in to the app with it first`);
  const tokens = tokensOf(user.data());
  if (!tokens.length) throw new HttpsError("failed-precondition", "That customer has no device registered. Open the app and allow notifications");
  const lang = (user.get("lang") as Lang | undefined) ?? "en";
  const res = await sender.sendEachForMulticast(campaignMessage("test", c, lang, tokens));
  await writeAudit(actor, { action: "campaign.test", target: `users/${user.id}`, after: { name: c.name } });
  if (res.successCount < 1) {
    throw new HttpsError("failed-precondition", "The phone didn’t accept it. Reopen the app there and try again");
  }
  return { ok: true, lang };
}

/** One tap on a campaign push (first tap per customer counts). */
export async function recordOpen(uid: string, campaignId: unknown) {
  if (typeof campaignId !== "string" || !campaignId || campaignId === "test") return { ok: true };
  const ref = db.collection(CAMPAIGNS).doc(campaignId);
  await db.runTransaction(async (tx) => {
    const [campaign, open] = await tx.getAll(ref, ref.collection("opens").doc(uid));
    if (!campaign.exists || open.exists) return;
    tx.create(open.ref, { at: FieldValue.serverTimestamp() });
    tx.update(ref, { "stats.opened": FieldValue.increment(1) });
  });
  return { ok: true };
}

export async function saveTemplate(actor: Actor, raw: Record<string, unknown>) {
  // Same copy rules as a campaign; segment and link aren't part of a template.
  const input = validateCampaign({ ...raw, segment: {}, linkType: "none" });
  const id = typeof raw.id === "string" && raw.id ? raw.id : null;
  const ref = id ? db.collection(TEMPLATES).doc(id) : db.collection(TEMPLATES).doc();
  await ref.set(
    {
      name: input.name,
      copy: input.copy,
      translations: input.translations,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: actor.uid,
    },
    { merge: true },
  );
  await writeAudit(actor, { action: "template.save", target: ref.path, after: { name: input.name } });
  return { id: ref.id };
}

export const adminSaveCampaign = onCall(async (request) =>
  saveCampaign(requireRole(request, ROLES), (request.data ?? {}) as Record<string, unknown>),
);

export const adminEstimateAudience = onCall(async (request) => {
  requireRole(request, ROLES);
  return estimateAudience(request.data?.segment);
});

export const adminScheduleCampaign = onCall({ timeoutSeconds: 300, memory: "512MiB" }, async (request) =>
  scheduleCampaign(requireRole(request, ROLES), request.data?.id, request.data?.sendAtMs ?? null),
);

export const adminCancelCampaign = onCall(async (request) =>
  cancelCampaign(requireRole(request, ROLES), request.data?.id),
);

export const adminTestCampaign = onCall(async (request) =>
  testCampaign(requireRole(request, ROLES), (request.data ?? {}) as Record<string, unknown>),
);

export const adminSaveTemplate = onCall(async (request) =>
  saveTemplate(requireRole(request, ROLES), (request.data ?? {}) as Record<string, unknown>),
);

export const adminDeleteTemplate = onCall(async (request) => {
  const actor = requireRole(request, ROLES);
  const id = request.data?.id;
  if (typeof id !== "string" || !id) throw new HttpsError("invalid-argument", "Invalid id");
  await db.collection(TEMPLATES).doc(id).delete();
  await writeAudit(actor, { action: "template.delete", target: `${TEMPLATES}/${id}` });
  return { ok: true };
});

export const trackCampaignOpen = onCall(async (request) => {
  const uid = requireUid(request);
  rateLimit("trackCampaignOpen", uid);
  return recordOpen(uid, request.data?.campaignId);
});

/** The scheduled send time arrived (queued by scheduleCampaign). */
export const sendScheduledCampaign = onTaskDispatched<{ id: string; version: number }>(
  { retryConfig: { maxAttempts: 5, minBackoffSeconds: 30 }, rateLimits: { maxConcurrentDispatches: 5 }, timeoutSeconds: 540, memory: "512MiB" },
  async (req) => {
    const { id, version } = req.data ?? ({} as { id: string; version: number });
    if (typeof id !== "string" || typeof version !== "number") return;
    const snap = await db.collection(CAMPAIGNS).doc(id).get();
    const sendAt = snap.get("sendAt") as Timestamp | null | undefined;
    const due = campaignDue(
      { status: snap.get("status"), taskVersion: snap.get("taskVersion"), sendAtMs: sendAt?.toMillis() ?? null },
      version,
      Date.now(),
    );
    if (due === "send") {
      await sendCampaign(id);
    } else if (due === "requeue" && sendAt) {
      await queueDue(id, version, sendAt.toMillis(), firebaseTasks);
    }
  },
);

/** One FCM batch of a big campaign (queued by sendCampaign). */
export const sendCampaignChunk = onTaskDispatched<{ id: string; index: number; chunk: Chunk }>(
  {
    retryConfig: { maxAttempts: 3, minBackoffSeconds: 20 },
    rateLimits: { maxConcurrentDispatches: 4, maxDispatchesPerSecond: 5 },
    timeoutSeconds: 120,
  },
  async (req) => {
    const { id, index, chunk } = req.data ?? ({} as { id: string; index: number; chunk: Chunk });
    if (typeof id !== "string" || typeof index !== "number" || !chunk?.recipients) return;
    await sendChunk(id, index, chunk);
  },
);

/**
 * Hourly safety net, not the timer (Cloud Tasks is): sends scheduled
 * campaigns whose task never ran, queues those that came within the
 * 30-day Cloud Tasks window, and closes sends whose batches stalled.
 */
export const dispatchCampaigns = onSchedule(
  { schedule: "every 60 minutes", timeoutSeconds: 540, memory: "512MiB" },
  async () => {
    const now = Date.now();
    const col = db.collection(CAMPAIGNS);
    const [overdue, later, stalled] = await Promise.all([
      col.where("status", "==", "scheduled").where("sendAt", "<=", Timestamp.fromMillis(now - 5 * 60_000)).limit(10).get(),
      col
        .where("status", "==", "scheduled")
        .where("queued", "==", false)
        .where("sendAt", "<=", Timestamp.fromMillis(now + MAX_TASK_AHEAD_MS))
        .limit(50)
        .get(),
      col.where("status", "==", "sending").where("sendingAt", "<=", Timestamp.fromMillis(now - 2 * 3_600_000)).limit(20).get(),
    ]);
    for (const d of overdue.docs) {
      try {
        await sendCampaign(d.id);
      } catch {
        // Recorded on the campaign as failed; carry on with the rest.
      }
    }
    for (const d of later.docs) {
      const sendAt = d.get("sendAt") as Timestamp;
      if (await queueDue(d.id, (d.get("taskVersion") as number | undefined) ?? 0, sendAt.toMillis(), firebaseTasks)) {
        await d.ref.update({ queued: true });
      }
    }
    for (const d of stalled.docs) {
      await d.ref.update({
        status: "failed",
        failureReason: `Only ${d.get("chunksDone") ?? 0} of ${d.get("chunks") ?? 0} batches were sent`,
      });
    }
  },
);
