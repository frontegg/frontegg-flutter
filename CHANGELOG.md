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
