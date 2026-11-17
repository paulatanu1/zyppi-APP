/**
 * One-off: rebuilds stats/daily/days/* and stats/areas/days/* from every
 * order, with the same counting as the onOrderWritten trigger
 * (src/stats/model.ts), so the dashboard covers orders from before it.
 * Replaces the existing stats docs. Run it at a quiet time: an order written
 * while it runs may be counted twice or not at all (run it again to fix).
 * Dry run unless --write.
 *
 *   npm --prefix functions run backfill-stats -- --project zippy-app-2024
 *   npm --prefix functions run backfill-stats -- --project zippy-app-2024 --write
 */
import { initializeApp } from "firebase-admin/app";
import { FieldValue, getFirestore } from "firebase-admin/firestore";
import { AREAS, DAILY, DAYS, STATS, rebuild } from "../src/stats/model";

const args = process.argv.slice(2);
const i = args.indexOf("--project");
const projectId = i > -1 ? args[i + 1] : process.env.GCLOUD_PROJECT;
const write = args.includes("--write");

initializeApp(projectId ? { projectId } : undefined);
const db = getFirestore();

(async () => {
  const orders = await db.collection("orders").get();
  const docs = rebuild(orders.docs.map((d) => d.data()));
  const old = [
    ...(await db.collection(STATS).doc(DAILY).collection(DAYS).listDocuments()),
    ...(await db.collection(STATS).doc(AREAS).collection(DAYS).listDocuments()),
  ];
  const days = [...docs.values()].filter((d) => !d.areaId).map((d) => d.day).sort();
  console.log(
    `${orders.size} orders → ${docs.size} stats docs (${days[0] ?? "-"} … ${days.at(-1) ?? "-"}); ` +
      `${old.length} existing docs replaced.`,
  );
  if (!write) {
    console.log("Dry run. Add --write to save.");
    return;
  }
  const keep = new Set([...docs.keys()].map((p) => `${STATS}/${p}`));
  const ops: ((b: FirebaseFirestore.WriteBatch) => void)[] = [
    ...old.filter((r) => !keep.has(r.path)).map((r) => (b: FirebaseFirestore.WriteBatch) => b.delete(r)),
    ...[...docs.values()].map((d) => (b: FirebaseFirestore.WriteBatch) =>
      b.set(db.doc(`${STATS}/${d.path}`), {
        ...d.counts,
        date: d.day,
        ...(d.areaId ? { areaId: d.areaId } : {}),
        ...(Object.keys(d.labels).length ? { names: d.labels } : {}),
        updatedAt: FieldValue.serverTimestamp(),
      }),
    ),
  ];
  for (let n = 0; n < ops.length; n += 400) {
    const batch = db.batch();
    for (const op of ops.slice(n, n + 400)) op(batch);
    await batch.commit();
  }
  console.log(`Wrote ${docs.size} docs.`);
})();
