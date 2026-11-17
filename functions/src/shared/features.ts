import { HttpsError } from "firebase-functions/https";
import { db } from "./firebase";

/**
 * Kill switches for costly or risky services: `config/features`, public
 * read (the app hides what's off), written only by `adminUpdateFeatures`.
 * A missing doc or field means ON, so a fresh project behaves as before.
 */
export const FEATURES_DOC = "config/features";

export interface Features {
  /** Google Places search through placesProxy (billed per call). */
  placesSearch: boolean;
  /** The support bot (1 GiB function + model download on cold start). */
  supportBot: boolean;
  /** Phone OTP sign-in (billed per SMS). Read by the app only. */
  phoneOtp: boolean;
  /** Online payment methods through PayU. COD is always available. */
  payments: { upi: boolean; card: boolean };
  /** Stops every new order and payment; the app shows `message`. */
  maintenance: { enabled: boolean; message: string };
  /** Service areas where ordering is paused ("store closed"). */
  closedAreaIds: string[];
  /** Oldest app version allowed (x.y.z); older apps must update. */
  minAppVersion: string | null;
}

export const DEFAULT_FEATURES: Features = {
  placesSearch: true,
  supportBot: true,
  phoneOtp: true,
  payments: { upi: true, card: true },
  maintenance: { enabled: false, message: "" },
  closedAreaIds: [],
  minAppVersion: null,
};

export const MAX_MAINTENANCE_MESSAGE = 300;
const VERSION = /^\d{1,3}\.\d{1,3}\.\d{1,3}$/;

const bool = (v: unknown, fallback: boolean) => (typeof v === "boolean" ? v : fallback);

/** Tolerant read: anything missing or malformed falls back to the default. */
export function parseFeatures(raw: Record<string, unknown> | undefined): Features {
  const d = DEFAULT_FEATURES;
  if (!raw) return structuredClone(d);
  const payments = (raw.payments ?? {}) as Record<string, unknown>;
  const maintenance = (raw.maintenance ?? {}) as Record<string, unknown>;
  return {
    placesSearch: bool(raw.placesSearch, d.placesSearch),
    supportBot: bool(raw.supportBot, d.supportBot),
    phoneOtp: bool(raw.phoneOtp, d.phoneOtp),
    payments: { upi: bool(payments.upi, true), card: bool(payments.card, true) },
    maintenance: {
      enabled: bool(maintenance.enabled, false),
      message: typeof maintenance.message === "string" ? maintenance.message : "",
    },
    closedAreaIds: Array.isArray(raw.closedAreaIds)
      ? raw.closedAreaIds.filter((x): x is string => typeof x === "string")
      : [],
    minAppVersion:
      typeof raw.minAppVersion === "string" && VERSION.test(raw.minAppVersion)
        ? raw.minAppVersion
        : null,
  };
}

/**
 * Validates an admin's partial update and applies it to `current`.
 * Throws `invalid-argument` on any unknown key or wrong type, so a typo
 * never silently turns a service off.
 */
export function applyFeaturesPatch(current: Features, patch: unknown): Features {
  if (!patch || typeof patch !== "object" || Array.isArray(patch)) bad("patch");
  const p = patch as Record<string, unknown>;
  const next = structuredClone(current);
  for (const [key, value] of Object.entries(p)) {
    switch (key) {
      case "placesSearch":
      case "supportBot":
      case "phoneOtp":
        if (typeof value !== "boolean") bad(key);
        next[key] = value;
        break;
      case "payments": {
        const v = asObject(value, key);
        for (const [k, b] of Object.entries(v)) {
          if ((k !== "upi" && k !== "card") || typeof b !== "boolean") bad(`payments.${k}`);
          next.payments[k] = b;
        }
        break;
      }
      case "maintenance": {
        const v = asObject(value, key);
        for (const [k, x] of Object.entries(v)) {
          if (k === "enabled" && typeof x === "boolean") next.maintenance.enabled = x;
          else if (k === "message" && typeof x === "string" && x.length <= MAX_MAINTENANCE_MESSAGE) {
            next.maintenance.message = x.trim();
          } else bad(`maintenance.${k}`);
        }
        break;
      }
      case "closedAreaIds":
        if (
          !Array.isArray(value) ||
          value.length > 100 ||
          !value.every((x) => typeof x === "string" && x.length > 0 && x.length <= 128)
        ) {
          bad(key);
        }
        next.closedAreaIds = [...new Set(value as string[])];
        break;
      case "minAppVersion":
        if (value !== null && !(typeof value === "string" && VERSION.test(value))) bad(key);
        next.minAppVersion = value as string | null;
        break;
      default:
        bad(key);
    }
  }
  return next;
}

function asObject(value: unknown, key: string): Record<string, unknown> {
  if (!value || typeof value !== "object" || Array.isArray(value)) bad(key);
  return value as Record<string, unknown>;
}

function bad(field: string): never {
  throw new HttpsError("invalid-argument", `Invalid ${field}`);
}

// Read on hot paths (every order, chat message, Places call): cache for a
// minute per instance so a toggle costs ~nothing and applies within 60 s.
const TTL_MS = 60_000;
let cache: { at: number; value: Features } | null = null;

export async function getFeatures(nowMs = Date.now()): Promise<Features> {
  if (cache && nowMs - cache.at < TTL_MS) return cache.value;
  const snap = await db.doc(FEATURES_DOC).get();
  cache = { at: nowMs, value: parseFeatures(snap.data()) };
  return cache.value;
}

/** After a write on this instance, and between emulator tests. */
export function clearFeaturesCache(): void {
  cache = null;
}

export const MAINTENANCE_DEFAULT_MESSAGE =
  "Zyppi is taking a short break for maintenance. Please try again soon.";
export const METHOD_UNAVAILABLE = "This payment method is unavailable right now";

/** Throws before any new order or payment while maintenance is on or the method is off. */
export function assertCanOrder(features: Features, paymentMethod: string): void {
  if (features.maintenance.enabled) {
    throw new HttpsError(
      "failed-precondition",
      features.maintenance.message || MAINTENANCE_DEFAULT_MESSAGE,
    );
  }
  if (
    (paymentMethod === "UPI" && !features.payments.upi) ||
    (paymentMethod === "Credit or debit card" && !features.payments.card)
  ) {
    throw new HttpsError("failed-precondition", METHOD_UNAVAILABLE);
  }
}
