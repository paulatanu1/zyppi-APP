import { randomUUID } from "node:crypto";
import { FieldValue, Timestamp } from "firebase-admin/firestore";
import { HttpsError, onCall } from "firebase-functions/https";
import { isHttpsUrl } from "../catalog/model";
import { writeAudit } from "../shared/audit";
import { db } from "../shared/firebase";
import { type Actor, requireRole } from "../shared/roles";

/**
 * The app's Home screen: `homeSections/{id}` = {type, title, subtitle,
 * config, displayOrder, isActive, items[]}. Each item is
 * {id, data (type-specific, snake_case keys the app reads), startAt?,
 * endAt?, serviceAreaIds?, isActive?}: the app hides an item outside its
 * window, outside its areas (empty = everywhere) or switched off.
 *
 * Banner clicks are counted in `bannerStats/{sectionId}__{itemId}` (not in
 * the section, so a click never races an edit).
 */
export const HOME_SECTIONS = "homeSections";
export const BANNER_STATS = "bannerStats";
export const BANNER = "banner_carousel";
export const MAX_BANNERS = 10;
export const LINK_TYPES = ["none", "category", "product", "url"] as const;

export interface BannerInput {
  id?: string | null;
  title: string;
  ctaText: string | null;
  linkType: (typeof LINK_TYPES)[number];
  linkTarget: string | null;
  imageUrl: string | null;
  startAtMs: number | null;
  endAtMs: number | null;
  serviceAreaIds: string[];
  isActive: boolean;
}

/** https, or the Storage emulator's http://127.0.0.1 URLs while emulated (seeded images). */
function isImageUrl(v: string): boolean {
  if (isHttpsUrl(v)) return true;
  if (process.env.FUNCTIONS_EMULATOR !== "true") return false;
  try {
    const u = new URL(v);
    return u.protocol === "http:" && ["127.0.0.1", "localhost", "10.0.2.2"].includes(u.hostname);
  } catch {
    return false;
  }
}

const bad = (message: string) => new HttpsError("invalid-argument", message);
const str = (v: unknown) => (typeof v === "string" ? v.trim() : "");
const ms = (v: unknown, field: string): number | null => {
  if (v === null || v === undefined || v === "") return null;
  if (typeof v !== "number" || !Number.isInteger(v) || v < 0) throw bad(`Invalid ${field}`);
  return v;
};

/** Shape checks only; references (category, product, area) are checked against Firestore after. */
export function validateBanner(raw: unknown, n: number): BannerInput {
  const r = (raw ?? {}) as Record<string, unknown>;
  const at = `Banner ${n}`;
  const title = str(r.title);
  if (title.length < 2 || title.length > 60) throw bad(`${at}: the headline must be 2–60 characters`);
  const ctaText = str(r.ctaText) || null;
  if (ctaText && ctaText.length > 24) throw bad(`${at}: the button text must be 24 characters or fewer`);
  const linkType = LINK_TYPES.find((t) => t === r.linkType);
  if (!linkType) throw bad(`${at}: choose where it opens`);
  const linkTarget = linkType === "none" ? null : str(r.linkTarget) || null;
  if (linkType !== "none" && !linkTarget) throw bad(`${at}: choose the ${linkType} it opens`);
  if (linkType === "url" && !isHttpsUrl(linkTarget)) throw bad(`${at}: the link must start with https://`);
  const imageUrl = str(r.imageUrl) || null;
  if (imageUrl && !isImageUrl(imageUrl)) throw bad(`${at}: the image must be an https:// URL`);
  const startAtMs = ms(r.startAtMs, `${at} start`);
  const endAtMs = ms(r.endAtMs, `${at} end`);
  if (startAtMs != null && endAtMs != null && endAtMs <= startAtMs) {
    throw bad(`${at}: the end must be after the start`);
  }
  const serviceAreaIds = Array.isArray(r.serviceAreaIds)
    ? [...new Set(r.serviceAreaIds.filter((s): s is string => typeof s === "string" && !!s))]
    : [];
  if (serviceAreaIds.length > 50) throw bad(`${at}: too many areas`);
  const id = str(r.id) || null;
  if (id && !/^[\w-]{1,64}$/.test(id)) throw bad(`${at}: invalid id`);
  return {
    id,
    title,
    ctaText,
    linkType,
    linkTarget,
    imageUrl,
    startAtMs,
    endAtMs,
    serviceAreaIds,
    isActive: r.isActive !== false,
  };
}

/** The stored item (data keys are the ones banner_carousel_section.dart reads). */
export function bannerItem(b: BannerInput) {
  return {
    id: b.id ?? randomUUID(),
    data: {
      title: b.title,
      cta_text: b.ctaText,
      link_type: b.linkType === "none" ? null : b.linkType,
      link_target: b.linkTarget,
      image_url: b.imageUrl,
    },
    startAt: b.startAtMs == null ? null : Timestamp.fromMillis(b.startAtMs),
    endAt: b.endAtMs == null ? null : Timestamp.fromMillis(b.endAtMs),
    serviceAreaIds: b.serviceAreaIds,
    isActive: b.isActive,
  };
}

async function checkReferences(banners: BannerInput[]): Promise<void> {
  const refs = new Map<string, { label: string; n: number }>();
  banners.forEach((b, i) => {
    if (b.linkType === "category") refs.set(`categories/${b.linkTarget}`, { label: "category", n: i + 1 });
    if (b.linkType === "product") refs.set(`products/${b.linkTarget}`, { label: "product", n: i + 1 });
    for (const a of b.serviceAreaIds) refs.set(`serviceAreas/${a}`, { label: "area", n: i + 1 });
  });
  if (!refs.size) return;
  const snaps = await db.getAll(...[...refs.keys()].map((p) => db.doc(p)));
  const missing = snaps.find((s) => !s.exists);
  if (missing) {
    const { label, n } = refs.get(missing.ref.path)!;
    throw bad(`Banner ${n}: that ${label} no longer exists`);
  }
}

/**
 * Creates a banner carousel (no `id`) or edits a section: `title`,
 * `isActive`, and, for banner carousels, the whole `banners` list in
 * display order. Other section types keep their items (they come from the
 * seed until their editors exist). Exported for the emulator tests.
 */
export async function saveHomeSection(actor: Actor, raw: Record<string, unknown>) {
  const id = str(raw.id) || null;
  const title = raw.title === undefined ? undefined : str(raw.title) || null;
  if (title && title.length > 60) throw bad("The section title must be 60 characters or fewer");
  const isActive = typeof raw.isActive === "boolean" ? raw.isActive : undefined;
  let banners: BannerInput[] | undefined;
  if (raw.banners !== undefined) {
    if (!Array.isArray(raw.banners)) throw bad("Invalid banners");
    if (raw.banners.length > MAX_BANNERS) throw bad(`At most ${MAX_BANNERS} banners per carousel`);
    banners = raw.banners.map((b, i) => validateBanner(b, i + 1));
    const ids = banners.map((b) => b.id).filter(Boolean);
    if (new Set(ids).size !== ids.length) throw bad("Two banners have the same id");
    await checkReferences(banners);
  }

  const col = db.collection(HOME_SECTIONS);
  return db.runTransaction(async (tx) => {
    const ref = id ? col.doc(id) : col.doc();
    const snap = await tx.get(ref);
    if (id && !snap.exists) throw new HttpsError("not-found", "Section not found");
    const before = snap.data();
    const type = (before?.type as string | undefined) ?? BANNER;
    if (banners && type !== BANNER) {
      throw new HttpsError("failed-precondition", "Only banner carousels can be edited here");
    }

    const doc: Record<string, unknown> = {
      updatedAt: FieldValue.serverTimestamp(),
      updatedBy: actor.uid,
    };
    if (title !== undefined) doc.title = title;
    if (isActive !== undefined) doc.isActive = isActive;
    if (banners) doc.items = banners.map(bannerItem);
    if (!before) {
      // New carousels go last; drag them into place.
      const last = await tx.get(col.orderBy("displayOrder", "desc").limit(1));
      Object.assign(doc, {
        type: BANNER,
        title: title ?? null,
        subtitle: null,
        config: { autoplay: true },
        displayOrder: ((last.docs[0]?.get("displayOrder") as number | undefined) ?? -1) + 1,
        isActive: isActive ?? false,
        items: doc.items ?? [],
        createdAt: FieldValue.serverTimestamp(),
      });
    }
    tx.set(ref, doc, { merge: true });
    writeAudit(
      actor,
      {
        action: before ? "home.update" : "home.create",
        target: ref.path,
        before: before ? sectionSummary(before) : null,
        after: sectionSummary({ ...before, ...doc }),
      },
      tx,
    );
    return { id: ref.id };
  });
}

const sectionSummary = (d: Record<string, unknown>) => ({
  type: d.type ?? null,
  title: d.title ?? null,
  isActive: d.isActive ?? null,
  items: Array.isArray(d.items)
    ? d.items.map((i: Record<string, unknown>) => ({
        id: i.id,
        title: (i.data as Record<string, unknown> | undefined)?.title ?? null,
        isActive: i.isActive ?? true,
      }))
    : null,
});

/** New top-to-bottom order of every section. */
export async function reorderHomeSections(actor: Actor, ids: unknown) {
  if (!Array.isArray(ids) || ids.length === 0 || ids.length > 100) throw bad("Invalid order");
  const all = await db.collection(HOME_SECTIONS).get();
  const same = ids.length === all.size && all.docs.every((d) => (ids as unknown[]).includes(d.id));
  if (!same) throw new HttpsError("failed-precondition", "The list changed. Reload and try again");
  const batch = db.batch();
  (ids as string[]).forEach((id, i) =>
    batch.update(db.collection(HOME_SECTIONS).doc(id), { displayOrder: i }),
  );
  await batch.commit();
  await writeAudit(actor, {
    action: "home.reorder",
    target: HOME_SECTIONS,
    before: null,
    after: { order: ids },
  });
  return { ok: true };
}

/** Banner carousels only: other sections can't be rebuilt from the panel yet, so they are hidden instead. */
export async function deleteHomeSection(actor: Actor, id: unknown) {
  if (typeof id !== "string" || !id) throw bad("Invalid id");
  const ref = db.collection(HOME_SECTIONS).doc(id);
  const snap = await ref.get();
  if (!snap.exists) throw new HttpsError("not-found", "Section not found");
  if (snap.get("type") !== BANNER) {
    throw new HttpsError("failed-precondition", "Only banner carousels can be deleted. Hide this one instead");
  }
  await ref.delete();
  await writeAudit(actor, {
    action: "home.delete",
    target: ref.path,
    before: sectionSummary(snap.data()!),
    after: null,
  });
  return { ok: true };
}

/** One tap on a banner in the app (any signed-in user, guests included). */
export async function recordBannerClick(sectionId: unknown, itemId: unknown) {
  if (typeof sectionId !== "string" || typeof itemId !== "string" || !sectionId || !itemId) {
    throw bad("Invalid banner");
  }
  const section = await db.collection(HOME_SECTIONS).doc(sectionId).get();
  const items = (section.get("items") as { id?: string }[] | undefined) ?? [];
  if (section.get("type") !== BANNER || !items.some((i) => i.id === itemId)) {
    throw new HttpsError("not-found", "Banner not found");
  }
  await db
    .collection(BANNER_STATS)
    .doc(`${sectionId}__${itemId}`)
    .set(
      { sectionId, itemId, clicks: FieldValue.increment(1), lastClickAt: FieldValue.serverTimestamp() },
      { merge: true },
    );
  return { ok: true };
}

export const adminSaveHomeSection = onCall(async (request) =>
  saveHomeSection(requireRole(request, ["catalog"]), (request.data ?? {}) as Record<string, unknown>),
);

export const adminReorderHomeSections = onCall(async (request) =>
  reorderHomeSections(requireRole(request, ["catalog"]), request.data?.ids),
);

export const adminDeleteHomeSection = onCall(async (request) =>
  deleteHomeSection(requireRole(request, ["catalog"]), request.data?.id),
);

export const trackBannerClick = onCall(async (request) => {
  if (!request.auth?.uid) throw new HttpsError("unauthenticated", "Not authenticated");
  return recordBannerClick(request.data?.sectionId, request.data?.itemId);
});
