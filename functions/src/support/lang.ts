/** The app's four languages (assets/translations: en-UK, bn-BN, hi-IN, pa-Guru). */
export const LANGS = ["en", "bn", "hi", "pa"] as const;
export type Lang = (typeof LANGS)[number];

export function isLang(value: unknown): value is Lang {
  return typeof value === "string" && (LANGS as readonly string[]).includes(value);
}

/** App locale code (e.g. "bn_BN", "pa-Guru", "en") → bot language. */
export function langFromLocale(locale: unknown): Lang {
  const code = typeof locale === "string" ? locale.slice(0, 2).toLowerCase() : "";
  return isLang(code) ? code : "en";
}

const SCRIPTS: [Lang, RegExp][] = [
  ["bn", /[ঀ-৿]/gu], // Bengali
  ["hi", /[ऀ-ॿ]/gu], // Devanagari
  ["pa", /[਀-੿]/gu], // Gurmukhi
];

/**
 * The language a message is written in, from its script. Latin text
 * ("refund kab milega") is ambiguous between English and romanised
 * Hindi/Bengali, so it keeps [fallback]: the chat's language.
 */
export function detectLang(text: string, fallback: Lang = "en"): Lang {
  let best: Lang | null = null;
  let bestCount = 0;
  for (const [lang, re] of SCRIPTS) {
    const count = text.match(re)?.length ?? 0;
    if (count > bestCount) {
      best = lang;
      bestCount = count;
    }
  }
  return best ?? fallback;
}
