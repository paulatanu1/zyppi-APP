import { randomInt } from "node:crypto";
import { HttpsError } from "firebase-functions/https";

/**
 * Zyppi Delivery (rider app) — pure rules, unit-tested.
 * Data: riders/{uid}.presence, riders/{uid}/offers/{orderId},
 * orders/{id}.{riderStage, offer, dispatch, pickups},
 * orders/{id}/private/handover, orders/{id}/tracking/live, config/riders.
 */

export const RIDER_CONFIG_DOC = "config/riders";
export const OFFERS = "offers";
export const SOS_ALERTS = "sosAlerts";

export type RiderStage =
  | "accepted"
  | "at_store"
  | "picked_up"
  | "at_customer"
  | "returning"
  | "delivered";

export type DispatchState = "searching" | "offered" | "assigned" | "manual" | "unassigned" | "issue";

export interface DispatchConfig {
  /** Auto-assign on/off (off = ops assigns by hand). */
  auto: boolean;
  /** When to look for a rider. */
  assignAt: "placed" | "packed";
  offerSeconds: number;
  /** Riders offered before the order is flagged unassigned. */
  maxOffers: number;
  maxDistanceKm: number;
  /** A position older than this doesn't count. */
  pingFreshSeconds: number;
}

export interface PayRate {
  basePaise: number;
  perKmPaise: number;
  minPaise: number;
  maxPaise: number;
}

export interface RiderConfig {
  dispatch: DispatchConfig;
  emergency: { ambulance: string; police: string; accident: string };
  /**
   * Cash a rider may hold (paise). Above it the app warns "hand over cash",
   * and dispatch stops offering cash orders that would push them past it
   * (see pickRider). 0 = no limit.
   */
  cashLimitPaise: number;
  /** Minutes to wait at the door before "can't deliver" unlocks. */
  waitMinutes: number;
  /** Paid per pickup stop after the first (marketplace orders; 0 = none). */
  extraPickupPaise: number;
  /** Pay per service area id, plus "default". */
  pay: Record<string, PayRate>;
  surge: { enabled: boolean; extraPaise: number; label: string };
  peak: { start: string; end: string; extraPaise: number }[];
  slots: { cancelHours: number; bookDaysAhead: number };
  /** Gig slots per service area id, plus "default". */
  slotTemplates: Record<string, SlotTemplate[]>;
}

export interface SlotTemplate {
  /** HH:MM India time; `end` after `start` (no slots past midnight). */
  start: string;
  end: string;
  capacity: number;
  /** Paid once for being online within 15 min of the start. */
  bonusPaise: number;
}

export const DEFAULT_RATE: PayRate = { basePaise: 2500, perKmPaise: 600, minPaise: 2500, maxPaise: 12000 };

export const DEFAULT_RIDER_CONFIG: RiderConfig = {
  dispatch: {
    auto: true,
    assignAt: "placed",
    offerSeconds: 30,
    maxOffers: 3,
    maxDistanceKm: 5,
    pingFreshSeconds: 180,
  },
  emergency: { ambulance: "108", police: "112", accident: "" },
  cashLimitPaise: 300000,
  waitMinutes: 10,
  extraPickupPaise: 0,
  pay: { default: DEFAULT_RATE },
  surge: { enabled: false, extraPaise: 1000, label: "Rain bonus" },
  peak: [],
  slots: { cancelHours: 2, bookDaysAhead: 7 },
  slotTemplates: {
    default: [
      { start: "07:00", end: "11:00", capacity: 5, bonusPaise: 0 },
      { start: "11:00", end: "15:00", capacity: 5, bonusPaise: 0 },
      { start: "15:00", end: "19:00", capacity: 5, bonusPaise: 0 },
      { start: "19:00", end: "23:00", capacity: 5, bonusPaise: 0 },
    ],
  },
};

function templates(v: unknown, fallback: SlotTemplate[]): SlotTemplate[] {
  if (!Array.isArray(v)) return fallback;
  return v
    .map(obj)
    .filter((t) => HHMM.test(String(t.start)) && HHMM.test(String(t.end)) && String(t.start) < String(t.end))
    .slice(0, 12)
    .map((t) => ({
      start: String(t.start),
      end: String(t.end),
      capacity: num(t.capacity, 5, 1, 100),
      bonusPaise: num(t.bonusPaise, 0, 0, 100000),
    }))
    .sort((a, b) => a.start.localeCompare(b.start));
}

const num = (v: unknown, fb: number, min: number, max: number) =>
  typeof v === "number" && Number.isFinite(v) ? Math.min(max, Math.max(min, Math.round(v))) : fb;
const obj = (v: unknown): Record<string, unknown> =>
  v && typeof v === "object" && !Array.isArray(v) ? (v as Record<string, unknown>) : {};
const str = (v: unknown, fb: string) => (typeof v === "string" ? v.trim() : fb);
const HHMM = /^([01]\d|2[0-3]):[0-5]\d$/;

function rate(v: unknown): PayRate {
  const r = obj(v);
  const d = DEFAULT_RATE;
  const basePaise = num(r.basePaise, d.basePaise, 0, 100000);
  const minPaise = num(r.minPaise, d.minPaise, 0, 100000);
  return {
    basePaise,
    perKmPaise: num(r.perKmPaise, d.perKmPaise, 0, 10000),
    minPaise,
    maxPaise: Math.max(minPaise, num(r.maxPaise, d.maxPaise, 0, 200000)),
  };
}

/** Tolerant read of config/riders: anything missing keeps its default. */
export function parseRiderConfig(raw: Record<string, unknown> | undefined): RiderConfig {
  const d = DEFAULT_RIDER_CONFIG;
  const r = obj(raw);
  const dis = obj(r.dispatch);
  const em = obj(r.emergency);
  const pay: Record<string, PayRate> = { default: rate(obj(r.pay).default) };
  for (const [k, v] of Object.entries(obj(r.pay))) if (k !== "default") pay[k] = rate(v);
  const surge = obj(r.surge);
  const slots = obj(r.slots);
  return {
    dispatch: {
      auto: typeof dis.auto === "boolean" ? dis.auto : d.dispatch.auto,
      assignAt: dis.assignAt === "packed" ? "packed" : "placed",
      offerSeconds: num(dis.offerSeconds, d.dispatch.offerSeconds, 15, 120),
      maxOffers: num(dis.maxOffers, d.dispatch.maxOffers, 1, 10),
      maxDistanceKm: num(dis.maxDistanceKm, d.dispatch.maxDistanceKm, 1, 30),
      pingFreshSeconds: num(dis.pingFreshSeconds, d.dispatch.pingFreshSeconds, 60, 900),
    },
    emergency: {
      ambulance: str(em.ambulance, d.emergency.ambulance) || d.emergency.ambulance,
      police: str(em.police, d.emergency.police) || d.emergency.police,
      accident: str(em.accident, ""),
    },
    cashLimitPaise: num(r.cashLimitPaise, d.cashLimitPaise, 0, 10_000_00),
    waitMinutes: num(r.waitMinutes, d.waitMinutes, 2, 30),
    extraPickupPaise: num(r.extraPickupPaise, d.extraPickupPaise, 0, 10000),
    pay,
    surge: {
      enabled: surge.enabled === true,
      extraPaise: num(surge.extraPaise, d.surge.extraPaise, 0, 10000),
      label: str(surge.label, d.surge.label) || d.surge.label,
    },
    peak: (Array.isArray(r.peak) ? r.peak : [])
      .map(obj)
      .filter((p) => HHMM.test(String(p.start)) && HHMM.test(String(p.end)))
      .slice(0, 6)
      .map((p) => ({ start: String(p.start), end: String(p.end), extraPaise: num(p.extraPaise, 0, 0, 10000) })),
    slots: {
      cancelHours: num(slots.cancelHours, d.slots.cancelHours, 0, 48),
      bookDaysAhead: num(slots.bookDaysAhead, d.slots.bookDaysAhead, 1, 14),
    },
    slotTemplates: Object.fromEntries([
      ["default", templates(obj(r.slotTemplates).default, d.slotTemplates.default)],
      ...Object.entries(obj(r.slotTemplates))
        .filter(([k]) => k !== "default")
        .map(([k, v]) => [k, templates(v, [])]),
    ]),
  };
}

/** India-time Date for yyyy-mm-dd + HH:MM. */
export function istInstant(day: string, hhmm: string): Date {
  return new Date(`${day}T${hhmm}:00+05:30`);
}

// ------------------------------------------------------------------ geo

export interface Point {
  lat: number;
  lng: number;
}

/** Straight-line distance in metres (haversine). */
export function distanceM(a: Point, b: Point): number {
  const R = 6_371_000;
  const toRad = (x: number) => (x * Math.PI) / 180;
  const dLat = toRad(b.lat - a.lat);
  const dLng = toRad(b.lng - a.lng);
  const h =
    Math.sin(dLat / 2) ** 2 + Math.cos(toRad(a.lat)) * Math.cos(toRad(b.lat)) * Math.sin(dLng / 2) ** 2;
  return Math.round(2 * R * Math.asin(Math.sqrt(h)));
}

/** Roads are longer than a straight line; 18 km/h average in town. */
export const ROAD_FACTOR = 1.3;
const SPEED_M_PER_MIN = 300;

/** Minutes to cover a straight-line distance by road (at least 1). */
export function etaMinutes(straightM: number): number {
  return Math.max(1, Math.ceil((straightM * ROAD_FACTOR) / SPEED_M_PER_MIN));
}

export function isPoint(v: unknown): v is Point {
  const p = v as Partial<Point> | null;
  return (
    !!p &&
    typeof p.lat === "number" &&
    typeof p.lng === "number" &&
    Math.abs(p.lat) <= 90 &&
    Math.abs(p.lng) <= 180 &&
    !(p.lat === 0 && p.lng === 0)
  );
}

/** A position from the app, or invalid-argument. */
export function requirePoint(raw: unknown): Point & { accuracy: number | null } {
  const r = obj(raw);
  const p = { lat: r.lat, lng: r.lng };
  if (!isPoint(p)) throw new HttpsError("invalid-argument", "LOCATION_REQUIRED");
  const acc = typeof r.accuracy === "number" && r.accuracy >= 0 ? Math.round(r.accuracy) : null;
  return { lat: p.lat as number, lng: p.lng as number, accuracy: acc };
}

/**
 * True when moving from `prev` to `next` in `seconds` means faster than
 * 150 km/h: a fake or broken GPS fix, ignored for dispatch.
 */
export function impossibleJump(prev: Point | null, next: Point, seconds: number): boolean {
  if (!prev || seconds <= 0) return false;
  return distanceM(prev, next) / seconds > 150 / 3.6;
}

// ------------------------------------------------------------------ dispatch

export interface Candidate {
  uid: string;
  lat: number | null;
  lng: number | null;
  pingAtMs: number | null;
  activeOrderId: string | null;
  offerOrderId: string | null;
  onBreakUntilMs: number | null;
  idleSinceMs: number | null;
  /** In a booked gig slot right now. */
  inSlot: boolean;
  /** Cash collected and not yet handed over (paise). */
  codBalancePaise: number;
}

/** What the order asks of the rider beyond being free and near. */
export interface CashRule {
  /** Cash the rider collects at the door (0 for prepaid orders). */
  collectPaise: number;
  /** config.cashLimitPaise; 0 = no limit. */
  cashLimitPaise: number;
}

/**
 * False when collecting `collectPaise` would take the rider past the cash
 * limit. Prepaid orders (nothing to collect) never count against it.
 */
export function withinCashLimit(codBalancePaise: number, rule: CashRule | undefined): boolean {
  if (!rule || rule.collectPaise <= 0 || rule.cashLimitPaise <= 0) return true;
  return Math.max(0, codBalancePaise) + rule.collectPaise <= rule.cashLimitPaise;
}

export interface Pick {
  uid: string;
  distanceM: number;
}

/**
 * The best rider for an order whose first pickup is at `store`: free,
 * not on a break, with a fresh position within range, not already tried.
 * Nearest first; within 500 m, riders in a booked slot first, then the
 * one waiting longest. Riders who would go over the cash limit by
 * collecting this order's cash are skipped (`cash`).
 */
export function pickRider(
  candidates: Candidate[],
  store: Point,
  config: DispatchConfig,
  tried: readonly string[],
  nowMs: number,
  cash?: CashRule,
): Pick | null {
  const usable = candidates
    .filter(
      (c) =>
        !tried.includes(c.uid) &&
        !c.activeOrderId &&
        !c.offerOrderId &&
        !(c.onBreakUntilMs && c.onBreakUntilMs > nowMs) &&
        c.lat != null &&
        c.lng != null &&
        c.pingAtMs != null &&
        nowMs - c.pingAtMs <= config.pingFreshSeconds * 1000 &&
        withinCashLimit(c.codBalancePaise, cash),
    )
    .map((c) => ({ c, d: distanceM({ lat: c.lat!, lng: c.lng! }, store) }))
    .filter((x) => x.d <= config.maxDistanceKm * 1000);
  if (!usable.length) return null;
  const band = (d: number) => Math.floor(d / 500);
  usable.sort(
    (a, b) =>
      band(a.d) - band(b.d) ||
      Number(b.c.inSlot) - Number(a.c.inSlot) ||
      (a.c.idleSinceMs ?? nowMs) - (b.c.idleSinceMs ?? nowMs) ||
      a.d - b.d,
  );
  return { uid: usable[0].c.uid, distanceM: usable[0].d };
}

// ------------------------------------------------------------------ handover

/** 4-digit delivery code the customer tells the rider. */
export function newHandoverCode(): string {
  return String(randomInt(0, 10000)).padStart(4, "0");
}

export const MAX_CODE_ATTEMPTS = 5;

export const CANNOT_DELIVER_REASONS = [
  "customer_unreachable",
  "customer_refused",
  "wrong_address",
  "unsafe_location",
  "other",
] as const;
export type CannotDeliverReason = (typeof CANNOT_DELIVER_REASONS)[number];

// ------------------------------------------------------------------ pay

/** HH:MM India time of `at`. */
export function istHhmm(at: Date): string {
  const m = (at.getUTCHours() * 60 + at.getUTCMinutes() + 330) % 1440;
  return `${String(Math.floor(m / 60)).padStart(2, "0")}:${String(m % 60).padStart(2, "0")}`;
}

function inWindow(hhmm: string, start: string, end: string): boolean {
  return start < end ? hhmm >= start && hhmm < end : hhmm >= start || hhmm < end;
}

export interface OrderEarning {
  basePaise: number;
  distancePaise: number;
  peakPaise: number;
  surgePaise: number;
  /** Extra pickup stops (marketplace orders). */
  pickupPaise: number;
  /** Store(s) → customer, by road (estimate), metres. */
  distanceM: number;
  totalPaise: number;
}

/**
 * What the rider earns for one delivery (tips are credited separately):
 * base + per-km by road (store(s) → customer, straight line × 1.3),
 * clamped to min/max, plus peak-hour, surge and extra-pickup extras.
 */
export function earningFor(
  config: RiderConfig,
  serviceAreaId: string,
  straightM: number,
  deliveredAt: Date,
  extraStops = 0,
): OrderEarning {
  const r = config.pay[serviceAreaId] ?? config.pay.default ?? DEFAULT_RATE;
  const roadM = Math.round(straightM * ROAD_FACTOR);
  const distancePaise = Math.round((roadM / 1000) * r.perKmPaise);
  const core = Math.min(r.maxPaise, Math.max(r.minPaise, r.basePaise + distancePaise));
  const hhmm = istHhmm(deliveredAt);
  const peakPaise = config.peak
    .filter((p) => inWindow(hhmm, p.start, p.end))
    .reduce((m, p) => Math.max(m, p.extraPaise), 0);
  const surgePaise = config.surge.enabled ? config.surge.extraPaise : 0;
  const pickupPaise = Math.max(0, Math.floor(extraStops)) * config.extraPickupPaise;
  return {
    basePaise: core - Math.min(distancePaise, core),
    distancePaise: Math.min(distancePaise, core),
    peakPaise,
    surgePaise,
    pickupPaise,
    distanceM: roadM,
    totalPaise: core + peakPaise + surgePaise + pickupPaise,
  };
}
