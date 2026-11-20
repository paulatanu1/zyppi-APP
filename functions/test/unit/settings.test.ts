import { describe, expect, it } from "vitest";
import {
  phoneOrNull,
  validateAppConfig,
  validateDeliveryConfig,
  validateServiceArea,
  validateSlot,
  validateStore,
} from "../../src/admin/settings_model";
import { isOpenAt, parseHours } from "../../src/shared/hours";
import { validateKbEntry } from "../../src/support/kb/admin";

// India time = UTC + 5:30.
const ist = (h: number, m = 0) => new Date(Date.UTC(2026, 10, 15, h, m) - 330 * 60_000);

describe("store hours", () => {
  it("is open between open and close, India time", () => {
    const h = { open: "08:00", close: "22:00" };
    expect(isOpenAt(h, ist(7, 59))).toBe(false);
    expect(isOpenAt(h, ist(8, 0))).toBe(true);
    expect(isOpenAt(h, ist(21, 59))).toBe(true);
    expect(isOpenAt(h, ist(22, 0))).toBe(false);
  });

  it("handles hours past midnight", () => {
    const h = { open: "18:00", close: "02:00" };
    expect(isOpenAt(h, ist(23))).toBe(true);
    expect(isOpenAt(h, ist(1, 30))).toBe(true);
    expect(isOpenAt(h, ist(12))).toBe(false);
  });

  it("treats missing or malformed hours as always open", () => {
    expect(parseHours(undefined)).toBeNull();
    expect(parseHours({ open: "8am", close: "22:00" })).toBeNull();
    expect(parseHours({ open: "08:00", close: "08:00" })).toBeNull();
    expect(isOpenAt(null, ist(3))).toBe(true);
  });
});

describe("settings validation", () => {
  it("accepts a service area inside India and rejects swapped coordinates", () => {
    expect(
      validateServiceArea({ name: "Purulia", centerLat: 23.33, centerLng: 86.36, radiusMeters: 6000 }),
    ).toEqual({ name: "Purulia", centerLat: 23.33, centerLng: 86.36, radiusMeters: 6000, isActive: true });
    expect(() =>
      validateServiceArea({ name: "Purulia", centerLat: 86.36, centerLng: 23.33, radiusMeters: 6000 }),
    ).toThrow(/Latitude/);
    expect(() =>
      validateServiceArea({ name: "P", centerLat: 23, centerLng: 86, radiusMeters: 6000 }),
    ).toThrow(/Name/);
  });

  it("validates stores, hours and phone", () => {
    const s = validateStore({
      name: "Purulia Dark Store",
      serviceAreaId: "area-1",
      phone: "098300 12345",
      hours: { open: "07:00", close: "23:00" },
    });
    expect(s).toMatchObject({ phone: "+919830012345", hours: { open: "07:00", close: "23:00" }, address: null });
    expect(validateStore({ name: "Store", serviceAreaId: "a" }).hours).toBeNull();
    expect(() => validateStore({ name: "Store", serviceAreaId: "a", hours: { open: "7", close: "23:00" } })).toThrow(
      /HH:MM/,
    );
    expect(() => validateStore({ name: "Store" })).toThrow(/service area/);
  });

  it("normalises Indian mobile numbers", () => {
    expect(phoneOrNull("+91 98300-12345", "Phone")).toBe("+919830012345");
    expect(phoneOrNull("", "Phone")).toBeNull();
    expect(() => phoneOrNull("12345", "Phone")).toThrow(/10-digit/);
  });

  it("validates slots and delivery pricing in whole paise", () => {
    expect(validateSlot({ label: "Express", etaMinutes: 15, isExpress: true })).toEqual({
      label: "Express",
      etaMinutes: 15,
      isExpress: true,
      isActive: true,
      sortOrder: 0,
    });
    expect(validateDeliveryConfig({ feePaise: 2500, freeAbovePaise: 49900, minOrderPaise: 9900 })).toEqual({
      feePaise: 2500,
      freeAbovePaise: 49900,
      minOrderPaise: 9900,
    });
    expect(() => validateDeliveryConfig({ feePaise: 25.5, freeAbovePaise: 0, minOrderPaise: 0 })).toThrow(/whole/);
    // The handling fee is optional (left untouched when absent), may be 0, capped at ₹100.
    expect(validateDeliveryConfig({ feePaise: 0, freeAbovePaise: 0, minOrderPaise: 0, handlingFeePaise: 0 })).toEqual({
      feePaise: 0,
      freeAbovePaise: 0,
      minOrderPaise: 0,
      handlingFeePaise: 0,
    });
    expect(() =>
      validateDeliveryConfig({ feePaise: 0, freeAbovePaise: 0, minOrderPaise: 0, handlingFeePaise: 100_01 }),
    ).toThrow(/Handling fee/);
  });

  it("needs announcement text before it can be turned on", () => {
    expect(() => validateAppConfig({ announcement: { enabled: true, text: "" } })).toThrow(/announcement/);
    expect(
      validateAppConfig({
        supportPhone: "9830012345",
        supportEmail: "help@zyppi.in",
        announcement: { enabled: true, text: "Closed for Diwali on 1 Nov", tone: "warning" },
      }),
    ).toEqual({
      supportPhone: "+919830012345",
      whatsappNumber: null,
      supportEmail: "help@zyppi.in",
      announcement: { enabled: true, text: "Closed for Diwali on 1 Nov", tone: "warning" },
    });
    expect(() => validateAppConfig({ supportEmail: "nope" })).toThrow(/email/);
  });
});

describe("validateKbEntry", () => {
  const four = (s: string) => ({ en: s, bn: s, hi: s, pa: s });
  const entry = {
    id: "refund_time",
    action: "none",
    title: four("Refund time"),
    questions: { en: ["When will I get my refund?", "  ", "When will I get my refund?"], hi: ["रिफंड कब मिलेगा?"] },
    answers: four("Refunds reach you in 5–7 working days."),
    keywords: ["Refund", "money back"],
    related: ["refund_time", "refund"],
  };

  it("cleans the entry for the bot", () => {
    const e = validateKbEntry(entry);
    expect(e.questions.en).toEqual(["When will I get my refund?"]);
    expect(e.questions.bn).toEqual([]);
    expect(e.keywords).toEqual(["refund", "money back"]);
    expect(e.related).toEqual(["refund"]); // not itself
    expect(e.hidden).toBe(false);
  });

  it("names the language that's missing", () => {
    expect(() => validateKbEntry({ ...entry, title: { ...four("Refund time"), pa: "" } })).toThrow(/Punjabi title/);
    expect(() => validateKbEntry({ ...entry, answers: { ...four("x x"), bn: "" } })).toThrow(/Bengali answer/);
  });

  it("lets order-status entries leave answers empty", () => {
    expect(validateKbEntry({ ...entry, action: "order_status", answers: four("") }).answers.en).toBe("");
  });

  it("needs an English example question and a slug id", () => {
    expect(() => validateKbEntry({ ...entry, questions: { hi: ["x"] } })).toThrow(/English example/);
    expect(() => validateKbEntry({ ...entry, id: "Refund Time" })).toThrow(/Id/);
  });
});
