/**
 * One-off: shrinks catalogue images already in Storage (banners/, catalog/,
 * notifications/) that were uploaded before the admin started compressing,
 * so Home banners and product photos download faster. Each file is
 * re-encoded as WebP (at most 1200 px for banners, 1000 px otherwise) in
 * place: same path and download token, so every saved URL keeps working.
 * The original is copied to _originals/<path> first. Small WebP files only
 * get the year-long cache header. Also lists banner/product/category images
 * hosted on other sites, which only re-uploading in the admin can fix.
 * Dry run unless --write.
 *
 *   npm --prefix functions run optimize-images -- --project zippy-app-2024
 *   npm --prefix functions run optimize-images -- --project zippy-app-2024 --write
 *   (optional: --bucket <name>; default <project>.firebasestorage.app,
 *    then <project>.appspot.com)
 */
import { initializeApp } from "firebase-admin/app";
import { getFirestore } from "firebase-admin/firestore";
import { getStorage } from "firebase-admin/storage";
import sharp from "sharp";
import { CACHE_CONTROL, isExternalImage, planFor, worthReplacing } from "./image-plan";

const args = process.argv.slice(2);
const arg = (name: string) => {
  const i = args.indexOf(name);
  return i > -1 ? args[i + 1] : undefined;
};
const projectId = arg("--project") ?? process.env.GCLOUD_PROJECT;
const write = args.includes("--write");
if (!projectId) throw new Error("Pass --project <id>");

initializeApp({ projectId });

const kb = (n: number) => `${Math.round(n / 1024)} KB`;

async function pickBucket() {
  const names = arg("--bucket")
    ? [arg("--bucket")!]
    : [`${projectId}.firebasestorage.app`, `${projectId}.appspot.com`];
  for (const name of names) {
    const bucket = getStorage().bucket(name);
    const [exists] = await bucket.exists();
    if (exists) return bucket;
  }
  throw new Error(`No bucket found (tried ${names.join(", ")}). Pass --bucket.`);
}

async function externalImages() {
  const db = getFirestore();
  const found: string[] = [];
  const [sections, products, categories] = await Promise.all([
    db.collection("home_sections").get(),
    db.collection("products").get(),
    db.collection("categories").get(),
  ]);
  for (const s of sections.docs) {
    for (const item of (s.get("items") as { data?: { image_url?: unknown } }[] | undefined) ?? []) {
      if (isExternalImage(item.data?.image_url)) found.push(`home ${s.id}: ${item.data!.image_url}`);
    }
  }
  for (const [label, snap] of [["product", products], ["category", categories]] as const) {
    for (const d of snap.docs) {
      if (isExternalImage(d.get("imageUrl"))) found.push(`${label} ${d.id}: ${d.get("imageUrl")}`);
    }
  }
  return found;
}

(async () => {
  const bucket = await pickBucket();
  console.log(`Bucket ${bucket.name}${write ? "" : " (dry run)"}`);
  let before = 0;
  let after = 0;
  let changed = 0;
  let headers = 0;

  for (const prefix of ["banners/", "catalog/", "notifications/"]) {
    const [files] = await bucket.getFiles({ prefix });
    for (const file of files) {
      const meta = file.metadata;
      const plan = planFor({
        name: file.name,
        contentType: meta.contentType,
        size: Number(meta.size ?? 0),
        cacheControl: meta.cacheControl,
      });
      if (plan.action === "skip") continue;
      if (plan.action === "cache-header") {
        headers++;
        if (write) await file.setMetadata({ cacheControl: CACHE_CONTROL });
        continue;
      }

      const [original] = await file.download();
      const out = await sharp(original)
        .rotate() // respect EXIF orientation before it's stripped
        .resize({ width: plan.maxSide, height: plan.maxSide, fit: "inside", withoutEnlargement: true })
        .webp({ quality: 80 })
        .toBuffer();
      if (!worthReplacing(original.length, out.length)) {
        if (!meta.cacheControl) {
          headers++;
          if (write) await file.setMetadata({ cacheControl: CACHE_CONTROL });
        }
        continue;
      }
      console.log(`${file.name}: ${kb(original.length)} → ${kb(out.length)}`);
      before += original.length;
      after += out.length;
      changed++;
      if (!write) continue;

      const backup = bucket.file(`_originals/${file.name}`);
      const [hasBackup] = await backup.exists();
      if (!hasBackup) await file.copy(backup);
      await file.save(out, {
        resumable: false,
        metadata: {
          contentType: "image/webp",
          cacheControl: CACHE_CONTROL,
          // Keeps firebaseStorageDownloadTokens, so existing URLs still work.
          metadata: meta.metadata,
        },
      });
    }
  }

  console.log(
    `\n${changed} images ${write ? "re-encoded" : "to re-encode"}: ${kb(before)} → ${kb(after)}; ` +
      `${headers} ${write ? "got" : "need"} the cache header.`,
  );
  const external = await externalImages();
  if (external.length) {
    console.log(`\n${external.length} images are hosted on other sites; re-upload them in the admin:`);
    for (const line of external) console.log(`  ${line}`);
  }
  if (!write) console.log("\nDry run. Add --write to save.");
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
