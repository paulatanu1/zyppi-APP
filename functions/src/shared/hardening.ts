import { logger } from "firebase-functions";
import { type CallableRequest, HttpsError } from "firebase-functions/https";

/**
 * App Check, applied by every callable through requireUid / requireRole
 * (shared/callable.ts, shared/roles.ts).
 *
 * Starts in monitor mode so nothing breaks on deploy. Turn it on in
 * functions/.env.<project> (then redeploy functions):
 *
 *   APP_CHECK_ENFORCE=true      calls without a valid App Check token fail
 *
 * Firebase verifies any App Check token sent with a callable; an invalid
 * or missing one leaves `request.app` undefined.
 */

export interface HardeningEnv {
  appCheckEnforce: boolean;
}

export function hardeningEnv(env: NodeJS.ProcessEnv = process.env): HardeningEnv {
  return {
    appCheckEnforce: env.APP_CHECK_ENFORCE === "true",
  };
}

export const APP_CHECK_FAILED = "APP_CHECK_FAILED";

/** Throws (enforce) or logs (monitor) when the call has no App Check token. */
export function checkAppCheck(
  request: Pick<CallableRequest, "app" | "rawRequest">,
  env: HardeningEnv = hardeningEnv(),
): void {
  if (request.app) return;
  if (env.appCheckEnforce) {
    throw new HttpsError("unauthenticated", APP_CHECK_FAILED);
  }
  // Monitor mode: shows in Logs Explorer which callers still lack tokens.
  logger.info("Callable without App Check", {
    path: request.rawRequest?.path ?? null,
  });
}
