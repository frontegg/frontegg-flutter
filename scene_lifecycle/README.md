# scene_lifecycle

A Flutter app on the UIScene lifecycle, set up like `flutter create` 3.41 generates it:
`FlutterSceneDelegate` in `Info.plist`, an `AppDelegate` that registers plugins through
`FlutterImplicitEngineDelegate`, and go_router with a single route.

Its iOS tests check that a Frontegg link (for example a reset-password email link) reaches
the Frontegg SDK instead of the app's router, and that other links still reach the router:

- `RunnerTests`: a link delivered through `FlutterSceneDelegate` while the app is running.
- `RunnerUITests`: a cold launch from a link.

Run them on a simulator:

```bash
flutter build ios --debug --simulator --no-codesign
cd ios
xcodebuild test -workspace Runner.xcworkspace -scheme Runner \
  -destination "platform=iOS Simulator,name=iPhone 16"
```
