import { FieldValue } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { requireUid } from "../shared/callable";
import { requireRole } from "../shared/roles";
import { db } from "../shared/firebase";
import { rateLimit } from "../shared/rate_limit";

/**
 * Product-search insights for the admin ("Search insights"): what people
 * search for, and what found nothing (products to add).
 *
 *   searchStats/{day}__{term}   {day, term, count, zeroCount, lastResults, lastAt}
 *   searchStatsDaily/{day}      {day, count, zeroCount}
 *
 * Only aggregates are stored: no uid, so nothing personal. `day` is the
 * India date (YYYY-MM-DD, Asia/Kolkata).
 */
export const SEARCH_STATS = "searchStats";
export const SEARCH_STATS_DAILY = "searchStatsDaily";

/** Longest term kept; longer searches are cut. */
export const MAX_TERM = 60;

/**
 * The term as stored: lower-case, single spaces, letters/digits/space
 * only, at most [MAX_TERM] characters. Null when nothing is left or it's
 * too short to be useful (one character).
 */
export function normalizeTerm(raw: unknown): string | null {
  if (typeof raw !== "string") return null;
  const term = raw
    .toLowerCase()
    .replace(/[^\p{L}\p{M}\p{N}\s]/gu, " ")
    .replace(/\s+/g, " ")
    .trim()
    .slice(0, MAX_TERM)
    .trim();
  return term.length >= 2 ? term : null;
}

/** India date for [at], e.g. "2026-11-20". */
export function indiaDay(at: Date): string {
  return new Intl.DateTimeFormat("en-CA", {
    timeZone: "Asia/Kolkata",
    year: "numeric",
    month: "2-digit",
    day: "2-digit",
  }).format(at);
}

/** Firestore id for a (day, term) row: no "/" and at most 1500 bytes. */
export function statId(day: string, term: string): string {
  return `${day}__${encodeURIComponent(term)}`;
}

export async function recordSearch(rawTerm: unknown, rawResults: unknown, at = new Date()) {
  const term = normalizeTerm(rawTerm);
  if (!term) return { ok: false };
  const results =
    typeof rawResults === "number" && Number.isFinite(rawResults) && rawResults >= 0
      ? Math.min(Math.trunc(rawResults), 1000)
      : 0;
  const zero = results === 0 ? 1 : 0;
  const day = indiaDay(at);

  const batch = db.batch();
  batch.set(
    db.collection(SEARCH_STATS).doc(statId(day, term)),
    {
      day,
      term,
      count: FieldValue.increment(1),
      zeroCount: FieldValue.increment(zero),
      lastResults: results,
      lastAt: FieldValue.serverTimestamp(),
    },
    { merge: true },
  );
  batch.set(
    db.collection(SEARCH_STATS_DAILY).doc(day),
    { day, count: FieldValue.increment(1), zeroCount: FieldValue.increment(zero) },
    { merge: true },
  );
  await batch.commit();
  return { ok: true };
}

/**
 * Called by the app once per finished search (after the typing pause),
 * guests included. Request: {term, results}.
 */
export const logSearch = onCall(async (request) => {
  rateLimit("logSearch", requireUid(request));
  return recordSearch(request.data?.term, request.data?.results);
});

/** Rows for the admin page: one row per term over the last [days] days. */
export interface SearchInsightRow {
  term: string;
  count: number;
  zeroCount: number;
}

/** Adds up per-day rows into one row per term, most searched first. */
export function mergeRows(rows: { term?: unknown; count?: unknown; zeroCount?: unknown }[]): SearchInsightRow[] {
  const byTerm = new Map<string, SearchInsightRow>();
  for (const r of rows) {
    if (typeof r.term !== "string") continue;
    const row = byTerm.get(r.term) ?? { term: r.term, count: 0, zeroCount: 0 };
    row.count += typeof r.count === "number" ? r.count : 0;
    row.zeroCount += typeof r.zeroCount === "number" ? r.zeroCount : 0;
    byTerm.set(r.term, row);
  }
  return [...byTerm.values()].sort((a, b) => b.count - a.count || a.term.localeCompare(b.term));
}

/**
 * Admin "Search insights": totals per day, top terms and terms that found
 * nothing, for the last 7, 14 or 30 days. Request: {days?}.
 */
export const adminSearchInsights = onCall(async (request) => {
  requireRole(request, ["catalog", "ops"]);
  const days = [7, 14, 30].includes(Number(request.data?.days)) ? Number(request.data.days) : 14;
  const now = new Date();
  const from = indiaDay(new Date(now.getTime() - (days - 1) * 86_400_000));

  const [daily, rows] = await Promise.all([
    db.collection(SEARCH_STATS_DAILY).where("day", ">=", from).orderBy("day").get(),
    db.collection(SEARCH_STATS).where("day", ">=", from).get(),
  ]);
  if (rows.size > 20_000) throw new HttpsError("resource-exhausted", "Too many rows; pick fewer days");

  const terms = mergeRows(rows.docs.map((d) => d.data()));
  return {
    days,
    from,
    trend: daily.docs.map((d) => ({
      day: d.get("day") as string,
      count: (d.get("count") as number) ?? 0,
      zeroCount: (d.get("zeroCount") as number) ?? 0,
    })),
    top: terms.slice(0, 50),
    zeroResults: terms
      .filter((t) => t.zeroCount > 0)
      .sort((a, b) => b.zeroCount - a.zeroCount || a.term.localeCompare(b.term))
      .slice(0, 50),
  };
});
