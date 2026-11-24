import { describe, expect, it } from "vitest";
import { checkDigit, expandUpcE, isCanonicalGtin, offCode, parseGtin } from "../../src/catalog/gtin";

const withCheck = (body: string) => body + checkDigit(body);

describe("GS1 check digit", () => {
  it("EAN-13, EAN-8, UPC-A", () => {
    expect(checkDigit("301762042200")).toBe(3);
    expect(checkDigit("890105885129")).toBe(8);
    expect(checkDigit("9638507")).toBe(4);
    expect(checkDigit("03600029145")).toBe(2);
  });

  it("rejects a wrong last digit", () => {
    expect(parseGtin("3017620422004")).toEqual({ ok: false, problem: "check_digit" });
    expect(parseGtin("96385075")).toEqual({ ok: false, problem: "check_digit" });
    expect(parseGtin("036000291453")).toEqual({ ok: false, problem: "check_digit" });
  });
});

describe("normalization to GTIN-14", () => {
  it("EAN-13 (incl. Indian 890)", () => {
    expect(parseGtin("3017620422003")).toEqual({ ok: true, gtin: "03017620422003", kind: "gtin13", offCode: "3017620422003" });
    expect(parseGtin("8901058851298")).toMatchObject({ ok: true, gtin: "08901058851298" });
  });

  it("UPC-A, its EAN-13 form and GTIN-14 form are one key (leading zeros kept)", () => {
    const a = parseGtin("036000291452");
    expect(a).toEqual({ ok: true, gtin: "00036000291452", kind: "gtin12", offCode: "0036000291452" });
    expect(parseGtin("0036000291452")).toEqual(a);
    expect(parseGtin("00036000291452")).toEqual(a);
  });

  it("EAN-8 keeps 8 digits for Open Food Facts", () => {
    expect(parseGtin("96385074")).toEqual({ ok: true, gtin: "00000096385074", kind: "gtin8", offCode: "96385074" });
    expect(offCode("00000096385074")).toBe("96385074");
  });

  it("UPC-E expands to UPC-A (all four compression patterns)", () => {
    expect(expandUpcE("04252614")).toBe("042100005264");
    expect(expandUpcE("0425261")).toBe("042100005264");
    expect(expandUpcE("425261")).toBe("042100005264");
    expect(expandUpcE("01234531")?.slice(0, 11)).toBe("01230000045");
    expect(expandUpcE("0123454")?.slice(0, 11)).toBe("01234000005");
    expect(expandUpcE("0123457")?.slice(0, 11)).toBe("01234500007");
    expect(expandUpcE("2123457")).toBeNull(); // number system must be 0 / 1
    expect(expandUpcE("04252615")).toBeNull(); // wrong check digit
  });

  it("a scanned UPC-E matches its UPC-A", () => {
    expect(parseGtin("04252614", "upce")).toEqual(parseGtin("042100005264"));
  });

  it("a typed 8-digit code is EAN-8 first, UPC-E if only that checks", () => {
    expect(parseGtin("96385074")).toMatchObject({ kind: "gtin8" });
    expect(parseGtin("04252614")).toMatchObject({ ok: true, gtin: "00042100005264" });
  });

  it("ignores spaces and dashes; rejects other characters and lengths", () => {
    expect(parseGtin(" 3017620 422003 ")).toMatchObject({ ok: true });
    expect(parseGtin("30176-20422003")).toMatchObject({ ok: true });
    for (const bad of ["", "abc", "12345", "123456789", "1234567890", "301762042200x", "123456789012345", "0000000000000"]) {
      expect(parseGtin(bad)).toEqual({ ok: false, problem: "invalid_format" });
    }
    expect(parseGtin(3017620422003 as unknown as string)).toEqual({ ok: false, problem: "invalid_format" });
  });

  it("only canonical keys count as stored gtins", () => {
    expect(isCanonicalGtin("03017620422003")).toBe(true);
    expect(isCanonicalGtin("3017620422003")).toBe(false);
    expect(isCanonicalGtin("03017620422004")).toBe(false);
  });
});

describe("in-store / variable-measure and restricted numbers", () => {
  it("EAN-13 prefixes 20–29 (weighed / priced in store)", () => {
    for (const p of ["20", "23", "29"]) {
      expect(parseGtin(withCheck(`${p}1234500100`))).toEqual({ ok: false, problem: "variable_measure" });
    }
  });

  it("UPC number system 2 (random weight) and 4 (in-store)", () => {
    expect(parseGtin(withCheck("21234567890"))).toEqual({ ok: false, problem: "variable_measure" });
    expect(parseGtin(withCheck("41234567890"))).toEqual({ ok: false, problem: "restricted" });
  });

  it("EAN-8 starting 0 or 2", () => {
    expect(parseGtin(withCheck("2123456"))).toEqual({ ok: false, problem: "variable_measure" });
    expect(parseGtin(withCheck("0123456"), "ean8")).toEqual({ ok: false, problem: "variable_measure" });
  });

  it("coupons and refund receipts", () => {
    expect(parseGtin(withCheck("990000000001"))).toEqual({ ok: false, problem: "restricted" });
    expect(parseGtin(withCheck("980000000001"))).toEqual({ ok: false, problem: "restricted" });
    expect(parseGtin(withCheck("51234567890"))).toEqual({ ok: false, problem: "restricted" });
  });

  it("books (978) and ordinary 0-prefixed UPCs are fine", () => {
    expect(parseGtin(withCheck("978014300723"))).toMatchObject({ ok: true });
    expect(parseGtin("036000291452")).toMatchObject({ ok: true });
  });
});
