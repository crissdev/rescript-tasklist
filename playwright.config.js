import { defineConfig, devices } from "@playwright/test";

const port = 4173;
const isCI = !!process.env.CI;

// https://playwright.dev/docs/test-configuration
export default defineConfig({
  testDir: "e2e",
  // Specs are written in ReScript; Playwright runs the compiled output.
  testMatch: "**/*_spec.res.mjs",
  forbidOnly: isCI,
  retries: isCI ? 2 : 0,
  reporter: isCI ? [["github"], ["html", { open: "never" }]] : "list",
  use: {
    baseURL: `http://localhost:${port}`,
    trace: "on-first-retry",
  },
  projects: [{ name: "chromium", use: { ...devices["Desktop Chrome"] } }],
  // Serves the production build, so run `bun run build` first (`bun run test:e2e` does).
  webServer: {
    command: `bun run preview --port ${port} --strictPort`,
    url: `http://localhost:${port}`,
    reuseExistingServer: !isCI,
  },
});
