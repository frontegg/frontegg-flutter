import 'dart:async';

import 'package:frontegg/models/frontegg_constants.dart';

import 'frontegg_platform_interface.dart';
import 'models/frontegg_state.dart';

class FronteggFlutter {
  final _stateChanged = FronteggPlatform.instance.eventChannel.receiveBroadcastStream();
  FronteggState _currentState = const FronteggState();
  StreamSubscription? _stateStreamSubscription;

  FronteggFlutter() {
    _stateStreamSubscription = _stateChanged.listen((state) {
      _currentState = FronteggState.fromMap(state as Map<Object?, Object?>);
    });
  }

  Future<void> dispose() async {
    await _stateStreamSubscription?.cancel();
  }

  FronteggState get currentState => _currentState;

  Future<void> login() async {
    await FronteggPlatform.instance.login();
  }

  Stream<FronteggState> listener() {
    final stream = _stateChanged.map((state) {
      return FronteggState.fromMap(state as Map<Object?, Object?>);
    });

    FronteggPlatform.instance.subscribe();
    return stream;
  }

  Future<void> switchTenant(String tenantId) => FronteggPlatform.instance.switchTenant(tenantId);

  Future<void> directLoginAction(String type, String data) =>
      FronteggPlatform.instance.directLoginAction(type, data);

  Future<void> refreshToken() => FronteggPlatform.instance.refreshToken();

  Future<void> logout() => FronteggPlatform.instance.logout();

  Future<FronteggConstants> getConstants() async {
    final constants = await FronteggPlatform.instance.getConstants();
    return FronteggConstants.fromMap(constants!);
  }
}
