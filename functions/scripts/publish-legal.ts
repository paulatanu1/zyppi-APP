/**
 * Publishes docs/legal/*.md as the next version of each legal document
 * (functions/src/legal). Translations sit next to the English file as
 * <name>.bn.md / .hi.md / .pa.md. Unchanged documents are skipped, and
 * nothing is published while a [PLACEHOLDER] is left. Dry run unless
 * --write; --reaccept <type> (repeatable) makes everyone accept it again.
 *
 *   npm --prefix functions run publish-legal -- --project zippy-app-2024
 *   npm --prefix functions run publish-legal -- --project zippy-app-2024 --write
 */
import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { initializeApp } from "firebase-admin/app";
import { LANGS, type Lang, findPlaceholders, parseLegalMarkdown, publishProblems } from "../src/legal/model";

const args = process.argv.slice(2);
const i = args.indexOf("--project");
const projectId = i > -1 ? args[i + 1] : process.env.GCLOUD_PROJECT;
const write = args.includes("--write");
const reaccept = new Set(args.flatMap((a, n) => (a === "--reaccept" ? [args[n + 1]] : [])));
const dir = join(__dirname, "..", "..", "docs", "legal");

initializeApp(projectId ? { projectId } : undefined);

(async () => {
  // After initializeApp: shared/firebase reuses this app.
  const { publishLegalDoc } = await import("../src/legal/legal.js");
  const files = readdirSync(dir).filter((f) => /^[a-z-]+\.md$/.test(f) && f !== "readme.md" && f !== "README.md");
  let blocked = false;
  for (const file of files) {
    const en = parseLegalMarkdown(readFileSync(join(dir, file), "utf8"));
    if (!en) {
      console.warn(`${file}: no front matter, skipped`);
      continue;
    }
    const body: Partial<Record<Lang, string>> = { en: en.body };
    for (const l of LANGS.filter((x) => x !== "en")) {
      try {
        body[l] = parseLegalMarkdown(readFileSync(join(dir, file.replace(/\.md$/, `.${l}.md`)), "utf8"))?.body;
      } catch {
        // No translation yet.
      }
    }
    const { input, problems } = publishProblems({ type: en.type, title: en.title, body, requiresReaccept: reaccept.has(en.type) });
    const placeholders = findPlaceholders(Object.values(body).join("\n"));
    if (!input || placeholders.length) {
      blocked = true;
      console.error(`${file}: ${[...problems, ...placeholders.map((p) => `fill ${p}`)].join("; ")}`);
      continue;
    }
    const langs = Object.keys(input.body).join(", ");
    if (!write) {
      console.log(`${file}: ready (${input.type}; ${langs}${input.requiresReaccept ? "; everyone re-accepts" : ""})`);
      continue;
    }
    const r = await publishLegalDoc(null, input);
    console.log(`${file}: ${r.unchanged ? "unchanged" : `published v${r.version}`} (${langs})`);
  }
  if (blocked) process.exitCode = 1;
})().catch((e) => {
  console.error(e);
  process.exit(1);
});
