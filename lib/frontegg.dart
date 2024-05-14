
import 'frontegg_platform_interface.dart';

class FronteggFlutter {
  Future<void> login() {
    return FronteggPlatform.instance.login();
  }
}
