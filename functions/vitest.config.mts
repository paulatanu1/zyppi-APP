import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    // One shared emulator: run files one after another.
    fileParallelism: false,
    env: { GCLOUD_PROJECT: "demo-zyppi" },
    testTimeout: 20000,
  },
});
