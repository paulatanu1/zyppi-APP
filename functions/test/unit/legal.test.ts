import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { describe, expect, it } from "vitest";
import { type AcceptContext, acceptProblems, readAccept } from "../../src/legal/legal";
import {
  type CurrentDoc,
  bodyHash,
  findPlaceholders,
  isLegalType,
  nextHead,
  parseLegalMarkdown,
  pendingDocs,
  publishProblems,
} from "../../src/legal/model";

const doc = (type: CurrentDoc["type"], version: number, minVersion = 1): CurrentDoc => ({ type, version, minVersion, title: type, sha256: `h-${type}-${version}` });

describe("pendingDocs", () => {
  const current = [doc("customer_terms", 1), doc("privacy_policy", 1), doc("refund_policy", 1)];

  it("asks a new customer for every published document", () => {
    expect(pendingDocs("customer", current, []).map((d) => d.type)).toEqual(["customer_terms", "privacy_policy", "refund_policy"]);
  });

  it("doesn't ask for documents not published yet (gates switch on with publishing)", () => {
    expect(pendingDocs("rider", [doc("privacy_policy", 1)], [{ type: "privacy_policy", version: 1 }])).toEqual([]);
  });

  it("a typo-fix version carries on the earlier acceptance; a re-accept version doesn't", () => {
    const accepted = [{ type: "customer_terms" as const, version: 1 }];
    expect(pendingDocs("customer", [doc("customer_terms", 2, 1)], accepted)).toEqual([]);
    expect(pendingDocs("customer", [doc("customer_terms", 3, 2)], accepted).map((d) => d.version)).toEqual([3]);
    // Accepted v2 (the re-accept one) → still fine on a later typo fix v3.
    expect(pendingDocs("customer", [doc("customer_terms", 3, 2)], [{ type: "customer_terms", version: 2 }])).toEqual([]);
  });
});

describe("nextHead", () => {
  it("starts at v1 and moves minVersion only on re-accept", () => {
    expect(nextHead(undefined, false)).toEqual({ version: 1, minVersion: 1 });
    expect(nextHead({ currentVersion: 1, minVersion: 1 }, false)).toEqual({ version: 2, minVersion: 1 });
    expect(nextHead({ currentVersion: 2, minVersion: 1 }, true)).toEqual({ version: 3, minVersion: 3 });
  });
});

describe("publishing", () => {
  it("needs a type, a title and English text", () => {
    expect(publishProblems({ type: "x", title: "", body: {} }).problems).toEqual([
      "Unknown document type",
      "Title is required",
      "The English text is required",
    ]);
    const { input } = publishProblems({ type: "customer_terms", title: "Terms", body: { en: " Hi\r\nthere ", xx: "dropped" } });
    expect(input?.body).toEqual({ en: "Hi\nthere" });
  });

  it("hashes the exact text, independent of key order", () => {
    expect(bodyHash({ en: "a", bn: "b" })).toBe(bodyHash({ bn: "b", en: "a" }));
    expect(bodyHash({ en: "a" })).not.toBe(bodyHash({ en: "a " }));
  });

  it("finds placeholders and reads front matter", () => {
    expect(findPlaceholders("By [COMPANY LEGAL NAME], see [x] and [CIN].")).toEqual(["[COMPANY LEGAL NAME]", "[CIN]"]);
    expect(parseLegalMarkdown("---\ntype: refund_policy\ntitle: Refunds: how\n---\n\n# Body\n")).toEqual({
      type: "refund_policy",
      title: "Refunds: how",
      body: "# Body",
    });
    expect(parseLegalMarkdown("# no front matter")).toBeNull();
  });

  it("every draft in docs/legal has a valid type and title", () => {
    const dir = join(__dirname, "..", "..", "..", "docs", "legal");
    const files = readdirSync(dir).filter((f) => /^[a-z-]+\.md$/.test(f));
    expect(files.length).toBe(5);
    for (const f of files) {
      const p = parseLegalMarkdown(readFileSync(join(dir, f), "utf8"));
      expect(p && isLegalType(p.type), f).toBe(true);
      // Drafts still carry [PLACEHOLDERS] for the lawyer; nothing else may be wrong.
      const problems = publishProblems({ ...p, body: { en: p!.body } }).problems;
      expect(problems.filter((x) => !x.startsWith("Fill the placeholders")), f).toEqual([]);
    }
  });

  it("refuses text that still has placeholders", () => {
    const res = publishProblems({ type: "customer_terms", title: "Terms", body: { en: "Run by [COMPANY LEGAL NAME]." } });
    expect(res.input).toBeNull();
    expect(res.problems[0]).toContain("[COMPANY LEGAL NAME]");
  });
});

describe("acceptProblems", () => {
  const nowS = 1_800_000_000;
  const ctx = (over: Partial<AcceptContext> = {}): AcceptContext => ({ uid: "u1", anonymous: false, authTime: nowS - 60, ip: null, userAgent: null, nowS, ...over });
  const current = [doc("customer_terms", 2), doc("privacy_policy", 1), doc("seller_agreement", 1)];

  it("accepts the live versions with a checkbox for customers (guests too)", () => {
    const input = readAccept({ audience: "customer", items: [{ type: "customer_terms", version: 2, sha256: "h-customer_terms-2" }, { type: "privacy_policy", version: 1 }] });
    expect(acceptProblems(input, ctx({ anonymous: true, authTime: null }), current)).toEqual([]);
  });

  it("refuses an old version or changed text (the app must reload the terms)", () => {
    const input = readAccept({ audience: "customer", items: [{ type: "customer_terms", version: 1 }] });
    expect(acceptProblems(input, ctx(), current)).toEqual(["TERMS_CHANGED"]);
    const changed = readAccept({ audience: "customer", items: [{ type: "customer_terms", version: 2, sha256: "other" }] });
    expect(acceptProblems(changed, ctx(), current)).toEqual(["TERMS_CHANGED"]);
  });

  it("refuses a document meant for someone else", () => {
    const input = readAccept({ audience: "customer", items: [{ type: "seller_agreement", version: 1 }] });
    expect(acceptProblems(input, ctx(), current)).toEqual(["seller_agreement isn't for customers"]);
  });

  it("a seller agreement needs the seller's own signature and a fresh OTP", () => {
    const base = { audience: "seller", items: [{ type: "seller_agreement", version: 1 }, { type: "privacy_policy", version: 1 }] };
    expect(acceptProblems(readAccept({ ...base, signaturePath: "sellers/u1/kyc/signature.png" }), ctx(), current)).toEqual([]);
    expect(acceptProblems(readAccept({ ...base, signaturePath: "sellers/u2/kyc/signature.png" }), ctx(), current)).toEqual(["Draw your signature to sign"]);
    expect(acceptProblems(readAccept({ ...base, signaturePath: "sellers/u1/kyc/signature.png" }), ctx({ authTime: nowS - 11 * 60 }), current)).toEqual(["OTP_REQUIRED"]);
    expect(acceptProblems(readAccept({ ...base, signaturePath: "sellers/u1/kyc/s.png" }), ctx({ anonymous: true }), current)).toEqual(["Sign in to sign"]);
  });

  it("rejects malformed requests", () => {
    expect(() => readAccept({ audience: "admin", items: [] })).toThrow("Invalid audience");
    expect(() => readAccept({ items: [{ type: "nope", version: 1 }] })).toThrow("Nothing to accept");
  });
});
