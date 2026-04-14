import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class E2ETestMode {
  static const _channel = MethodChannel('frontegg_e2e');
  static const bootstrapFileName = 'e2e_embedded_bootstrap.json';

  static bool _isEnabled = false;
  static String? _baseUrl;
  static String? _clientId;
  static bool _forceNetworkPathOffline = false;
  static bool? _enableOfflineMode;

  static bool get isEnabled => _isEnabled;
  static String? get baseUrl => _baseUrl;
  static String? get clientId => _clientId;
  static bool get forceNetworkPathOffline => _forceNetworkPathOffline;
  static bool? get enableOfflineMode => _enableOfflineMode;

  static Future<void> applyBootstrapIfPresent() async {
    try {
      final result = await _channel.invokeMethod<Map>('consumeBootstrap');
      if (result != null) {
        _isEnabled = true;
        _baseUrl = result['baseUrl'] as String?;
        _clientId = result['clientId'] as String?;
        _forceNetworkPathOffline =
            result['forceNetworkPathOffline'] as bool? ?? false;
        _enableOfflineMode = result['enableOfflineMode'] as bool?;
        debugPrint(
          'E2ETestMode: enabled, baseUrl=$_baseUrl, clientId=$_clientId',
        );
      }
    } on MissingPluginException {
      debugPrint('E2ETestMode: no native handler (expected outside E2E)');
    } catch (e) {
      debugPrint('E2ETestMode: bootstrap failed: $e');
    }
  }

  static Future<void> writeBootstrap({
    required String baseUrl,
    required String clientId,
    bool resetState = true,
    bool forceNetworkPathOffline = false,
    bool? enableOfflineMode,
  }) async {
    try {
      await _channel.invokeMethod('writeBootstrap', {
        'baseUrl': baseUrl.replaceAll(RegExp(r'/+$'), ''),
        'clientId': clientId,
        'resetState': resetState,
        'forceNetworkPathOffline': forceNetworkPathOffline,
        if (enableOfflineMode != null) 'enableOfflineMode': enableOfflineMode,
      });
    } on MissingPluginException {
      debugPrint('E2ETestMode: writeBootstrap not available on this platform');
    }
  }

  static Future<void> initializeForE2E({
    required String baseUrl,
    required String clientId,
    bool resetState = true,
    bool forceNetworkPathOffline = false,
    bool? enableOfflineMode,
  }) async {
    try {
      await _channel.invokeMethod('initializeForE2E', {
        'baseUrl': baseUrl.replaceAll(RegExp(r'/+$'), ''),
        'clientId': clientId,
        'resetState': resetState,
        'forceNetworkPathOffline': forceNetworkPathOffline,
        if (enableOfflineMode != null) 'enableOfflineMode': enableOfflineMode,
      });
      _isEnabled = true;
      _baseUrl = baseUrl;
      _clientId = clientId;
      _forceNetworkPathOffline = forceNetworkPathOffline;
      _enableOfflineMode = enableOfflineMode;
    } on MissingPluginException {
      debugPrint('E2ETestMode: initializeForE2E not available');
    }
  }

  static Future<void> resetForTesting() async {
    try {
      await _channel.invokeMethod('resetForTesting');
    } on MissingPluginException {
      debugPrint('E2ETestMode: resetForTesting not available');
    }
  }
}
