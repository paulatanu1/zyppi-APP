import type { DocumentSnapshot } from "firebase-admin/firestore";

/**
 * `config/delivery` — admin-edited delivery pricing, read by `quoteOrder`
 * (and by the app, to show the free-delivery progress bar). All amounts
 * are integer paise. A missing doc or field means 0, i.e. free delivery
 * and no minimum, so the app keeps working before the doc exists.
 */
export interface DeliveryConfig {
  /** Charged when the item total is below [freeAbovePaise]. */
  feePaise: number;
  /** Item total at or above which delivery is free (0 = always free). */
  freeAbovePaise: number;
  /** Smallest item total that can be ordered (0 = no minimum). */
  minOrderPaise: number;
}

export const DELIVERY_CONFIG_PATH = "config/delivery";

function paise(value: unknown): number {
  return typeof value === "number" && Number.isInteger(value) && value > 0 ? value : 0;
}

export function deliveryConfigFrom(snap: DocumentSnapshot): DeliveryConfig {
  return {
    feePaise: paise(snap.get("feePaise")),
    freeAbovePaise: paise(snap.get("freeAbovePaise")),
    minOrderPaise: paise(snap.get("minOrderPaise")),
  };
}

/** Delivery fee for an item total under [config]. */
export function deliveryFeeFor(itemTotalPaise: number, config: DeliveryConfig): number {
  if (config.freeAbovePaise === 0 || itemTotalPaise >= config.freeAbovePaise) return 0;
  return config.feePaise;
}
