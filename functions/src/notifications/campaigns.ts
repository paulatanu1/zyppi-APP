import { FieldValue, Timestamp } from "firebase-admin/firestore";
import type { MulticastMessage } from "firebase-admin/messaging";
import { logger } from "firebase-functions";
import { HttpsError, onCall } from "firebase-functions/https";
import { onSchedule } from "firebase-functions/scheduler";
import { writeAudit } from "../shared/audit";
import { db, messaging } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import {
  CAMPAIGNS,
  type CampaignInput,
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

/** FCM's limit per multicast call. */
const BATCH = 500;
const ROLES = ["catalog"] as const;

/**
 * Everyone who opted in and can receive a push, filtered by [segment].
 * Reads every opted-in user: fine at launch scale (thousands). Past that,
 * move to FCM topics or a segment index.
 */
export async function resolveAudience(segment: Segment, nowMs = Date.now()): Promise<Recipient[]> {
  const snap = await db.collection("users").where("notifyOffers", "==", true).get();
  return snap.docs
    .map((d) => toRecipient(d.id, d.data()))
    .filter((r): r is Recipient => r != null && matchesSegment(r, segment, nowMs));
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

export interface PushSender {
  sendEachForMulticast(m: MulticastMessage): Promise<{
    successCount: number;
    failureCount: number;
    responses: { success: boolean; error?: { code: string } }[];
  }>;
}

const DEAD_TOKEN = [
  "messaging/registration-token-not-registered",
  "messaging/invalid-registration-token",
];

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

/**
 * Sends one campaign now. The scheduled → sending switch happens in a
 * transaction, so the scheduler and a "Send now" can never both send it.
 * Exported for tests.
 */
export async function sendCampaign(id: string, sender: PushSender = messaging) {
  const ref = db.collection(CAMPAIGNS).doc(id);
  const claimed = await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const status = snap.get("status") as CampaignStatus | undefined;
    if (status !== "scheduled" && status !== "draft") return null;
    tx.update(ref, { status: "sending", sendingAt: FieldValue.serverTimestamp() });
    return snap.data()!;
  });
  if (!claimed) return { sent: 0, failed: 0, skipped: true };

  try {
    const c = readCampaign(claimed);
    const people = await resolveAudience(c.segment);
    const byLang = new Map<Lang, Recipient[]>();
    for (const p of people) byLang.set(p.lang, [...(byLang.get(p.lang) ?? []), p]);

    let sent = 0;
    let failed = 0;
    const dead: string[] = [];
    for (const [lang, group] of byLang) {
      for (let i = 0; i < group.length; i += BATCH) {
        const chunk = group.slice(i, i + BATCH);
        const res = await sender.sendEachForMulticast(campaignMessage(id, c, lang, chunk.map((p) => p.token)));
        sent += res.successCount;
        failed += res.failureCount;
        res.responses.forEach((r, j) => {
          if (!r.success && r.error && DEAD_TOKEN.includes(r.error.code)) dead.push(chunk[j].uid);
        });
      }
    }
    // Uninstalled apps: forget their tokens (same as order pushes).
    for (let i = 0; i < dead.length; i += 400) {
      const batch = db.batch();
      for (const uid of dead.slice(i, i + 400)) {
        batch.update(db.collection("users").doc(uid), { fcmToken: null });
      }
      await batch.commit();
    }
    await ref.update({
      status: "sent",
      sentAt: FieldValue.serverTimestamp(),
      "stats.targeted": people.length,
      "stats.sent": sent,
      "stats.failed": failed,
    });
    return { sent, failed, skipped: false };
  } catch (error) {
    logger.error("Campaign failed", { id, error });
    await ref.update({
      status: "failed",
      failureReason: String((error as Error)?.message ?? error).slice(0, 300),
    });
    throw error;
  }
}

/** Send now (`sendAtMs` null) or at a time (at least a minute ahead). */
export async function scheduleCampaign(actor: Actor, id: unknown, sendAtMs: unknown) {
  if (typeof id !== "string" || !id) throw new HttpsError("invalid-argument", "Invalid id");
  const ref = db.collection(CAMPAIGNS).doc(id);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Campaign not found");
  const status = snap.get("status") as CampaignStatus;
  if (status !== "draft" && status !== "scheduled") {
    throw new HttpsError("failed-precondition", "This campaign was already sent");
  }
  readCampaign(snap.data()!); // still valid

  if (sendAtMs == null) {
    await writeAudit(actor, { action: "campaign.send", target: ref.path, after: { when: "now" } });
    const res = await sendCampaign(id);
    return { status: "sent" as const, ...res };
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
  await ref.update({ status: "scheduled", sendAt: Timestamp.fromMillis(sendAtMs) });
  await writeAudit(actor, {
    action: "campaign.schedule",
    target: ref.path,
    after: { sendAt: new Date(sendAtMs).toISOString() },
  });
  return { status: "scheduled" as const };
}

export async function cancelCampaign(actor: Actor, id: unknown) {
  if (typeof id !== "string" || !id) throw new HttpsError("invalid-argument", "Invalid id");
  const ref = db.collection(CAMPAIGNS).doc(id);
  await db.runTransaction(async (tx) => {
    const snap = await tx.get(ref);
    const status = snap.get("status") as CampaignStatus | undefined;
    if (status !== "scheduled" && status !== "draft") {
      throw new HttpsError("failed-precondition", "Only drafts and scheduled campaigns can be cancelled");
    }
    tx.update(ref, { status: "cancelled", sendAt: null });
    writeAudit(actor, { action: "campaign.cancel", target: ref.path }, tx);
  });
  return { ok: true };
}

/**
 * Sends the composer's current copy to one customer's phone (found by
 * phone number), whatever their opt-in, for checking before a real send.
 */
export async function testCampaign(actor: Actor, raw: Record<string, unknown>, sender: PushSender = messaging) {
  const c = validateCampaign(raw);
  const phone = typeof raw.phone === "string" ? raw.phone.replace(/[\s-]/g, "") : "";
  if (!/^\+?\d{10,13}$/.test(phone)) throw new HttpsError("invalid-argument", "Enter the test phone number");
  const full = phone.startsWith("+") ? phone : `+91${phone.slice(-10)}`;
  const users = await db.collection("users").where("phone", "==", full).limit(1).get();
  const user = users.docs[0];
  const token = user?.get("fcmToken") as string | null | undefined;
  if (!user) throw new HttpsError("not-found", `No customer with ${full}. Sign in to the app with it first`);
  if (!token) throw new HttpsError("failed-precondition", "That customer has no device registered. Open the app and allow notifications");
  const lang = (user.get("lang") as Lang | undefined) ?? "en";
  const res = await sender.sendEachForMulticast(campaignMessage("test", c, lang, [token]));
  await writeAudit(actor, { action: "campaign.test", target: `users/${user.id}`, after: { name: c.name } });
  if (res.successCount !== 1) {
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
  const uid = request.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Not authenticated");
  return recordOpen(uid, request.data?.campaignId);
});

/** Every 5 minutes: sends scheduled campaigns that are due. */
export const dispatchCampaigns = onSchedule(
  { schedule: "every 5 minutes", timeoutSeconds: 540, memory: "512MiB" },
  async () => {
    const due = await db
      .collection(CAMPAIGNS)
      .where("status", "==", "scheduled")
      .where("sendAt", "<=", Timestamp.now())
      .limit(10)
      .get();
    for (const d of due.docs) {
      try {
        await sendCampaign(d.id);
      } catch {
        // Recorded on the campaign as failed; carry on with the rest.
      }
    }
  },
);
