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
  static const String logoutMethodName = "logout";
  static const String switchTenantMethodName = "switchTenant";
  static const String directLoginActionMethodName = "directLoginAction";
  static const String refreshTokenMethodName = "refreshToken";
  static const String getConstantsMethodName = "getConstants";

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

  /// Performs a direct login action by invoking the native platform's directLoginAction method.
  ///
  /// [type]: The type of login action to perform.
  /// [data]: The data associated with the login action.
  /// [ephemeralSession]: Optional boolean indicating whether the session should be ephemeral (not sharing session with default browser). Defaults to true.
  ///
  /// Returns a [Future] that completes when the login action is finished.
  @override
  Future<void> directLoginAction(String type, String data, {bool ephemeralSession = true}) =>
      methodChannel.invokeMethod(
        directLoginActionMethodName,
        {
          "type": type,
          "data": data,
          "ephemeralSession": ephemeralSession,
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
}
