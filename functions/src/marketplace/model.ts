import { HttpsError } from "firebase-functions/https";
import { type Payout, payoutSummary } from "../riders/model";

/**
 * Marketplace sellers (docs/MARKETPLACE.md). sellers/{sellerId} is keyed
 * by the owner's Auth uid at application time; staff logins of the same
 * shop are mapped in sellerUsers/{uid}. Zyppi's own stock is the seller
 * `zyppi` (model `own`). Written only by callables.
 */
export const SELLERS = "sellers";
export const SELLER_USERS = "sellerUsers";
export const SELLER_PLANS = "sellerPlans";
export const LISTINGS = "listings";
export const OFFERS = "offers";

export const ZYPPI_SELLER_ID = "zyppi";

/** Stores without a `sellerId` predate the marketplace and are Zyppi's. */
export const isZyppiStore = (sellerId: unknown) => sellerId == null || sellerId === ZYPPI_SELLER_ID;

/** How an outside seller works with Zyppi (`own` is only Zyppi itself). */
export const SELLER_MODELS = ["subscription", "supply"] as const;
export type SellerModel = (typeof SELLER_MODELS)[number];

/** Where the stock sits: the seller's shop (rider picks up there) or a Zyppi dark store. */
export const FULFILMENTS = ["seller_shop", "zyppi_store"] as const;
export type Fulfilment = (typeof FULFILMENTS)[number];

export const SELLER_STATUSES = [
  "draft",
  "applied",
  "changes_requested",
  "approved",
  "rejected",
  "suspended",
] as const;
export type SellerStatus = (typeof SELLER_STATUSES)[number];

/** Statuses in which the applicant may edit and (re)submit. */
export const SELLER_EDITABLE: SellerStatus[] = ["draft", "changes_requested", "rejected"];

export const SELLER_ROLES = ["owner", "staff"] as const;
export type SellerRole = (typeof SELLER_ROLES)[number];

export const SHOP_CATEGORIES = [
  "grocery",
  "fruits_vegetables",
  "dairy_bakery",
  "meat_fish",
  "pharmacy",
  "household",
  "personal_care",
  "stationery",
  "other",
] as const;

/** Camera captures and documents in the applicant's private KYC folder. */
export const SELLER_DOC_KEYS = [
  "selfie",
  "shopPhoto1",
  "shopPhoto2",
  "shopPhoto3",
  "fssaiCertificate",
  "gstCertificate",
  "signature",
] as const;
export type SellerDocKey = (typeof SELLER_DOC_KEYS)[number];

/** Where and when a camera photo was taken (the app stamps it). */
export interface Capture {
  path: string;
  lat: number | null;
  lng: number | null;
  takenAt: string | null;
}

export interface SellerApplication {
  ownerName: string;
  phone: string;
  email: string;
  pan: string;
  aadhaarLast4: string;
  shopName: string;
  shopCategory: string;
  address: string;
  lat: number | null;
  lng: number | null;
  serviceAreaId: string;
  hours: { open: string; close: string } | null;
  gstin: string;
  fssaiNo: string;
  fssaiExpiry: string;
  model: SellerModel | "";
  fulfilment: Fulfilment | "";
  planId: string;
  docs: Partial<Record<SellerDocKey, Capture>>;
  payout: Payout | null;
}

const text = (v: unknown, max = 300) => (typeof v === "string" ? v.trim().slice(0, max) : "");
const upper = (v: unknown, max = 30) => text(v, max).toUpperCase().replace(/\s+/g, "");
const num = (v: unknown, min: number, max: number) =>
  typeof v === "number" && Number.isFinite(v) && v >= min && v <= max ? v : null;
const oneOf = <T extends string>(list: readonly T[], v: unknown): T | "" =>
  (list as readonly string[]).includes(v as string) ? (v as T) : "";

/** Only files in this applicant's own private folder. */
function readCapture(raw: unknown, sellerId: string): Capture | null {
  const r = (typeof raw === "string" ? { path: raw } : raw) as Record<string, unknown> | null;
  if (!r || typeof r !== "object") return null;
  const path = text(r.path, 300);
  if (!path || !path.startsWith(`sellers/${sellerId}/kyc/`) || path.includes("..")) return null;
  const takenAt = text(r.takenAt, 40);
  return {
    path,
    lat: num(r.lat, -90, 90),
    lng: num(r.lng, -180, 180),
    takenAt: takenAt && !Number.isNaN(Date.parse(takenAt)) ? new Date(takenAt).toISOString() : null,
  };
}

function readPayout(raw: unknown): Payout | null {
  const p = (raw ?? null) as Record<string, unknown> | null;
  if (!p || (p.method !== "upi" && p.method !== "bank")) return null;
  return p.method === "upi"
    ? { method: "upi", upiId: text(p.upiId, 120) }
    : {
        method: "bank",
        accountName: text(p.accountName, 80),
        accountNumber: text(p.accountNumber, 20).replace(/\s+/g, ""),
        ifsc: upper(p.ifsc, 11),
      };
}

const HHMM = /^([01]\d|2[0-3]):[0-5]\d$/;

/** Normalises what the seller app sent (unknown keys are dropped). */
export function readSellerApplication(raw: Record<string, unknown>, sellerId: string): SellerApplication {
  const docsIn = (raw.docs ?? {}) as Record<string, unknown>;
  const docs: Partial<Record<SellerDocKey, Capture>> = {};
  for (const k of SELLER_DOC_KEYS) {
    const c = readCapture(docsIn[k], sellerId);
    if (c) docs[k] = c;
  }
  const h = (raw.hours ?? null) as Record<string, unknown> | null;
  const hours =
    h && HHMM.test(text(h.open, 5)) && HHMM.test(text(h.close, 5))
      ? { open: text(h.open, 5), close: text(h.close, 5) }
      : null;
  return {
    ownerName: text(raw.ownerName, 80),
    phone: text(raw.phone, 16).replace(/[\s-]/g, ""),
    email: text(raw.email, 120).toLowerCase(),
    pan: upper(raw.pan, 10),
    aadhaarLast4: text(raw.aadhaarLast4, 4),
    shopName: text(raw.shopName, 80),
    shopCategory: oneOf(SHOP_CATEGORIES, raw.shopCategory),
    address: text(raw.address, 300),
    lat: num(raw.lat, -90, 90),
    lng: num(raw.lng, -180, 180),
    serviceAreaId: text(raw.serviceAreaId, 128),
    hours,
    gstin: upper(raw.gstin, 15),
    fssaiNo: text(raw.fssaiNo, 14).replace(/\s+/g, ""),
    fssaiExpiry: text(raw.fssaiExpiry, 10),
    model: oneOf(SELLER_MODELS, raw.model),
    fulfilment: oneOf(FULFILMENTS, raw.fulfilment),
    planId: text(raw.planId, 128),
    docs,
    payout: readPayout(raw.payout),
  };
}

/** Food categories need an FSSAI licence (FSS Act 2006). */
export const needsFssai = (a: Pick<SellerApplication, "shopCategory">) =>
  a.shopCategory !== "stationery" && a.shopCategory !== "household" && a.shopCategory !== "personal_care";

/** Metres between two points (haversine). */
export function metresBetween(a: { lat: number; lng: number }, b: { lat: number; lng: number }): number {
  const R = 6_371_000;
  const rad = (d: number) => (d * Math.PI) / 180;
  const dLat = rad(b.lat - a.lat);
  const dLng = rad(b.lng - a.lng);
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(rad(a.lat)) * Math.cos(rad(b.lat)) * Math.sin(dLng / 2) ** 2;
  return 2 * R * Math.asin(Math.sqrt(h));
}

/** Shop photos must be taken this close to the shop's map pin. */
export const SHOP_PHOTO_RADIUS_M = 200;

/**
 * Every problem with an application. `complete` = submitting (all required
 * fields); otherwise only fields that are filled in are checked (drafts).
 */
export function sellerApplicationProblems(a: SellerApplication, complete: boolean, now = new Date()): string[] {
  const out: string[] = [];
  const need = (ok: boolean, msg: string) => complete && !ok && out.push(msg);

  need(a.ownerName.length >= 3, "Owner name is required");
  if (a.ownerName && !/^[\p{L} .'-]{3,80}$/u.test(a.ownerName)) out.push("Name can only have letters");
  need(!!a.phone, "Mobile number is required");
  if (a.phone && !/^(\+91)?[6-9]\d{9}$/.test(a.phone)) out.push("Enter a 10-digit Indian mobile number");
  if (a.email && !/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(a.email)) out.push("Email looks wrong");
  need(!!a.pan, "PAN is required");
  if (a.pan && !/^[A-Z]{5}\d{4}[A-Z]$/.test(a.pan)) out.push("PAN looks wrong (e.g. ABCDE1234F)");
  if (a.aadhaarLast4 && !/^\d{4}$/.test(a.aadhaarLast4)) out.push("Enter only the last 4 digits of Aadhaar");

  need(a.shopName.length >= 2, "Shop name is required");
  need(!!a.shopCategory, "Choose what your shop sells");
  need(a.address.length >= 10, "Shop address is required");
  need(a.lat !== null && a.lng !== null, "Drop a pin on your shop's location");
  need(!!a.serviceAreaId, "Choose the area your shop is in");
  need(!!a.hours, "Add your shop's opening hours");

  if (a.gstin && !/^\d{2}[A-Z]{5}\d{4}[A-Z][1-9A-Z]Z[0-9A-Z]$/.test(a.gstin)) out.push("GSTIN looks wrong");
  if (a.gstin && a.pan && a.gstin.slice(2, 12) !== a.pan) out.push("GSTIN doesn't match the PAN");
  if (needsFssai(a) || a.fssaiNo) {
    need(!!a.fssaiNo, "FSSAI licence number is required for food");
    if (a.fssaiNo && !/^\d{14}$/.test(a.fssaiNo)) out.push("FSSAI number must be 14 digits");
    need(!!a.fssaiExpiry, "FSSAI licence expiry date is required");
    if (a.fssaiExpiry) {
      const exp = Date.parse(`${a.fssaiExpiry}T00:00:00Z`);
      if (!/^\d{4}-\d{2}-\d{2}$/.test(a.fssaiExpiry) || Number.isNaN(exp)) out.push("FSSAI expiry isn't a valid date");
      else if (exp <= now.getTime()) out.push("Your FSSAI licence has expired");
    }
    need(!!a.docs.fssaiCertificate, "Upload a photo of your FSSAI certificate");
  }

  need(!!a.model, "Choose subscription or supply");
  need(!!a.fulfilment, "Choose where your stock will be");
  if (a.model === "subscription") need(!!a.planId, "Choose a subscription plan");

  need(!!a.docs.selfie, "Take a live selfie");
  need(!!a.docs.shopPhoto1, "Take at least one photo of your shop with its signboard");
  if (a.lat !== null && a.lng !== null) {
    for (const k of ["shopPhoto1", "shopPhoto2", "shopPhoto3"] as const) {
      const c = a.docs[k];
      if (!c) continue;
      if (c.lat === null || c.lng === null) {
        need(false, "Shop photos must be taken with location on");
      } else if (metresBetween({ lat: a.lat, lng: a.lng }, { lat: c.lat, lng: c.lng }) > SHOP_PHOTO_RADIUS_M) {
        out.push("Shop photos must be taken at the shop");
        break;
      }
    }
  }
  need(!!a.docs.signature, "Sign the seller agreement");

  need(!!a.payout, "Add a UPI ID or bank account for payouts");
  if (a.payout?.method === "upi") {
    need(!!a.payout.upiId, "UPI ID is required");
    if (a.payout.upiId && !/^[\w.-]{2,256}@[a-zA-Z]{2,64}$/.test(a.payout.upiId)) {
      out.push("UPI ID looks wrong (e.g. name@okaxis)");
    }
  }
  if (a.payout?.method === "bank") {
    const b = a.payout;
    need(!!b.accountName, "Account holder name is required");
    need(!!b.accountNumber, "Account number is required");
    if (b.accountNumber && !/^\d{9,18}$/.test(b.accountNumber)) out.push("Account number must be 9–18 digits");
    need(!!b.ifsc, "IFSC is required");
    if (b.ifsc && !/^[A-Z]{4}0[A-Z0-9]{6}$/.test(b.ifsc)) out.push("IFSC looks wrong (e.g. SBIN0001234)");
  }
  return [...new Set(out)];
}

export function assertNoProblems(problems: string[]): void {
  if (problems.length) throw new HttpsError("invalid-argument", problems.join("; "));
}

export { payoutSummary };

// ------------------------------------------------------------------ plans

export const PLAN_MONTHS = [1, 3, 6] as const;

export interface SellerPlanInput {
  name: string;
  months: (typeof PLAN_MONTHS)[number];
  feePaise: number;
  /** Most active listings a seller on this plan may have (0 = no limit). */
  maxListings: number;
  isActive: boolean;
}

export function readPlan(raw: Record<string, unknown>): SellerPlanInput {
  return {
    name: text(raw.name, 60),
    months: Number(raw.months) as SellerPlanInput["months"],
    feePaise: Number(raw.feePaise),
    maxListings: Number(raw.maxListings ?? 0),
    isActive: raw.isActive !== false,
  };
}

export function planProblems(p: SellerPlanInput): string[] {
  const out: string[] = [];
  if (p.name.length < 2) out.push("Plan name is required");
  if (!(PLAN_MONTHS as readonly number[]).includes(p.months)) out.push("A plan is 1, 3 or 6 months");
  if (!Number.isInteger(p.feePaise) || p.feePaise < 0 || p.feePaise > 10_000_000) out.push("Fee must be ₹0–₹1,00,000");
  if (!Number.isInteger(p.maxListings) || p.maxListings < 0 || p.maxListings > 100_000) {
    out.push("Listing limit must be 0 (no limit) or more");
  }
  return out;
}

// --------------------------------------------------------------- listings

/**
 * A listing's id is also its inventory row's id: Zyppi's own stock keeps
 * the existing `{storeId}_{variantId}`; a seller's is
 * `{storeId}_{sellerId}_{variantId}`.
 */
export function listingIdFor(storeId: string, sellerId: string, variantId: string): string {
  return sellerId === ZYPPI_SELLER_ID ? `${storeId}_${variantId}` : `${storeId}_${sellerId}_${variantId}`;
}
