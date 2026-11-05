import { tmpdir } from "node:os";
import { join } from "node:path";

/**
 * Free, open multilingual sentence-embedding model (MIT licence), run
 * in-process with transformers.js / ONNX Runtime — no external API, no
 * key, no per-call cost. 384-dim vectors; understands en, bn, hi, pa.
 */
export const EMBEDDING_MODEL = "Xenova/multilingual-e5-small";

export type Embedder = (texts: string[], kind: "query" | "passage") => Promise<Float32Array[]>;

type Extractor = (
  texts: string[],
  options: { pooling: "mean"; normalize: boolean },
) => Promise<{ tolist(): number[][] }>;

let extractor: Promise<Extractor> | null = null;

/**
 * Loads the model once per Function instance. The first load downloads
 * the quantized weights (~120 MB) from the Hugging Face hub into the
 * instance's temp dir; `SUPPORT_MODEL_CACHE` points it at a bundled copy
 * instead. Imported lazily so the other Functions in this codebase don't
 * pay for ONNX Runtime at cold start.
 */
function load(): Promise<Extractor> {
  extractor ??= (async () => {
    const { pipeline, env } = await import("@huggingface/transformers");
    env.cacheDir = process.env.SUPPORT_MODEL_CACHE ?? join(tmpdir(), "hf-models");
    return (await pipeline("feature-extraction", EMBEDDING_MODEL, {
      dtype: "q8",
    })) as unknown as Extractor;
  })().catch((error) => {
    extractor = null; // retry on the next message
    throw error;
  });
  return extractor;
}

/** e5 models expect "query: " / "passage: " prefixes. Vectors are unit length. */
export const embed: Embedder = async (texts, kind) => {
  if (texts.length === 0) return [];
  const extract = await load();
  const output = await extract(
    texts.map((t) => `${kind}: ${t}`),
    { pooling: "mean", normalize: true },
  );
  return output.tolist().map((v) => Float32Array.from(v));
};

/** Firestore can't store nested arrays: vectors are kept as base64 Float32. */
export function encodeVector(v: Float32Array): string {
  return Buffer.from(v.buffer, v.byteOffset, v.byteLength).toString("base64");
}

export function decodeVector(s: string): Float32Array {
  const bytes = Buffer.from(s, "base64");
  const copy = new Uint8Array(bytes); // aligned copy
  return new Float32Array(copy.buffer, 0, copy.byteLength / 4);
}

/** Dot product = cosine similarity for unit vectors. */
export function cosine(a: Float32Array, b: Float32Array): number {
  let sum = 0;
  for (let i = 0; i < a.length; i++) sum += a[i] * b[i];
  return sum;
}
