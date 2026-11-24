/**
 * Retail barcodes (docs/BARCODES.md). Every EAN-13 / EAN-8 / UPC-A / UPC-E
 * is validated with the GS1 mod-10 check digit and normalized to one
 * canonical key: a 14-digit GTIN string (GS1's recommended storage form),
 * zero-padded and never a number, so the same item scanned as UPC-A or
 * EAN-13 matches. Restricted-circulation numbers (in-store, variable
 * measure / weight, coupons) are rejected: they are not globally unique.
 *
 * Mirrored in the seller app (lib/core/barcode/gtin.dart) with the same
 * test vectors; the server always re-validates.
 */

/** What the scanner said it read; "unknown" for typed codes. */
export type BarcodeFormat = "ean13" | "ean8" | "upca" | "upce" | "unknown";

export type GtinProblem =
  /** Not digits, or a length no retail barcode has. */
  | "invalid_format"
  /** The last digit doesn't match. */
  | "check_digit"
  /** In-store / weighed items (prefixes 02, 20–29, EAN-8 0/2): encode price or weight. */
  | "variable_measure"
  /** Company-internal numbers (prefix 04), coupons (05, 98–99), refund receipts (980). */
  | "restricted";

export type GtinKind = "gtin8" | "gtin12" | "gtin13" | "gtin14";

export type GtinResult =
  | { ok: true; gtin: string; kind: GtinKind; offCode: string }
  | { ok: false; problem: GtinProblem };

/** GS1 mod-10 check digit for the digits before it. */
export function checkDigit(body: string): number {
  let sum = 0;
  for (let i = 0; i < body.length; i++) {
    const d = body.charCodeAt(body.length - 1 - i) - 48;
    sum += i % 2 === 0 ? d * 3 : d;
  }
  return (10 - (sum % 10)) % 10;
}

function checkOk(code: string): boolean {
  return checkDigit(code.slice(0, -1)) === code.charCodeAt(code.length - 1) - 48;
}

/**
 * UPC-E (8 digits: number system 0/1, six data digits, check; or the six /
 * seven digits without the check) → UPC-A (12 digits). Null if not UPC-E.
 */
export function expandUpcE(code: string): string | null {
  let ns: string;
  let d: string;
  let check: string | null = null;
  if (code.length === 6) {
    ns = "0";
    d = code;
  } else if (code.length === 7) {
    ns = code[0];
    d = code.slice(1);
  } else if (code.length === 8) {
    ns = code[0];
    d = code.slice(1, 7);
    check = code[7];
  } else {
    return null;
  }
  if (ns !== "0" && ns !== "1") return null;
  const last = d[5];
  let body: string;
  if (last <= "2") body = `${d[0]}${d[1]}${last}0000${d[2]}${d[3]}${d[4]}`;
  else if (last === "3") body = `${d[0]}${d[1]}${d[2]}00000${d[3]}${d[4]}`;
  else if (last === "4") body = `${d[0]}${d[1]}${d[2]}${d[3]}00000${d[4]}`;
  else body = `${d[0]}${d[1]}${d[2]}${d[3]}${d[4]}0000${last}`;
  const upcA = `${ns}${body}`;
  const cd = String(checkDigit(upcA));
  if (check !== null && check !== cd) return null;
  return upcA + cd;
}

/** Parses a scanned or typed barcode. */
export function parseGtin(raw: unknown, format: BarcodeFormat = "unknown"): GtinResult {
  if (typeof raw !== "string") return { ok: false, problem: "invalid_format" };
  const code = raw.replace(/[\s-]/g, "");
  if (!/^\d{6,14}$/.test(code)) return { ok: false, problem: "invalid_format" };

  let full: string;
  if (format === "upce" || code.length === 6 || code.length === 7) {
    const a = expandUpcE(code);
    if (!a) return { ok: false, problem: code.length === 8 ? "check_digit" : "invalid_format" };
    full = a;
  } else if (code.length === 8) {
    // EAN-8 first; a typed UPC-E (same length) only if the EAN-8 check fails.
    if (checkOk(code)) full = code;
    else {
      const a = format === "ean8" ? null : expandUpcE(code);
      if (!a) return { ok: false, problem: "check_digit" };
      full = a;
    }
  } else if (code.length === 12 || code.length === 13 || code.length === 14) {
    full = code;
  } else {
    return { ok: false, problem: "invalid_format" };
  }
  if (!checkOk(full)) return { ok: false, problem: "check_digit" };

  const gtin = full.padStart(14, "0");
  if (/^0+$/.test(gtin.slice(0, -1))) return { ok: false, problem: "invalid_format" };
  const problem = restriction(gtin);
  if (problem) return { ok: false, problem };
  return { ok: true, gtin, kind: kindOf(gtin), offCode: offCode(gtin) };
}

function kindOf(gtin: string): GtinKind {
  if (gtin[0] !== "0") return "gtin14";
  if (gtin.startsWith("000000")) return "gtin8";
  if (gtin.startsWith("00")) return "gtin12";
  return "gtin13";
}

/** The code Open Food Facts indexes products under (EAN-8 stays 8 digits). */
export function offCode(gtin: string): string {
  if (gtin[0] !== "0") return gtin;
  if (gtin.startsWith("000000")) return gtin.slice(6);
  return gtin.slice(1);
}

/** GS1 prefixes that are not globally unique trade items. */
export function restriction(gtin: string): GtinProblem | null {
  if (gtin[0] !== "0") return null; // GTIN-14 case codes: indicator digit, real items
  if (gtin.startsWith("000000")) {
    const e8 = gtin.slice(6);
    return e8[0] === "0" || e8[0] === "2" ? "variable_measure" : null;
  }
  const g13 = gtin.slice(1);
  const p2 = Number(g13.slice(0, 2));
  const p3 = Number(g13.slice(0, 3));
  if (p3 >= 20 && p3 <= 29) return "variable_measure"; // UPC number system 2
  if (p3 >= 40 && p3 <= 49) return "restricted"; // UPC number system 4
  if (p3 >= 50 && p3 <= 59) return "restricted"; // UPC coupons
  if (p2 >= 20 && p2 <= 29) return "variable_measure"; // EAN in-store
  if (p3 >= 980 && p3 <= 984) return "restricted"; // refund receipts, coupons
  if (p2 === 99) return "restricted"; // coupons
  return null;
}

/** A stored gtin must already be canonical (what parseGtin returns). */
export function isCanonicalGtin(v: unknown): v is string {
  if (typeof v !== "string" || !/^\d{14}$/.test(v)) return false;
  const r = parseGtin(v);
  return r.ok && r.gtin === v;
}
