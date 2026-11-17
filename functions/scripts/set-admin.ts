/**
 * Bootstrap / break-glass: grants a staff role (default super_admin) or,
 * with --revoke, removes it. Day-to-day role changes happen in the admin
 * panel (Settings → Admins & roles → `adminSetRole`). The person must sign
 * out and back in (or wait up to an hour) for a new role to apply.
 *
 *   npm --prefix functions run set-admin -- admin@zyppi.one --project zippy-app-2024
 *   npm --prefix functions run set-admin -- ops@zyppi.one --role ops --project zippy-app-2024
 *   npm --prefix functions run set-admin -- admin@zyppi.one --revoke --project zippy-app-2024
 *
 * Also migrates a legacy `admin: true` account: it drops that claim and
 * sets `role`. Creating the login itself: Firebase console →
 * Authentication → Add user (email + password).
 */
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { ROLES, isRole } from "../src/shared/roles";

const args = process.argv.slice(2);
const flag = (name: string) => {
  const i = args.indexOf(name);
  return i > -1 ? args[i + 1] : undefined;
};
const projectId = flag("--project") ?? process.env.GCLOUD_PROJECT;
const email = args.find((a) => a.includes("@"));
const revoke = args.includes("--revoke");
const role = flag("--role") ?? "super_admin";

if (!email || (!revoke && !isRole(role))) {
  console.error(`Usage: set-admin <email> [--role ${ROLES.join("|")}] [--revoke] [--project <id>]`);
  process.exit(1);
}

initializeApp(projectId ? { projectId } : undefined);

(async () => {
  const auth = getAuth();
  const user = await auth.getUserByEmail(email);
  const claims: Record<string, unknown> = { ...(user.customClaims ?? {}) };
  delete claims.admin;
  if (revoke) delete claims.role;
  else claims.role = role;
  await auth.setCustomUserClaims(user.uid, claims);

  const staff = getFirestore().collection("staff").doc(user.uid);
  if (revoke) {
    await auth.revokeRefreshTokens(user.uid);
    await staff.delete();
  } else {
    await staff.set({
      email: user.email ?? email,
      displayName: user.displayName ?? null,
      role,
      disabled: user.disabled,
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: "set-admin script",
    });
  }
  console.log(`${revoke ? "Revoked staff access for" : `Granted ${role} to`} ${email} (${user.uid}).`);
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
