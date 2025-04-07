import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

void main() {
  group('FronteggException.fromFailureReason', () {
    test('returns correct exception for each known failureReason', () {
      final cases = {
        "couldNotExchangeToken": CouldNotExchangeTokenException,
        "failedToAuthenticate": FailedToAuthenticateException,
        "frontegg.error.failed_to_authenticate": FailedToAuthenticateException,
        "failedToRefreshToken": FailedToRefreshTokenException,
        "failedToLoadUserData": FailedToLoadUserDataException,
        "failedToExtractCode": FailedToExtractCodeException,
        "failedToSwitchTenant": FailedToSwitchTenantException,
        "codeVerifierNotFound": CodeVerifierNotFoundException,
        "couldNotFindRootViewController": CouldNotFindRootViewControllerException,
        "invalidPasskeysRequest": InvalidPasskeysRequestException,
        "failedToAuthenticateWithPasskeys": FailedToAuthenticateWithPasskeysException,
        "operationCanceled": OperationCanceledException,
        "mfaRequired": MfaRequiredException,
        "frontegg.error.mfa_required": MfaRequiredException,
        "notAuthenticated": NotAuthenticatedException,
        "frontegg.error.not_authenticated_error": NotAuthenticatedException,
        "failedToMFA": FailedToMFAException,
        "invalidResponse": InvalidResponseException,
        "other": OtherException,
        "frontegg.error.canceled_by_user": CanceledByUserException,
        "frontegg.error.cookie_not_found": CookieNotFoundException,
        "frontegg.error.key_not_found_shared_preferences": KeyNotFoundSharedPreferencesException,
        "frontegg.error.failed_to_register_wbeauthn_error": FailedToRegisterWbeauthnException,
        "frontegg.error.mfa_not_enrolled": MfaNotEnrolledException,
        "unknown": UnknownException,
        "frontegg.error.unknown": UnknownException,
        "someRandomError": UnknownException,
      };

      for (final entry in cases.entries) {
        final failureReason = entry.key;
        final expectedType = entry.value;

        final exception =
            FronteggException.fromFailureReason(failureReason, message: 'Test message');

        expect(exception, isA<FronteggException>());
        expect(exception.runtimeType, expectedType);
      }
    });
  });
}
