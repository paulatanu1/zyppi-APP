/**
 * Grants (or with --revoke, removes) the admin custom claim used by
 * firestore.rules, storage.rules and the admin callables. The admin must
 * sign out and back in (or refresh their ID token) for it to apply.
 *
 *   npm --prefix functions run set-admin -- admin@zyppi.one --project zippy-app-2024
 *   npm --prefix functions run set-admin -- admin@zyppi.one --revoke --project zippy-app-2024
 *
 * Creating the admin login itself: Firebase console → Authentication →
 * Add user (email + password).
 */
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

const args = process.argv.slice(2);
const projectArg = args.indexOf("--project");
const projectId = projectArg > -1 ? args[projectArg + 1] : process.env.GCLOUD_PROJECT;
const email = args.find((a) => a.includes("@"));
const revoke = args.includes("--revoke");

if (!email) {
  console.error("Usage: set-admin <email> [--revoke] [--project <id>]");
  process.exit(1);
}

initializeApp(projectId ? { projectId } : undefined);

(async () => {
  const user = await getAuth().getUserByEmail(email);
  const claims = { ...(user.customClaims ?? {}) };
  if (revoke) delete claims.admin;
  else claims.admin = true;
  await getAuth().setCustomUserClaims(user.uid, claims);
  console.log(`${revoke ? "Revoked" : "Granted"} admin for ${email} (${user.uid}).`);
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
