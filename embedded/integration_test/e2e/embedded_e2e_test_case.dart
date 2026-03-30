import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter_embedded_example/e2e_test_mode.dart';
import 'package:frontegg_flutter_embedded_example/main.dart';
import 'package:patrol/patrol.dart';

import 'local_mock_auth_server.dart';

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
    await $.pumpAndSettle(timeout: const Duration(seconds: 25));
  }

  Future<void> waitForLoginPage(PatrolIntegrationTester $, {Duration timeout = const Duration(seconds: 20)}) async {
    await waitForSemantics($, 'LoginPageRoot', timeout: timeout);
  }

  Future<void> waitForUserEmail(PatrolIntegrationTester $, String email, {Duration timeout = const Duration(seconds: 30)}) async {
    await waitForSemantics($, 'UserPageRoot', timeout: timeout);
    await waitForText($, email, timeout: timeout);
  }

  Future<void> tapSemantics(PatrolIntegrationTester $, String label, {Duration timeout = const Duration(seconds: 10)}) async {
    await _waitForSemantics($, label, timeout: timeout);
    final finder = find.bySemanticsLabel(label);
    await $.tap(finder.first);
    await $.pumpAndSettle();
  }

  Future<void> loginWithPassword(PatrolIntegrationTester $) async {
    await waitForLoginPage($);
    await tapSemantics($, 'E2EEmbeddedPasswordButton');
    await Future.delayed(const Duration(seconds: 2));
    await tapWebButtonIfPresent($, 'Sign in', timeout: const Duration(seconds: 55));
  }

  Future<void> tapLogout(PatrolIntegrationTester $) async {
    await tapSemantics($, 'LogoutButton');
  }

  int oauthRefreshRequestCount() {
    const paths = ['/oauth/token', '/frontegg/identity/resources/auth/v1/user/token/refresh'];
    return paths.fold(0, (sum, p) => sum + mock.requestCount(null, p));
  }

  Future<int> accessTokenVersion(PatrolIntegrationTester $, {Duration timeout = const Duration(seconds: 10)}) async {
    await _waitForSemantics($, 'AccessTokenVersionValue', timeout: timeout);
    final widget = find.bySemanticsLabel('AccessTokenVersionValue');
    final textWidget = widget.evaluate().first.widget;
    if (textWidget is Text) {
      return int.tryParse(textWidget.data ?? '0') ?? 0;
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
      await $.pump(const Duration(milliseconds: 350));
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
      await $.pump(const Duration(milliseconds: 250));
      final found = find.textContaining(fragment).evaluate().isNotEmpty;
      if (found) return true;
    }
    return false;
  }

  Future<void> waitDurationSeconds(int seconds) async {
    await Future.delayed(Duration(seconds: seconds));
  }

  Future<void> waitForSemantics(PatrolIntegrationTester $, String label, {Duration timeout = const Duration(seconds: 20)}) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await $.pump(const Duration(milliseconds: 250));
      if (find.bySemanticsLabel(label).evaluate().isNotEmpty) return;
    }
    throw AssertionError('Timeout waiting for semantics label=$label');
  }

  Future<void> waitForText(PatrolIntegrationTester $, String text, {Duration timeout = const Duration(seconds: 20)}) async {
    final deadline = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(deadline)) {
      await $.pump(const Duration(milliseconds: 250));
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
        throw AssertionError('Web/UI button not found: $text');
      }
    }
  }
}
