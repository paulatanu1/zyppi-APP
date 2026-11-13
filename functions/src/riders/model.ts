import { HttpsError } from "firebase-functions/https";

/**
 * Delivery partner (rider) applications: riders/{uid}, keyed by the
 * rider's Auth uid. Written only by callables (functions/src/riders).
 */
export const RIDERS = "riders";

export const VEHICLE_TYPES = ["bike", "scooter", "ev_scooter", "cycle"] as const;
export type VehicleType = (typeof VEHICLE_TYPES)[number];

export const RIDER_STATUSES = [
  "draft",
  "submitted",
  "changes_requested",
  "approved",
  "rejected",
  "suspended",
] as const;
export type RiderStatus = (typeof RIDER_STATUSES)[number];

/** Statuses in which the rider may edit and (re)submit. */
export const EDITABLE: RiderStatus[] = ["draft", "changes_requested", "rejected"];

export const DOC_KEYS = ["aadhaarFront", "aadhaarBack", "selfie", "drivingLicence", "rc"] as const;
export type DocKey = (typeof DOC_KEYS)[number];

export interface Payout {
  method: "upi" | "bank";
  upiId?: string;
  accountName?: string;
  accountNumber?: string;
  ifsc?: string;
}

export interface Application {
  fullName: string;
  phone: string;
  dob: string;
  gender: string | null;
  address: string;
  serviceAreaId: string;
  vehicleType: VehicleType | "";
  vehicleNumber: string;
  drivingLicenceNumber: string;
  docs: Partial<Record<DocKey, string>>;
  payout: Payout | null;
}

const text = (v: unknown, max = 300) => (typeof v === "string" ? v.trim().slice(0, max) : "");
const upper = (v: unknown, max = 30) => text(v, max).toUpperCase().replace(/\s+/g, " ");

/** Normalises what the rider portal sent (unknown keys are dropped). */
export function readApplication(raw: Record<string, unknown>, uid: string): Application {
  const docsIn = (raw.docs ?? {}) as Record<string, unknown>;
  const docs: Partial<Record<DocKey, string>> = {};
  for (const k of DOC_KEYS) {
    const p = text(docsIn[k], 300);
    // Only files in this rider's own private folder.
    if (p && p.startsWith(`riders/${uid}/kyc/`) && !p.includes("..")) docs[k] = p;
  }
  const p = (raw.payout ?? null) as Record<string, unknown> | null;
  const payout: Payout | null =
    p && (p.method === "upi" || p.method === "bank")
      ? p.method === "upi"
        ? { method: "upi", upiId: text(p.upiId, 120) }
        : {
            method: "bank",
            accountName: text(p.accountName, 80),
            accountNumber: text(p.accountNumber, 20).replace(/\s+/g, ""),
            ifsc: upper(p.ifsc, 11),
          }
      : null;
  return {
    fullName: text(raw.fullName, 80),
    phone: text(raw.phone, 16).replace(/[\s-]/g, ""),
    dob: text(raw.dob, 10),
    gender: text(raw.gender, 20) || null,
    address: text(raw.address, 300),
    serviceAreaId: text(raw.serviceAreaId, 128),
    vehicleType: (VEHICLE_TYPES as readonly string[]).includes(raw.vehicleType as string)
      ? (raw.vehicleType as VehicleType)
      : "",
    vehicleNumber: upper(raw.vehicleNumber, 15),
    drivingLicenceNumber: upper(raw.drivingLicenceNumber, 20),
    docs,
    payout,
  };
}

export const needsLicence = (a: Pick<Application, "vehicleType">) =>
  a.vehicleType !== "cycle" && a.vehicleType !== "";

/** Age in whole years on `now`. NaN for a bad date. */
export function ageOn(dob: string, now = new Date()): number {
  const m = /^(\d{4})-(\d{2})-(\d{2})$/.exec(dob);
  if (!m) return Number.NaN;
  const d = new Date(Date.UTC(+m[1], +m[2] - 1, +m[3]));
  if (d.getUTCMonth() !== +m[2] - 1) return Number.NaN;
  let age = now.getUTCFullYear() - d.getUTCFullYear();
  const before =
    now.getUTCMonth() < d.getUTCMonth() ||
    (now.getUTCMonth() === d.getUTCMonth() && now.getUTCDate() < d.getUTCDate());
  if (before) age--;
  return age;
}

/**
 * Every problem with an application. `complete` = submitting (all required
 * fields); otherwise only fields that are filled in are checked (drafts).
 */
export function applicationProblems(a: Application, complete: boolean, now = new Date()): string[] {
  const out: string[] = [];
  const need = (ok: boolean, msg: string) => complete && !ok && out.push(msg);

  need(a.fullName.length >= 3, "Full name is required");
  if (a.fullName && !/^[\p{L} .'-]{3,80}$/u.test(a.fullName)) out.push("Name can only have letters");
  need(!!a.phone, "Mobile number is required");
  if (a.phone && !/^(\+91)?[6-9]\d{9}$/.test(a.phone)) out.push("Enter a 10-digit Indian mobile number");
  need(!!a.dob, "Date of birth is required");
  if (a.dob) {
    const age = ageOn(a.dob, now);
    if (Number.isNaN(age)) out.push("Date of birth isn’t a valid date");
    else if (age < 18) out.push("Riders must be at least 18");
    else if (age > 65) out.push("Check the date of birth");
  }
  need(a.address.length >= 10, "Home address is required");
  need(!!a.serviceAreaId, "Choose the area you want to deliver in");
  need(!!a.vehicleType, "Choose a vehicle type");
  if (needsLicence(a)) {
    need(!!a.vehicleNumber, "Vehicle number is required");
    if (a.vehicleNumber && !/^[A-Z]{2} ?\d{1,2} ?[A-Z]{0,3} ?\d{1,4}$/.test(a.vehicleNumber)) {
      out.push("Vehicle number looks wrong (e.g. WB 56 AB 1234)");
    }
    need(!!a.drivingLicenceNumber, "Driving licence number is required");
    if (a.drivingLicenceNumber && !/^[A-Z0-9 -]{10,20}$/.test(a.drivingLicenceNumber)) {
      out.push("Driving licence number looks wrong");
    }
  }
  need(!!a.docs.aadhaarFront, "Upload the front of your Aadhaar");
  need(!!a.docs.aadhaarBack, "Upload the back of your Aadhaar");
  need(!!a.docs.selfie, "Upload a clear selfie");
  if (needsLicence(a)) {
    need(!!a.docs.drivingLicence, "Upload your driving licence");
    need(!!a.docs.rc, "Upload the vehicle RC");
  }
  need(!!a.payout, "Add a UPI ID or bank account for payouts");
  if (a.payout?.method === "upi" && a.payout.upiId && !/^[\w.-]{2,256}@[a-zA-Z]{2,64}$/.test(a.payout.upiId)) {
    out.push("UPI ID looks wrong (e.g. name@okaxis)");
  }
  if (a.payout?.method === "bank") {
    const b = a.payout;
    need(!!b.accountName, "Account holder name is required");
    if (b.accountNumber && !/^\d{9,18}$/.test(b.accountNumber)) out.push("Account number must be 9–18 digits");
    need(!!b.accountNumber, "Account number is required");
    if (b.ifsc && !/^[A-Z]{4}0[A-Z0-9]{6}$/.test(b.ifsc)) out.push("IFSC looks wrong (e.g. SBIN0001234)");
    need(!!b.ifsc, "IFSC is required");
  }
  if (a.payout?.method === "upi") need(!!a.payout.upiId, "UPI ID is required");
  return out;
}

export function assertNoProblems(problems: string[]): void {
  if (problems.length) throw new HttpsError("invalid-argument", problems.join("; "));
}

/** What staff see about payouts on the main doc (full details stay private). */
export function payoutSummary(p: Payout | null) {
  if (!p) return null;
  return p.method === "upi"
    ? { method: "upi", upiId: p.upiId ?? null, accountLast4: null, ifsc: null }
    : { method: "bank", upiId: null, accountLast4: (p.accountNumber ?? "").slice(-4) || null, ifsc: p.ifsc ?? null };
}
