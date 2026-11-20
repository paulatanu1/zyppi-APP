import { describe, expect, it } from "vitest";
import type { DocumentSnapshot } from "firebase-admin/firestore";
import { DEFAULT_HANDLING_FEE_PAISE, deliveryConfigFrom } from "../../src/orders/delivery_config";

const snap = (data: Record<string, unknown> | undefined) =>
  ({ get: (field: string) => data?.[field] }) as unknown as DocumentSnapshot;

describe("deliveryConfigFrom", () => {
  it("defaults the handling fee to ₹5 when the doc or field is missing", () => {
    expect(DEFAULT_HANDLING_FEE_PAISE).toBe(500);
    expect(deliveryConfigFrom(snap(undefined))).toEqual({
      feePaise: 0,
      freeAbovePaise: 0,
      minOrderPaise: 0,
      handlingFeePaise: 500,
    });
    expect(deliveryConfigFrom(snap({ handlingFeePaise: "9" })).handlingFeePaise).toBe(500);
    expect(deliveryConfigFrom(snap({ handlingFeePaise: -1 })).handlingFeePaise).toBe(500);
  });

  it("uses a set handling fee, including 0", () => {
    expect(deliveryConfigFrom(snap({ handlingFeePaise: 900 })).handlingFeePaise).toBe(900);
    expect(deliveryConfigFrom(snap({ handlingFeePaise: 0 })).handlingFeePaise).toBe(0);
  });
});
