import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'frontegg_platform_interface.dart';

/// An implementation of [FronteggFlutterPlatform] that uses method channels.
class MethodChannelFrontegg extends FronteggPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('frontegg_flutter');

  @visibleForTesting
  final stateChangedEventChanel = const EventChannel('frontegg_flutter_state_changed');

  late final Stream<dynamic> _stateChangedEventChanelStream =
      stateChangedEventChanel.receiveBroadcastStream();

  @override
  Stream get stateChanged => _stateChangedEventChanelStream;

  @override
  Future<void> login() => methodChannel.invokeMethod<void>('login');

  @override
  Future<void> switchTenant(String tenantId) =>
      methodChannel.invokeMethod('switchTenant', {"tenantId": tenantId});

  @override
  Future<void> directLoginAction(String type, String data) =>
      methodChannel.invokeMethod('directLoginAction', {"type": type, "data": data});

  @override
  Future<bool?> refreshToken() => methodChannel.invokeMethod<bool>('refreshToken');

  @override
  Future<void> logout() => methodChannel.invokeMethod('logout');

  @override
  Future<Map<Object?, Object?>?> getConstants() =>
      methodChannel.invokeMethod<Map<Object?, Object?>>('getConstants');
}
