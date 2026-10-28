## v1.0.55
This PR now carries the whole stack that replaced frontegg/frontegg-flutter#157, plus two earlier PRs. It was reviewed in parts:

| Part | Reviewed in | Merged into this branch |
|---|---|---|
| Error mapping, scene-lifecycle test, example Gradle versions | this PR (with the former #160 and #161) | — |
| `getOrRefreshAccessToken` and FronteggSwift 1.3.26 | frontegg/frontegg-flutter#163 | yes |
| Multi-region | frontegg/frontegg-flutter#164 | yes, via #163 |
| README | frontegg/frontegg-flutter#165 | yes, via #164 |
| Bridge-contract tests | frontegg/frontegg-flutter#159 | yes, via #165 |
| Android SDK 1.3.43 | frontegg/frontegg-flutter#155 | yes; its FronteggSwift 1.3.24 pin is superseded by 1.3.26 |
| docsify 5.0.0 with pinned CDN versions | frontegg/frontegg-flutter#156 | yes, unchanged |

Jira: FR-25950 (API audit), FR-25952 (get-or-refresh helper), FR-25959 (multi-region), FR-25951 (bridge-contract tests).

## Summary

### Error mapping (FR-25950)
- **Android codes:** `switch_tenant_failed` and `refresh_failed` now map to `FailedToSwitchTenantException` and `FailedToRefreshTokenException` instead of `UnknownException`.
- **Unknown codes:** an unrecognised platform code still becomes `UnknownException`, but its `failureReason` now keeps the platform code (for example `MISSING_PARAMS`).
- **Cancelled login:** `CanceledByUserException.failureReason` is now `"canceledByUser"`. It used to be `"other"`, which mapped back to `OtherException`.
- **Invalid region:** `INVALID_REGION` maps to the new `InvalidRegionException`.

### getOrRefreshAccessToken (FR-25952)
`Future<String?> getOrRefreshAccessToken()` returns an access token that is valid for more than 15 s, refreshing it first when needed. Call it before API calls after the app resumes.

**When it returns `null`:**
- there is no session;
- the refresh token was rejected;
- the app is multi-region and no region is selected yet.

**When it waits:**
- If initialization or a refresh is still running, it waits up to 20 s, then throws `FailedToAuthenticateException`.
- On Android, if a background refresh is still settling, it waits up to 10 s for it.

**Offline:**
- With offline mode on, it returns the cached token, which may be expired.
- With offline mode off, it throws `FailedToAuthenticateException`.

**Implementation:**
- **iOS:** calls FronteggSwift's `getOrRefreshAccessTokenAsync()`. The plugin now pins FronteggSwift 1.3.26 (was 1.3.21). 1.3.26 includes frontegg/frontegg-ios-swift#347: the call now waits for an automatic refresh that is already running, instead of racing it with the same refresh token and signing the user out. 1.3.26 also carries 1.3.24's embedded step-up fixes from #155.
- **Android:** uses SDK 1.3.43 (was 1.3.41), which includes the step-up fixes from #155. It builds the same behaviour from the SDK's public APIs: `refreshTokenAndWait`, the network check and the offline-mode setting.
- **Errors:** on both platforms, every failure reaches Dart as `FailedToAuthenticateException`.

**Behaviour change from FronteggSwift 1.3.25:** token exchange, passkey and Apple sign-in failures can now arrive as `OtherException`.

### Multi-region (FR-25959)
- **New API:** `FronteggRegionConfig`, `FronteggConstants.regions` and `isRegional`, `FronteggState.selectedRegion`, and `initWithRegion(regionKey)`.
- **Unknown region key:** `initWithRegion` throws `InvalidRegionException` before calling the native SDK, which would otherwise crash on iOS.
- **Android:** overlapping `initWithRegion` calls now run one after the other.
- **Configuration:** regions are set natively, in the `regions` array in `Frontegg.plist` on iOS and through `FronteggApp.initWithRegions` on Android.
- **Switching while signed in:** `initWithRegion` does not clear the session, so apps must call `logout()` before switching regions. This is documented.
- **iOS MFA:** FronteggSwift 1.3.26 rebuilds its MFA client when a region is selected, so native Apple sign-in that requires MFA works in multi-region apps.
- **Hosted example:** has an opt-in multi-region mode with a region picker.
- **Docs:** see "Multi-region support" in `docs/advanced.md`.

### Bridge-contract tests (FR-25951)
`test/src/bridge_contract_test.dart` runs in the existing `flutter test` job. It checks that both native handlers:
- dispatch exactly the methods Dart calls;
- read exactly the argument keys Dart sends;
- return every key the Dart `fromMap` readers expect.

### Scene-lifecycle iOS test
- **Problem:** this check is also red on `master`. The host-app link test waited for Dart's router, which gets the link only after Flutter's background QoS queue delivers it. On CI simulators that took more than 60 s.
- **Fix:** a test-only scene delegate records the links the plugin passes on to Flutter, and the test asserts on that instead.

### Example apps and docs
- **Example apps:** `hosted` and `application_id` now use Gradle 8.14.3, AGP 8.11.1 and Kotlin 2.2.20, so `flutter build apk` passes Flutter's dependency check.
- **SDK versions:** all example apps and `docs/setup.md` use Android SDK 1.3.43.
- **README:** new "Why Frontegg for Flutter" section, and it lists FronteggSwift 1.3.26 and Android 1.3.43.
- **Docs site:** docsify 5.0.0 with exact CDN versions over https (#156). The 4.x search plugin wrote the `s` query parameter into the page without escaping it.

## Testing
- **Dart:** `flutter analyze lib test` is clean. `flutter test` passes 96/96, including the 12 bridge-contract tests.
- **Android:** after merging #155, the plugin compiles against SDK 1.3.43. Its unit tests pass 18/18, including the 11 `ResolveValidAccessTokenTest` cases.
- **iOS:** the scene-lifecycle `xcodebuild test` job passed against FronteggSwift 1.3.26 on #163 and #164.
- **Reviews:** nureview and Bugbot findings were fixed or resolved on each part.
- **Not verified:**
  - no device test, including #155's embedded step-up check against an MFA-enforced tenant;
  - the hosted example's US-region client ID differs between Android and iOS and needs a check in the Frontegg portal;
  - the example `Package.resolved` files pin only `frontegg-ios-swift`, so Xcode adds the GoogleSignIn-iOS pins on first resolve.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

https://claude.ai/code/session_01S2yW3aohcrkGZ96iyLpv3a

## v1.0.54
- Fixed: on iOS apps using the UIScene lifecycle (the `flutter create` default since Flutter 3.41), Frontegg links such as reset-password emails now reach the SDK instead of the app's router.

## v1.0.53
- Bump native SDKs to Android `1.3.41` / iOS `1.3.21`.
- Fixed: Android no longer retries forever when a refresh token is rejected; the session now ends.
- Fixed: Android no longer crashes when the network is unreachable while entitlements load.
- Fixed: Android account-unlock email links open the app, and incoming deep links are checked against the configured Frontegg domain.
- Fixed: iOS users are no longer signed out when the app relaunches after a reboot before the device is unlocked.
- Fixed: iOS SSO sign-in failing with `Failed to login with SSO`, and the account-unlock link hanging on a spinner.
- Fixed: sign-in now returns to the app when the Frontegg base URL includes a path.

## v1.0.52
- Fixed: embedded Google login on iOS failed with `Failed to get extract code from hostedLoginCallback url` even though the provider had already authenticated the user (FR-26132).
- Fixed: the App-Link OAuth callback was treated as a magic link, dropping the PKCE verifier and failing the token exchange with `ER-00001` when `useAssetLinks` is enabled.
- Improved: social login callbacks that cannot be processed now log the specific reason instead of a single generic message.
- Bump native SDK to iOS `1.3.17`.

## v1.0.51
- Fixed: Android `getConstants()` omitted `clientId`, crashing `FronteggConstants.fromMap` on every call (FR-25941).
- Fixed: activity-dependent methods hung the Dart Future when no Activity was attached; now complete with an error (FR-25943).
- Fixed: `login` / `directLogin` / `switchTenant` reported success on failure or cancel; now reject/propagate the error (iOS + Android) (FR-25942).
- Fixed: `forceStateUpdate()` never emitted state (Android no-op / iOS `MissingPluginException`); also fixed the iOS Combine listener leak on re-subscribe (FR-25944).
- Bump native SDKs to Android `1.3.36` / iOS `1.3.12`.

# v1.0.50

- Updated native SDKs to `frontegg-ios-swift` 1.3.11 / `frontegg-android-kotlin` 1.3.35 — fixes embedded step-up showing a blank page instead of the MFA challenge (requires hosted login box ≥ 7.118.0)
- Added `getFeatureEntitlement()` and `getPermissionEntitlement()` to query feature/permission entitlements on-device

## v1.0.49
- Bump frontegg-android-kotlin SDK to `1.3.34`
- Bump frontegg-ios-swift SDK to `1.3.10`
- Added `openAdminPortal()` API to open the embedded Admin Portal. Added `Open Admin Portal` button to all demo apps

## v1.0.48
Bump frontegg-kotlin sdk to 1.3.32.
Bump frontegg-ios sfk to 1.3.7.

## v1.0.47
## Summary
- Trust server tenant on fresh login instead of stale cache.
- Gate `AndroidDebugConfigurationChecker` on host app debuggable flag.

## v1.0.46
Bump frontegg-android-kotlin version to 1.3.28.
- Trust server tenant on fresh login instead of stale cache.
- Gate `AndroidDebugConfigurationChecker` on host app debuggable flag.

## v1.0.45
Bump frontegg-android-kotlin sdk to 1.3.27.

## v1.0.44
Bump frontegg-ios-swift version to 1.3.3.

## v1.0.43
Added support for disable automatic token refresh

## v1.0.42
- Bump frontegg-android-kotlin sdk to 1.3.25 version.
- Added offlie mode support for flutter-sdk.

## v1.0.41
Fixed bug with session management for offline mode.

## v1.0.40
- Added entitlements and roles feature support
- Bump IOS and Android versions
- Minimum required version of Flutter is `3.41+`

## v1.0.39
## Summary
- **Example apps** now uses shared Frontegg credentials (for automation / E2E).
- **iOS**: `Frontegg.plist` + `.entitlements` (associated domains) updated.
- **Android**: `build.gradle` `fronteggDomain` / `fronteggClientId` updated.
Aligns the Android plugin with Frontegg Android SDK 1.3.22 and fixes `state.accessToken` staying stale after await `frontegg.refreshToken()` by waiting for native refresh to finish and forcing a state push to Flutter before the method channel returns

## v1.0.38
Bump frontegg-android-kotlin version to 1.3.19.
Integrate iOS `FronteggSwift` exclusively via Swift Package Manager (SPM).

## v1.0.37
FR-23832.
Fixed ephemeralSession.

## v1.0.36
Fixed: "Remember MFA Device" Setting Ignored.
Fixed: Autofill Password Managers kills activity.
Fixed: screen rotation resets flow.

## v1.0.35
Bump frontegg-kotlin version 1.3.16.
Bump FronteggSwift version 1.2.73.

## v1.0.34
- Bump IOS version to 1.2.73

## v1.0.33
- Bump IOS version to 1.2.71

## v1.0.32
- bump IOS version to 1.2.70

## v1.0.31
- Bump IOS version to 1.2.69

## v1.0.31
Updated FronteggSwift version to 1.2.69.

## v1.0.30
Updated FronteggSwift version to 1.2.66.

## v1.0.29
- ios version upgrade
- added `requestAuthorize` in hosted example

## v1.0.28
Fixed: Google Login fails to redirect to app in embeddedMode when Safari session exists

## v1.0.27
- Enable session per tenant support 

## v1.0.26
Fixed magic links
Fixed: post Activation Redirect to App fails, leaving user on "Opening Application" page

## v1.0.25
Bug fixing.
Increased versions of Kotlin and Swift-sdks

## v1.0.24
Fixed issue when reset password link sometimes redirected to blank screen.

## v1.0.23
Bump swift-sdk to 1.2.51v
Bump kotlin-sdk to 1.3.10v
Added examples for token retrieval after login below the "Sensitive action" button

## v1.0.22
Bump Frontegg-Kotlin-SDK version to 1.3.9
Bump Frontegg-Swift-SDK version to 1.2.48

## v1.0.20
- Updating android SDK

- Upgrade android version to `1.2.48`

## v1.0.18
- Upgrade native library for latency improvements

## v1.0.17
Fix publish script
- Upgrade android version to `1.2.47`
- Added check for init of android app

## v1.0.16
- Updated example projects UI
- Upgrade ios version to 1.2.44

## v1.0.15

### 🔄 Integration Enhancements

* **Channel Subscription After Initialization**
  The Flutter SDK now subscribes to the native event channel **only after Frontegg is fully initialized**, ensuring stability and preventing race conditions during early-stage interactions.

---

### 🧹 Native SDK Dependency Updates

#### 🟢 Android – v1.2.42

* **📁 Web Resource Caching for WebView**
  Introduced persistent disk caching for **JavaScript**, **CSS**, and **font** files used in embedded login flows and hosted assets, reducing redundant requests and improving load times.

  ✅ **How to enable**:
  Add the following line to your `android/app/build.gradle` file:

  ```gradle
  buildConfigField "Boolean", "FRONTEGG_USE_DISK_CACHE_WEBVIEW", "true"
  ```

* **✅ Stability Improvements**

  * Fixed `loginDirectAction` reliability after cold launches.
  * Channel subscription now deferred until SDK is initialized.
  * Migrated to structured coroutine scopes for better async control.
  * Improved error handling for background token refreshes.
  * Added safe wrappers for API calls (`api.me()` and `api.exchangeToken()`).

* **🛠️ QA & Tooling**

  * Integrated [[Detekt](https://github.com/detekt/detekt)](https://github.com/detekt/detekt) for code quality checks.
  * Refined publishing scripts and documentation.

---

#### 🍎 iOS – v1.2.44

* **⚡ WebView & UI Performance**

  * Optimized **WKWebView** initialization for faster login rendering.
  * Unified loading indicators across flows.
  * Prevented reloads on social login cancelation.

* **🧪 Testing & CI**

  * Enabled E2E tests on iOS simulators.
  * Automated test runs before each release to ensure quality.

* **🐞 Bug Fixes**

  * Addressed crashes tied to authentication state and view lifecycle.

## v1.0.14
- Updated Android SDK

## v1.0.13
FR-20294 - Add missing login completion call after closing with custom scheme

## v1.0.12
- upgraded native SDKs.

## v1.0.11
- updated iOS Frontegg SDK up to `1.2.37`.
- Updated project documentation.

## v1.0.10
- Added `step-up` instruction.

## v1.0.9
- Deprecated `directLoginAction` method.
- Added `directLogin(url)`, `socialLogin(provider)`, and `customSocialLogin(id)` methods instead of `directLoginAction` method.
- Added docs to code.
- Updated `README.md`. Added `login` with `loginHint` description.
- Fix `CHANGELOG.md` generation
- Updated workflows Flutter version to `3.27.4`
- Added unit and integration tests.
- Added `DefaultLoader` native functional
- Added `embedded` example project.
- Added `hosted` example project.
- Added `application_id` example project.
- Added step-up functionality
- Upgraded Android SDK

# v1.0.8
- CHANGELOG.md generation automation.
- Added `additionalQueryParams` to `directLoginAction`
- Upgraded Frontegg IOS version to `1.2.32`

## v1.0.7
- Added `requestAuthorize` method.

## v1.0.6
Automate publish versions

## v1.0.5
Publish Flow Testing

## v1.0.4
- Added `registerPasskeys` method.
- Added `loginWithPasskeys` method.
- Added support for prompting the user to save web credentials after successful authentication. To enable this feature, add `shouldSuggestSavePassword` to `Frontegg.plist` and set it to true.
- Added `refreshingToken` to `FronteggState`. `refreshingToken` indicates when token refreshing is in progress.
- Fixed awaiting `login` and `logout` methods.

## v1.0.3
**iOS:**
- **Keychain Data Persistence Configuration:** Added support to keep or remove Keychain data upon app reinstall. This feature is configurable via a new property in `Frontegg.plist`, allowing more flexibility in how sensitive data is handled across app reinstalls.
- **Token Refresh Rescheduling:** Improved token management by rescheduling token refresh when the internet connection is inactive, ensuring seamless token refresh when the network becomes available again.

**Android:**
- **Security Dependencies Update:** Updated security dependencies to enhance app security and compatibility with the latest Android versions.
- **Direct Login Action Race Condition Fix:** Resolved a race condition issue in the Direct Login Action, improving the reliability of the login process.
- **ACCESS_NETWORK_STATE Permission:** Added the missing permission for `ACCESS_NETWORK_STATE`, enabling better handling of network state detection during token refresh and login actions.

## v1.0.2
- Multi-Application Support
    - Now you can pass applicationId in configuration files, making it easier to manage multiple applications.
- Build Config Fix
  - Resolved issues with Build Config retrieval when using Android flavors, ensuring smooth builds across environments.

- Documentation Update
  - The README has been updated for better clarity on SDK integration and usage.

- Native SDK Upgrades
  - Upgraded to the latest Android and iOS native SDKs, with the following improvements:

  **Android**
    - Token Refresh Improvements
      - Implemented `TimerTask` for immediate token refresh in the foreground.
      - Used `JobScheduler` for efficient background token refresh.
      - Added retry logic for failed background jobs.
      - Enhanced state transition handling between foreground and background.
      - Improved handling of near-expiry tokens.
      - Introduced checks for token refresh status.
 
    - OAuth/Authorize Error Fix
      - Fixed infinite loading on `/oauth/authorize` by correctly displaying backend errors.
  
  **iOS**
    - Demo App and Documentation 
      - Fixed issues in the demo app and updated the README for clearer instructions.
  
    - OAuth Error Handling 
      - Improved error handling during OAuth authorization for a smoother login experience.
  
    - Code Cleanup 
      - Removed unnecessary logs and fixed a typo related to `ephemeralSession`.

    - Token Refresh Enhancements 
      - Improved token refresh during app state transitions for consistent sessions.

## v1.0.1

- Add MultiApp support
- Upgrade iOS SDK for social login fix

## v1.0.0

Official version of frontegg flutter sdk

Frontegg is a first-of-its-kind full-stack user management platform, empowering software teams with user infrastructure
features for the product-led era.

## v0.0.5

- Pre-Release official version of flutter sdk

## v0.0.4

- Connecting iOS and Android FronteggSDKs and native methods usage

## v0.0.3

- Add support for hash routing

## v0.0.1

- Initialize Frontegg AdminPortal wrapper
