import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

import "frontegg_platform_interface.dart";

/// FronteggMethodChannel is the platform-specific implementation of the
/// FronteggPlatform interface using MethodChannels to communicate with
/// the native platform.
class FronteggMethodChannel extends FronteggPlatform {
  // Method channel and event channel names
  static const String methodChannelName = "frontegg_flutter";
  static const String stateEventChannelName = "frontegg_flutter/state_stream";

  // Method names for platform-specific method calls
  static const String loginMethodName = "login";
  static const String registerPasskeysMethodName = "registerPasskeys";
  static const String loginWithPasskeysMethodName = "loginWithPasskeys";
  static const String logoutMethodName = "logout";
  static const String switchTenantMethodName = "switchTenant";
  static const String directLoginActionMethodName = "directLoginAction";
  static const String directLoginMethodName = "directLogin";
  static const String socialLoginMethodName = "socialLogin";
  static const String customSocialLoginMethodName = "customSocialLogin";
  static const String refreshTokenMethodName = "refreshToken";
  static const String getConstantsMethodName = "getConstants";
  static const String requestAuthorizeMethodName = "requestAuthorize";

  /// MethodChannel used for invoking platform-specific methods.
  @visibleForTesting
  final methodChannel = const MethodChannel(methodChannelName);

  /// EventChannel used for listening to state changes from the native platform.
  @visibleForTesting
  final stateChangedEventChanel = const EventChannel(stateEventChannelName);

  /// A stream that provides broadcast events from the native platform
  /// related to state changes.
  late final Stream<dynamic> _stateChangedEventChanelStream =
      stateChangedEventChanel.receiveBroadcastStream();

  /// Stream to listen to state changes from the native platform.
  @override
  Stream get stateChanged => _stateChangedEventChanelStream;

  /// Initiates the login process by invoking the native platform's login method.
  ///
  /// [loginHint]: Prefill string of the Login field.
  ///
  /// Returns a [Future] that completes when the login process is finished.
  @override
  Future<void> login({
    String? loginHint,
  }) =>
      methodChannel.invokeMethod(
        loginMethodName,
        {
          "loginHint": loginHint,
        },
      );

  /// Registers passkeys.
  ///
  /// Returns a [Future] that completes when the passkeys are registered.
  ///
  /// Throws [FronteggException] if registration is failed.
  @override
  Future<void> registerPasskeys() => methodChannel.invokeMethod(registerPasskeysMethodName);

  /// Login with passkeys.
  ///
  /// Returns a [Future] that completes when the login process is finished.
  ///
  /// Throws [FronteggException] if login is failed.
  @override
  Future<void> loginWithPasskeys() => methodChannel.invokeMethod(loginWithPasskeysMethodName);

  /// Switches the current tenant by invoking the native platform's switchTenant method.
  ///
  /// [tenantId]: The ID of the tenant to switch to.
  ///
  /// Returns a [Future] that completes when the tenant switch process is finished.
  @override
  Future<void> switchTenant(String tenantId) => methodChannel.invokeMethod(
        switchTenantMethodName,
        {
          "tenantId": tenantId,
        },
      );

  /// Initiates a direct login by invoking the native platform's `directLoginAction` method.
  ///
  /// - [url]: The URL used for the direct login.
  /// - [ephemeralSession]: (Optional) Whether the session should be ephemeral (i.e., not shared with the default browser). Defaults to `true`.
  /// - [additionalQueryParams]: (Optional) A map containing additional query parameters. Defaults to `null`.
  ///
  /// Returns a [Future] that completes when the login action is finished.
  @override
  Future<void> directLoginAction(String type, String data,
          {bool ephemeralSession = true, Map<String, String>? additionalQueryParams}) =>
      methodChannel.invokeMethod(
        directLoginActionMethodName,
        {
          "type": type,
          "data": data,
          "ephemeralSession": ephemeralSession,
          "additionalQueryParams": additionalQueryParams,
        },
      );

  /// Initiates a direct login by invoking the native platform's `directLogin` method.
  ///
  /// - [url]: The URL used for the direct login.
  /// - [ephemeralSession]: (Optional) Whether the session should be ephemeral (i.e., not shared with the default browser). Defaults to `true`.
  /// - [additionalQueryParams]: (Optional) A map containing additional query parameters. Defaults to `null`.
  ///
  /// Returns a [Future] that completes when the login action is finished.
  @override
  Future<void> directLogin({
    required String url,
    bool ephemeralSession = true,
    Map<String, String>? additionalQueryParams,
  }) =>
      methodChannel.invokeMethod(
        directLoginMethodName,
        {
          "url": url,
          "ephemeralSession": ephemeralSession,
          "additionalQueryParams": additionalQueryParams,
        },
      );

  /// Initiates a direct login by invoking the native platform's `directLogin` method.
  ///
  /// - [provider]: The Social Provider used for the Social Login.
  /// - [ephemeralSession]: (Optional) Whether the session should be ephemeral (i.e., not shared with the default browser). Defaults to `true`.
  /// - [additionalQueryParams]: (Optional) A map containing additional query parameters. Defaults to `null`.
  ///
  /// Returns a [Future] that completes when the login action is finished.
  @override
  Future<void> socialLogin({
    required String provider,
    bool ephemeralSession = true,
    Map<String, String>? additionalQueryParams,
  }) =>
      methodChannel.invokeMethod(
        socialLoginMethodName,
        {
          "provider": provider,
          "ephemeralSession": ephemeralSession,
          "additionalQueryParams": additionalQueryParams,
        },
      );

  /// Initiates a Custom Social login by invoking the native platform's `customSocial` method.
  ///
  /// - [id]: The ID(UUID) used for the Custom Social Login.
  /// - [ephemeralSession]: (Optional) Whether the session should be ephemeral (i.e., not shared with the default browser). Defaults to `true`.
  /// - [additionalQueryParams]: (Optional) A map containing additional query parameters. Defaults to `null`.
  ///
  /// Returns a [Future] that completes when the login action is finished.
  @override
  Future<void> customSocialLogin({
    required String id,
    bool ephemeralSession = true,
    Map<String, String>? additionalQueryParams,
  }) =>
      methodChannel.invokeMethod(
        customSocialLoginMethodName,
        {
          "id": id,
          "ephemeralSession": ephemeralSession,
          "additionalQueryParams": additionalQueryParams,
        },
      );

  /// Refreshes the current session token by invoking the native platform's refreshToken method.
  ///
  /// Returns a [Future] that completes with a boolean value indicating
  /// whether the token refresh was successful.
  @override
  Future<bool?> refreshToken() => methodChannel.invokeMethod<bool>(refreshTokenMethodName);

  /// Logs the user out by invoking the native platform's logout method.
  ///
  /// Returns a [Future] that completes when the logout process is finished.
  @override
  Future<void> logout() => methodChannel.invokeMethod(logoutMethodName);

  /// Retrieves a map of constants from the native platform.
  ///
  /// Returns a [Future] that completes with a map containing key-value pairs
  /// of constants from the native platform.
  @override
  Future<Map<Object?, Object?>?> getConstants() =>
      methodChannel.invokeMethod<Map<Object?, Object?>>(getConstantsMethodName);

  /// Requests authorization process with [refreshToken] and [deviceTokenCookie].
  ///
  /// Returns a [Future] that completes when the logout process is finished.
  @override
  Future<Map<String, Object>?> requestAuthorize({
    required String refreshToken,
    String? deviceTokenCookie,
  }) =>
      methodChannel.invokeMapMethod<String, Object>(
        requestAuthorizeMethodName,
        {
          "refreshToken": refreshToken,
          "deviceTokenCookie": deviceTokenCookie,
        },
      );
}
