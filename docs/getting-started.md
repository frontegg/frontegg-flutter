# Getting started with Frontegg Flutter SDK

Welcome to the Frontegg Flutter SDK! Bring Frontegg’s out-of-the-box authentication and user
management to your Flutter apps for a seamless cross-platform experience.

The Frontegg Flutter SDK can be used in two ways:

1. With the hosted Frontegg login that opens in a WebView, enabling all login methods supported by
   the login box.

2. By directly calling Frontegg APIs from your own custom UI, using the available methods.

The SDK automatically handles token management and refresh in the background, so your users stay
authenticated without any manual effort.

## Project requirements

- **iOS**: Minimum deployment version ≥ 14
- **Android**: Minimum SDK version ≥ 26

## Prepare your Frontegg environment

- Navigate to Frontegg Portal [ENVIRONMENT] → `Keys & domains`
- If you don't have an application, follow the integration steps after signing up
- Copy your environment's `FronteggDomain` from Frontegg Portal domain for future steps

- Navigate to [ENVIRONMENT] → Authentication → Login method
- Make sure hosted login is toggled on.
- For iOS add `https://{{IOS_BUNDLE_IDENTIFIER}}://{{FRONTEGG_BASE_URL}}/ios/oauth/callback`
- For Android add `{{ANDROID_PACKAGE_NAME}}://{{FRONTEGG_BASE_URL}}/android/oauth/callback` **(
  without assetlinks)**
- Add `Add https://{{FRONTEGG_BASE_URL}}/oauth/account/redirect/android/{{ANDROID_PACKAGE_NAME}}` *
  *(required for assetlinks)**
- Add `https://{{FRONTEGG_BASE_URL}}/oauth/authorize`
- Replace `IOS_BUNDLE_IDENTIFIER` with your application identifier
- Replace `FRONTEGG_BASE_URL` with your Frontegg domain, i.e `app-xxxx.frontegg.com` or your custom
  domain.
- Replace `ANDROID_PACKAGE_NAME` with your android package name

<br>

> [!WARNING]
> On every step, if you have
> a [custom domain](https://developers.frontegg.com/guides/env-settings/custom-domain), replace the
`[frontegg-domain]` and `[your-custom-domain]` placeholders with your custom domain instead of the
> value from the settings page.

## Installation

You can add the Frontegg Flutter package using either method:

**Using Dart pub:**

```bash
dart pub add frontegg_flutter
```

**Or manually in pubspec.yaml:**

```yaml
dependencies:
  frontegg_flutter: ^1.0.0
```

## Setup Android Project

### Set the minimum SDK version

1. Open your project in Android Studio.
2. Navigate to the root-level Gradle file: `android/build.gradle`.
3. Locate the `buildscript.ext` section in the file.
4. Add or update the `minSdkVersion` value. For example:

```groovy
buildscript {
    ext {
        minSdkVersion = 26
        // ...
    }
}
```

### Configure build config fields

To set up your Android application on to communicate with Frontegg:

1. Add `buildConfigField` entries to `android/app/build.gradle`:

```groovy
def fronteggDomain = "{{FRONTEGG_BASE_URL}}" // without protocol https://
def fronteggClientId = "{{FRONTEGG_CLIENT_ID}}"

android {
    defaultConfig {

        manifestPlaceholders = [
                "package_name"      : applicationId,
                "frontegg_domain"   : fronteggDomain,
                "frontegg_client_id": fronteggClientId
        ]

        buildConfigField "String", '{{FRONTEGG_BASE_URL}}', "\"$fronteggDomain\""
        buildConfigField "String", '{{FRONTEGG_CLIENT_ID}}', "\"$fronteggClientId\""
        buildConfigField "Boolean", 'FRONTEGG_USE_ASSETS_LINKS', "true"
        /** For using frontegg domain for deeplinks **/
        buildConfigField "Boolean", 'FRONTEGG_USE_CHROME_CUSTOM_TABS', "true"
        /** For using custom chrome tab for social-logins **/
    }
}
```

- Replace `{{FRONTEGG_BASE_URL}}` with the domain name from your Frontegg Portal.
- Replace `{{FRONTEGG_CLIENT_ID}}` with your Frontegg client ID.

2. Add `buildConfig = true` under the `buildFeatures` block in the `android` section of your
   `android/app/build.gradle` file if it doesn't already exist:

```groovy
android {
    buildFeatures {
        buildConfig = true
    }
}
```

## Setup iOS Project

### Create Frontegg.plist

1. Add a new file named `Frontegg.plist` to your root project directory.
2. Add the following content:

```xml
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>baseUrl</key>
        <string>https://{{FRONTEGG_BASE_URL}}</string>
        <key>clientId</key>
        <string>{{FRONTEGG_CLIENT_ID}}</string>
    </dict>
</plist>
```

- Replace `{{FRONTEGG_BASE_URL}}` with the domain name from your Frontegg Portal.
- Replace `{{FRONTEGG_CLIENT_ID}}` with your Frontegg client ID.

### Handle open app with URL

To support login via magic link and other authentication methods that require your app to open from
a URL, add the following code to your app.

#### `For Objective-C:`

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

4. Register your domain with Frontegg:

**NOTE**: Make youre you have
a [vendor token to access Frontegg APIs](https://docs.frontegg.com/reference/getting-started-with-your-api).

a. Open your terminal or API tool (such as Postman or cURL).
b. Send a `POST` request to the following endpoint:
`https://api.frontegg.com/vendors/resources/associated-domains/v1/ios`.
c. Include the following JSON payload in the request body:

```json
{
  "appId": "{{ASSOCIATED_DOMAIN}}"
}
```

d. Replace `{{ASSOCIATED_DOMAIN}}` with the actual associated domain you want to use for the iOS
app.
e. Repeat this step for each Frontegg environment where you want to support URL-based app opening.

#### `For Swift:`

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