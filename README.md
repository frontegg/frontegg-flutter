# @frontegg/flutter

Frontegg is a first-of-its-kind full-stack user management platform, empowering software teams with user infrastructure
features for the product-led era.

## Table of Contents

- [@frontegg/flutter](#fronteggflutter)
  - [Table of Contents](#table-of-contents)
  - [Project Requirements](#project-requirements)
  - [Getting Started](#getting-started)
    - [Prepare Frontegg workspace](#prepare-frontegg-workspace)
    - [Add frontegg package to the project](#add-frontegg-package-to-the-project)
  - [Setup iOS Project](#setup-ios-project)
    - [Create Frontegg plist file](#create-frontegg-plist-file)
    - [Handle Open App with URL](#handle-open-app-with-url)
    - [`For Objective-C:`](#for-objective-c)
    - [`For Swift:`](#for-swift)
    - [Handle Open App with URL (Objective-C)](#handle-open-app-with-url-objective-c)
    - [Config iOS associated domain](#config-ios-associated-domain)
  - [Setup Android Project](#setup-android-project)
    - [Set minimum sdk version](#set-minimum-sdk-version)
    - [Configure build config fields](#configure-build-config-fields)
    - [Add permissions to AndroidManifest.xml](#add-permissions-to-androidmanifestxml)
    - [Config Android AssetLinks](#config-android-assetlinks)
    - [Enabling Chrome Custom Tabs for Social Login](#enabling-chrome-custom-tabs-for-social-login)
  - [Usages](#usages)
    - [Wrap your root Widget with FronteggProvider:](#wrap-your-root-widget-with-fronteggprovider)
    - [Access to frontegg instance](#access-to-frontegg-instance)
    - [Login with frontegg](#login-with-frontegg)
    - [Switch tenant frontegg](#switch-tenant-frontegg)
    - [Frontegg state](#frontegg-state)
    - [Other frontegg features:](#other-frontegg-features)

## Project Requirements

- Minimum iOS deployment version **=> 14**
- Min Android SDK **=> 26**

## Getting Started

### Prepare Frontegg workspace

Navigate to [Frontegg Portal Settings](https://portal.frontegg.com/development/settings), If you don't have application
follow integration steps after signing up.
Copy FronteggDomain to future steps
from [Frontegg Portal Domain](https://portal.frontegg.com/development/settings/domains)

- Navigate to [Login Method Settings](https://portal.frontegg.com/development/authentication/hosted)
- Toggle Hosted login method for iOS:
    - Add `{{IOS_BUNDLE_IDENTIFIER}}://{{FRONTEGG_BASE_URL}}/ios/oauth/callback`
- Toggle Hosted login method for Android:
    - Add `{{ANDROID_PACKAGE_NAME}}://{{FRONTEGG_BASE_URL}}/android/oauth/callback`
    - Add `https://{{FRONTEGG_BASE_URL}}/oauth/account/redirect/android/{{ANDROID_PACKAGE_NAME}}`
- Replace `IOS_BUNDLE_IDENTIFIER` with your application identifier
- Replace `FRONTEGG_BASE_URL` with your frontegg base url
- Replace `ANDROID_PACKAGE_NAME` with your android package name
-

### Add frontegg package to the project

Use a package manager pab to install frontegg Flutter library.

**Terminal:**

```bash
dart pub add frontegg-flutter
```

**Or manually:**

```yaml
dependencies:
  frontegg-flutter: ^0.0.4
```

## Setup iOS Project

### Create Frontegg plist file

To setup your SwiftUI application to communicate with Frontegg, you have to create a new file named `Frontegg.plist`
under
your root project directory, this file will store values to be used variables by Frontegg SDK:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>baseUrl</key>
        <string>https://[DOMAIN_HOST_FROM_PREVIOUS_STEP]</string>
        <key>clientId</key>
        <string>[CLIENT_ID_FROM_PREVIOUS_STEP]</string>
    </dict>
</plist>
```

### Handle Open App with URL

To handle Login with magic link and other authentication methods that require to open the app with a URL, you have to
add the following code to.

### `For Objective-C:`

1. Create `FronteggSwiftAdapter.swift` in your project and add the following code:

    ```objective-c
    //  FronteggSwiftAdapter.swift
    
    import Foundation
    import FronteggSwift
    
    @objc(FronteggSwiftAdapter)
    public class FronteggSwiftAdapter: NSObject {
        @objc public static let shared = FronteggSwiftAdapter()
    
        @objc public func handleOpenUrl(_ url: URL) -> Bool {
            return FronteggAuth.shared.handleOpenUrl(url)
        }
    }
    ```

2. Open `AppDelegate.m` file and import swift headers:

    ```objective-c
    #import <[YOUR_PROJECT_NAME]-Swift.h>
    ```
3. Add URL handlers to `AppDelegate.m`:

    ```objective-c
    #import <[YOUR_PROJECT_NAME]-Swift.h>
   
   // ...CODE...
   
   - (BOOL)application:(UIApplication *)app openURL:(NSURL *)url
            options:(NSDictionary<UIApplicationOpenURLOptionsKey, id> *)options
    {
      
      if([[FronteggSwiftAdapter shared] handleOpenUrl:url] ){
        return TRUE;
      }
      return [RCTLinkingManager application:app openURL:url options:options];
    }
    
    - (BOOL)application:(UIApplication *)application continueUserActivity:(nonnull NSUserActivity *)userActivity
     restorationHandler:(nonnull void (^)(NSArray<id<UIUserActivityRestoring>> * _Nullable))restorationHandler
    {
      
      if (userActivity.webpageURL != NULL){
        if([[FronteggSwiftAdapter shared] handleOpenUrl:userActivity.webpageURL] ){
          return TRUE;
        }
      }
     return [RCTLinkingManager application:application
                      continueUserActivity:userActivity
                        restorationHandler:restorationHandler];
    }
    ```

### `For Swift:`

1. Open `AppDelegate.m` file and import swift headers:

    ```swift
    import FronteggSwift
    ```
2. Add URL handlers to `AppDelegate.swift`:
    ```swift  
    import UIKit
    import FronteggSwift
    
    @UIApplicationMain
    class AppDelegate: UIResponder, UIApplicationDelegate {
    
        /*
         * Called when the app was launched with a url. Feel free to add additional processing here,
         * but if you want the App API to support tracking app url opens, make sure to keep this call
         */
        func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
            
            if(FronteggAuth.shared.handleOpenUrl(url)){
                return true
            }
            
            return ApplicationDelegateProxy.shared.application(app, open: url, options: options)
        }
        
        /*
         * Called when the app was launched with an activity, including Universal Links.
         * Feel free to add additional processing here, but if you want the App API to support
         * tracking app url opens, make sure to keep this call
         */
        func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
            
            if let url = userActivity.webpageURL {
                if(FronteggAuth.shared.handleOpenUrl(url)){
                    return true
                }
            }
            return ApplicationDelegateProxy.shared.application(application, continue: userActivity, restorationHandler: restorationHandler)
        }
    }
    ```

### Handle Open App with URL (Objective-C)

### Config iOS associated domain

Configuring your iOS associated domain is required for Magic Link authentication / Reset Password / Activate Account.

In order to add your iOS associated domain to your Frontegg application, you will need to update in each of your
integrated Frontegg Environments the iOS associated domain that you would like to use with that Environment. Send a POST
request to `https://api.frontegg.com/vendors/resources/associated-domains/v1/ios` with the following payload:

```
{
    “appId”:[YOUR_ASSOCIATED_DOMAIN]
}
```

In order to use our API’s, follow [this guide](‘https://docs.frontegg.com/reference/getting-started-with-your-api’) to
generate a vendor token.

## Setup Android Project

### Set minimum sdk version

To set up your Android minimum sdk version, open root gradle file at`android/build.gradle`,
and add/edit the `minSdkVersion` under `buildscript.ext`:

```groovy
buildscript {
    ext {
        minSdkVersion = 26
        // ...
    }
}
```

### Configure build config fields

To set up your Android application on to communicate with Frontegg, you have to add `buildConfigField` property the
gradle `android/app/build.gradle`.
This property will store frontegg hostname (without https) and client id from previous step:

```groovy

def fronteggDomain = "FRONTEGG_DOMAIN_HOST.com" // without protocol https://
def fronteggClientId = "FRONTEGG_CLIENT_ID"

android {
    defaultConfig {

        manifestPlaceholders = [
                "package_name" : applicationId,
                "frontegg_domain" : fronteggDomain,
                "frontegg_client_id": fronteggClientId
        ]

        buildConfigField "String", 'FRONTEGG_DOMAIN', "\"$fronteggDomain\""
        buildConfigField "String", 'FRONTEGG_CLIENT_ID', "\"$fronteggClientId\""
        buildConfigField "Boolean", 'FRONTEGG_USE_ASSETS_LINKS', "true" /** For using frontegg domain for deeplinks **/
        buildConfigField "Boolean", 'FRONTEGG_USE_CHROME_CUSTOM_TABS', "true"  /** For using custom chrome tab for social-logins **/
    }
    
    
}
```

Note: 
`FRONTEGG_USE_ASSETS_LINKS` by default is `true`.
`FRONTEGG_USE_CHROME_CUSTOM_TABS` by default is `true`. 
So, if you do not set up those values we will use values by default.

Add bundleConfig=true if not exists inside the android section inside the app gradle `android/app/build.gradle`

```groovy
android {
  buildFeatures {
    buildConfig = true
  }
}
```

### Add permissions to AndroidManifest.xml

Add `INTERNET` permission to the app's manifest file.

```xml

<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

### Config Android AssetLinks

Configuring your Android `AssetLinks` is required for Magic Link authentication / Reset Password / Activate Account /
login with IdPs.

To add your `AssetLinks` to your Frontegg application, you will need to update in each of your integrated Frontegg
Environments the `AssetLinks` that you would like to use with that Environment. Send a POST request
to `https://api.frontegg.com/vendors/resources/associated-domains/v1/android` with the following payload:

```
{
    "packageName": "YOUR_APPLICATION_PACKAGE_NAME",
    "sha256CertFingerprints": ["YOUR_KEYSTORE_CERT_FINGERPRINTS"]
}
```

Each Android app has multiple certificate fingerprint, to get your `DEBUG` sha256CertFingerprint you have to run the
following command:

For Debug mode, run the following command and copy the `SHA-256` value

NOTE: make sure to choose the Variant and Config equals to `debug`

```bash
./gradlew signingReport

###################
#  Example Output:
###################

#  Variant: debug
#  Config: debug
#  Store: /Users/davidfrontegg/.android/debug.keystore
#  Alias: AndroidDebugKey
#  MD5: 25:F5:99:23:FC:12:CA:10:8C:43:F4:02:7D:AD:DC:B6
#  SHA1: FC:3C:88:D6:BF:4E:62:2E:F0:24:1D:DB:D7:15:36:D6:3E:14:84:50
#  SHA-256: D9:6B:4A:FD:62:45:81:65:98:4D:5C:8C:A0:68:7B:7B:A5:31:BD:2B:9B:48:D9:CF:20:AE:56:FD:90:C1:C5:EE
#  Valid until: Tuesday, 18 June 2052

```

For Release mode, Extract the SHA256 using keytool from your `Release` keystore file:

```bash
keytool -list -v -keystore /PATH/file.jks -alias YourAlias -storepass *** -keypass ***
```

In order to use our API’s, follow [this guide](https://docs.frontegg.com/reference/getting-started-with-your-api) to
generate a vendor token.

### Enabling Chrome Custom Tabs for Social Login

To enable social login using Chrome Custom Tabs within your Android application, you need to modify the `android/app/build.gradle` file. Add a boolean `buildConfigField` for the `FRONTEGG_USE_CHROME_CUSTOM_TABS` flag and set it to true.

By default, the SDK defaults to using the Chrome browser for social login.

 ```groovy

def fronteggDomain = "FRONTEGG_DOMAIN_HOST.com" // without protocol https://
def fronteggClientId = "FRONTEGG_CLIENT_ID"

android {
    defaultConfig {

        manifestPlaceholders = [
                "package_name" : applicationId,
                "frontegg_domain" : fronteggDomain,
                "frontegg_client_id": fronteggClientId
        ]

        buildConfigField "String", 'FRONTEGG_DOMAIN', "\"$fronteggDomain\""
        buildConfigField "String", 'FRONTEGG_CLIENT_ID', "\"$fronteggClientId\""
        
        buildConfigField "Boolean", 'FRONTEGG_USE_CHROME_CUSTOM_TABS', "true"
    }
    
    
}
```

## Usages

### Wrap your root Widget with FronteggProvider:

```dart
import 'package:flutter/material.dart';
import 'package:frontegg/frontegg_flutter.dart';

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

Or Use Provider from the [plugin](https://pub.dev/packages/provider) or other suitable plugin,
don't forget about `dispose` of the `FronteggFlutter`:

```dart
import 'package:flutter/material.dart';
import 'package:frontegg/frontegg_flutter.dart';
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

### Access to frontegg instance

To get the `FronteggFlutter` instance use the Frontegg BuildContext extension down the widget tree:

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


### Login with frontegg

To log in with frontegg you can use the `context`.`frontegg` accessor and call `login` method:

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

### Switch tenant frontegg

To switch tenant  with frontegg you can use the `context`.`frontegg` accessor and call `switchTenant` method:

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

`FronteggPlugin` has a `FronteggState` and this state is changing according to the plugin flowing:

```dart
class FronteggState {
  final String? accessToken;
  final String? refreshToken;
  final FronteggUser? user;
  final bool isAuthenticated;
  final bool isLoading;
  final bool initializing;
  final bool showLoader;
}
```

To get a state of the `FronteggFlutter` you have two option:

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
    import 'package:frontegg/frontegg_flutter.dart';
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

### Other frontegg features:

Also frontegg give you next features:
  1. `logout` - logs out from `FronteggFlutter`;
  2. `refreshToken` - refreshes `accessToken` and `refreshToken` only if needed, returns `true` if refreshing succeeds;
  3. `getConstants` - returns `Frontegg Flutter` initialize constants;
  4. `directLoginAction` - direct logs in with `type` and `data`.
   