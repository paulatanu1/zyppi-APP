import { FieldValue } from "firebase-admin/firestore";
import { expireAt } from "../notifications/inbox";
import { tokensOf } from "../notifications/tokens";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { db, messaging } from "../shared/firebase";
import { requireRole } from "../shared/roles";
import { RIDERS } from "../riders/model";

const BATCH = 500;

/**
 * Request: {title, body, serviceAreaIds?}. Ops messages approved riders
 * (all, or some areas): a row in each rider's inbox plus a push.
 * Response: {riders, pushed}.
 */
export const adminAnnounceToRiders = onCall({ timeoutSeconds: 120 }, async (request) => {
  const actor = requireRole(request, ["ops"]);
  const title = typeof request.data?.title === "string" ? request.data.title.trim() : "";
  const body = typeof request.data?.body === "string" ? request.data.body.trim() : "";
  if (title.length < 3 || title.length > 65) throw new HttpsError("invalid-argument", "Title: 3–65 characters");
  if (body.length < 3 || body.length > 500) throw new HttpsError("invalid-argument", "Message: 3–500 characters");
  const areas: string[] = Array.isArray(request.data?.serviceAreaIds)
    ? request.data.serviceAreaIds.filter((a: unknown): a is string => typeof a === "string").slice(0, 20)
    : [];

  const riders = await db.collection(RIDERS).where("status", "==", "approved").get();
  const targets = riders.docs.filter((r) => !areas.length || areas.includes(r.get("serviceAreaId")));
  for (let i = 0; i < targets.length; i += 400) {
    const batch = db.batch();
    for (const r of targets.slice(i, i + 400)) {
      batch.create(r.ref.collection("inbox").doc(), {
        title,
        body,
        at: FieldValue.serverTimestamp(),
        by: actor.uid,
        expireAt: expireAt(Date.now(), 90),
      });
    }
    await batch.commit();
  }
  const tokens = [...new Set(targets.flatMap((r) => tokensOf(r.data())))];
  let pushed = 0;
  for (let i = 0; i < tokens.length; i += BATCH) {
    const res = await messaging.sendEachForMulticast({
      tokens: tokens.slice(i, i + BATCH),
      notification: { title, body: body.slice(0, 240) },
      data: { type: "announcement" },
      android: { priority: "high", notification: { channelId: "general" } },
    });
    pushed += res.successCount;
  }
  await writeAudit(actor, {
    action: "riders.announce",
    target: RIDERS,
    after: { title, areas, riders: targets.length, pushed },
  });
  return { riders: targets.length, pushed };
});
