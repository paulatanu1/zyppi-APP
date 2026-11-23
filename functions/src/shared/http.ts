/**
 * Outbound HTTP with a time limit. Without one, a hung PayU / Places /
 * Identity Toolkit call holds a function instance for its whole timeout
 * (60–300 s). A timeout rejects like a network error (a DOMException named
 * "TimeoutError"), so each caller's existing failure path handles it.
 */
export const OUTBOUND_TIMEOUT_MS = 8_000;

export function fetchWithTimeout(
  url: string | URL,
  init: RequestInit = {},
  timeoutMs: number = OUTBOUND_TIMEOUT_MS,
): Promise<Response> {
  return fetch(url, { ...init, signal: AbortSignal.timeout(timeoutMs) });
}
