/**
 * One-off: sets users/{uid}.createdAt (from the Firebase Auth account's
 * creation time) on profiles that don't have it, so the admin panel's
 * Customers list (sorted by createdAt) shows them. New profiles get it
 * from onUserProfileCreated. Only adds the missing field; safe to
 * re-run. Dry run unless --write.
 *
 *   npm --prefix functions run backfill-user-created-at -- --project zippy-app-2024
 *   npm --prefix functions run backfill-user-created-at -- --project zippy-app-2024 --write
 */
import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { Timestamp, getFirestore } from "firebase-admin/firestore";

const args = process.argv.slice(2);
const i = args.indexOf("--project");
const projectId = i > -1 ? args[i + 1] : process.env.GCLOUD_PROJECT;
const write = args.includes("--write");

initializeApp(projectId ? { projectId } : undefined);
const db = getFirestore();
const auth = getAuth();

// Same rule as signUpTime in src/account.ts (not imported: that module
// initialises its own Firebase app).
const signUpTime = (creationTime: string | undefined): Timestamp => {
  const ms = creationTime ? Date.parse(creationTime) : Number.NaN;
  return Timestamp.fromMillis(Number.isNaN(ms) ? Date.now() : ms);
};

(async () => {
  const users = await db.collection("users").get();
  let missing = 0;
  for (const doc of users.docs) {
    if (doc.get("createdAt") != null) continue;
    missing++;
    const user = await auth.getUser(doc.id).catch(() => null);
    const createdAt = signUpTime(user?.metadata.creationTime);
    console.log(`${doc.id}: ${createdAt.toDate().toISOString()}${user ? "" : " (no Auth account: now)"}`);
    if (write) await doc.ref.update({ createdAt });
  }
  console.log(`${users.size} profiles, ${missing} without createdAt${write ? " — fixed" : " (dry run: add --write)"}`);
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
