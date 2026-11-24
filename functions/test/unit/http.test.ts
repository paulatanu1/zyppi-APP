import { createServer, type Server } from "node:http";
import type { AddressInfo } from "node:net";
import { afterAll, afterEach, beforeAll, describe, expect, it, vi } from "vitest";
import { HttpsError } from "firebase-functions/https";
import { OUTBOUND_TIMEOUT_MS, fetchWithTimeout } from "../../src/shared/http";
import { passwordMatches } from "../../src/marketplace/store_code_auth";

describe("fetchWithTimeout", () => {
  let server: Server;
  let url: string;
  beforeAll(async () => {
    // Never answers: a hung upstream.
    server = createServer(() => {});
    await new Promise<void>((r) => server.listen(0, "127.0.0.1", r));
    url = `http://127.0.0.1:${(server.address() as AddressInfo).port}/`;
  });
  afterAll(() => {
    server.closeAllConnections();
    server.close();
  });

  it("defaults to 8 s", () => {
    expect(OUTBOUND_TIMEOUT_MS).toBe(8_000);
  });

  it("rejects with a TimeoutError instead of hanging", async () => {
    const started = Date.now();
    await expect(fetchWithTimeout(url, {}, 100)).rejects.toMatchObject({ name: "TimeoutError" });
    expect(Date.now() - started).toBeLessThan(2_000);
  });

  it("keeps the caller's init", async () => {
    const spy = vi.spyOn(globalThis, "fetch").mockResolvedValue(new Response("{}"));
    await fetchWithTimeout("https://example.test", { method: "POST", body: "x" });
    const init = spy.mock.calls[0][1]!;
    expect(init.method).toBe("POST");
    expect(init.body).toBe("x");
    expect(init.signal).toBeInstanceOf(AbortSignal);
    spy.mockRestore();
  });
});

describe("Store ID password check when Identity Toolkit is unreachable", () => {
  afterEach(() => vi.restoreAllMocks());

  it("maps a timeout to unavailable / NO_NETWORK", async () => {
    vi.spyOn(globalThis, "fetch").mockRejectedValue(new DOMException("timed out", "TimeoutError"));
    const err = await passwordMatches("a@b.c", "secret1").catch((e) => e);
    expect(err).toBeInstanceOf(HttpsError);
    expect(err.code).toBe("unavailable");
    expect(err.message).toBe("NO_NETWORK");
  });

  it("still reads a wrong password as false", async () => {
    vi.spyOn(globalThis, "fetch").mockResolvedValue(
      new Response(JSON.stringify({ error: { message: "INVALID_LOGIN_CREDENTIALS" } }), { status: 400 }),
    );
    await expect(passwordMatches("a@b.c", "secret1")).resolves.toBe(false);
  });
});
