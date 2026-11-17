/**
 * Instance caps. Cloud Run reserves cpu x maxInstances of every function
 * against the project's regional CPU quota, so the default (index.ts) is
 * small and only the busy customer, payment and rider paths get more.
 */
export const DEFAULT_MAX_INSTANCES = 2;

/** Busy paths: checkout, payments, order triggers, rider location. */
export const HOT = { maxInstances: 5 } as const;
