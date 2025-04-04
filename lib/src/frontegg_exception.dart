/// Represents an exception that occurs within the Frontegg authentication system.
sealed class FronteggException implements Exception {
  /// The error message describing the exception, if available.
  final String failureReason;
  final String? message;

  /// Creates a [FronteggException] instance with an optional message.
  const FronteggException({
    this.failureReason = "unknown",
    this.message,
  });

  @override
  String toString() {
    return '$runtimeType{message: $message}';
  }

  factory FronteggException.fromFailureReason(
    String failureReason, {
    String? message,
  }) {
    switch (failureReason) {
      case "couldNotExchangeToken":
        return CouldNotExchangeTokenException(message);
      case "failedToAuthenticate":
      case "frontegg.error.failed_to_authenticate":
        return FailedToAuthenticateException(message);
      case "failedToRefreshToken":
        return FailedToRefreshTokenException(message);
      case "failedToLoadUserData":
        return FailedToLoadUserDataException(message);
      case "failedToExtractCode":
        return FailedToExtractCodeException(message);
      case "failedToSwitchTenant":
        return FailedToSwitchTenantException(message);
      case "codeVerifierNotFound":
        return CodeVerifierNotFoundException(message);
      case "couldNotFindRootViewController":
        return CouldNotFindRootViewControllerException(message);
      case "invalidPasskeysRequest":
        return InvalidPasskeysRequestException(message);
      case "failedToAuthenticateWithPasskeys":
        return FailedToAuthenticateWithPasskeysException(message);
      case "operationCanceled":
        return OperationCanceledException(message);
      case "mfaRequired":
      case "frontegg.error.mfa_required":
        return MfaRequiredException(message);
      case "notAuthenticated":
      case "frontegg.error.not_authenticated_error":
        return NotAuthenticatedException(message);
      case "failedToMFA":
        return FailedToMFAException(message);
      case "invalidResponse":
        return InvalidResponseException(message);
      case "other":
        return OtherException(message);
      case "frontegg.error.canceled_by_user":
        return CanceledByUserException(message);
      case "frontegg.error.cookie_not_found":
        return CookieNotFoundException(message);

      case "frontegg.error.key_not_found_shared_preferences":
        return KeyNotFoundSharedPreferencesException(message);
      case "frontegg.error.failed_to_register_wbeauthn_error":
        return FailedToRegisterWbeauthnException(message);
      case "frontegg.error.mfa_not_enrolled":
        return MfaNotEnrolledException(message);

      case "unknown":
      case "frontegg.error.unknown":
      default:
        return UnknownException(message);
    }
  }
}

/// Exception thrown when a key is not found in SharedPreferences storage.
/// This typically occurs when trying to access stored authentication data that doesn't exist.
class KeyNotFoundSharedPreferencesException extends FronteggException {
  const KeyNotFoundSharedPreferencesException([String? message])
      : super(
          failureReason: "keyNotFoundSharedPreferences",
          message: message,
        );
}

/// Exception thrown when WebAuthn registration process fails.
/// This can occur during passkey or biometric authentication setup.
class FailedToRegisterWbeauthnException extends FronteggException {
  const FailedToRegisterWbeauthnException([String? message])
      : super(
          failureReason: "failedToRegisterWbeauthn",
          message: message,
        );
}

/// Exception thrown when an operation requires authentication but the user is not authenticated.
/// This typically occurs when trying to access protected resources without valid credentials.
class NotAuthenticatedException extends FronteggException {
  const NotAuthenticatedException([String? message])
      : super(
          failureReason: "notAuthenticated",
          message: message,
        );
}

/// Exception thrown when MFA (Multi-Factor Authentication) is required but not set up.
/// This occurs when the user hasn't enrolled in required MFA methods for their account.
class MfaNotEnrolledException extends FronteggException {
  const MfaNotEnrolledException([String? message])
      : super(
          failureReason: "mfaNotEnrolled",
          message: message,
        );
}

/// Exception thrown when token exchange fails
class CouldNotExchangeTokenException extends FronteggException {
  const CouldNotExchangeTokenException([String? message])
      : super(
          failureReason: "couldNotExchangeToken",
          message: message,
        );
}

/// Exception thrown when authentication fails
class FailedToAuthenticateException extends FronteggException {
  const FailedToAuthenticateException([String? message])
      : super(
          failureReason: "failedToAuthenticate",
          message: message,
        );
}

/// Exception thrown when token refresh fails
class FailedToRefreshTokenException extends FronteggException {
  const FailedToRefreshTokenException([String? message])
      : super(
          failureReason: "failedToRefreshToken",
          message: message,
        );
}

/// Exception thrown when loading user data fails
class FailedToLoadUserDataException extends FronteggException {
  const FailedToLoadUserDataException([String? message])
      : super(
          failureReason: "failedToLoadUserData",
          message: message,
        );
}

/// Exception thrown when code extraction fails
class FailedToExtractCodeException extends FronteggException {
  const FailedToExtractCodeException([String? message])
      : super(
          failureReason: "failedToExtractCode",
          message: message,
        );
}

/// Exception thrown when tenant switching fails
class FailedToSwitchTenantException extends FronteggException {
  const FailedToSwitchTenantException([String? message])
      : super(
          failureReason: "failedToSwitchTenant",
          message: message,
        );
}

/// Exception thrown when code verifier is not found
class CodeVerifierNotFoundException extends FronteggException {
  const CodeVerifierNotFoundException([String? message])
      : super(
          failureReason: "codeVerifierNotFound",
          message: message,
        );
}

/// Exception thrown when root view controller cannot be found
class CouldNotFindRootViewControllerException extends FronteggException {
  const CouldNotFindRootViewControllerException([String? message])
      : super(
          failureReason: "couldNotFindRootViewController",
          message: message,
        );
}

/// Exception thrown when passkeys request is invalid
class InvalidPasskeysRequestException extends FronteggException {
  const InvalidPasskeysRequestException([String? message])
      : super(
          failureReason: "invalidPasskeysRequest",
          message: message,
        );
}

/// Exception thrown when passkeys authentication fails
class FailedToAuthenticateWithPasskeysException extends FronteggException {
  const FailedToAuthenticateWithPasskeysException([String? message])
      : super(
          failureReason: "failedToAuthenticateWithPasskeys",
          message: message,
        );
}

/// Exception thrown when operation is canceled
class OperationCanceledException extends FronteggException {
  const OperationCanceledException([String? message])
      : super(
          failureReason: "operationCanceled",
          message: message,
        );
}

/// Exception thrown when MFA is required
class MfaRequiredException extends FronteggException {
  const MfaRequiredException([String? message])
      : super(
          failureReason: "mfaRequired",
          message: message,
        );
}

/// Exception thrown for unknown errors
class UnknownException extends FronteggException {
  const UnknownException([String? message])
      : super(
          failureReason: "unknown",
          message: message,
        );
}

/// Exception thrown for other unspecified errors
class OtherException extends FronteggException {
  const OtherException([String? message])
      : super(
          failureReason: "other",
          message: message,
        );
}

/// Exception thrown for other unspecified errors
class CanceledByUserException extends FronteggException {
  const CanceledByUserException([String? message])
      : super(
          failureReason: "other",
          message: message,
        );
}

/// Exception thrown for other unspecified errors
class CookieNotFoundException extends FronteggException {
  const CookieNotFoundException([String? message])
      : super(
          failureReason: "cookieNotFound",
          message: message,
        );
}

/// Exception thrown when MFA fails
class FailedToMFAException extends FronteggException {
  const FailedToMFAException([String? message])
      : super(
          failureReason: "failedToMFA",
          message: message,
        );
}

/// Exception thrown when response is invalid
class InvalidResponseException extends FronteggException {
  const InvalidResponseException([String? message])
      : super(
          failureReason: "invalidResponse",
          message: message,
        );
}
