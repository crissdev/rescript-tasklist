import { defineConfig } from "vitest/config";
import react from "@vitejs/plugin-react";
import tailwindcss from "@tailwindcss/vite";
import { playwright } from "@vitest/browser-playwright";

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [
    tailwindcss(),
    react({
      include: ["**/*.res.mjs"],
    }),
  ],
  server: {
    watch: {
      // We ignore ReScript build artifacts to avoid unnecessarily triggering HMR on incremental compilation
      ignored: ["**/lib/bs/**", "**/lib/ocaml/**", "**/lib/rescript.lock"],
    },
  },
  // https://vitest.dev/config/
  test: {
    // Tests are written in ReScript; Vitest runs the compiled output.
    include: ["tests/**/*_test.res.mjs"],
    browser: {
      enabled: true,
      provider: playwright(),
      // Run headless unless overridden with `--browser.headless=false`.
      headless: true,
      instances: [{ browser: "chromium" }],
    },
    coverage: {
      // V8 coverage in browser mode requires a Chromium-based browser.
      provider: "v8",
      // ReScript does not emit source maps, so coverage is reported on the compiled `.res.mjs` files.
      include: ["src/**/*.res.mjs"],
      // Application entry point that only mounts <App /> into the page.
      exclude: ["src/Main.res.mjs"],
    },
  },
});
