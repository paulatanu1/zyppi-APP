import { getApps, initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";
import { getFirestore } from "firebase-admin/firestore";
import { getMessaging } from "firebase-admin/messaging";

if (getApps().length === 0) initializeApp();

export const db = getFirestore();
export const auth = getAuth();
export const messaging = getMessaging();

/** Mumbai: closest region to the launch towns (West Bengal). */
export const REGION = "asia-south1";
