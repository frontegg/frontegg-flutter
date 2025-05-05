import "dart:async";

import "package:flutter/services.dart";
import "package:frontegg_flutter/frontegg_flutter.dart";
import "package:frontegg_flutter/src/frontegg_platform_interface.dart";
import "package:rxdart/rxdart.dart";

class FronteggFlutter {
  static FronteggState _currentState = const FronteggState();
  StreamSubscription? _stateStreamSubscription;
  static final _stateChangedSubscription =
      BehaviorSubject<FronteggState>.seeded(_currentState);

  FronteggFlutter() {
    _stateStreamSubscription =
        FronteggPlatform.instance.stateChanged.listen((state) {
      _currentState = FronteggState.fromMap(state as Map<Object?, Object?>);
      _stateChangedSubscription.add(_currentState);
    });
  }

  /// Cancels the subscription to the state stream.
  ///
  /// This method should be called to release resources when the object is no longer
  /// needed. It safely cancels the active subscription to prevent memory leaks.
  Future<void> dispose() async {
    await _stateStreamSubscription?.cancel();
  }

  /// Gets the current state of the Frontegg instance.
  ///
  /// This property returns the [FronteggState] which includes information
  /// such as authentication status, loading status, and user details.
  FronteggState get currentState => _currentState;

  /// Logs in the user by initiating the authentication process.
  ///
  /// This method launches the Frontegg Login Box, either in embedded mode or
  /// via a separate authentication activity, depending on the configuration.
  ///
  /// After a successful login, [accessToken], [refreshToken], and [user]
  /// should be non-null, and [isAuthenticated] should be `true`.
  ///
  /// - [loginHint]: (Optional) A pre-filled value for the login field in the Frontegg Login Box.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns a [Future] that completes when the login process is finished.
  Future<void> login({
    String? loginHint,
  }) =>
      _runAction(() async {
        await FronteggPlatform.instance.login(
          loginHint: loginHint,
        );
      });

  /// Registers passkeys for the user.
  ///
  /// This method attempts to register passkeys and may throw an exception if an error occurs.
  ///
  /// If an exception occurs during registration, a [FronteggException] is thrown with the error message.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns a [Future] that completes when the registration process is finished.
  Future<void> registerPasskeys() => _runAction(() async {
        await FronteggPlatform.instance.registerPasskeys();
      });

  /// Logs in the user using passkeys.
  ///
  /// This method attempts to authenticate the user via passkeys.
  ///
  /// If an exception occurs during the login process, a [FronteggException] is thrown with the error message.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns a [Future] that completes when the login process is finished.
  Future<void> loginWithPasskeys() => _runAction(() async {
        await FronteggPlatform.instance.loginWithPasskeys();
      });

  /// A stream that emits changes to the FronteggState.
  ///
  /// This stream listens for updates to the internal state and ensures that each
  /// emitted state is distinct, meaning it will only emit a new state if it's
  /// different from the last emitted state. This helps avoid redundant updates.
  ///
  /// The `stateChanged` stream provides real-time updates on the state of
  /// authentication, user details, and loading statuses.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns a [Stream] that emits distinct [FronteggState] objects.
  Stream<FronteggState> get stateChanged =>
      _stateChangedSubscription.stream.distinct();

  /// Switches the user's tenant.
  ///
  /// This method updates the active tenant for the user.
  ///
  /// - [tenantId]: The ID of the tenant to switch to. Available tenant IDs can be retrieved from [User].tenants.tenantId.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns a [Future] that completes when the tenant switching process is finished.
  Future<void> switchTenant(String tenantId) => _runAction(() async {
        await FronteggPlatform.instance.switchTenant(tenantId);
      });

  /// Performs a direct login action.
  ///
  /// **Deprecated:** Use [directLogin] for URL-based login, [socialLogin] for social authentication,
  /// or [customSocialLogin] for custom social login instead.
  ///
  /// This method supports different types of direct login:
  /// - `"direct"`: Uses a URL string for login.
  /// - `"social-login"`: Requires a provider (e.g., Google, LinkedIn, Facebook, GitHub, Apple, etc.).
  /// - `"custom-social-login"`: Requires a configured UUID.
  ///
  /// - [type]: The type of direct login (`"direct"`, `"social-login"`, or `"custom-social-login"`).
  /// - [data]: The associated data for the login type (e.g., a URL, provider name, or UUID).
  /// - [ephemeralSession]: (Optional) Whether the session should be ephemeral (not shared with the default browser). Defaults to `true`.
  /// - [additionalQueryParams]: (Optional) Additional query parameters. Defaults to `null`.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns a [Future] that completes when the login action is finished.
  @Deprecated(
      "Use directLogin(url), socialLogin(provider), or customSocialLogin(id) instead.")
  Future<void> directLoginAction(
    String type,
    String data, {
    bool ephemeralSession = true,
    Map<String, String>? additionalQueryParams,
  }) =>
      _runAction(() async {
        return FronteggPlatform.instance.directLoginAction(
          type,
          data,
          ephemeralSession: ephemeralSession,
          additionalQueryParams: additionalQueryParams,
        );
      });

  /// Initiates a direct login using a provided URL.
  ///
  /// This method starts the authentication process using the specified URL.
  ///
  /// - [url]: The URL for the direct login.
  /// - [ephemeralSession]: (Optional) Determines whether the session should be ephemeral
  ///   (not shared with the default browser). Defaults to `true`.
  /// - [additionalQueryParams]: (Optional) A map containing additional query parameters. Defaults to `null`.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns a [Future] that completes when the login process is finished.
  Future<void> directLogin({
    required String url,
    bool ephemeralSession = true,
    Map<String, String>? additionalQueryParams,
  }) =>
      _runAction(() async {
        return FronteggPlatform.instance.directLogin(
          url: url,
          ephemeralSession: ephemeralSession,
          additionalQueryParams: additionalQueryParams,
        );
      });

  /// Initiates a social login using the specified social provider.
  ///
  /// This method starts the authentication process with the specified social provider (e.g., Google, Facebook, LinkedIn).
  ///
  /// - [provider]: The social provider for authentication (e.g., Google, Facebook, LinkedIn).
  /// - [ephemeralSession]: (Optional) Determines whether the session should be ephemeral
  ///   (not shared with the default browser). Defaults to `true`.
  /// - [additionalQueryParams]: (Optional) A map containing additional query parameters. Defaults to `null`.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns a [Future] that completes when the social login process is finished.
  Future<void> socialLogin({
    required FronteggSocialProvider provider,
    bool ephemeralSession = true,
    Map<String, String>? additionalQueryParams,
  }) =>
      _runAction(() async {
        return FronteggPlatform.instance.socialLogin(
          provider: provider.type,
          ephemeralSession: ephemeralSession,
          additionalQueryParams: additionalQueryParams,
        );
      });

  /// Initiates a custom social login using a unique identifier.
  ///
  /// This method starts the authentication process with a custom social login, using the provided unique identifier.
  ///
  /// - [id]: The unique identifier for the custom social login.
  /// - [ephemeralSession]: (Optional) Determines whether the session should be ephemeral
  ///   (not shared with the default browser). Defaults to `true`.
  /// - [additionalQueryParams]: (Optional) A map containing additional query parameters. Defaults to `null`.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns a [Future] that completes when the custom social login process is finished.
  Future<void> customSocialLogin({
    required String id,
    bool ephemeralSession = true,
    Map<String, String>? additionalQueryParams,
  }) =>
      _runAction(() async {
        await FronteggPlatform.instance.customSocialLogin(
          id: id,
          ephemeralSession: ephemeralSession,
          additionalQueryParams: additionalQueryParams,
        );
      });

  /// Refreshes the token if needed.
  ///
  /// This method checks if the token needs to be refreshed and performs the refresh operation.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns `true` if the token was successfully refreshed, and `false` otherwise.
  Future<bool> refreshToken() => _runAction(() async {
        final success = await FronteggPlatform.instance.refreshToken();
        return success ?? false;
      });

  /// Logs out the user and clears user-related data.
  ///
  /// This method may perform a network request to complete the logout process.
  /// After logout, [accessToken], [refreshToken], and [user] should be `null`,
  /// and [isAuthenticated] should be `false`.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns a [Future] that completes when the logout process is finished.
  Future<void> logout() => _runAction(() async {
        await FronteggPlatform.instance.logout();
      });

  /// Fetches the Frontegg constants from the platform.
  ///
  /// Returns a [FronteggConstants] object containing configuration values such
  /// as base URL, client ID, application ID, and others.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Throws an exception if the constants cannot be retrieved.
  Future<FronteggConstants> getConstants() => _runAction(() async {
        final constants = await FronteggPlatform.instance.getConstants();
        return FronteggConstants.fromMap(constants!);
      });

  /// Initiates authorization request using a refresh token.
  ///
  /// This method performs the authorization process using the provided refresh token and
  /// optionally a device token for additional authentication.
  ///
  /// - [refreshToken]: The refresh token used for authentication.
  /// - [deviceTokenCookie]: (Optional) A device token for additional authentication.
  ///
  /// Throws a [FronteggException] if the login process encounters a platform-specific error.
  ///
  /// Returns a [Future] that resolves to a [FronteggUser] if the authentication is successful,
  /// or `null` if the authentication fails.
  Future<FronteggUser?> requestAuthorize({
    required String refreshToken,
    String? deviceTokenCookie,
  }) =>
      _runAction(() async {
        final userMap = await FronteggPlatform.instance.requestAuthorize(
          refreshToken: refreshToken,
          deviceTokenCookie: deviceTokenCookie,
        );
        if (userMap != null) {
          return FronteggUser.fromMap(userMap);
        }
        return null;
      });

  /// Checks whether step-up authentication has been performed and is still valid.
  ///
  /// If [maxAge] is provided, the authentication timestamp is checked
  /// against the given duration to ensure it is still valid.
  ///
  /// Returns a [Future] that completes with `true` if step-up authentication
  /// is valid, otherwise `false`.
  Future<bool> isSteppedUp({
    Duration? maxAge,
  }) =>
      _runAction(
        () => FronteggPlatform.instance.isSteppedUp(
          maxAge: maxAge,
        ),
      );

  /// Initiates a step-up authentication process.
  ///
  /// Optionally accepts [maxAge] to define the maximum duration for which
  /// the authentication should be considered valid.
  ///
  /// Returns a [Future] that completes when the authentication process finishes.
  Future<void> stepUp({
    Duration? maxAge,
  }) =>
      _runAction(() => FronteggPlatform.instance.stepUp(maxAge: maxAge));

  Future<T> _runAction<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PlatformException catch (e) {
      throw FronteggException.fromFailureReason(
        e.code,
        message: e.message,
      );
    } catch (e) {
      throw UnknownException(
        e.toString(),
      );
    }
  }
}
