import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

import "frontegg_platform_interface.dart";

class FronteggMethodChannel extends FronteggPlatform {
  static const String methodChannelName = "frontegg_flutter";
  static const String stateEventChannelName = "frontegg_flutter/state_stream";

  static const String loginMethodName = "login";
  static const String logoutMethodName = "logout";
  static const String switchTenantMethodName = "switchTenant";
  static const String directLoginActionMethodName = "directLoginAction";
  static const String refreshTokenMethodName = "refreshToken";
  static const String getConstantsMethodName = "getConstants";

  @visibleForTesting
  final methodChannel = const MethodChannel(methodChannelName);

  @visibleForTesting
  final stateChangedEventChanel = const EventChannel(stateEventChannelName);

  late final Stream<dynamic> _stateChangedEventChanelStream =
      stateChangedEventChanel.receiveBroadcastStream();

  @override
  Stream get stateChanged => _stateChangedEventChanelStream;

  @override
  Future<void> login() => methodChannel.invokeMethod(loginMethodName);

  @override
  Future<void> switchTenant(String tenantId) => methodChannel.invokeMethod(
        switchTenantMethodName,
        {
          "tenantId": tenantId,
        },
      );

  @override
  Future<void> directLoginAction(String type, String data) => methodChannel.invokeMethod(
        directLoginActionMethodName,
        {
          "type": type,
          "data": data,
        },
      );

  @override
  Future<bool?> refreshToken() => methodChannel.invokeMethod<bool>(refreshTokenMethodName);

  @override
  Future<void> logout() => methodChannel.invokeMethod(logoutMethodName);

  @override
  Future<Map<Object?, Object?>?> getConstants() =>
      methodChannel.invokeMethod<Map<Object?, Object?>>(getConstantsMethodName);
}
