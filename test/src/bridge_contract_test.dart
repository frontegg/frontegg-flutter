import "dart:io";

import "package:flutter/foundation.dart";
import "package:flutter/services.dart";
import "package:flutter_test/flutter_test.dart";
import "package:frontegg_flutter/src/frontegg_method_channel.dart";

const _androidSources = "android/src/main/kotlin/com/frontegg/flutter";
const _iosSources = "ios/frontegg_flutter/Sources/frontegg_flutter";

// The Android SDK's directLoginAction(activity, type, data) takes no session or query parameters.
const _androidIgnoredArguments = {
  "directLoginAction": {"ephemeralSession", "additionalQueryParams"},
  "directLogin": {"ephemeralSession", "additionalQueryParams"},
};

// FronteggSwift has no asset-links or Chrome Custom Tabs settings.
const _iosMissingConstants = {"useAssetsLinks", "useChromeCustomTabs"};

String _read(String path) => File(path).readAsStringSync();

String _balancedFrom(String source, int start, String open, String close) {
  final openIndex = source.indexOf(open, start);
  var depth = 0;
  for (var index = openIndex; index < source.length; index++) {
    if (source[index] == open) depth++;
    if (source[index] == close && --depth == 0) {
      return source.substring(openIndex, index + 1);
    }
  }
  throw StateError("Unbalanced `$open` after offset $start");
}

String _functionBody(String source, String declaration) {
  final start = source.indexOf(declaration);
  if (start < 0) throw StateError("`$declaration` not found");
  final paramsEnd = start + _balancedFrom(source, start, "(", ")").length;
  final braceIndex = source.indexOf("{", paramsEnd);
  final expressionIndex = source.indexOf("=", paramsEnd);
  final isExpressionBody =
      expressionIndex >= 0 && (braceIndex < 0 || expressionIndex < braceIndex);
  return isExpressionBody
      ? _balancedFrom(source, expressionIndex, "(", ")")
      : _balancedFrom(source, paramsEnd, "{", "}");
}

Set<String> _matches(String pattern, String text) =>
    RegExp(pattern).allMatches(text).map((match) => match.group(1)!).toSet();

Map<String, Set<String>> _androidArgumentKeysByMethod(String source) {
  final dispatch =
      _balancedFrom(source, source.indexOf("when (call.method)"), "{", "}");
  return {
    for (final route in RegExp(r'"(\w+)"\s*->\s*(\w+)\(').allMatches(dispatch))
      route.group(1)!: _matches(
        r'argument<[^(]*\("(\w+)"\)',
        _functionBody(source, "fun ${route.group(2)}("),
      ),
  };
}

Map<String, Set<String>> _iosArgumentKeysByMethod(String source) {
  final dispatch =
      _balancedFrom(source, source.indexOf("switch call.method"), "{", "}");
  return {
    for (final route in RegExp(r'case "(\w+)":\s*(\w+)\(').allMatches(dispatch))
      route.group(1)!: route.group(2) == "result"
          ? <String>{}
          : _matches(
              r'arguments\??\["(\w+)"\]',
              _functionBody(source, "func ${route.group(2)}("),
            ),
  };
}

Set<String> _dartKeysRead(String modelFile, String factory) => _matches(
      r'map\["(\w+)"\]',
      _functionBody(_read("lib/src/models/$modelFile"), "factory $factory("),
    );

Set<String> _kotlinKeysWritten(String file, String declaration) => _matches(
      r'"(\w+)"\s*(?:to\b|,)',
      _functionBody(_read("$_androidSources/$file"), declaration),
    );

Set<String> _swiftKeysWritten(String file, String declaration) => _matches(
      r'"(\w+)"\s*:',
      _functionBody(_read("$_iosSources/$file"), declaration),
    );

Future<Map<String, Set<String>>> _recordDartArgumentKeys() async {
  const channel = MethodChannel(FronteggMethodChannel.methodChannelName);
  final keysByMethod = <String, Set<String>>{};
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (call) async {
    final arguments = call.arguments as Map<Object?, Object?>?;
    keysByMethod[call.method] = arguments?.keys.cast<String>().toSet() ?? {};
    return null;
  });

  final platform = FronteggMethodChannel();
  const queryParams = {"prompt": "login"};
  await platform.login(loginHint: "user@example.com");
  await platform.registerPasskeys();
  await platform.loginWithPasskeys();
  await platform.switchTenant("tenant-1");
  await platform.directLoginAction("social-login", "google",
      ephemeralSession: false, additionalQueryParams: queryParams);
  await platform.directLogin(
      url: "https://example.com",
      ephemeralSession: false,
      additionalQueryParams: queryParams);
  await platform.socialLogin(
      provider: "google",
      ephemeralSession: false,
      additionalQueryParams: queryParams);
  await platform.customSocialLogin(
      id: "provider-1",
      ephemeralSession: false,
      additionalQueryParams: queryParams);
  await platform.refreshToken();
  await platform.getOrRefreshAccessToken();
  await platform.initWithRegion("eu");
  await platform.logout();
  await platform.getConstants();
  await platform.requestAuthorize(
      refreshToken: "refresh-token", deviceTokenCookie: "device-cookie");
  await platform.isSteppedUp(maxAge: const Duration(minutes: 5));
  await platform.stepUp(maxAge: const Duration(minutes: 5));
  await platform.forceStateUpdate();
  await platform.getFeatureEntitlement("feature-1");
  await platform.getPermissionEntitlement("permission-1");
  await platform.loadEntitlements(forceRefresh: true);
  await platform.openAdminPortal();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null);
  return keysByMethod;
}

List<String> _argumentMismatches(
  Map<String, Set<String>> dartKeysByMethod,
  Map<String, Set<String>> nativeKeysByMethod,
  Map<String, Set<String>> ignoredArguments,
) =>
    [
      for (final method in dartKeysByMethod.keys)
        if (!setEquals(
          nativeKeysByMethod[method],
          dartKeysByMethod[method]!.difference(ignoredArguments[method] ?? {}),
        ))
          "$method: Dart sends ${dartKeysByMethod[method]}, native reads ${nativeKeysByMethod[method]}",
    ];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, Set<String>> dartKeysByMethod;
  final androidKeysByMethod = _androidArgumentKeysByMethod(
      _read("$_androidSources/FronteggMethodCallHandler.kt"));
  final iosKeysByMethod = _iosArgumentKeysByMethod(
      _read("$_iosSources/FronteggMethodCallHandler.swift"));

  setUpAll(() async {
    dartKeysByMethod = await _recordDartArgumentKeys();
  });

  group("argument bridging", () {
    test("Android handles exactly the methods Dart calls", () {
      expect(androidKeysByMethod.keys.toSet(), dartKeysByMethod.keys.toSet());
    });

    test("iOS handles exactly the methods Dart calls", () {
      expect(iosKeysByMethod.keys.toSet(), dartKeysByMethod.keys.toSet());
    });

    test("Android reads exactly the arguments Dart sends", () {
      expect(
        _argumentMismatches(
            dartKeysByMethod, androidKeysByMethod, _androidIgnoredArguments),
        isEmpty,
      );
    });

    test("iOS reads exactly the arguments Dart sends", () {
      expect(_argumentMismatches(dartKeysByMethod, iosKeysByMethod, const {}),
          isEmpty);
    });
  });

  group("return shapes", () {
    final shapes = {
      "constants": (
        dart: _dartKeysRead(
            "frontegg_constants.dart", "FronteggConstants.fromMap"),
        android: _kotlinKeysWritten(
            "FronteggMethodCallHandler.kt", "fun buildFronteggConstants("),
        ios: _swiftKeysWritten(
                "FronteggMethodCallHandler.swift", "func constantsToExport(")
            .union(_iosMissingConstants),
      ),
      "state": (
        dart: _dartKeysRead("frontegg_state.dart", "FronteggState.fromMap"),
        android:
            _kotlinKeysWritten("stateListener/FronteggState.kt", "fun toMap("),
        ios: _swiftKeysWritten(
            "stateListener/FronteggState.swift", "func toMap("),
      ),
      "region": (
        dart: _dartKeysRead(
            "frontegg_region_config.dart", "FronteggRegionConfig.fromMap"),
        android:
            _kotlinKeysWritten("Parser.kt", "fun RegionConfig.toReadableMap("),
        ios: _swiftKeysWritten("RegionConfig+Map.swift", "func toMap("),
      ),
      "entitlement": (
        dart: _dartKeysRead("entitlement.dart", "Entitlement.fromMap"),
        android: _kotlinKeysWritten(
            "FronteggMethodCallHandler.kt", "fun entitlementToMap("),
        ios: _swiftKeysWritten(
            "FronteggMethodCallHandler.swift", "func entitlementToDict("),
      ),
    };

    for (final shape in shapes.entries) {
      test("Android sends every ${shape.key} field Dart reads", () {
        expect(shape.value.dart.difference(shape.value.android), isEmpty);
      });

      test("iOS sends every ${shape.key} field Dart reads", () {
        expect(shape.value.dart.difference(shape.value.ios), isEmpty);
      });
    }
  });
}
