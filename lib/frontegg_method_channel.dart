import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'frontegg_platform_interface.dart';

/// An implementation of [FronteggFlutterPlatform] that uses method channels.
class MethodChannelFrontegg extends FronteggPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('frontegg_flutter');

  @override
  final eventChannel = const EventChannel('frontegg_flutter_state_changed');

  @override
  Future<void> login() => methodChannel.invokeMethod<void>('login');

  @override
  Future<void> subscribe() => methodChannel.invokeMethod('subscribe');

  @override
  Future<void> switchTenant(String tenantId) =>
      methodChannel.invokeMethod('switchTenant', {"tenantId": tenantId});

  @override
  Future<void> directLoginAction(String type, String data) =>
      methodChannel.invokeMethod('directLoginAction', {"type": type, "data": data});

  @override
  Future<void> refreshToken() => methodChannel.invokeMethod('refreshToken');

  @override
  Future<void> logout() => methodChannel.invokeMethod('logout');

  @override
  Future<Map<Object?, Object?>?> getConstants() =>
      methodChannel.invokeMethod<Map<Object?, Object?>>('getConstants');
}
