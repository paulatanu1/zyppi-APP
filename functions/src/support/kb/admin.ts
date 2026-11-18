import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { writeAudit } from "../../shared/audit";
import { db } from "../../shared/firebase";
import { type Actor, requireRole } from "../../shared/roles";
import { LANGS, type Lang } from "../lang";
import { type Embedder, embed, encodeVector } from "./embed";
import { KB_COLLECTION, clearRetrieverCache } from "./store";
import type { KbAction, KbEntry } from "./types";

/**
 * KB editor (admin Support → Knowledge base). Saving re-embeds the example
 * questions so the bot matches them. Other bot instances pick the change
 * up within their 10-minute cache (store.ts).
 *
 * Note: `npm run seed:support` replaces the whole collection with
 * kb/seed.ts, so it would undo edits made here.
 */

const ACTIONS: KbAction[] = ["none", "order_status", "handoff", "return_flow"];
const ID = /^[a-z0-9_]{2,40}$/;

function bad(message: string): never {
  throw new HttpsError("invalid-argument", message);
}

const LANG_NAMES: Record<Lang, string> = { en: "English", bn: "Bengali", hi: "Hindi", pa: "Punjabi" };

function perLang<T>(raw: unknown, what: string, f: (v: unknown, lang: Lang) => T): Record<Lang, T> {
  const o = (raw ?? {}) as Record<string, unknown>;
  if (typeof o !== "object" || Array.isArray(o)) bad(`Invalid ${what}`);
  return Object.fromEntries(LANGS.map((l) => [l, f(o[l], l)])) as Record<Lang, T>;
}

function strings(v: unknown, max: number, len: number): string[] {
  if (v == null) return [];
  if (!Array.isArray(v)) bad("Expected a list");
  const out = v
    .filter((x): x is string => typeof x === "string")
    .map((x) => x.trim())
    .filter((x) => x.length > 0);
  if (out.length > max) bad(`At most ${max} entries`);
  if (out.some((x) => x.length > len)) bad(`Each entry can be at most ${len} characters`);
  return [...new Set(out)];
}

/** A KB entry as the bot expects it (types.ts); throws a readable error otherwise. */
export function validateKbEntry(raw: unknown): KbEntry {
  if (!raw || typeof raw !== "object") bad("Invalid entry");
  const d = raw as Record<string, unknown>;
  const id = typeof d.id === "string" ? d.id.trim() : "";
  if (!ID.test(id)) bad("Id: 2–40 lowercase letters, digits or _");
  const action = ACTIONS.includes(d.action as KbAction) ? (d.action as KbAction) : bad("Invalid action");

  const title = perLang(d.title, "title", (v, l) => {
    const s = typeof v === "string" ? v.trim() : "";
    if (s.length < 2 || s.length > 80) bad(`${LANG_NAMES[l]} title: 2–80 characters`);
    return s;
  });
  const questions = perLang(d.questions, "questions", (v) => strings(v, 20, 200));
  if (questions.en.length === 0) bad("Add at least one English example question");
  const answers = perLang(d.answers, "answers", (v, l) => {
    const s = typeof v === "string" ? v.trim() : "";
    if (s.length > 1500) bad(`${LANG_NAMES[l]} answer: at most 1500 characters`);
    // order_status entries may show just the live status.
    if (action !== "order_status" && s.length < 2) bad(`Write the ${LANG_NAMES[l]} answer`);
    return s;
  });
  const related = strings(d.related, 6, 40).filter((r) => r !== id);
  if (related.some((r) => !ID.test(r))) bad("Invalid related entry");

  return {
    id,
    action,
    title,
    questions,
    answers,
    keywords: strings(d.keywords, 30, 40).map((k) => k.toLowerCase()),
    related,
    hidden: d.hidden === true,
  };
}

export async function saveKbEntry(actor: Actor, raw: unknown, embedder: Embedder = embed) {
  const entry = validateKbEntry(raw);
  const ref = db.collection(KB_COLLECTION).doc(entry.id);
  const vectors = (await embedder(LANGS.flatMap((l) => entry.questions[l]), "passage")).map(encodeVector);
  const { id: _id, ...data } = entry;
  const before = await ref.get();
  await ref.set({ ...data, vectors, updatedAt: FieldValue.serverTimestamp(), updatedBy: actor.uid });
  clearRetrieverCache();
  await writeAudit(actor, {
    action: before.exists ? "kb.update" : "kb.create",
    target: `${KB_COLLECTION}/${entry.id}`,
    before: before.exists ? { title: before.get("title"), answers: before.get("answers") } : null,
    after: { title: entry.title, answers: entry.answers, action: entry.action },
  });
  return { id: entry.id, created: !before.exists };
}

export async function deleteKbEntry(actor: Actor, idRaw: unknown) {
  const id = typeof idRaw === "string" ? idRaw : "";
  if (!ID.test(id)) bad("Invalid id");
  const ref = db.collection(KB_COLLECTION).doc(id);
  const before = await ref.get();
  if (!before.exists) throw new HttpsError("not-found", "Entry not found");
  await ref.delete();
  clearRetrieverCache();
  await writeAudit(actor, {
    action: "kb.delete",
    target: `${KB_COLLECTION}/${id}`,
    before: { title: before.get("title"), answers: before.get("answers") },
  });
  return { ok: true };
}

/** Request: a KbEntry (types.ts). Embeds its questions (1 GiB for the model). */
export const adminSaveKbEntry = onCall(
  { memory: "1GiB", cpu: 1, maxInstances: 1, timeoutSeconds: 120 },
  async (request) => saveKbEntry(requireRole(request, ["support"]), request.data),
);

/** Request: {id}. */
export const adminDeleteKbEntry = onCall(async (request) =>
  deleteKbEntry(requireRole(request, ["support"]), request.data?.id),
);
