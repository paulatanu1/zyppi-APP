/**
 * Runs the support bot's retrieval with the real embedding model over
 * sample questions (paraphrases the seed doesn't contain, all four
 * languages, off-topic text) and prints what it would do. Use it to tune
 * THRESHOLDS in src/support/kb/retrieve.ts after editing the seed.
 *
 *   npm --prefix functions run smoke:support
 *
 * Downloads the model (~120 MB) on the first run. No Firestore needed.
 */
import { LANGS } from "../src/support/lang";
import { embed } from "../src/support/kb/embed";
import { IndexedEntry, Retriever } from "../src/support/kb/retrieve";
import { KB_SEED } from "../src/support/kb/seed";

/** [question, expected entry id | "suggest" | "unknown"] */
const CASES: [string, string][] = [
  ["where's my stuff", "where_is_order"],
  ["how much longer for my delivery", "where_is_order"],
  ["my groceries still haven't come, it's been an hour", "late_order"],
  ["my order never came", "late_order"],
  ["do you deliver in raghunathpur", "delivery_areas"],
  ["is there a delivery charge", "delivery_fee"],
  ["can I pay with cash", "payment_methods"],
  ["COD available?", "payment_methods"],
  ["money got debited twice", "payment_failed"],
  ["I need my money back", "refund"],
  ["please cancel it", "cancel_order"],
  ["the milk packet was torn", "missing_item"],
  ["you sent me the wrong brand", "missing_item"],
  ["discount code not applying", "coupons"],
  ["I put the wrong house number", "change_address"],
  ["verification sms not received", "otp_login"],
  ["can I speak to someone", "talk_to_person"],
  ["hello", "greeting"],
  ["thanks a lot", "thanks"],
  ["টাকা ফেরত কবে পাব?", "refund"],
  ["আমার জিনিস কখন আসবে", "where_is_order"],
  ["ভুল জিনিস পাঠিয়েছেন", "missing_item"],
  ["मेरा सामान कब तक आएगा", "where_is_order"],
  ["कैश में पेमेंट कर सकता हूँ?", "payment_methods"],
  ["ऑर्डर रद्द करना है", "cancel_order"],
  ["ਮੇਰਾ ਆਰਡਰ ਕਦੋਂ ਪਹੁੰਚੇਗਾ", "where_is_order"],
  ["ਪੈਸੇ ਵਾਪਸ ਚਾਹੀਦੇ ਹਨ", "refund"],
  ["what's the weather today", "unknown"],
  ["asdkjh qwe", "unknown"],
  ["do you sell iphones", "unknown"],
];

async function main() {
  const t0 = Date.now();
  const indexed: IndexedEntry[] = [];
  for (const entry of KB_SEED) {
    const questions = LANGS.flatMap((l) => entry.questions[l]);
    indexed.push({ entry, vectors: await embed(questions, "passage") });
  }
  console.log(`Indexed ${indexed.length} entries in ${Date.now() - t0} ms\n`);
  const retriever = new Retriever(indexed);

  let ok = 0;
  for (const [question, expected] of CASES) {
    const [vector] = await embed([question], "query");
    const decision = retriever.decide(question, vector);
    const top = retriever.search(question, vector).slice(0, 2);
    const got =
      decision.kind === "answer"
        ? decision.entry.id
        : decision.kind === "suggest"
          ? `suggest(${decision.entries.map((e) => e.id).join(",")})`
          : "unknown";
    const pass =
      got === expected ||
      (expected === "unknown" && got === "unknown") ||
      // A suggestion that includes the right entry is acceptable.
      (decision.kind === "suggest" && decision.entries.some((e) => e.id === expected));
    if (pass) ok++;
    const detail = top
      .map((r) => `${indexed[r.index].entry.id}:${r.cosine.toFixed(3)}/${r.bm25.toFixed(1)}`)
      .join("  ");
    console.log(`${pass ? "✓" : "✗"} ${question}\n    → ${got}   [${detail}]`);
  }
  console.log(`\n${ok}/${CASES.length} as expected`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
