<p align="center">
  <img src="https://raw.githubusercontent.com/frontegg/frontegg-flutter/master/images/frontegg-flutter.png" alt="Frontegg Flutter SDK" width="640" />
</p>

<h1 align="center">Frontegg Flutter SDK</h1>

<p align="center">
  <strong>Authentication and user management for your Flutter app — one package, both platforms.</strong>
</p>

<p align="center">
  <a href="https://pub.dev/packages/frontegg_flutter"><img src="https://img.shields.io/pub/v/frontegg_flutter?label=pub.dev&color=6c47ff" alt="pub.dev version" /></a>
  <img src="https://img.shields.io/badge/iOS-14%2B-lightgrey" alt="iOS 14+" />
  <img src="https://img.shields.io/badge/Android-API%2026%2B-3ddc84" alt="Android API 26+" />
  <img src="https://img.shields.io/badge/Dart-3-0175c2" alt="Dart 3" />
  <a href="https://github.com/frontegg/frontegg-flutter/blob/master/LICENSE"><img src="https://img.shields.io/github/license/frontegg/frontegg-flutter?color=blue" alt="Licence" /></a>
</p>

---

[Frontegg](https://frontegg.com/) is a self-served user management platform for modern SaaS
applications. Drop this SDK in and your app gets a production login screen, a live session, and a
user object — without you writing an auth flow or touching a token.

| | |
| --- | --- |
| **Embedded or hosted login** | An in-app webview by default, or the system browser and Chrome Custom Tabs |
| **Every method your tenants need** | Email, social, SSO, magic link, passkeys, MFA and step-up |
| **Sessions that stay alive** | Tokens refresh in the background; offline mode keeps users working without a connection |
| **Built for multi-tenant SaaS** | Multi-tenancy, RBAC, entitlements and multi-region support |

---

## Install

```bash
dart pub add frontegg_flutter
```

Or in `pubspec.yaml`:

```yaml
dependencies:
  frontegg_flutter: ^1.0.0
```

> Requires **iOS 14+** and **Android API 26+**. The [releases page](https://github.com/frontegg/frontegg-flutter/releases) has the current version.

## Quick start

**1 · Allow the redirect URLs.** In the Frontegg Portal, under **[ENVIRONMENT] → Authentication →
Login method**, turn hosted login on and add one per platform:

```
# iOS
{{IOS_BUNDLE_IDENTIFIER}}://{{FRONTEGG_BASE_URL}}/ios/oauth/callback

# Android
{{ANDROID_PACKAGE_NAME}}://{{FRONTEGG_BASE_URL}}/android/oauth/callback
```

**2 · Configure the native projects.** Android takes its domain and client ID from `build.gradle`;
iOS reads a `Frontegg.plist`. Both are covered step by step in the
[Get Started guide](https://flutter-guide.frontegg.com/#/getting-started) — this is the one part
that is not Dart, and it differs per platform.

**3 · Wrap your root widget.**

```dart
import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: FronteggProvider(
        child: const MainPage(),
      ),
    );
  }
}
```

**4 · Reach the SDK** anywhere below it through the `BuildContext` extension.

```dart
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Login'),
          onPressed: () async => frontegg.login(),
        ),
      ),
    );
  }
}
```

## Documentation

| Guide | What it covers |
| --- | --- |
| [Get Started](https://flutter-guide.frontegg.com/#/getting-started) | Requirements, environment prep, iOS and Android setup |
| [Setup](https://flutter-guide.frontegg.com/#/setup) | Detailed configuration |
| [API Reference](https://flutter-guide.frontegg.com/#/api) | Every method the SDK exposes |
| [Usage Examples](https://flutter-guide.frontegg.com/#/usage) | Login flows, social providers, offline mode |
| [Advanced Topics](https://flutter-guide.frontegg.com/#/advanced) | Complex integration scenarios |

Full platform documentation lives at [developers.frontegg.com](https://developers.frontegg.com).

## Example apps

Three runnable projects, each a complete integration:

[Hosted](https://github.com/frontegg/frontegg-flutter/tree/master/hosted) ·
[Embedded](https://github.com/frontegg/frontegg-flutter/tree/master/embedded) ·
[Application-Id](https://github.com/frontegg/frontegg-flutter/tree/master/application_id)

## Support

No Frontegg account yet? [Sign up free](https://portal.us.frontegg.com/signup).

Questions, or something broken? Reach the team at
[support.frontegg.com](https://support.frontegg.com/frontegg/directories) or
[open an issue](https://github.com/frontegg/frontegg-flutter/issues).

Licensed under the [LICENSE](https://github.com/frontegg/frontegg-flutter/blob/master/LICENSE) in this repository.
