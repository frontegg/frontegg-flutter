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

  Future<void> login() {
    throw UnimplementedError('login() has not been implemented.');
  }
}
