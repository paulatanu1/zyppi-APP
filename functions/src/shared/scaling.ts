/**
 * Instance caps, so one runaway function can't use the whole regional CPU
 * quota (it counts running instances; see index.ts). The default is small;
 * only the busy customer, payment and rider paths get more.
 */
export const DEFAULT_MAX_INSTANCES = 2;

/** Busy paths: checkout, payments, order triggers, rider location. */
export const HOT = { maxInstances: 5 } as const;
