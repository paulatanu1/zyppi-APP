import { type DocumentSnapshot, FieldValue, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { db } from "../shared/firebase";
import { EARNINGS, istDayAndWeek } from "./earnings";
import { RIDER_CONFIG_DOC, type SlotTemplate, istHhmm, istInstant, parseRiderConfig } from "./model";
import { requireRider } from "./rider_auth";

/**
 * Gigs: riders book slots (from the area's templates in config/riders)
 * up to `bookDaysAhead` days ahead. Booked riders get dispatch priority
 * while online in their slot, and the slot's bonus when they're online
 * within 15 minutes of the start. Capacity is enforced on
 * gigSlots/{areaId}_{date}_{start}.
 */

export const GIG_SLOTS = "gigSlots";
export const SLOTS = "slots";

const DATE = /^\d{4}-\d{2}-\d{2}$/;
const HHMM = /^([01]\d|2[0-3]):[0-5]\d$/;

export const slotKey = (date: string, start: string) => `${date}_${start.replace(":", "")}`;

export function templatesFor(config: ReturnType<typeof parseRiderConfig>, areaId: string): SlotTemplate[] {
  const own = config.slotTemplates[areaId];
  return own && own.length ? own : (config.slotTemplates.default ?? []);
}

/** Why a booking isn't allowed now, or null. */
export function bookingProblem(
  date: string,
  template: SlotTemplate,
  nowMs: number,
  bookDaysAhead: number,
): string | null {
  const start = istInstant(date, template.start).getTime();
  if (start <= nowMs) return "SLOT_STARTED";
  const { day: today } = istDayAndWeek(new Date(nowMs));
  const last = new Date(Date.parse(`${today}T00:00:00Z`) + bookDaysAhead * 86_400_000).toISOString().slice(0, 10);
  if (date > last) return "TOO_FAR_AHEAD";
  return null;
}

function readInput(data: unknown): { date: string; start: string } {
  const d = (data ?? {}) as Record<string, unknown>;
  const date = String(d.date ?? "");
  const start = String(d.start ?? "");
  if (!DATE.test(date) || !HHMM.test(start)) throw new HttpsError("invalid-argument", "Invalid slot");
  return { date, start };
}

/** Request: {date, start}. */
export const riderBookSlot = onCall(async (request) => {
  const rider = await requireRider(request);
  const { date, start } = readInput(request.data);
  const areaId = (rider.get("serviceAreaId") as string) ?? "";
  return db.runTransaction(async (tx) => {
    const config = parseRiderConfig((await tx.get(db.doc(RIDER_CONFIG_DOC))).data());
    const template = templatesFor(config, areaId).find((t) => t.start === start);
    if (!template) throw new HttpsError("invalid-argument", "Invalid slot");
    const problem = bookingProblem(date, template, Date.now(), config.slots.bookDaysAhead);
    if (problem) throw new HttpsError("failed-precondition", problem);
    const key = slotKey(date, start);
    const slotRef = db.collection(GIG_SLOTS).doc(`${areaId}_${key}`);
    const mineRef = rider.ref.collection(SLOTS).doc(key);
    const [slot, mine] = await Promise.all([tx.get(slotRef), tx.get(mineRef)]);
    if (mine.get("status") === "booked") return { ok: true };
    const booked = (slot.get("booked") as number | undefined) ?? 0;
    if (booked >= template.capacity) throw new HttpsError("failed-precondition", "SLOT_FULL");
    tx.set(
      slotRef,
      { areaId, date, start, end: template.end, capacity: template.capacity, booked: FieldValue.increment(1) },
      { merge: true },
    );
    tx.set(mineRef, {
      areaId,
      date,
      start,
      end: template.end,
      bonusPaise: template.bonusPaise,
      status: "booked",
      bookedAt: FieldValue.serverTimestamp(),
      attendedAt: null,
    });
    return { ok: true };
  });
});

/** Request: {date, start}. Allowed until `cancelHours` before the start. */
export const riderCancelSlot = onCall(async (request) => {
  const rider = await requireRider(request);
  const { date, start } = readInput(request.data);
  const areaId = (rider.get("serviceAreaId") as string) ?? "";
  return db.runTransaction(async (tx) => {
    const config = parseRiderConfig((await tx.get(db.doc(RIDER_CONFIG_DOC))).data());
    const key = slotKey(date, start);
    const mineRef = rider.ref.collection(SLOTS).doc(key);
    const mine = await tx.get(mineRef);
    if (mine.get("status") !== "booked") return { ok: true };
    const startMs = istInstant(date, start).getTime();
    if (startMs - Date.now() < config.slots.cancelHours * 3_600_000) {
      throw new HttpsError("failed-precondition", "TOO_LATE_TO_CANCEL");
    }
    tx.update(mineRef, { status: "cancelled", cancelledAt: FieldValue.serverTimestamp() });
    tx.set(
      db.collection(GIG_SLOTS).doc(`${areaId}_${key}`),
      { booked: FieldValue.increment(-1) },
      { merge: true },
    );
    return { ok: true };
  });
});

/**
 * While online: finds the rider's booked slot covering now, marks
 * attendance (on time = within 15 min of the start → bonus) and returns
 * presence fields for dispatch priority. Called from riderSetOnline /
 * riderPing at most every few minutes.
 */
export async function slotPresence(rider: DocumentSnapshot, nowMs = Date.now()): Promise<Record<string, unknown>> {
  const now = new Date(nowMs);
  const { day, week } = istDayAndWeek(now);
  const hhmm = istHhmm(now);
  const bookings = await rider.ref.collection(SLOTS).where("date", "==", day).where("status", "==", "booked").get();
  const current = bookings.docs.find((b) => String(b.get("start")) <= hhmm && hhmm < String(b.get("end")));
  if (!current) return { "presence.slotEndsAt": null, "presence.slotCheckedAt": Timestamp.fromMillis(nowMs) };
  if (!current.get("attendedAt")) {
    await db.runTransaction(async (tx) => {
      const fresh = await tx.get(current.ref);
      if (fresh.get("attendedAt")) return;
      const startMs = istInstant(day, String(fresh.get("start"))).getTime();
      const onTime = nowMs - startMs <= 15 * 60_000;
      const bonus = (fresh.get("bonusPaise") as number | undefined) ?? 0;
      tx.update(fresh.ref, { attendedAt: FieldValue.serverTimestamp(), onTime });
      if (onTime && bonus > 0) {
        tx.set(rider.ref.collection(EARNINGS).doc(`slot_${fresh.id}`), {
          type: "incentive",
          title: `Slot ${fresh.get("start")}–${fresh.get("end")}`,
          amountPaise: bonus,
          day,
          week,
          at: FieldValue.serverTimestamp(),
        });
        tx.update(rider.ref, {
          earningsBalancePaise: FieldValue.increment(bonus),
          earnedTotalPaise: FieldValue.increment(bonus),
        });
      }
    });
  }
  return {
    "presence.slotEndsAt": Timestamp.fromDate(istInstant(day, String(current.get("end")))),
    "presence.slotCheckedAt": Timestamp.fromMillis(nowMs),
  };
}
