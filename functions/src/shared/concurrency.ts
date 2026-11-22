/**
 * Runs `fn` over `items` with at most `limit` running at once. Every item
 * is attempted: a failure doesn't stop the others. Returns the errors (by
 * item index), so the caller decides how to log or count them.
 */
export async function forEachLimit<T>(
  items: readonly T[],
  limit: number,
  fn: (item: T, index: number) => Promise<void>,
): Promise<{ index: number; error: unknown }[]> {
  const errors: { index: number; error: unknown }[] = [];
  let next = 0;
  const worker = async () => {
    while (next < items.length) {
      const i = next++;
      try {
        await fn(items[i], i);
      } catch (error) {
        errors.push({ index: i, error });
      }
    }
  };
  await Promise.all(Array.from({ length: Math.max(1, Math.min(limit, items.length)) }, worker));
  return errors;
}
