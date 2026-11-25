import { HttpsError } from "firebase-functions/https";
import { logger } from "firebase-functions";
import { afterEach, describe, expect, it, vi } from "vitest";
import { PRICE_CHANGED, priceChanged, shownTotalOf } from "../../src/orders/place_order";
import { OrderError } from "../../src/orders/quote";
import { toHttpsError } from "../../src/shared/callable";
import { logLifecycle } from "../../src/shared/log";

afterEach(() => vi.restoreAllMocks());

describe("shownTotalOf (the bill the app showed)", () => {
  it("takes a non-negative integer and ignores anything else", () => {
    expect(shownTotalOf({ expectedTotalPaise: 12345 })).toBe(12345);
    expect(shownTotalOf({ expectedTotalPaise: 0 })).toBe(0);
    expect(shownTotalOf({})).toBeUndefined(); // older apps
    expect(shownTotalOf({ expectedTotalPaise: 12.5 })).toBeUndefined();
    expect(shownTotalOf({ expectedTotalPaise: -1 })).toBeUndefined();
    expect(shownTotalOf({ expectedTotalPaise: "100" })).toBeUndefined();
  });
});

describe("priceChanged", () => {
  it("rewords the total mismatch for a checkout", () => {
    const e = priceChanged(new OrderError("PAYMENT_AMOUNT_MISMATCH"));
    expect(e).toBeInstanceOf(OrderError);
    expect((e as Error).message).toBe(PRICE_CHANGED);
  });

  it("leaves other errors alone", () => {
    const stock = new OrderError("Insufficient stock for Milk");
    expect(priceChanged(stock)).toBe(stock);
  });
});

describe("toHttpsError refusal logging", () => {
  it("logs an OrderError refusal with its reason, then throws failed-precondition", () => {
    const warn = vi.spyOn(logger, "warn").mockImplementation(() => {});
    expect(() =>
      toHttpsError(new OrderError("STORES_CLOSED"), { event: "order.refused", uid: "u1", paymentMethod: "Cash on delivery" }),
    ).toThrow(HttpsError);
    expect(warn).toHaveBeenCalledWith(
      "order.refused",
      expect.objectContaining({ event: "order.refused", uid: "u1", reason: "STORES_CLOSED", code: "failed-precondition" }),
    );
  });

  it("logs nothing without a refusal context, and rethrows unknown errors as they are", () => {
    const warn = vi.spyOn(logger, "warn").mockImplementation(() => {});
    const boom = new Error("db down");
    expect(() => toHttpsError(boom, { event: "order.refused", uid: "u1" })).toThrow(boom);
    expect(() => toHttpsError(new OrderError("Cart is empty"))).toThrow(HttpsError);
    expect(warn).not.toHaveBeenCalled();
  });
});

describe("logLifecycle", () => {
  it("logs steps at info and refusals at warn, always with the event name", () => {
    const info = vi.spyOn(logger, "info").mockImplementation(() => {});
    const warn = vi.spyOn(logger, "warn").mockImplementation(() => {});
    logLifecycle("order.placed", { orderId: "o1" });
    logLifecycle("payment.refused", { uid: "u1" });
    expect(info).toHaveBeenCalledWith("order.placed", { event: "order.placed", orderId: "o1" });
    expect(warn).toHaveBeenCalledWith("payment.refused", { event: "payment.refused", uid: "u1" });
  });
});
