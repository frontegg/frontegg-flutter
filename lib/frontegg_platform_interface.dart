import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'frontegg_method_channel.dart';

abstract class FronteggPlatform extends PlatformInterface {
  /// Constructs a FronteggFlutterPlatform.
  FronteggPlatform() : super(token: _token);

  static final Object _token = Object();

  static FronteggPlatform _instance = MethodChannelFrontegg();

  /// The default instance of [FronteggPlatform] to use.
  ///
  /// Defaults to [MethodChannelFronteggFlutter].
  static FronteggPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FronteggPlatform] when
  /// they register themselves.
  static set instance(FronteggPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  EventChannel get eventChannel;

  Future<void> login() {
    throw UnimplementedError('login() has not been implemented.');
  }

  Future<void> subscribe() {
    throw UnimplementedError('login() has not been implemented.');
  }

  Future<void> switchTenant(String tenantId) {
    throw UnimplementedError('switchTenant() has not been implemented.');
  }

  Future<void> directLoginAction(String type, String data) {
    throw UnimplementedError('directLoginAction() has not been implemented.');
  }

  Future<void> refreshToken() {
    throw UnimplementedError('refreshToken() has not been implemented.');
  }

  Future<void> logout() {
    throw UnimplementedError('logout() has not been implemented.');
  }

  Future<Map<Object?, Object?>?> getConstants() {
    throw UnimplementedError('getConstants() has not been implemented.');
  }
}
