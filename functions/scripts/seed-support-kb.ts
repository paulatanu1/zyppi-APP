/**
 * Indexes the support bot's knowledge base (src/support/kb/seed.ts) into
 * Firestore `supportKb`: embeds every example question with the free
 * multilingual model and stores the vectors. Re-run after editing the seed.
 *
 *   # Emulators (`firebase emulators:start` running):
 *   FIRESTORE_EMULATOR_HOST=127.0.0.1:8080 npm --prefix functions run seed:support
 *
 *   # Real project (gcloud application-default credentials):
 *   npm --prefix functions run seed:support -- --project zippy-app-2024
 *
 * Downloads the model (~120 MB) on the first run.
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { embed } from "../src/support/kb/embed";
import { KB_SEED } from "../src/support/kb/seed";
import { ingest } from "../src/support/kb/store";

const projectArg = process.argv.indexOf("--project");
const projectId =
  projectArg > -1 ? process.argv[projectArg + 1] : (process.env.GCLOUD_PROJECT ?? "demo-zyppi");

initializeApp({ projectId });

ingest(getFirestore(), KB_SEED, embed)
  .then((count) => console.log(`Indexed ${count} support entries into ${projectId}/supportKb`))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
