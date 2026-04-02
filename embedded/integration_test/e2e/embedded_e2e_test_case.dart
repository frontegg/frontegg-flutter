import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter_embedded_example/e2e_test_mode.dart';
import 'package:frontegg_flutter_embedded_example/main.dart';
import 'package:patrol/patrol.dart';

import 'local_mock_auth_server.dart';

/// Finds a [Semantics] widget whose [SemanticsProperties.label] equals [label].
///
/// Unlike [find.bySemanticsLabel], this does NOT rely on the compiled semantics
/// tree (RenderObject.debugSemantics), which may be null when the
/// sendSemanticsUpdate frame phase has not yet completed — a common situation
/// in [LiveTestWidgetsFlutterBinding] (integration tests).
Finder _semFinder(String label) {
  return find.byWidgetPredicate(
    (w) => w is Semantics && w.properties.label == label,
    description: 'Semantics(label: "$label")',
  );
}

/// Base harness for embedded mock-server E2E tests (Swift/Kotlin parity).
///
/// Provides lifecycle helpers, mock server management, and UI interaction
/// utilities that mirror `EmbeddedE2ETestCase` on both native platforms.
class EmbeddedE2ETestCase {
  late LocalMockAuthServer mock;

  Future<void> setUp() async {
    mock = LocalMockAuthServer();
    await mock.start();
  }

  Future<void> tearDown() async {
    await mock.shutdown();
  }

  Future<void> launchApp(
    PatrolIntegrationTester $, {
    bool resetState = true,
    bool forceNetworkPathOffline = false,
    bool? enableOfflineMode,
  }) async {
    await E2ETestMode.initializeForE2E(
      baseUrl: mock.urlRoot,
      clientId: mock.clientId,
      resetState: resetState,
      forceNetworkPathOffline: forceNetworkPathOffline,
      enableOfflineMode: enableOfflineMode,
    );

    await $.pumpWidget(const MyApp());
    await $.pump();

    // Poll until the SDK finishes initializing and the widget tree updates.
    // Future.delayed alone does not advance the test binding; bare pump() applies
    // one frame (safe during cold launch). Avoid pump(Duration), which can stall
    // when a modal webview is presented later in the flow.
    final deadline = DateTime.now().add(const Duration(seconds: 30));
    var settled = false;
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 300));
      await $.pump();
      if (_semFinder('LoginPageRoot').evaluate().isNotEmpty ||
          _semFinder('UserPageRoot').evaluate().isNotEmpty) {
        settled = true;
        break;
      }
    }
    if (!settled) {
      throw AssertionError(
        'launchApp: UI not ready after 30s — baseUrl=${mock.urlRoot}',
      );
    }
  }

  Future<void> waitForLoginPage(PatrolIntegrationTester $, {Duration timeout = const Duration(seconds: 20)}) async {
    await waitForSemantics($, 'LoginPageRoot', timeout: timeout);
  }

  /// When [awaitingUserPageAfterEmbeddedWebView] is true, skips [WidgetTester.pump]
  /// while waiting for [UserPageRoot] — pump can deadlock while a native embedded
  /// WebView is modal. Use false for in-app flows (e.g. [FronteggFlutter.requestAuthorize]).
  Future<void> waitForUserEmail(
    PatrolIntegrationTester $,
    String email, {
    Duration timeout = const Duration(seconds: 30),
    bool awaitingUserPageAfterEmbeddedWebView = false,
  }) async {
    await waitForSemantics(
      $,
      'UserPageRoot',
      timeout: timeout,
      pumpFrame: !awaitingUserPageAfterEmbeddedWebView,
    );
    await waitForText($, email, timeout: timeout);
  }

  Future<void> tapSemantics(PatrolIntegrationTester $, String label, {Duration timeout = const Duration(seconds: 10)}) async {
    await waitForSemantics($, label, timeout: timeout);
    final finder = _semFinder(label).first;
    await $.tester.ensureVisible(finder);
    await Future.delayed(const Duration(milliseconds: 300));
    await $.pump();
    await $.tester.tap(finder);
    // Do not pump() after tap: embedded login can present a native webview
    // immediately; WidgetTester.pump then blocks and never returns, so job hits CI timeout.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<void> loginWithPassword(
    PatrolIntegrationTester $, {
    Duration emailTimeout = const Duration(seconds: 60),
  }) async {
    await waitForLoginPage($);
    await tapSemantics($, 'E2EEmbeddedPasswordButton');
    await waitForUserEmail(
      $,
      'test@frontegg.com',
      timeout: emailTimeout,
      awaitingUserPageAfterEmbeddedWebView: true,
    );
  }

  Future<void> tapLogout(PatrolIntegrationTester $) async {
    await tapSemantics($, 'LogoutButton');
  }

  int oauthRefreshRequestCount() {
    const paths = ['/oauth/token', '/frontegg/identity/resources/auth/v1/user/token/refresh'];
    return paths.fold(0, (sum, p) => sum + mock.requestCount(null, p));
  }

  Future<int> accessTokenVersion(PatrolIntegrationTester $, {Duration timeout = const Duration(seconds: 10)}) async {
    await waitForSemantics($, 'AccessTokenVersionValue', timeout: timeout);
    final sem = _semFinder('AccessTokenVersionValue').evaluate().first;
    final textFinder = find.descendant(of: find.byWidget(sem.widget), matching: find.byType(Text));
    if (textFinder.evaluate().isNotEmpty) {
      final textWidget = textFinder.evaluate().first.widget;
      if (textWidget is Text) {
        return int.tryParse(textWidget.data ?? '0') ?? 0;
      }
    }
    return 0;
  }

  Future<int> waitForAccessTokenVersionChange(
    PatrolIntegrationTester $,
    int from, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 350));
      try {
        final v = await accessTokenVersion($, timeout: const Duration(seconds: 2));
        if (v != from) return v;
      } catch (_) {}
    }
    throw AssertionError('Token version did not change from $from');
  }

  Future<bool> waitForA11yTextContains(PatrolIntegrationTester $, String fragment, {Duration timeout = const Duration(seconds: 30)}) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 250));
      // No pump(): same embedded WebView / Custom Tab deadlock as UserPageRoot wait.
      final found = find.textContaining(fragment).evaluate().isNotEmpty;
      if (found) return true;
    }
    return false;
  }

  Future<void> waitDurationSeconds(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  Future<void> waitForSemantics(
    PatrolIntegrationTester $,
    String label, {
    Duration timeout = const Duration(seconds: 20),
    bool pumpFrame = true,
  }) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 250));
      if (pumpFrame) await $.pump();
      if (_semFinder(label).evaluate().isNotEmpty) return;
    }
    throw AssertionError('Timeout waiting for semantics label=$label');
  }

  Future<void> waitForText(PatrolIntegrationTester $, String text, {Duration timeout = const Duration(seconds: 20)}) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(milliseconds: 250));
      await $.pump();
      if (find.text(text).evaluate().isNotEmpty) return;
    }
    throw AssertionError('Timeout waiting for text=$text');
  }

  Future<void> tapWebButtonIfPresent(PatrolIntegrationTester $, String text, {Duration timeout = const Duration(seconds: 20)}) async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      await $.native.tap(Selector(text: text), timeout: timeout);
    } catch (_) {
      try {
        await $.native.tap(Selector(textContains: text), timeout: const Duration(seconds: 5));
      } catch (_) {
        // Button not found — likely already auto-submitted (e.g. password
        // login with prefilled credentials). This is expected behaviour.
      }
    }
  }
}
