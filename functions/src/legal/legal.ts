import { FieldValue } from "firebase-admin/firestore";
import { type CallableRequest, HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../shared/audit";
import { requireUid } from "../shared/callable";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";
import {
  AUDIENCE_COLLECTION,
  AUDIENCE_DOCS,
  type Accepted,
  type Audience,
  CONSENTS,
  type CurrentDoc,
  LEGAL_DOCS,
  type LegalType,
  type PublishInput,
  SIGNATURE_OTP_MAX_AGE_S,
  SIGNED_TYPES,
  bodyHash,
  consentId,
  isAudience,
  isLegalType,
  nextHead,
  pendingDocs,
  publishProblems,
} from "./model";

/**
 * Publishes the next version of a legal document. `actor` null = the
 * publish-legal script (no audit row). Exported for the script and tests.
 */
export async function publishLegalDoc(actor: Actor | null, input: PublishInput, by = actor?.uid ?? "script") {
  const head = db.collection(LEGAL_DOCS).doc(input.type);
  const sha256 = bodyHash(input.body);
  return db.runTransaction(async (tx) => {
    const prev = await tx.get(head);
    if (prev.exists && prev.get("sha256") === sha256 && prev.get("title") === input.title && !input.requiresReaccept) {
      return { type: input.type, version: prev.get("currentVersion") as number, unchanged: true };
    }
    const { version, minVersion } = nextHead(prev.data(), input.requiresReaccept);
    tx.create(head.collection("versions").doc(String(version)), {
      type: input.type,
      version,
      title: input.title,
      body: input.body,
      sha256,
      requiresReaccept: input.requiresReaccept,
      effectiveFrom: FieldValue.serverTimestamp(),
      publishedBy: by,
    });
    tx.set(head, {
      type: input.type,
      title: input.title,
      currentVersion: version,
      minVersion,
      sha256,
      updatedAt: FieldValue.serverTimestamp(),
    });
    if (actor) {
      writeAudit(actor, { action: "legal.publish", target: head.path, before: prev.exists ? { version: prev.get("currentVersion") } : null, after: { version, minVersion, sha256 } }, tx);
    }
    return { type: input.type, version, unchanged: false };
  });
}

/** Request: {type, title, body: {en, bn?, hi?, pa?}, requiresReaccept}. */
export const adminPublishLegalDoc = onCall(async (request) => {
  const actor = requireRole(request, []);
  const { input, problems } = publishProblems(request.data ?? {});
  if (!input) throw new HttpsError("invalid-argument", problems.join("; "));
  return publishLegalDoc(actor, input);
});

async function currentDocs(types: LegalType[]): Promise<CurrentDoc[]> {
  const snaps = await db.getAll(...types.map((t) => db.collection(LEGAL_DOCS).doc(t)));
  return snaps
    .filter((s) => s.exists && Number.isInteger(s.get("currentVersion")))
    .map((s) => ({
      type: s.id as LegalType,
      version: s.get("currentVersion") as number,
      title: (s.get("title") as string) ?? s.id,
      sha256: (s.get("sha256") as string) ?? "",
      minVersion: (s.get("minVersion") as number | undefined) ?? 1,
    }));
}

async function acceptedBy(audience: Audience, id: string): Promise<Accepted[]> {
  const snap = await db.collection(AUDIENCE_COLLECTION[audience]).doc(id).collection(CONSENTS).get();
  return snap.docs
    .map((d) => ({ type: d.get("type"), version: d.get("version") }))
    .filter((a): a is Accepted => isLegalType(a.type) && Number.isInteger(a.version));
}

/** What `id` still has to accept as `audience`. */
export async function pendingFor(audience: Audience, id: string): Promise<CurrentDoc[]> {
  const [current, accepted] = await Promise.all([currentDocs(AUDIENCE_DOCS[audience]), acceptedBy(audience, id)]);
  return pendingDocs(audience, current, accepted);
}

/**
 * Registration gate: throws TERMS_NOT_ACCEPTED unless `id` accepted the
 * live version of everything its audience must. Documents not yet
 * published don't block, so a gate switches on when its document is
 * published (publish the rider agreement only once the rider app asks
 * for it).
 */
export async function assertConsented(audience: Audience, id: string): Promise<void> {
  const pending = await pendingFor(audience, id);
  if (pending.length) {
    throw new HttpsError("failed-precondition", "TERMS_NOT_ACCEPTED", { pending: pending.map((d) => d.type) });
  }
}

function audienceOf(request: CallableRequest): Audience {
  const a = request.data?.audience ?? "customer";
  if (!isAudience(a)) throw new HttpsError("invalid-argument", "Invalid audience");
  return a;
}

/** Request: {audience}. Reply: {pending: [{type, version, title, sha256, signed}]}. */
export const legalStatus = onCall(async (request) => {
  const uid = requireUid(request);
  const audience = audienceOf(request);
  const pending = await pendingFor(audience, uid);
  return { pending: pending.map((d) => ({ ...d, signed: SIGNED_TYPES.includes(d.type) })) };
});

const text = (v: unknown, max: number) => (typeof v === "string" ? v.trim().slice(0, max) : "");

export interface AcceptInput {
  audience: Audience;
  items: { type: LegalType; version: number; sha256: string }[];
  signaturePath: string | null;
  appId: string;
  appVersion: string;
  platform: string;
}

export interface AcceptContext {
  uid: string;
  anonymous: boolean;
  /** Seconds since epoch of the last sign-in / OTP (ID token `auth_time`). */
  authTime: number | null;
  ip: string | null;
  userAgent: string | null;
  nowS: number;
}

export function readAccept(raw: Record<string, unknown>): AcceptInput {
  const audience = raw.audience ?? "customer";
  if (!isAudience(audience)) throw new HttpsError("invalid-argument", "Invalid audience");
  const items = (Array.isArray(raw.items) ? raw.items : []).slice(0, 10).map((i) => {
    const r = (i ?? {}) as Record<string, unknown>;
    return { type: r.type as LegalType, version: Number(r.version), sha256: text(r.sha256, 64) };
  });
  if (!items.length || items.some((i) => !isLegalType(i.type) || !Number.isInteger(i.version) || i.version < 1)) {
    throw new HttpsError("invalid-argument", "Nothing to accept");
  }
  return {
    audience,
    items,
    signaturePath: text(raw.signaturePath, 300) || null,
    appId: text(raw.appId, 80),
    appVersion: text(raw.appVersion, 40),
    platform: text(raw.platform, 20),
  };
}

/**
 * Checks an acceptance against what is live. Signed agreements (rider,
 * seller) need a drawn signature in the caller's own KYC folder and a
 * phone OTP in the last 10 minutes. Pure, for the tests.
 */
export function acceptProblems(input: AcceptInput, ctx: AcceptContext, current: CurrentDoc[]): string[] {
  const out: string[] = [];
  for (const item of input.items) {
    if (!AUDIENCE_DOCS[input.audience].includes(item.type)) {
      out.push(`${item.type} isn't for ${input.audience}s`);
      continue;
    }
    const doc = current.find((d) => d.type === item.type);
    if (!doc) out.push(`${item.type} isn't published`);
    else if (doc.version !== item.version || (item.sha256 && item.sha256 !== doc.sha256)) out.push("TERMS_CHANGED");
  }
  const signed = input.items.some((i) => SIGNED_TYPES.includes(i.type) && AUDIENCE_DOCS[input.audience].includes(i.type));
  if (signed) {
    if (ctx.anonymous) out.push("Sign in with your phone number to sign");
    const folder = `${AUDIENCE_COLLECTION[input.audience]}/${ctx.uid}/kyc/`;
    const p = input.signaturePath;
    if (!p || !p.startsWith(folder) || p.includes("..")) out.push("Draw your signature to sign");
    if (ctx.authTime === null || ctx.nowS - ctx.authTime > SIGNATURE_OTP_MAX_AGE_S) out.push("OTP_REQUIRED");
  }
  return [...new Set(out)];
}

/**
 * Request: {audience, items: [{type, version, sha256}], signaturePath?,
 * appId, appVersion, platform}. Records one consent per document;
 * accepting the same version again changes nothing.
 */
export const acceptLegal = onCall(async (request) => {
  const uid = requireUid(request);
  const input = readAccept(request.data ?? {});
  const token = request.auth?.token;
  const ctx: AcceptContext = {
    uid,
    anonymous: token?.firebase?.sign_in_provider === "anonymous",
    authTime: typeof token?.auth_time === "number" ? token.auth_time : null,
    ip: request.rawRequest?.ip ?? null,
    userAgent: text(request.rawRequest?.headers?.["user-agent"], 300) || null,
    nowS: Math.floor(Date.now() / 1000),
  };
  const current = await currentDocs(input.items.map((i) => i.type));
  const problems = acceptProblems(input, ctx, current);
  if (problems.length) throw new HttpsError("failed-precondition", problems.join("; "));

  const base = db.collection(AUDIENCE_COLLECTION[input.audience]).doc(uid).collection(CONSENTS);
  const signed = input.items.some((i) => SIGNED_TYPES.includes(i.type));
  await db.runTransaction(async (tx) => {
    const refs = input.items.map((i) => base.doc(consentId(i.type, i.version)));
    const existing = await tx.getAll(...refs);
    input.items.forEach((item, n) => {
      if (existing[n].exists) return;
      const doc = current.find((d) => d.type === item.type)!;
      tx.create(refs[n], {
        type: item.type,
        version: item.version,
        sha256: doc.sha256,
        acceptedAt: FieldValue.serverTimestamp(),
        method: SIGNED_TYPES.includes(item.type) ? "signature+otp" : "checkbox",
        signaturePath: signed ? input.signaturePath : null,
        phone: typeof request.auth?.token.phone_number === "string" ? request.auth.token.phone_number : null,
        appId: input.appId || null,
        appVersion: input.appVersion || null,
        platform: input.platform || null,
        ip: ctx.ip,
        userAgent: ctx.userAgent,
      });
    });
  });
  return { ok: true };
});
