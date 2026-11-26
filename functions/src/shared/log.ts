import { logger } from "firebase-functions";

/**
 * Order and payment lifecycle logs (audit LOG-01/02). One structured line
 * per step, always with the ids that tie it together (`orderId`, `txnid`),
 * so Logs Explorer can follow an order end to end:
 *
 *   jsonPayload.event =~ "^order\." AND jsonPayload.orderId = "<id>"
 *
 * Only ids, statuses, amounts and reason codes: never names, phones,
 * addresses or payment details.
 */
export type LifecycleEvent =
  | "order.placed"
  | "order.refused"
  | "order.status"
  | "order.seller"
  | "order.rider"
  | "order.partial"
  | "payment.intent"
  | "payment.refused"
  | "payment.completed";

export function logLifecycle(event: LifecycleEvent, fields: Record<string, unknown>): void {
  const line = { event, ...fields };
  if (event.endsWith(".refused")) logger.warn(event, line);
  else logger.info(event, line);
}
