import { createHash } from "node:crypto";

/**
 * Versioned legal documents and who accepted which version
 * (docs/MARKETPLACE.md → Terms & Conditions and consent).
 *
 *   legalDocs/{type}                 currentVersion, title, requiresReaccept, updatedAt
 *   legalDocs/{type}/versions/{v}    title, body {en, bn?, hi?, pa?}, sha256, effectiveFrom
 *   {users|riders|sellers}/{id}/consents/{type}_v{v}
 *
 * Everyone reads the documents; only adminPublishLegalDoc (or
 * scripts/publish-legal.ts) writes them; only acceptLegal writes consents.
 */
export const LEGAL_DOCS = "legalDocs";
export const CONSENTS = "consents";

export const LEGAL_TYPES = [
  "customer_terms",
  "privacy_policy",
  "refund_policy",
  "rider_agreement",
  "seller_agreement",
] as const;
export type LegalType = (typeof LEGAL_TYPES)[number];

export const AUDIENCES = ["customer", "rider", "seller"] as const;
export type Audience = (typeof AUDIENCES)[number];

/** What each kind of user has to accept. */
export const AUDIENCE_DOCS: Record<Audience, LegalType[]> = {
  customer: ["customer_terms", "privacy_policy", "refund_policy"],
  rider: ["rider_agreement", "privacy_policy"],
  seller: ["seller_agreement", "privacy_policy"],
};

/** Where an audience's consents are kept. */
export const AUDIENCE_COLLECTION: Record<Audience, string> = {
  customer: "users",
  rider: "riders",
  seller: "sellers",
};

/** Agreements that need a drawn signature and a fresh phone OTP. */
export const SIGNED_TYPES: LegalType[] = ["rider_agreement", "seller_agreement"];

/** The phone OTP behind a signature must be this recent. */
export const SIGNATURE_OTP_MAX_AGE_S = 10 * 60;

export const LANGS = ["en", "bn", "hi", "pa"] as const;
export type Lang = (typeof LANGS)[number];

export const MAX_BODY = 200_000;

export const isLegalType = (v: unknown): v is LegalType =>
  typeof v === "string" && (LEGAL_TYPES as readonly string[]).includes(v);
export const isAudience = (v: unknown): v is Audience =>
  typeof v === "string" && (AUDIENCES as readonly string[]).includes(v);

export const consentId = (type: LegalType, version: number) => `${type}_v${version}`;

/**
 * Fingerprint of exactly the text published (all languages, fixed key
 * order), kept with every consent as evidence of what was shown.
 */
export function bodyHash(body: Partial<Record<Lang, string>>): string {
  const canonical = LANGS.filter((l) => body[l]).map((l) => `${l}\n${body[l]}`).join("\n\u0000\n");
  return createHash("sha256").update(canonical, "utf8").digest("hex");
}

export interface PublishInput {
  type: LegalType;
  title: string;
  body: Partial<Record<Lang, string>>;
  /** Everyone must accept this version again before carrying on. */
  requiresReaccept: boolean;
}

/** Problems with a document an admin wants to publish. */
export function publishProblems(raw: Record<string, unknown>): { input: PublishInput | null; problems: string[] } {
  const problems: string[] = [];
  if (!isLegalType(raw.type)) problems.push("Unknown document type");
  const title = typeof raw.title === "string" ? raw.title.trim().slice(0, 120) : "";
  if (title.length < 3) problems.push("Title is required");
  const bodyIn = (raw.body ?? {}) as Record<string, unknown>;
  const body: Partial<Record<Lang, string>> = {};
  for (const l of LANGS) {
    const v = bodyIn[l];
    if (typeof v === "string" && v.trim()) body[l] = v.replace(/\r\n/g, "\n").trim();
  }
  if (!body.en) problems.push("The English text is required");
  for (const [l, v] of Object.entries(body)) {
    if (v.length > MAX_BODY) problems.push(`The ${l} text is too long`);
  }
  if (problems.length) return { input: null, problems };
  return {
    input: { type: raw.type as LegalType, title, body, requiresReaccept: raw.requiresReaccept === true },
    problems,
  };
}

/** The live version of a document (legalDocs/{type}), as the callables see it. */
export interface CurrentDoc {
  type: LegalType;
  version: number;
  title: string;
  sha256: string;
  /**
   * The oldest version whose acceptance still counts: the latest version
   * published with "everyone must accept again" (1 until then).
   */
  minVersion: number;
}

/** An accepted version (from the consents subcollection). */
export interface Accepted {
  type: LegalType;
  version: number;
}

/**
 * Documents the user still has to accept: never accepted, or only
 * versions older than `minVersion`. A newer version that didn't require
 * accepting again (a typo fix) carries on the earlier acceptance.
 * Documents not published yet are not asked for.
 */
export function pendingDocs(audience: Audience, current: CurrentDoc[], accepted: Accepted[]): CurrentDoc[] {
  return AUDIENCE_DOCS[audience].flatMap((type) => {
    const doc = current.find((d) => d.type === type);
    if (!doc) return [];
    const ok = accepted.some((a) => a.type === type && a.version >= doc.minVersion);
    return ok ? [] : [doc];
  });
}

/** legalDocs/{type} after publishing `requiresReaccept` as the next version. */
export function nextHead(prev: { currentVersion?: number; minVersion?: number } | undefined, requiresReaccept: boolean) {
  const version = (prev?.currentVersion ?? 0) + 1;
  const minVersion = requiresReaccept || !prev?.minVersion ? version : prev.minVersion;
  return { version, minVersion };
}

/** `[UPPER CASE]` placeholders left in a draft (docs/legal/README.md). */
export function findPlaceholders(text: string): string[] {
  return [...new Set(text.match(/\[[A-Z][A-Z0-9 ]{1,40}\]/g) ?? [])];
}

/**
 * A docs/legal file: a `---` front-matter block with `type:` and `title:`,
 * then the Markdown body.
 */
export function parseLegalMarkdown(source: string): { type: string; title: string; body: string } | null {
  const m = /^---\r?\n([\s\S]*?)\r?\n---\r?\n([\s\S]*)$/.exec(source);
  if (!m) return null;
  const meta = Object.fromEntries(
    m[1].split(/\r?\n/).map((l) => {
      const i = l.indexOf(":");
      return i < 0 ? [l.trim(), ""] : [l.slice(0, i).trim(), l.slice(i + 1).trim()];
    }),
  );
  return { type: meta.type ?? "", title: meta.title ?? "", body: m[2].trim() };
}
