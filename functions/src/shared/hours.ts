/**
 * Store opening hours, India time: `{open: "08:00", close: "22:00"}`.
 * `close` before `open` runs past midnight (e.g. 18:00–02:00). A store
 * without hours is always open.
 */
export interface Hours {
  open: string;
  close: string;
}

const HHMM = /^([01]\d|2[0-3]):[0-5]\d$/;
const IST_OFFSET_MIN = 5 * 60 + 30;

export function isHhmm(v: unknown): v is string {
  return typeof v === "string" && HHMM.test(v);
}

function minutes(hhmm: string): number {
  const [h, m] = hhmm.split(":").map(Number);
  return h * 60 + m;
}

/** Hours from Firestore, or null when missing / malformed (= always open). */
export function parseHours(v: unknown): Hours | null {
  const h = v as Partial<Hours> | null | undefined;
  return h && isHhmm(h.open) && isHhmm(h.close) && h.open !== h.close
    ? { open: h.open, close: h.close }
    : null;
}

/** True when a store with these hours is open at `at`. */
export function isOpenAt(hours: Hours | null, at: Date): boolean {
  if (!hours) return true;
  const now = (at.getUTCHours() * 60 + at.getUTCMinutes() + IST_OFFSET_MIN) % (24 * 60);
  const open = minutes(hours.open);
  const close = minutes(hours.close);
  return open < close ? now >= open && now < close : now >= open || now < close;
}
