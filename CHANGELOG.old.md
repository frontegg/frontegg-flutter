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