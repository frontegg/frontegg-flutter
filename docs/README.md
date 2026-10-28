# Frontegg Flutter SDK
![Frontegg_Flutter_SDK](/images/frontegg-flutter.png)

Welcome to the official **Frontegg Flutter SDK** — your all-in-one solution for
integrating authentication and user management into your Flutter mobile
app. [Frontegg](https://frontegg.com/) is a self-served user management platform, built for modern
SaaS applications. Easily implement authentication, SSO, RBAC, multi-tenancy, and more — all from a
single SDK.

## Why Frontegg for Flutter

The official Flutter plugin, built on Frontegg's native iOS (`FronteggSwift`) and Android
(`frontegg-android-kotlin`) SDKs, so one Dart API covers both platforms:

- **Hosted and embedded login**: the Frontegg login box in an in-app WebView (embedded), or in the
  system browser and Chrome Custom Tabs (hosted).
- **Social login and passkeys**: Google, Apple, Microsoft, GitHub, LinkedIn, Facebook, Slack and
  custom social providers, plus `loginWithPasskeys()` and `registerPasskeys()`.
- **B2B multi-tenancy**: the user's tenants and active tenant on `FronteggUser`, `switchTenant()`,
  and optional per-tenant sessions.
- **Multi-region**: configure several regions natively and select one at runtime with
  `initWithRegion()`.
- **Multi-app**: sign in to a specific Frontegg application with `applicationId`.
- **Step-up authentication**: `stepUp()` and `isSteppedUp()` for sensitive actions.
- **Entitlements**: on-device feature and permission checks with `getFeatureEntitlement()` and
  `getPermissionEntitlement()`.
- **Admin Portal (beta)**: `openAdminPortal()` opens the self-service portal in a native WebView.
- **Session handling**: the native SDKs store and refresh tokens, `stateChanged` streams the
  authentication state, offline mode keeps the session without a network, and
  `getOrRefreshAccessToken()` returns a valid token after the app resumes.

## 📚 Documentation

This repository includes:

- A [Get Started](https://flutter-guide.frontegg.com/#/getting-started) guide for quick integration
- A [Setup Guide](https://flutter-guide.frontegg.com/#/setup) with detailed setup instructions
- An [API Reference](https://flutter-guide.frontegg.com/#/api) for detailed SDK functionality
- [Usage Examples](https://flutter-guide.frontegg.com/#/usage) with common implementation patterns
- [Advanced Topics](https://flutter-guide.frontegg.com/#/advanced) for complex integration scenarios
- A [Hosted](https://github.com/frontegg/frontegg-flutter/tree/master/hosted) (which also has a [multi-region mode](https://github.com/frontegg/frontegg-flutter/tree/master/hosted#multi-region-mode)), [Embedded](https://github.com/frontegg/frontegg-flutter/tree/master/embedded), and [Application-Id](https://github.com/frontegg/frontegg-flutter/tree/master/application_id) example projects to help you get started quickly

For full documentation, visit the Frontegg Developer Portal:  
🔗 [https://developers.frontegg.com](https://developers.frontegg.com)

---

## 🧑‍💻 Getting Started with Frontegg

Don't have a Frontegg account yet?  
Sign up here → [https://portal.us.frontegg.com/signup](https://portal.us.frontegg.com/signup)

---

## 🔐 Per-tenant sessions (`enableSessionPerTenant`)

The Flutter SDK supports Frontegg's **per-tenant sessions** feature through the underlying native SDKs.

- On **Android**, the plugin and example apps use `com.frontegg.sdk:android:1.3.41`.
- On **iOS**, the plugin depends on `FronteggSwift`:
  - **Flutter 3.41+** (SPM): `1.3.21` from GitHub. Run `flutter config --enable-swift-package-manager`, then `flutter pub get` and build.
  - Note: CocoaPods fallback is no longer supported for `FronteggSwift`.
  - SPM integration requires **Xcode 15+**.

To enable and use per-tenant sessions:

1. **Enable the flag in your iOS configuration**
   - Add the following key to your `Frontegg.plist`:
   ```xml
   <plist version="1.0">
     <dict>
       <key>enableSessionPerTenant</key>
       <true/>
       ...
     </dict>
   </plist>
   ```

2. **Enable the flag in your Android configuration**  
   - Android: verify your Gradle config includes:
     ```groovy
     buildConfigField "Boolean", "FRONTEGG_ENABLE_SESSION_PER_TENANT", "true"
     ```

---

## 💬 Support

Need help? Our team is here for you:  
[https://support.frontegg.com/frontegg/directories](https://support.frontegg.com/frontegg/directories)
