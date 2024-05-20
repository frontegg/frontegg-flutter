import "package:flutter/foundation.dart";
import "package:flutter/services.dart";

import "frontegg_platform_interface.dart";

class MethodChannelFrontegg extends FronteggPlatform {
  static const String _methodChannelName = "frontegg_flutter";
  static const String _stateEventChannel = "frontegg_flutter/state_stream";
  @visibleForTesting
  final methodChannel = const MethodChannel(_methodChannelName);

  @visibleForTesting
  final stateChangedEventChanel = const EventChannel(_stateEventChannel);

  late final Stream<dynamic> _stateChangedEventChanelStream =
      stateChangedEventChanel.receiveBroadcastStream();

  @override
  Stream get stateChanged => _stateChangedEventChanelStream;

  @override
  Future<void> login() => methodChannel.invokeMethod<void>("login");

  @override
  Future<void> switchTenant(String tenantId) => methodChannel.invokeMethod(
        "switchTenant",
        {
          "tenantId": tenantId,
        },
      );

  @override
  Future<void> directLoginAction(String type, String data) => methodChannel.invokeMethod(
        "directLoginAction",
        {
          "type": type,
          "data": data,
        },
      );

  @override
  Future<bool?> refreshToken() => methodChannel.invokeMethod<bool>("refreshToken");

  @override
  Future<void> logout() => methodChannel.invokeMethod("logout");

  @override
  Future<Map<Object?, Object?>?> getConstants() =>
      methodChannel.invokeMethod<Map<Object?, Object?>>("getConstants");
}
