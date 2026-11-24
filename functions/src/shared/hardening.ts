import { logger } from "firebase-functions";
import { type CallableRequest, HttpsError } from "firebase-functions/https";

/**
 * App Check, applied by every callable through requireUid / requireRole
 * (shared/callable.ts, shared/roles.ts).
 *
 * Starts in monitor mode so nothing breaks on deploy. Turn it on in
 * functions/.env.<project> (then redeploy functions):
 *
 *   APP_CHECK_ENFORCE=true        app calls (customer, rider, seller apps)
 *                                 without a valid App Check token fail
 *   APP_CHECK_ENFORCE_WEB=true    same for web calls: staff in the admin
 *                                 panel and its rider sign-up portal
 *                                 (needs the admin's reCAPTCHA Enterprise
 *                                 site key, environment appCheckSiteKey)
 *
 * Two switches so the apps can be enforced first, while the admin panel
 * still has no site key. Callables used from both (acceptLegal,
 * riderSaveApplication) follow the web switch.
 *
 * Firebase verifies any App Check token sent with a callable; an invalid
 * or missing one leaves `request.app` undefined.
 */

export interface HardeningEnv {
  appCheckEnforce: boolean;
  appCheckEnforceWeb: boolean;
}

export function hardeningEnv(env: NodeJS.ProcessEnv = process.env): HardeningEnv {
  return {
    appCheckEnforce: env.APP_CHECK_ENFORCE === "true",
    appCheckEnforceWeb: env.APP_CHECK_ENFORCE_WEB === "true",
  };
}

/** Who is calling: the Android apps, or the web (admin panel, rider portal). */
export type Caller = "app" | "web";

export const APP_CHECK_FAILED = "APP_CHECK_FAILED";

/** Share of tokenless calls logged in monitor mode (audit OPT-05). */
export const APP_CHECK_LOG_SAMPLE = 0.01;

/** Swappable in tests. */
export const appCheckLogSampler = { pick: (): boolean => Math.random() < APP_CHECK_LOG_SAMPLE };

/** Throws (enforce) or logs (monitor) when the call has no App Check token. */
export function checkAppCheck(
  request: Pick<CallableRequest, "app" | "rawRequest">,
  env: HardeningEnv = hardeningEnv(),
  caller: Caller = "app",
): void {
  if (request.app) return;
  if (caller === "web" ? env.appCheckEnforceWeb : env.appCheckEnforce) {
    throw new HttpsError("unauthenticated", APP_CHECK_FAILED);
  }
  // Monitor mode: shows in Logs Explorer which callers still lack tokens.
  // Sampled, since every tokenless call would otherwise be a log line;
  // multiply counts by 1 / sampleRate.
  if (!appCheckLogSampler.pick()) return;
  logger.info("Callable without App Check", {
    caller,
    path: request.rawRequest?.path ?? null,
    sampleRate: APP_CHECK_LOG_SAMPLE,
  });
}
