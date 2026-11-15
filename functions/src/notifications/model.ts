import { Timestamp } from "firebase-admin/firestore";
import { HttpsError } from "firebase-functions/https";

/**
 * Push campaigns (`campaigns/{id}`) and reusable templates
 * (`notificationTemplates/{id}`). Pure helpers: validation, who a segment
 * matches, and which language's copy a user gets.
 *
 * Marketing pushes only ever go to customers who opted in
 * (`users.notifyOffers == true`, Account → Notifications in the app).
 */
export const CAMPAIGNS = "campaigns";
export const TEMPLATES = "notificationTemplates";

export const LANGS = ["en", "bn", "hi", "pa"] as const;
export type Lang = (typeof LANGS)[number];
export const LINK_TYPES = ["none", "product", "category", "coupon", "url"] as const;
export type LinkType = (typeof LINK_TYPES)[number];
export const BEHAVIOURS = [
  "any",
  "never_ordered",
  "ordered_within_days",
  "inactive_days",
  "min_orders",
  "min_spent",
] as const;
export type Behaviour = (typeof BEHAVIOURS)[number];

export type CampaignStatus = "draft" | "scheduled" | "sending" | "sent" | "failed" | "cancelled";

export interface Copy {
  title: string;
  body: string;
}

export interface Segment {
  /** Empty = every area. */
  serviceAreaIds: string[];
  /** Empty = every language. */
  langs: Lang[];
  behaviour: Behaviour;
  /** Days for *_days, a count for min_orders, paise for min_spent. */
  value: number | null;
}

export interface CampaignInput {
  name: string;
  /** English copy; used for any language without its own. */
  copy: Copy;
  translations: Partial<Record<Exclude<Lang, "en">, Copy>>;
  imageUrl: string | null;
  linkType: LinkType;
  linkTarget: string | null;
  segment: Segment;
}

/** The fields of a user doc a segment looks at. */
export interface Recipient {
  uid: string;
  token: string;
  lang: Lang;
  serviceAreaId: string | null;
  orderCount: number;
  totalSpentPaise: number;
  lastOrderAtMs: number | null;
}

const DAY = 86_400_000;
const bad = (m: string) => new HttpsError("invalid-argument", m);
const str = (v: unknown) => (typeof v === "string" ? v.trim() : "");

export function isLang(v: unknown): v is Lang {
  return typeof v === "string" && (LANGS as readonly string[]).includes(v);
}

/** Reads a users/{uid} doc; null when it can't receive a marketing push. */
export function toRecipient(uid: string, d: Record<string, unknown>): Recipient | null {
  if (d.notifyOffers !== true || d.blocked === true) return null;
  const token = typeof d.fcmToken === "string" && d.fcmToken ? d.fcmToken : null;
  if (!token) return null;
  const last = d.lastOrderAt;
  return {
    uid,
    token,
    lang: isLang(d.lang) ? d.lang : "en",
    serviceAreaId: typeof d.serviceAreaId === "string" ? d.serviceAreaId : null,
    orderCount: Math.max(Number(d.orderCount) || 0, 0),
    totalSpentPaise: Math.max(Number(d.totalSpentPaise) || 0, 0),
    lastOrderAtMs: last instanceof Timestamp ? last.toMillis() : null,
  };
}

export function matchesSegment(r: Recipient, s: Segment, nowMs: number): boolean {
  if (s.serviceAreaIds.length && (!r.serviceAreaId || !s.serviceAreaIds.includes(r.serviceAreaId))) {
    return false;
  }
  if (s.langs.length && !s.langs.includes(r.lang)) return false;
  const v = s.value ?? 0;
  switch (s.behaviour) {
    case "any":
      return true;
    case "never_ordered":
      return r.orderCount === 0;
    case "ordered_within_days":
      return r.lastOrderAtMs != null && nowMs - r.lastOrderAtMs <= v * DAY;
    case "inactive_days":
      // Ordered before, but not in the last N days.
      return r.lastOrderAtMs != null && nowMs - r.lastOrderAtMs > v * DAY;
    case "min_orders":
      return r.orderCount >= v;
    case "min_spent":
      return r.totalSpentPaise >= v;
  }
}

/** The user's language if the campaign has it, English otherwise. */
export function copyFor(c: Pick<CampaignInput, "copy" | "translations">, lang: Lang): Copy {
  if (lang === "en") return c.copy;
  return c.translations[lang] ?? c.copy;
}

function validateCopy(raw: unknown, label: string, required: boolean): Copy | null {
  const r = (raw ?? {}) as Record<string, unknown>;
  const title = str(r.title);
  const body = str(r.body);
  if (!title && !body && !required) return null;
  if (title.length < 2 || title.length > 65) throw bad(`${label}: the title must be 2–65 characters`);
  if (body.length < 2 || body.length > 240) throw bad(`${label}: the message must be 2–240 characters`);
  return { title, body };
}

export function validateSegment(raw: unknown): Segment {
  const r = (raw ?? {}) as Record<string, unknown>;
  const behaviour = BEHAVIOURS.find((b) => b === r.behaviour) ?? "any";
  const serviceAreaIds = Array.isArray(r.serviceAreaIds)
    ? [...new Set(r.serviceAreaIds.filter((s): s is string => typeof s === "string" && !!s))]
    : [];
  if (serviceAreaIds.length > 50) throw bad("Too many areas");
  const langs = Array.isArray(r.langs) ? [...new Set(r.langs.filter(isLang))] : [];
  let value: number | null = null;
  if (behaviour !== "any" && behaviour !== "never_ordered") {
    const v = r.value;
    const max = behaviour === "min_spent" ? 100_000_000 : 3650;
    if (typeof v !== "number" || !Number.isInteger(v) || v < 1 || v > max) {
      throw bad(
        behaviour === "min_spent"
          ? "Enter the amount spent (at least ₹0.01)"
          : behaviour === "min_orders"
            ? "Enter the number of orders (1 or more)"
            : "Enter the number of days (1–3650)",
      );
    }
    value = v;
  }
  return { serviceAreaIds, langs, behaviour, value };
}

/** Validates the composer. Throws invalid-argument with a readable reason. */
export function validateCampaign(raw: Record<string, unknown>): CampaignInput {
  const name = str(raw.name);
  if (name.length < 2 || name.length > 80) throw bad("Give the campaign a name (2–80 characters)");
  const copy = validateCopy(raw.copy, "English", true)!;
  const translations: CampaignInput["translations"] = {};
  const t = (raw.translations ?? {}) as Record<string, unknown>;
  for (const lang of ["bn", "hi", "pa"] as const) {
    const c = validateCopy(t[lang], { bn: "Bengali", hi: "Hindi", pa: "Punjabi" }[lang], false);
    if (c) translations[lang] = c;
  }
  const imageUrl = str(raw.imageUrl) || null;
  if (imageUrl && !/^https:\/\//.test(imageUrl)) throw bad("The image must be an https:// URL");
  const linkType = LINK_TYPES.find((l) => l === raw.linkType) ?? "none";
  const linkTarget = linkType === "none" ? null : str(raw.linkTarget) || null;
  if (linkType !== "none" && !linkTarget) throw bad(`Choose the ${linkType} it opens`);
  if (linkType === "url" && !/^https:\/\//.test(linkTarget!)) throw bad("The link must start with https://");
  if (linkType === "coupon" && !/^[A-Z0-9]{3,20}$/.test(linkTarget!.toUpperCase())) {
    throw bad("Invalid coupon code");
  }
  return {
    name,
    copy,
    translations,
    imageUrl,
    linkType,
    linkTarget: linkType === "coupon" ? linkTarget!.toUpperCase() : linkTarget,
    segment: validateSegment(raw.segment),
  };
}

/** The FCM data payload the app's push handler reads (strings only). */
export function pushData(campaignId: string, c: Pick<CampaignInput, "linkType" | "linkTarget">) {
  return {
    campaignId,
    linkType: c.linkType,
    linkTarget: c.linkTarget ?? "",
  };
}
