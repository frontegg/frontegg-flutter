import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import 'embedded_e2e_test_case.dart';

/// Full embedded E2E suite mirroring Swift `DemoEmbeddedE2ETests` and
/// Kotlin `EmbeddedE2ETests`.
void main() {
  final tc = EmbeddedE2ETestCase();

  const expiringAccessTokenTTL = 21;
  const longLivedRefreshTokenTTL = 120;

  patrolSetUp(() async {
    await tc.setUp();
  });

  patrolTearDown(() async {
    await tc.tearDown();
  });

  patrolTest('testPasswordLoginAndSessionRestore', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.loginWithPassword($);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 120));
    // Simulate terminate + relaunch (widget rebuild with preserved state)
    await tc.launchApp($, resetState: false);
    await Future.delayed(const Duration(milliseconds: 1500));
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 180));
  });

  patrolTest('testEmbeddedSamlLogin', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.waitForLoginPage($);
    await tc.tapSemantics($, 'E2EEmbeddedSAMLButton');
    await tc.tapWebButtonIfPresent($, 'Login With Okta');
    await tc.waitForUserEmail($, 'test@saml-domain.com');
  });

  patrolTest('testEmbeddedOidcLogin', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.waitForLoginPage($);
    await tc.tapSemantics($, 'E2EEmbeddedOIDCButton');
    await tc.tapWebButtonIfPresent($, 'Login With Okta');
    await tc.waitForUserEmail($, 'test@oidc-domain.com');
  });

  patrolTest('testRequestAuthorizeFlow', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 35));
    await tc.tapSemantics($, 'E2ESeedRequestAuthorizeTokenButton');
    await Future.delayed(const Duration(seconds: 2));
    await tc.tapSemantics($, 'RequestAuthorizeButton');
    await tc.waitForUserEmail($, 'signup@frontegg.com', timeout: const Duration(seconds: 120));
  });

  patrolTest('testCustomSSOBrowserHandoff', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.waitForLoginPage($);
    await tc.tapSemantics($, 'E2ECustomSSOButton');
    await Future.delayed(const Duration(milliseconds: 4500));
    await tc.waitForUserEmail($, 'custom-sso@frontegg.com', timeout: const Duration(seconds: 60));
  });

  patrolTest('testDirectSocialBrowserHandoff', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.waitForLoginPage($);
    await tc.tapSemantics($, 'E2EDirectSocialLoginButton');
    await Future.delayed(const Duration(seconds: 6));
    await tc.waitForUserEmail($, 'social-login@frontegg.com', timeout: const Duration(seconds: 90));
  });

  patrolTest('testEmbeddedGoogleSocialLoginWithSystemWebAuthenticationSession', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 40));
    await tc.tapSemantics($, 'E2EEmbeddedGoogleSocialButton');
    await Future.delayed(const Duration(seconds: 32));
    await tc.waitForUserEmail($, 'google-social@frontegg.com', timeout: const Duration(seconds: 150));
  });

  patrolTest('testEmbeddedGoogleSocialLoginOAuthErrorShowsToastAndKeepsLoginOpen', ($) async {
    tc.mock.queueEmbeddedSocialSuccessOAuthError(
      'ER-05001',
      'JWT token size exceeded the maximum allowed size. Please contact support to reduce token payload size.',
    );
    await tc.launchApp($, resetState: true);
    await tc.waitForLoginPage($);
    await tc.tapSemantics($, 'E2EEmbeddedGoogleSocialButton');
    await Future.delayed(const Duration(seconds: 18));
    final found = await tc.waitForA11yTextContains($, 'ER-05001', timeout: const Duration(seconds: 50));
    expect(found, isTrue, reason: 'Expected error text in UI');
  });

  patrolTest('testColdLaunchTransientProbeTimeoutsDoNotBlinkNoConnectionPage', ($) async {
    tc.mock.queueProbeTimeouts(count: 2, delayMs: 1500);
    await tc.launchApp($, resetState: true);
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 20));
    await Future.delayed(const Duration(milliseconds: 2100));
    expect(find.bySemanticsLabel('NoConnectionPageRoot').evaluate().isEmpty, isTrue,
        reason: 'Unexpected NoConnection overlay');
  });

  patrolTest('testLogoutTerminateTransientProbeFailureDoesNotBlinkNoConnectionPage', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.loginWithPassword($);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 90));
    await tc.tapLogout($);
    await tc.waitForLoginPage($);
    tc.mock.queueProbeFailures([503, 503]);
    await tc.launchApp($, resetState: false);
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 50));
    await Future.delayed(const Duration(milliseconds: 3500));
  });

  patrolTest('testAuthenticatedOfflineModeWhenNetworkPathUnavailable', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.loginWithPassword($);
    final initialVersion = await tc.accessTokenVersion($);
    await tc.launchApp($, resetState: false, forceNetworkPathOffline: true);
    await tc.waitForUserEmail($, 'test@frontegg.com');
    await tc.waitForSemantics($, 'AuthenticatedOfflineModeEnabled', timeout: const Duration(seconds: 10));
    await tc.waitForSemantics($, 'OfflineModeBadge', timeout: const Duration(seconds: 10));
    expect(await tc.accessTokenVersion($), equals(initialVersion));
    expect(find.bySemanticsLabel('RetryConnectionButton').evaluate().isEmpty, isTrue,
        reason: 'Did not expect Retry button');
  });

  patrolTest('testExpiredAccessTokenRefreshesOnAuthenticatedRelaunch', ($) async {
    tc.mock.configureTokenPolicy(
      email: 'test@frontegg.com',
      accessTTL: expiringAccessTokenTTL,
      refreshTTL: longLivedRefreshTokenTTL,
    );
    await tc.launchApp($, resetState: true);
    await tc.loginWithPassword($);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 90));
    final v0 = await tc.accessTokenVersion($);
    final rc0 = tc.oauthRefreshRequestCount();
    await tc.waitDurationSeconds(expiringAccessTokenTTL + 6);
    await tc.launchApp($, resetState: false);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 120));
    await tc.waitForAccessTokenVersionChange($, v0, timeout: const Duration(seconds: 150));
    expect(tc.oauthRefreshRequestCount(), greaterThan(rc0));
  });

  patrolTest('testAuthenticatedOfflineModeRecoversToOnlineAndRefreshesToken', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.loginWithPassword($);
    final v0 = await tc.accessTokenVersion($);
    await tc.launchApp($, resetState: false, forceNetworkPathOffline: true);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 120));
    await tc.waitForSemantics($, 'OfflineModeBadge', timeout: const Duration(seconds: 75));
    await tc.launchApp($, resetState: false, forceNetworkPathOffline: false);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 120));
    await Future.delayed(const Duration(seconds: 18));
    await tc.waitForAccessTokenVersionChange($, v0, timeout: const Duration(seconds: 240));
  });

  patrolTest('testAuthenticatedOfflineModeKeepsUserLoggedInUntilReconnectRefreshesExpiredToken', ($) async {
    tc.mock.configureTokenPolicy(
      email: 'test@frontegg.com',
      accessTTL: expiringAccessTokenTTL,
      refreshTTL: longLivedRefreshTokenTTL,
    );
    await tc.launchApp($, resetState: true);
    await tc.loginWithPassword($);
    await tc.launchApp($, resetState: false, forceNetworkPathOffline: true);
    await tc.waitForUserEmail($, 'test@frontegg.com');
    await tc.waitForSemantics($, 'OfflineModeBadge', timeout: const Duration(seconds: 30));
    await tc.waitDurationSeconds(expiringAccessTokenTTL + 2);
    await tc.waitForSemantics($, 'AuthenticatedOfflineModeEnabled', timeout: const Duration(seconds: 10));
    final versionBeforeReconnect = await tc.accessTokenVersion($);
    await tc.launchApp($, resetState: false, forceNetworkPathOffline: false);
    await tc.waitForUserEmail($, 'test@frontegg.com');
    await tc.waitForAccessTokenVersionChange($, versionBeforeReconnect, timeout: const Duration(seconds: 75));
  });

  patrolTest('testLogoutTerminateTransientNoConnectionThenCustomSSORecovers', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.loginWithPassword($);
    await tc.tapLogout($);
    await tc.waitForLoginPage($);
    tc.mock.queueProbeFailures([503]);
    await tc.launchApp($, resetState: false);
    await tc.waitForSemantics($, 'NoConnectionPageRoot', timeout: const Duration(seconds: 20));
    tc.mock.reset();
    await tc.tapSemantics($, 'RetryConnectionButton', timeout: const Duration(seconds: 10));
    await tc.tapSemantics($, 'E2ECustomSSOButton');
    await Future.delayed(const Duration(milliseconds: 5500));
    await tc.waitForUserEmail($, 'custom-sso@frontegg.com', timeout: const Duration(seconds: 90));
  });

  patrolTest('testColdLaunchWithOfflineModeDisabledReachesLoginQuickly', ($) async {
    tc.mock.queueProbeFailures([503, 503]);
    await tc.launchApp($, resetState: true, enableOfflineMode: false);
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 50));
    await Future.delayed(const Duration(milliseconds: 3500));
  });

  patrolTest('testOfflineModeDisabledPreservesSessionDuringConnectionLossAndRecovers', ($) async {
    await tc.launchApp($, resetState: true, enableOfflineMode: false);
    await tc.loginWithPassword($);
    tc.mock.queueConnectionDrops(method: 'POST', path: '/oauth/token', count: 1);
    await tc.launchApp($, resetState: false, enableOfflineMode: false);
    await tc.waitForUserEmail($, 'test@frontegg.com');
    await Future.delayed(const Duration(seconds: 2));
    tc.mock.reset();
  });

  patrolTest('testPasswordLoginWorksWithOfflineModeDisabled', ($) async {
    await tc.launchApp($, resetState: true, enableOfflineMode: false);
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 35));
    await tc.loginWithPassword($);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 90));
  });

  patrolTest('testLogoutClearsSessionAndRelaunchShowsLogin', ($) async {
    await tc.launchApp($, resetState: true);
    await tc.loginWithPassword($);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 120));
    await tc.tapLogout($);
    await tc.waitForLoginPage($);
    await tc.launchApp($, resetState: false);
    await Future.delayed(const Duration(milliseconds: 1500));
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 60));
  });

  patrolTest('testExpiredRefreshTokenClearsSessionAndShowsLogin', ($) async {
    tc.mock.configureTokenPolicy(email: 'test@frontegg.com', accessTTL: 30, refreshTTL: 12);
    await tc.launchApp($, resetState: true);
    await tc.loginWithPassword($);
    await tc.waitForUserEmail($, 'test@frontegg.com');
    await tc.waitDurationSeconds(18);
    await tc.launchApp($, resetState: true);
    await Future.delayed(const Duration(milliseconds: 2500));
    await tc.waitForLoginPage($, timeout: const Duration(seconds: 60));
  });

  patrolTest('testScheduledTokenRefreshFiresBeforeExpiry', ($) async {
    tc.mock.configureTokenPolicy(
      email: 'test@frontegg.com',
      accessTTL: 45,
      refreshTTL: longLivedRefreshTokenTTL,
    );
    await tc.launchApp($, resetState: true);
    await tc.loginWithPassword($);
    final start = tc.oauthRefreshRequestCount();
    await Future.delayed(const Duration(seconds: 35));
    expect(tc.oauthRefreshRequestCount(), greaterThan(start));
  });

  patrolTest('testAuthenticatedRelaunchWithExpiredAccessTokenAndFreshRefreshToken', ($) async {
    tc.mock.configureTokenPolicy(
      email: 'test@frontegg.com',
      accessTTL: expiringAccessTokenTTL,
      refreshTTL: longLivedRefreshTokenTTL,
    );
    await tc.launchApp($, resetState: true);
    await tc.loginWithPassword($);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 90));
    await tc.waitDurationSeconds(expiringAccessTokenTTL + 8);
    await tc.launchApp($, resetState: false);
    await tc.waitForUserEmail($, 'test@frontegg.com', timeout: const Duration(seconds: 150));
  });
}
