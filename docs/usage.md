# Authentication and usage

The Frontegg Flutter SDK supports two authentication modes to enhance the user experience on mobile platforms:

* **Embedded webview**: A customizable in-app webview login experience, which is enabled by default.
* **Hosted Webview**: A secure, system-level authentication flow leveraging:
  - **Android**: Chrome Custom Tabs for social login and strong session isolation.

### Social Login Support

The Frontegg Flutter SDK supports social login in both authentication modes:

* **Embedded mode**: Social login works through the embedded WebView
* **Hosted mode**: Social login uses Chrome Custom Tabs (Android) or system browser (iOS)

The Android SDK automatically handles the mode selection internally, so social login works seamlessly in both configurations.

Social login is available for the following providers:
- Google
- Facebook  
- LinkedIn
- GitHub
- Apple
- Microsoft
- Slack

#### Using Social Login

```dart
// Standard social login
await frontegg.socialLogin(
  provider: FronteggSocialProvider.google,
  ephemeralSession: true,
  additionalQueryParams: {'custom_param': 'value'},
);

// Custom social login
await frontegg.customSocialLogin(
  id: 'your-custom-provider-id',
  ephemeralSession: true,
  additionalQueryParams: {'custom_param': 'value'},
);
```

### Chrome Custom Tabs Configuration

To enable social login using Chrome Custom Tabs within your Android application, you need to modify the `android/app/build.gradle` file as described below.

1. Open the `android/app/build.gradle` file.
2. Before the android `{}` block, declare the following variables (replace placeholders with your actual values):

```groovy
def fronteggDomain = "{{FRONTEGG_BASE_URL}}" // without https://
def fronteggClientId = "{{FRONTEGG_CLIENT_ID}}"
```

3. Within the `android { defaultConfig { ... } }` section, add the following:

```groovy
manifestPlaceholders = [
    "package_name"        : applicationId,
    "frontegg_domain"     : fronteggDomain,
    "frontegg_client_id"  : fronteggClientId
]

buildConfigField "String", "FRONTEGG_DOMAIN", "\"$fronteggDomain\""
buildConfigField "String", "FRONTEGG_CLIENT_ID", "\"$fronteggClientId\""
buildConfigField "Boolean", "FRONTEGG_USE_CHROME_CUSTOM_TABS", "true"
buildConfigField "Boolean", "FRONTEGG_ENABLE_SESSION_PER_TENANT", "false"
```

- Replace `{{FRONTEGG_BASE_URL}}` with the domain name from your Frontegg Portal.
- Replace `{{FRONTEGG_CLIENT_ID}}` with your Frontegg client ID.

4. After saving your changes, sync the Gradle project to apply the configuration.

**NOTE**: By default, the Frontegg SDK will use the Chrome browser for social login when this flag is set to `true`.


### Wrap your root widget with `FronteggProvider`

To enable Frontegg in your Flutter app, wrap your root widget with `FronteggProvider`. This makes the SDK available throughout the widget tree:

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

Alternatively, you can use [Provider](https://pub.dev/packages/provider) from the provider package or any other state management solution. Just make sure to properly `dispose` the `FronteggFlutter` instance:

```dart
import 'package:flutter/material.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';
import 'package:provider/provider.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Provider(
        create: (_) => FronteggFlutter(),
        dispose: (_, frontegg) => frontegg.dispose(),
        child: const MainPage(),
      ),
    );
  }
}
```

### Access the Frontegg instance

To get the `FronteggFlutter` instance, use the Frontegg `BuildContext` extension down the widget tree:

```dart
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return const SizedBox();
  }
}
```

### Login with Frontegg

To log in with Frontegg, you can use the `context.frontegg` accessor and call `login` method:

```dart
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("Login"),
          onPressed: () async {
            await frontegg.login();
          },
        ),
      ),
    );
  }
}
```

You can prefill the login input field by passing a `loginHint` parameter to the `login()` method:

```dart
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("Login"),
          onPressed: () async {
            await frontegg.login(loginHint: "some@mail.com");
          },
        ),
      ),
    );
  }
}
```

### Switch account (tenant)

To switch user accounts using Frontegg, access the SDK instance via `context.frontegg` and call the `switchTenant()` method:


```dart
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final frontegg = context.frontegg;
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text("Login"),
          onPressed: () async {
            final tenantId = "TENANT_ID";
            await frontegg.switchTenant(tenantId);
          },
        ),
      ),
    );
  }
}
```

### Frontegg state

The `FronteggPlugin` exposes a `FronteggState` object, which updates automatically as the authentication flow progresses:

```dart
class FronteggState {
  final String? accessToken;
  final String? refreshToken;
  final FronteggUser? user;
  final bool isAuthenticated;
  final bool isLoading;
  final bool initializing;
  final bool showLoader;
  final bool appLink;
}
```

You can access the current state of `FronteggFlutter` in two ways:

1. Get `currentState`:
   ```dart
    @override
    Widget build(BuildContext context) {
      final frontegg = context.frontegg;
      final fronteggState = frontegg.currentState;
    }
    
   ```
2. Listen `stateChanged` stream:
   ```dart
    import 'package:flutter/material.dart';
    import 'package:frontegg_flutter/frontegg_flutter.dart';
    import 'package:frontegg_flutter_example/login_page.dart';
    import 'package:frontegg_flutter_example/user_page.dart';

    class MainPage extends StatelessWidget {
      const MainPage({super.key});

      @override
      Widget build(BuildContext context) {
        final frontegg = context.frontegg;
        return Scaffold(
          body: Center(
            child: StreamBuilder<FronteggState>(
              stream: frontegg.stateChanged,
              builder: (BuildContext context, AsyncSnapshot<FronteggState> snapshot) {
                if (snapshot.hasData) {
                  final state = snapshot.data!;
                  if (state.isAuthenticated && state.user != null) {
                    return const UserPage();
                  } else if (state.initializing) {
                    return const CircularProgressIndicator();
                  } else {
                    return const LoginPage();
                  }
                }

                return const SizedBox();
              },
            ),
          ),
        );
      }
    }
   ```

### Logout user after application was uninstalled

If you want the user to be logged out after reinstalling the application, add the `keepUserLoggedInAfterReinstall` property to the `Frontegg.plist` file:

```xml
<plist version="1.0">
  <dict>
    <key>keepUserLoggedInAfterReinstall</key>
    <false/>
    ...
  </dict>
</plist>
```

By default `keepUserLoggedInAfterReinstall` is `true`.

### Enable per-tenant sessions (`enableSessionPerTenant`)

Per-tenant sessions are controlled by a flag in `Frontegg.plist`, similar to `keepUserLoggedInAfterReinstall`.

To enable per-tenant sessions on iOS, add the `enableSessionPerTenant` key to your `Frontegg.plist`:

```xml
<plist version="1.0">
  <dict>
    <key>enableSessionPerTenant</key>
    <true/>
    ...
  </dict>
</plist>
```
and verify your Gradle config includes:

```groovy
buildConfigField "Boolean", "FRONTEGG_ENABLE_SESSION_PER_TENANT", "true"
```

- When this key is `true`, and your Frontegg workspace has per-tenant sessions enabled, the SDK will maintain separate sessions per tenant.
- The existing Flutter API (`login`, `switchTenant(tenantId)`, etc.) will automatically respect this behaviour; no additional Dart configuration is required.

### Troubleshooting Hosted Mode Issues

If you experience infinite loading in hosted mode after successful authentication, this is typically caused by state not updating properly after returning from Chrome Custom Tabs. The Flutter SDK now includes automatic state refresh to resolve this issue.

The SDK automatically handles state updates after successful authentication by:
- Calling the public `forceNotifyChanges()` method on the state listener
- Ensuring immediate state synchronization with Flutter
- Providing reliable state updates for hosted mode

This ensures that the UI properly reflects the authenticated state immediately after returning from hosted authentication.

#### Manual State Update (if needed)

If you still experience issues, you can manually trigger a state update:

```dart
// This will force a state refresh
await frontegg.forceStateUpdate();
```

### Troubleshooting

#### Android

If you encounter a `MissingPluginException` like the one below:

```
The following MissingPluginException was thrown while activating platform stream on channel frontegg_flutter/state_stream:
MissingPluginException(No implementation found for method listen on channel frontegg_flutter/state_stream)
```

Add the following rule to your `proguard-rules.pro` file to ensure proper class retention during build:

```
-keepclasseswithmembers class com.frontegg.** {*;}
```
