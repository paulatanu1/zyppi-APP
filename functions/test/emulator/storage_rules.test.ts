import { readFileSync } from "node:fs";
import { join } from "node:path";
import { RulesTestEnvironment, assertFails, assertSucceeds, initializeTestEnvironment } from "@firebase/rules-unit-testing";
import { ref, uploadBytes } from "firebase/storage";
import { afterAll, beforeAll, describe, it } from "vitest";

// Needs the Storage emulator, which `npm test` doesn't start. Run with:
//   firebase emulators:exec --only storage --project demo-zyppi \
//     "npx vitest run test/emulator/storage_rules.test.ts"
const host = process.env.FIREBASE_STORAGE_EMULATOR_HOST;

describe.skipIf(!host)("storage.rules KYC folders", () => {
  let env: RulesTestEnvironment;
  const jpg = new Uint8Array([0xff, 0xd8, 0xff]);
  const meta = { contentType: "image/jpeg" };
  const user = (uid: string, provider = "password") =>
    env.authenticatedContext(uid, { firebase: { sign_in_provider: provider } }).storage();

  beforeAll(async () => {
    const [h, port] = host!.split(":");
    env = await initializeTestEnvironment({
      projectId: "demo-zyppi-storage",
      storage: { rules: readFileSync(join(__dirname, "..", "..", "..", "storage.rules"), "utf8"), host: h, port: Number(port) },
    });
  });
  afterAll(() => env?.cleanup());

  it("takes the seller app's KYC files, named as it names them", async () => {
    const s = user("shop1");
    await assertSucceeds(uploadBytes(ref(s, "sellers/shop1/kyc/selfie-1732262400000.jpg"), jpg, meta));
    await assertSucceeds(uploadBytes(ref(s, "sellers/shop1/kyc/shopPhoto3-1732262400000.jpg"), jpg, meta));
    await assertSucceeds(uploadBytes(ref(s, "sellers/shop1/kyc/signature-1732262400000.png"), jpg, { contentType: "image/png" }));
  });

  it("refuses other names and guest sessions", async () => {
    const s = user("shop1");
    await assertFails(uploadBytes(ref(s, "sellers/shop1/kyc/movie-1.jpg"), jpg, meta));
    await assertFails(uploadBytes(ref(s, "sellers/shop1/kyc/selfie.jpg"), jpg, meta));
    await assertFails(uploadBytes(ref(s, "sellers/shop1/kyc/shopPhoto9-1.jpg"), jpg, meta));
    await assertFails(uploadBytes(ref(user("shop1", "anonymous"), "sellers/shop1/kyc/selfie-1.jpg"), jpg, meta));
    await assertFails(uploadBytes(ref(user("guest", "anonymous"), "riders/guest/kyc/selfie.jpg"), jpg, meta));
    await assertSucceeds(uploadBytes(ref(user("ravi"), "riders/ravi/kyc/selfie.jpg"), jpg, meta));
  });
});
