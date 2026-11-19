/**
 * One-off: writes riders/{uid}/trips/{orderId} (src/dispatch/trips.ts) for
 * every order that has a rider, so the rider app's History keeps orders
 * from before the trips projection. Safe to re-run (same doc ids).
 * Run it before deploying the firestore.rules change that limits riders'
 * order reads. Dry run unless --write.
 *
 *   npm --prefix functions run backfill-rider-trips -- --project zippy-app-2024
 *   npm --prefix functions run backfill-rider-trips -- --project zippy-app-2024 --write
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { TRIPS, tripOf } from "../src/dispatch/trips";

const args = process.argv.slice(2);
const i = args.indexOf("--project");
const projectId = i > -1 ? args[i + 1] : process.env.GCLOUD_PROJECT;
const write = args.includes("--write");

initializeApp(projectId ? { projectId } : undefined);
const db = getFirestore();

(async () => {
  const orders = await db.collection("orders").where("riderId", "!=", null).get();
  console.log(`${orders.size} orders with a rider`);
  if (!write) {
    console.log("Dry run: add --write to save.");
    return;
  }
  let batch = db.batch();
  let n = 0;
  for (const o of orders.docs) {
    const riderId = o.get("riderId") as string;
    batch.set(db.collection("riders").doc(riderId).collection(TRIPS).doc(o.id), tripOf(o.data()));
    if (++n % 400 === 0) {
      await batch.commit();
      batch = db.batch();
    }
  }
  await batch.commit();
  console.log(`Wrote ${n} trips`);
})();
