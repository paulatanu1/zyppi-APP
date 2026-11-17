import type { DocumentSnapshot } from "firebase-admin/firestore";
import { type CallableRequest, HttpsError } from "firebase-functions/https";
import { requireUid } from "../shared/callable";
import { db } from "../shared/firebase";
import { RIDERS } from "../riders/model";

/** The caller as an approved rider (suspended / pending riders can't work). */
export async function requireRider(request: CallableRequest): Promise<DocumentSnapshot> {
  const uid = requireUid(request);
  const rider = await db.collection(RIDERS).doc(uid).get();
  if (!rider.exists) throw new HttpsError("permission-denied", "NOT_A_RIDER");
  if (rider.get("status") !== "approved") throw new HttpsError("permission-denied", "RIDER_NOT_APPROVED");
  return rider;
}
