import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'frontegg_platform_interface.dart';

/// An implementation of [FronteggFlutterPlatform] that uses method channels.
class MethodChannelFrontegg extends FronteggPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('frontegg_flutter');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
