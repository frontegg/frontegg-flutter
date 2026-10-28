# frontegg_flutter_example

Demonstrates how to use the frontegg_flutter plugin.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Multi-region mode

When the native SDK is configured with regions, the app shows a region picker (`lib/region_page.dart`)
before the login page, and selects the region with `initWithRegion()`. The mode is off by default.

- **Android**: set `FRONTEGG_MULTI_REGION` to `true` in `android/app/build.gradle`. `App.kt` then
  initializes the SDK with the `eu` region (`FRONTEGG_DOMAIN`) and the `us` region
  (`FRONTEGG_DOMAIN_2`).
- **iOS**: in `ios/Runner/Frontegg.plist`, replace the `baseUrl` and `clientId` keys with:

```xml
<key>regions</key>
<array>
    <dict>
        <key>key</key>
        <string>eu</string>
        <key>baseUrl</key>
        <string>https://app-x4gr8g28fxr5.frontegg.com</string>
        <key>clientId</key>
        <string>5f493de4-01c5-4a61-8642-fca650a6a9dc</string>
    </dict>
    <dict>
        <key>key</key>
        <string>us</string>
        <key>baseUrl</key>
        <string>https://authus.davidantoon.me</string>
        <key>clientId</key>
        <string>d7d07347-2c57-4450-8418-0ec7ee6e096b</string>
    </dict>
</array>
```

See [Multi-region support](../docs/advanced.md#multi-region-support) for the full setup.
