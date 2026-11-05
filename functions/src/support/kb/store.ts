import type { Firestore } from "firebase-admin/firestore";
import { LANGS } from "../lang";
import { decodeVector, encodeVector, type Embedder } from "./embed";
import { Retriever, type IndexedEntry } from "./retrieve";
import type { KbEntry } from "./types";

export const KB_COLLECTION = "supportKb";

/** How long an instance keeps the knowledge base before re-reading it. */
const CACHE_MS = 10 * 60 * 1000;

let cached: { retriever: Retriever; at: number } | null = null;

/** The knowledge base from Firestore, cached per Function instance. */
export async function loadRetriever(db: Firestore, nowMs = Date.now()): Promise<Retriever> {
  if (cached && nowMs - cached.at < CACHE_MS) return cached.retriever;
  const snap = await db.collection(KB_COLLECTION).get();
  const entries: IndexedEntry[] = snap.docs.map((doc) => {
    const { vectors, updatedAt: _updatedAt, ...entry } = doc.data() as KbEntry & {
      vectors?: string[];
      updatedAt?: unknown;
    };
    return {
      entry: { ...entry, id: doc.id },
      vectors: (vectors ?? []).map(decodeVector),
    };
  });
  cached = { retriever: new Retriever(entries), at: nowMs };
  return cached.retriever;
}

/** For tests: forget the cached knowledge base. */
export function clearRetrieverCache(): void {
  cached = null;
}

/**
 * Embeds every example question and writes the entries to `supportKb`,
 * deleting entries no longer in [entries]. Run by scripts/seed-support-kb.ts.
 */
export async function ingest(db: Firestore, entries: KbEntry[], embedder: Embedder): Promise<number> {
  const batch = db.batch();
  const keep = new Set(entries.map((e) => e.id));
  for (const doc of (await db.collection(KB_COLLECTION).get()).docs) {
    if (!keep.has(doc.id)) batch.delete(doc.ref);
  }
  for (const entry of entries) {
    const questions = LANGS.flatMap((l) => entry.questions[l] ?? []);
    const vectors = (await embedder(questions, "passage")).map(encodeVector);
    const { id, ...data } = entry;
    batch.set(db.collection(KB_COLLECTION).doc(id), {
      ...JSON.parse(JSON.stringify(data)), // drop undefined optionals
      vectors,
      updatedAt: new Date(),
    });
  }
  await batch.commit();
  clearRetrieverCache();
  return entries.length;
}
