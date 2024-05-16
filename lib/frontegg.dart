import 'dart:async';

import 'package:frontegg/models/frontegg_constants.dart';
import 'package:rxdart/rxdart.dart';

import 'frontegg_platform_interface.dart';
import 'models/frontegg_state.dart';

class FronteggFlutter {
  final _stateChanged = FronteggPlatform.instance.eventChannel.receiveBroadcastStream();
  FronteggState _currentState = const FronteggState();
  StreamSubscription? _stateStreamSubscription;
  final _stateSubscription = BehaviorSubject<FronteggState>.seeded(const FronteggState());

  FronteggFlutter() {
    _stateStreamSubscription = _stateChanged.listen((state) {
      _currentState = FronteggState.fromMap(state as Map<Object?, Object?>);
      _stateSubscription.add(_currentState);
    });
    FronteggPlatform.instance.subscribe();
  }

  Future<void> dispose() async {
    await _stateStreamSubscription?.cancel();
  }

  FronteggState get currentState => _currentState;

  Future<void> login() async {
    await FronteggPlatform.instance.login();
  }

  Stream<FronteggState> get onStateChanged => _stateSubscription.stream;

  Future<void> switchTenant(String tenantId) => FronteggPlatform.instance.switchTenant(tenantId);

  Future<void> directLoginAction(String type, String data) =>
      FronteggPlatform.instance.directLoginAction(type, data);

  Future<bool> refreshToken() async {
    final success = await FronteggPlatform.instance.refreshToken();
    return success ?? false;
  }

  Future<void> logout() => FronteggPlatform.instance.logout();

  Future<FronteggConstants> getConstants() async {
    final constants = await FronteggPlatform.instance.getConstants();
    return FronteggConstants.fromMap(constants!);
  }
}
