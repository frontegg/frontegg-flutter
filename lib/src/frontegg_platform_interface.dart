import "package:frontegg_flutter/src/frontegg_method_channel.dart";
import "package:plugin_platform_interface/plugin_platform_interface.dart";

abstract class FronteggPlatform extends PlatformInterface {
  FronteggPlatform() : super(token: _token);

  static final Object _token = Object();

  static FronteggPlatform _instance = FronteggMethodChannel();

  static FronteggPlatform get instance => _instance;

  static set instance(FronteggPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Stream get stateChanged {
    throw UnimplementedError("getter stateChanged has not been implemented.");
  }

  Future<void> login({
    String? loginHint,
  }) {
    throw UnimplementedError("login() has not been implemented.");
  }

  Future<void> registerPasskeys() {
    throw UnimplementedError("registerPasskeys() has not been implemented.");
  }

  Future<void> loginWithPasskeys() {
    throw UnimplementedError("loginWithPasskeys() has not been implemented.");
  }

  Future<void> switchTenant(String tenantId) {
    throw UnimplementedError("switchTenant() has not been implemented.");
  }

  Future<void> directLoginAction(String type, String data, {bool ephemeralSession = true, Map<String, String>? additionalQueryParams}) {
    throw UnimplementedError("directLoginAction() has not been implemented.");
  }

  Future<bool?> refreshToken() {
    throw UnimplementedError("refreshToken() has not been implemented.");
  }

  Future<void> logout() {
    throw UnimplementedError("logout() has not been implemented.");
  }

  Future<Map<Object?, Object?>?> getConstants() {
    throw UnimplementedError("getConstants() has not been implemented.");
  }

  Future<Map<String, Object>?> requestAuthorize({
    required String refreshToken,
    String? deviceTokenCookie,
  }) {
    throw UnimplementedError("requestAuthorize() has not been implemented.");
  }
}
