
import 'frontegg_platform_interface.dart';

class FronteggFlutter {
  Future<String?> getPlatformVersion() {
    return FronteggPlatform.instance.getPlatformVersion();
  }
}
