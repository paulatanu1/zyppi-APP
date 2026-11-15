import { logger } from "firebase-functions";
import { type CallableRequest, HttpsError } from "firebase-functions/https";

/**
 * App Check and super-admin 2FA, applied by every callable through
 * requireUid / requireRole (shared/callable.ts, shared/roles.ts).
 *
 * Both start in monitor mode so nothing breaks on deploy. Turn them on in
 * functions/.env.<project> (then redeploy functions):
 *
 *   APP_CHECK_ENFORCE=true      calls without a valid App Check token fail
 *   SUPER_ADMIN_MFA=required    super-admin sessions need the TOTP factor
 *
 * Firebase verifies any App Check token sent with a callable; an invalid
 * or missing one leaves `request.app` undefined.
 */

export interface HardeningEnv {
  appCheckEnforce: boolean;
  superAdminMfa: boolean;
}

export function hardeningEnv(env: NodeJS.ProcessEnv = process.env): HardeningEnv {
  return {
    appCheckEnforce: env.APP_CHECK_ENFORCE === "true",
    superAdminMfa: env.SUPER_ADMIN_MFA === "required",
  };
}

export const APP_CHECK_FAILED = "APP_CHECK_FAILED";
export const MFA_REQUIRED = "MFA_REQUIRED";

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

/** The second factor the ID token was minted with ("totp", "phone"), if any. */
export function secondFactorOf(token: Record<string, unknown> | undefined | null): string | null {
  const firebase = token?.firebase as { sign_in_second_factor?: unknown } | undefined;
  return typeof firebase?.sign_in_second_factor === "string" ? firebase.sign_in_second_factor : null;
}

/** Throws when a super admin signed in without their second factor (once required). */
export function checkSuperAdminMfa(
  role: string | null,
  token: Record<string, unknown> | undefined | null,
  env: HardeningEnv = hardeningEnv(),
): void {
  if (role !== "super_admin" || !env.superAdminMfa) return;
  if (!secondFactorOf(token)) {
    throw new HttpsError("permission-denied", MFA_REQUIRED);
  }
}
