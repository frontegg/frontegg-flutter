# Advanced options

In this guide, you'll find an overview and best practices for enabling advanced features like passkeys and multi-app configurations.

## iOS

### Multi-app support

If your Frontegg workspace supports multiple apps, you need to specify which one your iOS client should use.

To enable this feature, add `applicationId` to `Frontegg.plist` as follows:

```xml
<plist version="1.0">
  <dict>
    <key>applicationId</key>
    <string>{{FRONTEGG_APPLICATION_ID}}</string>

    <key>baseUrl</key>
    <string>{{FRONTEGG_BASE_URL}}</string>

    <key>clientId</key>
    <string>{{FRONTEGG_CLIENT_ID}}</string>
  </dict>
</plist>
```

- Replace `{{FRONTEGG_APPLICATION_ID}}` with your application ID.
- Replace `{{FRONTEGG_BASE_URL}}` with the domain name from your Frontegg Portal.
- Replace `{{FRONTEGG_CLIENT_ID}}` with your Frontegg client ID.


### Custom loader

To customize the loader for iOS when using Embedded mode, you can set up a custom loader by modifying your `AppDelegate.swift` file. The custom loader will be displayed during authentication processes.

First, ensure that Embedded mode is enabled in your configuration.

```xml
 <plist version="1.0">
<dict>
	<key>embeddedMode</key>
	<true/>
	...
</dict>
</plist>
```

Here's how to implement a custom loader:

```swift
import SwiftUI
import FronteggSwift

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
         ...
        // Setup Loader for Frontegg Embedded Loading
        // Can be any view
        DefaultLoader.customLoaderView = AnyView(Text("Loading..."))
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    ...
}
```

## Android

### Multi-app support

1. Open the `android/app/build.gradle` file in your project.
2. Add the following variable at the top of the file (outside the android block):

```groovy
def fronteggApplicationId = "{{FRONTEGG_APPLICATION_ID}}"
```

3. Inside the `android { defaultConfig { } }` block, add the following line:

```groovy
buildConfigField "String", "FRONTEGG_APPLICATION_ID", "\"$fronteggApplicationId\""
```

### Custom loader

To customize the loader for Android when using Embedded Activity mode, you can set up a custom loader by modifying your `MainActivity.kt` file. The custom loader will be displayed during authentication processes.

First, ensure that Embedded Activity mode is enabled in your configuration.

Here's how to implement a custom loader:

```groovy
import android.content.res.ColorStateList
import android.graphics.Color
import android.os.Bundle
import android.widget.ProgressBar
import com.frontegg.android.ui.DefaultLoader
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // Setup Loader for Frontegg Embedded Activity Loading
    DefaultLoader.setLoaderProvider {
      // Can be any view
      val progressBar = ProgressBar(it)
      val colorStateList = ColorStateList.valueOf(Color.GREEN)
      progressBar.indeterminateTintList = colorStateList

      progressBar
    }
  }
}
```

### Step-up authentication

Step-up authentication allows you to temporarily elevate a user's authentication level to perform sensitive actions. This is useful for operations like updating credentials, accessing confidential data, or performing secure transactions.


`maxAge` (optional): How long the elevated session is considered valid, in seconds.

`completion`: A closure called after authentication finishes. If step-up fails, it receives an error.

#### `stepUp`

Starts the step-up authentication flow. This will usually trigger a stronger authentication method ( e.g. biometric, MFA, etc).

```
await stepUp(maxAge: Duration(minutes: 5));
```

#### `isSteppedUp`

This method checks if the user has recently completed a step-up authentication and whether it is still valid.

```
final isElevated = await isSteppedUp(maxAge: Duration(minutes: 5));
if (isElevated) {
    // Proceed with sensitive action
} else {
    // Prompt user to step up
}
```

**Example:**

```
Future<void> performSensitiveAction() async {
    final steppedUp = await isSteppedUp(maxAge: Duration(minutes: 5));
      
    if (!steppedUp) {
        await stepUp(maxAge: Duration(minutes: 5));
    }
      
    // Continue with the sensitive action
}
```
