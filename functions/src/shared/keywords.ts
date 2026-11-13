/**
 * Search keywords for a product: lower-cased prefixes (min 2 chars) of the
 * whole name and of every word in it, so `array-contains "mil"` finds
 * "Toned Milk" and "toned m" finds it too. Firestore has no full-text
 * search; this replaces Postgres `search_vector`.
 *
 * Only the server generates these: the admin callables
 * (src/catalog/products.ts, import.ts) and the onProductWritten trigger for
 * edits made anywhere else.
 */
export function productKeywords(name: string, extra: string[] = []): string[] {
  const out = new Set<string>();
  const add = (text: string) => {
    const clean = text.toLowerCase().replace(/\s+/g, " ").trim();
    for (let i = 2; i <= Math.min(clean.length, 30); i++) {
      out.add(clean.slice(0, i));
    }
  };
  const normalized = name.toLowerCase().replace(/[^\p{L}\p{N}\s]/gu, " ");
  add(normalized);
  for (const word of normalized.split(/\s+/)) {
    if (word.length >= 2) add(word);
  }
  for (const word of extra) add(word);
  return [...out];
}
