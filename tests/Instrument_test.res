open Vitest

module SentryTest = {
  type client
  type options = {mutable enabled: bool}
  type log = {level: string, message: string}
  type assertion

  @module("vitest") @scope("vi")
  external stubEnv: (string, string) => unit = "stubEnv"

  @module("vitest") @scope("vi")
  external unstubAllEnvs: unit => unit = "unstubAllEnvs"

  @module("@sentry/react")
  external getClient: unit => client = "getClient"

  @send external getOptions: client => options = "getOptions"

  @send
  external onLog: (client, @as("afterCaptureLog") _, log => unit) => unit => unit = "on"

  @send external close: client => promise<bool> = "close"

  @module("vitest")
  external expectLogs: array<log> => assertion = "expect"

  @send external toMatchObject: (assertion, array<log>) => unit = "toMatchObject"
}

test("captures console output as Sentry logs", async () => {
  SentryTest.stubEnv("VITE_SENTRY_DSN", "https://public@example.invalid/1")
  Instrument.init()
  let client = SentryTest.getClient()
  let options = client->SentryTest.getOptions

  // Keep the real integration active, but prevent its transport from sending test data.
  options.enabled = false
  let logs = ref([])
  let unsubscribe = client->SentryTest.onLog(log => logs.contents = [...logs.contents, log])

  Console.log("test console message")
  Console.warn("test console warning")
  Console.error("test console error")

  unsubscribe()
  let _ = await client->SentryTest.close
  SentryTest.unstubAllEnvs()
  logs.contents
  ->SentryTest.expectLogs
  ->SentryTest.toMatchObject([
    {level: "info", message: "test console message"},
    {level: "warn", message: "test console warning"},
    {level: "error", message: "test console error"},
  ])
})
