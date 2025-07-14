# Project setup

This section guides you through configuring the Frontegg Flutter SDK for both iOS and Android, including required project files, authentication callbacks, and platform-specific settings.


## Configure iOS associated domains

This configuration is required for magic link authentication, password resets, and account
activation.

1. Obtain an environment token by
   following [these instructions](https://developers.frontegg.com/api/vendor-service)

2. Send a `POST` request to:

```
https://api.frontegg.com/vendors/resources/associated-domains/v1/ios
```

Request body:

```json
{
  "appId": "{{ASSOCIATED_DOMAIN}}"
}
```

3. Add associated domains capability to your iOS app:

    - Select your app target in Xcode
    - Go to "Signing & Capabilities"
    - Click "+ Capability" and select "Associated Domains"
    - Add `applinks:{{ASSOCIATED_DOMAIN}}`
    - Add `webcredentials:{{ASSOCIATED_DOMAIN}}` (required when Passkeys APIs are used)

To review the associated domains configuration, you may send a `GET` request to the same endpoint:

```
https://api.frontegg.com/vendors/resources/associated-domains/v1/ios
```

To update the configuration, first `DELETE` the existing configuration using its configuration ID,
then create a new configuration via `POST`. For example:

```
https://api.frontegg.com/vendors/resources/associated-domains/v1/ios/{{configurationId}} 
```

## Configure Android AssetLinks

To enable Android features like Magic Link authentication, password reset, account activation, and
login with identity providers, follow the steps below.

**NOTE**: Make youre you have
a [vendor token to access Frontegg APIs](https://docs.frontegg.com/reference/getting-started-with-your-api).

1. Send a `POST` request to the following Frontegg endpoint:

```
https://api.frontegg.com/vendors/resources/associated-domains/v1/android
```

2. Use the following payload:

```json
{
  "packageName": "YOUR_APPLICATION_PACKAGE_NAME",
  "sha256CertFingerprints": [
    "YOUR_KEYSTORE_CERT_FINGERPRINTS"
  ]
}
```

3. Get your `sha256CertFingerprints`. Each Android app has multiple certificate fingerprints. You
   must extract at least the one for `DEBUG` and optionally for `RELEASE`.

**For Debug mode:**

1. Open a terminal in your project root.
2. Run the following command:

``` bash
  ./gradlew signingReport
```

3. Look for the section with:

``` bash
Variant: debug
Config: debug
```

4. Copy the SHA-256 value from the output. Make sure the `Variant` and `Config` both equal `debug`.

Example output:

``` bash
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

**For Release mode:**

1. Run the following command (customize the path and credentials):

``` bash
keytool -list -v -keystore /PATH/file.jks -alias YourAlias -storepass *** -keypass ***
```

2. Copy the `SHA-256` value from the output.



## Using biometric authentication

### Android setup

1. **Update Gradle Dependencies**:
   Add the following dependencies in your `android/build.gradle`:
```groovy
dependencies {
    implementation 'androidx.browser:browser:1.8.0'
    implementation 'com.frontegg.sdk:android:1.2.47'
}
```

2. **Java Compatibility**: 
    Ensure sourceCompatibility and targetCompatibility are set to Java 8 in android/app/build.gradle**:
```groovy
android {
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

### iOS setup

1. **Set up the Associated Domains Capability**:
   - Open your project in Xcode.
   - Go to the **Signing & Capabilities** tab.
   - Add **Associated Domains** under the **+ Capability** section.
   - Enter the domain for your app in the format:
```
webcredentials:[YOUR_DOMAIN]
```
Example:
```
webcredentials:example.com
```

2. **Host the WebAuthn Configuration File**:
   - Add a `.well-known/webauthn` JSON file to your domain server with the following structure:
```json
{
  "origins": [
    "https://example.com",
    "https://subdomain.example.com"
  ]
}
```
   - Ensure this file is publicly accessible at `https://example.com/.well-known/webauthn`.

3. **Test Associated Domains**:
   - Verify that your associated domain configuration works using Apple's [Associated Domains Validator](https://developer.apple.com/contact/request/associated-domains).
