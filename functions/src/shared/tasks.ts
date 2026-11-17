import { getFunctions } from "firebase-admin/functions";
import { logger } from "firebase-functions";
import { REGION } from "./firebase";

/**
 * Cloud Tasks for one-off timers (a campaign's send time, a seller's
 * accept deadline, a discount starting or ending) instead of polling.
 *
 * Delivery is at least once: every handler re-reads Firestore and does
 * nothing unless the work is still due. Recurring jobs (settlement,
 * subscriptions, payouts) stay on Cloud Scheduler.
 */

/** Cloud Tasks refuses schedule times further ahead than this. */
export const MAX_TASK_AHEAD_MS = 30 * 86_400_000 - 3_600_000;

export interface TaskQueueClient {
  enqueue(name: string, data: Record<string, unknown>, opts: { id: string; scheduleTime?: Date }): Promise<void>;
  delete(name: string, id: string): Promise<void>;
}

/** Task ids: letters, digits, `-` and `_`, at most 500 characters. */
export function taskId(...parts: (string | number)[]): string {
  return parts
    .map((p) => String(p).replace(/[^A-Za-z0-9_-]/g, "-"))
    .join("-")
    .slice(0, 500);
}

const code = (e: unknown) => String((e as { code?: string })?.code ?? "");

export const firebaseTasks: TaskQueueClient = {
  async enqueue(name, data, opts) {
    try {
      await getFunctions()
        .taskQueue(`locations/${REGION}/functions/${name}`)
        .enqueue(data, { id: opts.id, ...(opts.scheduleTime ? { scheduleTime: opts.scheduleTime } : {}) });
    } catch (e) {
      // Same id already queued (a retried trigger): the first one stands.
      if (code(e).includes("task-already-exists")) return;
      throw e;
    }
  },
  async delete(name, id) {
    try {
      await getFunctions().taskQueue(`locations/${REGION}/functions/${name}`).delete(id);
    } catch (e) {
      if (code(e).includes("not-found")) return;
      throw e;
    }
  },
};

/**
 * Queues a task but never fails the caller: the polling safety net picks
 * up anything that couldn't be queued.
 */
export async function enqueueSafely(
  name: string,
  data: Record<string, unknown>,
  opts: { id: string; scheduleTime?: Date },
  client: TaskQueueClient = firebaseTasks,
): Promise<boolean> {
  try {
    await client.enqueue(name, data, opts);
    return true;
  } catch (error) {
    logger.warn("Task not queued; the safety net will pick it up", { name, id: opts.id, error });
    return false;
  }
}

/** When to run a task due at [atMs]: now for the past, never past the Cloud Tasks limit. */
export function scheduleFor(atMs: number, nowMs = Date.now()): Date | null {
  if (atMs - nowMs > MAX_TASK_AHEAD_MS) return null;
  return new Date(Math.max(atMs, nowMs));
}
