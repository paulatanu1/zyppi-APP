import { HttpsError } from "firebase-functions/https";
import { type Hours, isHhmm } from "../shared/hours";

/**
 * Validation for Settings → service areas, stores, delivery slots,
 * delivery pricing and app config. Every validator returns exactly the
 * fields to write, so nothing unexpected reaches Firestore.
 */

export const APP_CONFIG_DOC = "config/app";

function bad(message: string): never {
  throw new HttpsError("invalid-argument", message);
}

function obj(v: unknown, what: string): Record<string, unknown> {
  if (!v || typeof v !== "object" || Array.isArray(v)) bad(`Invalid ${what}`);
  return v as Record<string, unknown>;
}

function text(v: unknown, what: string, min: number, max: number): string {
  const s = typeof v === "string" ? v.trim() : "";
  if (s.length < min || s.length > max) {
    bad(min > 0 ? `${what} must be ${min}–${max} characters` : `${what} is too long (max ${max})`);
  }
  return s;
}

function optionalText(v: unknown, what: string, max: number): string | null {
  if (v == null || v === "") return null;
  return text(v, what, 0, max) || null;
}

function bool(v: unknown, fallback: boolean): boolean {
  return typeof v === "boolean" ? v : fallback;
}

function intIn(v: unknown, what: string, min: number, max: number): number {
  if (typeof v !== "number" || !Number.isInteger(v) || v < min || v > max) {
    bad(`${what} must be a whole number from ${min} to ${max}`);
  }
  return v;
}

function numIn(v: unknown, what: string, min: number, max: number): number {
  if (typeof v !== "number" || !Number.isFinite(v) || v < min || v > max) {
    bad(`${what} must be between ${min} and ${max}`);
  }
  return v;
}

/** Optional doc id: letters, digits, - and _ (new docs get a UUID). */
export function optionalId(v: unknown): string | null {
  if (v == null || v === "") return null;
  if (typeof v !== "string" || !/^[\w-]{1,64}$/.test(v)) bad("Invalid id");
  return v;
}

/** Indian phone numbers as +91 and 10 digits; null when blank. */
export function phoneOrNull(v: unknown, what: string): string | null {
  if (v == null || v === "") return null;
  const digits = String(v).replace(/[^\d]/g, "").replace(/^(91|0)(?=\d{10}$)/, "");
  if (!/^[6-9]\d{9}$/.test(digits)) bad(`${what} must be a 10-digit Indian mobile number`);
  return `+91${digits}`;
}

export interface ServiceAreaInput {
  name: string;
  centerLat: number;
  centerLng: number;
  radiusMeters: number;
  isActive: boolean;
}

export function validateServiceArea(raw: unknown): ServiceAreaInput {
  const d = obj(raw, "service area");
  return {
    name: text(d.name, "Name", 2, 60),
    // India's bounding box, roughly: catches swapped or zero coordinates.
    centerLat: numIn(d.centerLat, "Latitude", 6, 37),
    centerLng: numIn(d.centerLng, "Longitude", 68, 98),
    radiusMeters: intIn(d.radiusMeters, "Radius (m)", 300, 50_000),
    isActive: bool(d.isActive, true),
  };
}

export interface StoreInput {
  name: string;
  serviceAreaId: string;
  address: string | null;
  phone: string | null;
  /** null = open all day. */
  hours: Hours | null;
  /** Where riders pick up (navigation, dispatch distance); null = area centre. */
  lat: number | null;
  lng: number | null;
  isActive: boolean;
}

export function validateStore(raw: unknown): StoreInput {
  const d = obj(raw, "store");
  let hours: Hours | null = null;
  if (d.hours != null) {
    const h = obj(d.hours, "hours");
    if (!isHhmm(h.open) || !isHhmm(h.close)) bad("Hours must be HH:MM, 24-hour");
    if (h.open === h.close) bad("Opening and closing times must differ");
    hours = { open: h.open, close: h.close };
  }
  const serviceAreaId = optionalId(d.serviceAreaId);
  if (!serviceAreaId) bad("Pick the store's service area");
  return {
    name: text(d.name, "Name", 2, 80),
    serviceAreaId,
    address: optionalText(d.address, "Address", 300),
    phone: phoneOrNull(d.phone, "Phone"),
    hours,
    ...storePoint(d),
    isActive: bool(d.isActive, true),
  };
}

function storePoint(d: Record<string, unknown>): { lat: number | null; lng: number | null } {
  if (d.lat == null && d.lng == null) return { lat: null, lng: null };
  return { lat: numIn(d.lat, "Latitude", 6, 37), lng: numIn(d.lng, "Longitude", 68, 98) };
}

export interface SlotInput {
  label: string;
  etaMinutes: number;
  isExpress: boolean;
  isActive: boolean;
  sortOrder: number;
}

export function validateSlot(raw: unknown): SlotInput {
  const d = obj(raw, "delivery slot");
  return {
    label: text(d.label, "Label", 2, 40),
    etaMinutes: intIn(d.etaMinutes, "Delivery time (min)", 5, 24 * 60),
    isExpress: bool(d.isExpress, false),
    isActive: bool(d.isActive, true),
    sortOrder: d.sortOrder == null ? 0 : intIn(d.sortOrder, "Order", 0, 999),
  };
}

export interface DeliveryConfigInput {
  feePaise: number;
  freeAbovePaise: number;
  minOrderPaise: number;
}

/** Matches orders/delivery_config.ts (int paise, 0 = off). */
export function validateDeliveryConfig(raw: unknown): DeliveryConfigInput {
  const d = obj(raw, "delivery pricing");
  const max = 10_000_00; // ₹10,000
  return {
    feePaise: intIn(d.feePaise, "Delivery fee (paise)", 0, 500_00),
    freeAbovePaise: intIn(d.freeAbovePaise, "Free delivery above (paise)", 0, max),
    minOrderPaise: intIn(d.minOrderPaise, "Minimum order (paise)", 0, max),
  };
}

export const ANNOUNCEMENT_TONES = ["info", "warning", "offer"] as const;
export type AnnouncementTone = (typeof ANNOUNCEMENT_TONES)[number];

export interface AppConfig {
  supportPhone: string | null;
  whatsappNumber: string | null;
  supportEmail: string | null;
  announcement: { enabled: boolean; text: string; tone: AnnouncementTone };
}

export const DEFAULT_APP_CONFIG: AppConfig = {
  supportPhone: null,
  whatsappNumber: null,
  supportEmail: null,
  announcement: { enabled: false, text: "", tone: "info" },
};

export function validateAppConfig(raw: unknown): AppConfig {
  const d = obj(raw, "app config");
  const a = obj(d.announcement ?? {}, "announcement");
  const email = optionalText(d.supportEmail, "Support email", 120);
  if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) bad("Support email looks wrong");
  const enabled = bool(a.enabled, false);
  const announcementText = text(a.text ?? "", "Announcement", 0, 160);
  if (enabled && announcementText.length < 3) bad("Write the announcement before turning it on");
  const tone = (ANNOUNCEMENT_TONES as readonly string[]).includes(a.tone as string)
    ? (a.tone as AnnouncementTone)
    : "info";
  return {
    supportPhone: phoneOrNull(d.supportPhone, "Support phone"),
    whatsappNumber: phoneOrNull(d.whatsappNumber, "WhatsApp number"),
    supportEmail: email,
    announcement: { enabled, text: announcementText, tone },
  };
}
