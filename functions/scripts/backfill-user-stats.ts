/**
 * One-off: fills users/{uid}.orderCount / totalSpentPaise / lastOrderAt /
 * serviceAreaId from existing orders (cancelled ones don't count) and marks
 * those orders `countedForUser`, so a later cancel takes them back off.
 * New orders keep these up to date on their own (orders/quote.ts).
 * Safe to re-run: it recomputes from scratch. Dry run unless --write.
 *
 *   npm --prefix functions run backfill-user-stats -- --project zippy-app-2024
 *   npm --prefix functions run backfill-user-stats -- --project zippy-app-2024 --write
 */
import { initializeApp } from "firebase-admin/app";
import { Timestamp, getFirestore } from "firebase-admin/firestore";

const args = process.argv.slice(2);
const i = args.indexOf("--project");
const projectId = i > -1 ? args[i + 1] : process.env.GCLOUD_PROJECT;
const write = args.includes("--write");

initializeApp(projectId ? { projectId } : undefined);
const db = getFirestore();

interface Stats {
  orderCount: number;
  totalSpentPaise: number;
  lastOrderAt: Timestamp | null;
  serviceAreaId: string | null;
}

(async () => {
  const orders = await db.collection("orders").get();
  const byUser = new Map<string, Stats>();
  const counted: FirebaseFirestore.DocumentReference[] = [];
  for (const o of orders.docs) {
    const uid = o.get("userId") as string | undefined;
    if (!uid || o.get("status") === "cancelled") continue;
    const s = byUser.get(uid) ?? { orderCount: 0, totalSpentPaise: 0, lastOrderAt: null, serviceAreaId: null };
    const placed = o.get("placedAt") as Timestamp | undefined;
    s.orderCount += 1;
    s.totalSpentPaise += (o.get("totalPaise") as number | undefined) ?? 0;
    if (placed && (!s.lastOrderAt || placed.toMillis() > s.lastOrderAt.toMillis())) {
      s.lastOrderAt = placed;
      s.serviceAreaId = (o.get("serviceAreaId") as string | undefined) ?? s.serviceAreaId;
    }
    byUser.set(uid, s);
    if (o.get("countedForUser") !== true) counted.push(o.ref);
  }
  console.log(`${orders.size} orders → ${byUser.size} customers; ${counted.length} orders to mark.`);
  if (!write) {
    console.log("Dry run. Add --write to save.");
    return;
  }
  const writes: [FirebaseFirestore.DocumentReference, Record<string, unknown>][] = [
    ...[...byUser].map(([uid, s]) => [db.collection("users").doc(uid), { ...s }] as [typeof counted[0], Record<string, unknown>]),
    ...counted.map((ref) => [ref, { countedForUser: true }] as [typeof ref, Record<string, unknown>]),
  ];
  for (let n = 0; n < writes.length; n += 400) {
    const batch = db.batch();
    for (const [ref, data] of writes.slice(n, n + 400)) batch.set(ref, data, { merge: true });
    await batch.commit();
  }
  console.log(`Saved ${writes.length} docs.`);
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
