import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patrol/patrol.dart';

import 'embedded_e2e_test_case.dart';

Finder _semFinder(String label) => find.byWidgetPredicate(
      (w) => w is Semantics && w.properties.label == label,
      description: 'Semantics(label: "$label")',
    );

const _e2eTestFilter = String.fromEnvironment('E2E_TEST_FILTER');

/// When set (e.g. CI shards), only listed tests are registered. Supports a single
/// name or a comma-separated list so one `patrol test` run can execute a whole shard
/// without rebuilding the integration test target four times.
bool _e2eFilterAllows(String name) {
  if (_e2eTestFilter.isEmpty) return true;
  for (final raw in _e2eTestFilter.split(',')) {
    final part = raw.trim();
    if (part.isEmpty) continue;
    if (part == name) return true;
  }
  return false;
}

void e2ePatrolTest(String name, PatrolTesterCallback callback) {
  if (!_e2eFilterAllows(name)) return;
  patrolTest(name, callback);
}

/// Full embedded E2E suite mirroring Swift `DemoEmbeddedE2ETests` and
/// Kotlin `EmbeddedE2ETests`.
void main() {
  // Prevent Google Fonts from making HTTP requests during tests — the
  // emulator/simulator often has no internet, and a failed font fetch
  // throws an exception during teardown that marks the test as failed.
  GoogleFonts.config.allowRuntimeFetching = false;

  final tc = EmbeddedE2ETestCase();

  const expiringAccessTokenTTL = 21;
  const longLivedRefreshTokenTTL = 120;

  patrolSetUp(() async {
    await tc.setUp();
  });

  patrolTearDown(() async {
    await tc.tearDown();
  });

  e2ePatrolTest('testPasswordLoginAndSessionRestore', ($) async {
    await tc.launchApp($);
    await tc.loginWithPassword($);
    await tc.launchApp($, resetState: false);
    await Future.delayed(const Duration(milliseconds: 1500));
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 180));
  });

  e2ePatrolTest('testEmbeddedSamlLogin', ($) async {
    await tc.launchApp($);
    await tc.waitForLoginPage($);
    await tc.tapSemantics($, 'E2EEmbeddedSAMLButton');
    await tc.tapWebButtonIfPresent($, 'Login With Okta');
    await tc.waitForUserEmail(
      $,
      'test@saml-domain.com',
      timeout: const Duration(seconds: 90),
      awaitingUserPageAfterEmbeddedWebView: true,
    );
  });

  e2ePatrolTest('testEmbeddedOidcLogin', ($) async {
    await tc.launchApp($);
    await tc.waitForLoginPage($);
    await tc.tapSemantics($, 'E2EEmbeddedOIDCButton');
    await tc.tapWebButtonIfPresent($, 'Login With Okta');
    await tc.waitForUserEmail(
      $,
      'test@oidc-domain.com',
      timeout: const Duration(seconds: 90),
      awaitingUserPageAfterEmbeddedWebView: true,
    );
  });

  e2ePatrolTest('testRequestAuthorizeFlow', ($) async {
    await tc.launchApp($);
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 35));
    await tc.tapSemantics($, 'E2ESeedRequestAuthorizeTokenButton');
    await Future.delayed(const Duration(seconds: 2));
    await tc.tapSemantics($, 'RequestAuthorizeButton');
    await tc.waitForUserEmail($, 'signup@frontegg.com', timeout: const Duration(seconds: 120));
  });

  e2ePatrolTest('testCustomSSOBrowserHandoff', ($) async {
    await tc.launchApp($);
    await tc.waitForLoginPage($);
    await tc.tapSemantics($, 'E2ECustomSSOButton');
    await Future.delayed(const Duration(milliseconds: 4500));
    await tc.waitForUserEmail(
      $,
      'custom-sso@frontegg.com',
      timeout: const Duration(seconds: 60),
      awaitingUserPageAfterEmbeddedWebView: true,
    );
  });

  e2ePatrolTest('testDirectSocialBrowserHandoff', ($) async {
    await tc.launchApp($);
    await tc.waitForLoginPage($);
    await tc.tapSemantics($, 'E2EDirectSocialLoginButton');
    await Future.delayed(const Duration(seconds: 6));
    await tc.waitForUserEmail(
      $,
      'social-login@frontegg.com',
      timeout: const Duration(seconds: 90),
      awaitingUserPageAfterEmbeddedWebView: true,
    );
  });

  e2ePatrolTest('testEmbeddedGoogleSocialLoginWithSystemWebAuthenticationSession', ($) async {
    await tc.launchApp($);
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 40));
    await tc.tapSemantics($, 'E2EEmbeddedGoogleSocialButton');
    await Future.delayed(const Duration(seconds: 32));
    await tc.waitForUserEmail(
      $,
      'google-social@frontegg.com',
      timeout: const Duration(seconds: 150),
      awaitingUserPageAfterEmbeddedWebView: true,
    );
  });

  e2ePatrolTest('testEmbeddedGoogleSocialLoginOAuthErrorShowsToastAndKeepsLoginOpen', ($) async {
    tc.mock.queueEmbeddedSocialSuccessOAuthError(
      'ER-05001',
      'JWT token size exceeded the maximum allowed size. Please contact support to reduce token payload size.',
    );
    await tc.launchApp($);
    await tc.waitForLoginPage($);
    await tc.tapSemantics($, 'E2EEmbeddedGoogleSocialButton');
    await Future.delayed(const Duration(seconds: 24));
    final found = await tc.waitForA11yTextContains(
      $,
      'ER-05001',
      timeout: const Duration(seconds: 65),
    );
    expect(found, isTrue, reason: 'Expected error text in UI');
  });

  e2ePatrolTest('testColdLaunchTransientProbeTimeoutsDoNotBlinkNoConnectionPage', ($) async {
    tc.mock.queueProbeTimeouts(count: 2);
    await tc.launchApp($);
    await tc.waitForLoginPage($);
    await Future.delayed(const Duration(milliseconds: 2100));
    expect(
      _semFinder('NoConnectionPageRoot').evaluate().isEmpty,
      isTrue,
      reason: 'Unexpected NoConnection overlay',
    );
  });

  e2ePatrolTest('testLogoutTerminateTransientProbeFailureDoesNotBlinkNoConnectionPage', ($) async {
    await tc.launchApp($);
    await tc.loginWithPassword($);
    await tc.tapLogout($);
    await tc.waitForLoginPage($);
    tc.mock.queueProbeFailures([503, 503]);
    await tc.launchApp($, resetState: false);
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 50));
    await Future.delayed(const Duration(milliseconds: 3500));
  });

  e2ePatrolTest('testAuthenticatedOfflineModeWhenNetworkPathUnavailable', ($) async {
    await tc.launchApp($);
    await tc.loginWithPassword($);
    final initialVersion = await tc.accessTokenVersion($);
    await tc.launchApp($, resetState: false, forceNetworkPathOffline: true);
    await tc.waitForUserEmail(
      $,
      'test@frontegg.com',
      timeout: const Duration(seconds: 90),
    );
    await tc.waitForSemantics($, 'AuthenticatedOfflineModeEnabled', timeout: const Duration(seconds: 10));
    await tc.waitForSemantics($, 'OfflineModeBadge', timeout: const Duration(seconds: 10));
    expect(await tc.accessTokenVersion($), equals(initialVersion));
    expect(
      _semFinder('RetryConnectionButton').evaluate().isEmpty,
      isTrue,
      reason: 'Did not expect Retry button',
    );
  });

  e2ePatrolTest('testExpiredAccessTokenRefreshesOnAuthenticatedRelaunch', ($) async {
    tc.mock.configureTokenPolicy(
      email: 'test@frontegg.com',
      accessTTL: expiringAccessTokenTTL,
      refreshTTL: longLivedRefreshTokenTTL,
    );
    await tc.launchApp($);
    await tc.loginWithPassword($);
    final v0 = await tc.accessTokenVersion($);
    final rc0 = tc.oauthRefreshRequestCount();
    await tc.waitDurationSeconds(expiringAccessTokenTTL + 6);
    await tc.launchApp($, resetState: false);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 120));
    await tc.waitForAccessTokenVersionChange($, v0, timeout: const Duration(seconds: 150));
    expect(tc.oauthRefreshRequestCount(), greaterThan(rc0));
  });

  e2ePatrolTest('testAuthenticatedOfflineModeRecoversToOnlineAndRefreshesToken', ($) async {
    await tc.launchApp($);
    await tc.loginWithPassword($);
    final v0 = await tc.accessTokenVersion($);
    await tc.launchApp($, resetState: false, forceNetworkPathOffline: true);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 120));
    await tc.waitForSemantics($, 'OfflineModeBadge', timeout: const Duration(seconds: 75));
    await tc.launchApp($, resetState: false);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 120));
    await Future.delayed(const Duration(seconds: 18));
    await tc.waitForAccessTokenVersionChange($, v0, timeout: const Duration(seconds: 240));
  });

  e2ePatrolTest('testAuthenticatedOfflineModeKeepsUserLoggedInUntilReconnectRefreshesExpiredToken', ($) async {
    tc.mock.configureTokenPolicy(
      email: 'test@frontegg.com',
      accessTTL: expiringAccessTokenTTL,
      refreshTTL: longLivedRefreshTokenTTL,
    );
    await tc.launchApp($);
    await tc.loginWithPassword($);
    await tc.launchApp($, resetState: false, forceNetworkPathOffline: true);
    await tc.waitForUserEmail($, 'test@frontegg.com');
    await tc.waitForSemantics($, 'OfflineModeBadge', timeout: const Duration(seconds: 30));
    await tc.waitDurationSeconds(expiringAccessTokenTTL + 2);
    await tc.waitForSemantics($, 'AuthenticatedOfflineModeEnabled', timeout: const Duration(seconds: 10));
    final versionBeforeReconnect = await tc.accessTokenVersion($);
    await tc.launchApp($, resetState: false);
    await tc.waitForUserEmail($, 'test@frontegg.com');
    await tc.waitForAccessTokenVersionChange($, versionBeforeReconnect, timeout: const Duration(seconds: 75));
  });

  e2ePatrolTest('testLogoutTerminateTransientNoConnectionThenCustomSSORecovers', ($) async {
    await tc.launchApp($);
    await tc.loginWithPassword($);
    await tc.tapLogout($);
    await tc.waitForLoginPage($);
    tc.mock.queueProbeFailures([503]);
    await tc.launchApp($, resetState: false);
    await tc.waitForSemantics($, 'NoConnectionPageRoot', timeout: const Duration(seconds: 100));
    tc.mock.reset();
    await tc.tapSemantics($, 'RetryConnectionButton');
    await tc.tapSemantics($, 'E2ECustomSSOButton');
    await Future.delayed(const Duration(milliseconds: 5500));
    await tc.waitForUserEmail(
      $,
      'custom-sso@frontegg.com',
      timeout: const Duration(seconds: 90),
      awaitingUserPageAfterEmbeddedWebView: true,
    );
  });

  e2ePatrolTest('testColdLaunchWithOfflineModeDisabledReachesLoginQuickly', ($) async {
    tc.mock.queueProbeFailures([503, 503]);
    await tc.launchApp($, enableOfflineMode: false);
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 50));
    await Future.delayed(const Duration(milliseconds: 3500));
  });

  e2ePatrolTest('testOfflineModeDisabledPreservesSessionDuringConnectionLossAndRecovers', ($) async {
    await tc.launchApp($, enableOfflineMode: false);
    await tc.loginWithPassword($);
    tc.mock.queueConnectionDrops(path: '/oauth/token');
    await tc.launchApp($, resetState: false, enableOfflineMode: false);
    await tc.waitForUserEmail($, 'test@frontegg.com');
    await Future.delayed(const Duration(seconds: 2));
    tc.mock.reset();
  });

  e2ePatrolTest('testPasswordLoginWorksWithOfflineModeDisabled', ($) async {
    await tc.launchApp($, enableOfflineMode: false);
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 50));
    await tc.loginWithPassword(
      $,
      emailTimeout: const Duration(seconds: 90),
    );
  });

  e2ePatrolTest('testLogoutClearsSessionAndRelaunchShowsLogin', ($) async {
    await tc.launchApp($);
    await tc.loginWithPassword($);
    await tc.tapLogout($);
    await tc.waitForLoginPage($);
    await tc.launchApp($, resetState: false);
    await Future.delayed(const Duration(milliseconds: 1500));
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 60));
  });

  e2ePatrolTest('testExpiredRefreshTokenClearsSessionAndShowsLogin', ($) async {
    tc.mock.configureTokenPolicy(email: 'test@frontegg.com', accessTTL: 30, refreshTTL: 12);
    await tc.launchApp($);
    await tc.loginWithPassword($);
    await tc.waitDurationSeconds(18);
    await tc.launchApp($);
    await Future.delayed(const Duration(milliseconds: 2500));
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 60));
  });

  e2ePatrolTest('testScheduledTokenRefreshFiresBeforeExpiry', ($) async {
    tc.mock.configureTokenPolicy(
      email: 'test@frontegg.com',
      accessTTL: 45,
      refreshTTL: longLivedRefreshTokenTTL,
    );
    await tc.launchApp($);
    await tc.loginWithPassword($);
    final start = tc.oauthRefreshRequestCount();
    var sawRefresh = false;
    final deadline = DateTime.now().add(const Duration(seconds: 70));
    while (DateTime.now().isBefore(deadline)) {
      await Future.delayed(const Duration(seconds: 3));
      if (tc.oauthRefreshRequestCount() > start) {
        sawRefresh = true;
        break;
      }
    }
    expect(sawRefresh, isTrue, reason: 'Expected OAuth refresh before 45s access TTL on mock policy');
  });

  e2ePatrolTest('testAuthenticatedRelaunchWithExpiredAccessTokenAndFreshRefreshToken', ($) async {
    tc.mock.configureTokenPolicy(
      email: 'test@frontegg.com',
      accessTTL: expiringAccessTokenTTL,
      refreshTTL: longLivedRefreshTokenTTL,
    );
    await tc.launchApp($);
    await tc.loginWithPassword($);
    await tc.waitDurationSeconds(expiringAccessTokenTTL + 8);
    await tc.launchApp($, resetState: false);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 180));
  });
}
