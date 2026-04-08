# Embedded E2E (Flutter) — current state and webview-login blocker

## What runs today

| Platform | Tests | Why |
|---|---|---|
| iOS | `testColdLaunch*`, `testRequestAuthorizeFlow` | No webview required — they hit the mock server via the SDK's HTTP client only. `testRequestAuthorizeFlow` proves that `manualInit(baseUrl: <mock>)` correctly switches the SDK to the mock server. |
| Android | `testColdLaunch*` | Same — no webview required. Android SDK has no mock-server testing support at all (see below). |

Everything else is excluded in `.github/workflows/demo-e2e.yml`. The exclusion list
is long but the reason is the same single architectural blocker.

## The blocker: webview login against a localhost mock server

`FronteggSwift`'s `CustomWebView` (and the equivalent Android WebView client)
**unconditionally blocks navigation to `localhost` / `127.0.0.1`** as a security
measure. The OAuth callback URL (`com.frontegg.demo://127.0.0.1/ios/oauth/callback`)
is rejected by `decidePolicyFor` before the custom-scheme handler can process it,
which kills every embedded login flow against a localhost mock server.

In **frontegg-ios-swift master** (PR #243, commit `f6ffe22`) the SDK adds
`FronteggRuntime.isTesting` plus an `isAllowedTestingLoopbackURL` whitelist:
when `ProcessInfo.processInfo.environment["frontegg-testing"] == "true"`, the
WebView allows localhost URLs whose host matches the configured `baseUrl`.

This pin (`frontegg-ios-swift @ f6ffe22`) is what `ios/frontegg_flutter/Package.swift`
pulls today. The SDK code that whitelists localhost is **already present in the build**.

## Why we still can't enable webview tests

`FronteggRuntime.isTesting` reads from `ProcessInfo.processInfo.environment`,
which on iOS is **a snapshot of the environment at process creation time**.
Calling `setenv("frontegg-testing", "true", 1)` from `AppDelegate.didFinishLaunchingWithOptions`
modifies the C runtime environment but is NOT visible to `ProcessInfo`. The SDK
sees `isTesting == false` and the localhost block stays active.

The Swift demo-embedded-e2e target works around this by setting
`XCUIApplication.launchEnvironment` from `XCTestCase.setUp` **before** calling
`app.launch()`. The XCUITest harness then forks the app process with those env
vars merged into its `ProcessInfo`. **This is how every Frontegg testing env var
reaches the SDK** — there is no IPC, no plist file, no other channel.

Patrol (the Flutter integration-test framework we use) also goes through XCUITest,
**but it provides no public hook to set `XCUIApplication.launchEnvironment` on the
app it launches.** The Patrol runner picks the device, builds an `xctestrun` bundle,
launches the app from `IOSAutomator.swift`, and exposes none of those steps to the
Dart test code or to user-supplied Swift hooks. Attempting to inject env vars via:

- `setenv(...)` from `AppDelegate.didFinishLaunchingWithOptions` — **too late**
  (`ProcessInfo` already snapshotted)
- `setenv(...)` from an Objective-C `+load` method — earlier than Swift, but the
  pbxproj edits to add a new Obj-C source file to the Runner target broke the
  Patrol test launch (10-minute "Test runner never began executing tests")
- Modifying `Frontegg.plist` — the SDK reads env vars, not the plist, for testing flags
- `--dart-define` — passes Dart compile defines, not iOS process env

…all fail or break Patrol. The `LocalMockAuthServer.dart` mock server itself
works fine — `testRequestAuthorizeFlow` passes against it on every run, proving
the SDK's HTTP client is using the mock URL after `manualInit`. The only thing
that fails is the **WebView navigation policy**, which the SDK only relaxes for
the `frontegg-testing=true` env var that we cannot inject.

## Paths forward (none implemented yet)

1. **Drop Patrol, write native XCUITest in `RunnerUITests`.** Mirror
   `frontegg-ios-swift/demo-embedded/demo-embedded-e2e` exactly. Pros: known to
   work, full parity with the Swift reference. Cons: rewrites every test in
   Swift, loses the Dart `LocalMockAuthServer` reuse, needs a separate test
   process that can drive the Flutter UI semantically (XCUITest works against
   accessibility identifiers, which we already emit, so this is doable).

2. **Patch Patrol to expose `launchEnvironment`.** Send a PR upstream adding a
   way to set env vars from Dart that the iOS automator passes to
   `XCUIApplication.launchEnvironment` before launch. Pros: keeps the Dart test
   code and mock server. Cons: depends on upstream review/release.

3. **Patch FronteggSwift to read the testing flag from a different source.**
   E.g. read it from `Frontegg.plist` or from a UserDefaults key set by the
   Dart side via method channel before any FronteggApp code runs. Pros: no
   Patrol changes. Cons: requires upstream SDK PR that's specifically for
   the Flutter use case.

4. **Add an Android equivalent first.** The Android SDK has zero E2E testing
   infrastructure (no mock server, no isTesting flag, no localhost override,
   no manualInit). Whatever pattern we land on for iOS, the Android side needs
   the same upstream work — there is no Android workaround that doesn't touch
   the Frontegg Android SDK.

## What this directory contains today

- `local_mock_auth_server.dart` — Dart `HttpServer` mock with the same routes
  as `LocalMockAuthServer.swift`. Works correctly — verified by
  `testRequestAuthorizeFlow` passing.
- `embedded_e2e_test_case.dart` — test harness mirroring
  `DemoEmbeddedUITestCase.swift` (waitForScreen helpers, login helpers, etc.).
- `embedded_e2e_test.dart` — test definitions; the webview-dependent ones are
  excluded in CI via `INPUT_EXCLUDE_METHODS` in the workflow.

The full test set is kept compiling so that whoever picks up paths (1)–(4)
above doesn't have to rewrite the test bodies.
