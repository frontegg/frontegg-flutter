import "dart:async";

import "package:frontegg/src/frontegg_platform_interface.dart";
import "package:frontegg/src/models/frontegg_constants.dart";
import "package:frontegg/src/models/frontegg_state.dart";
import "package:rxdart/rxdart.dart";

class FronteggFlutter {
  static FronteggState _currentState = const FronteggState();
  StreamSubscription? _stateStreamSubscription;
  static final _stateChangedSubscription = BehaviorSubject<FronteggState>.seeded(_currentState);

  FronteggFlutter() {
    _stateStreamSubscription = FronteggPlatform.instance.stateChanged.listen((state) {
      _currentState = FronteggState.fromMap(state as Map<Object?, Object?>);
      _stateChangedSubscription.add(_currentState);
    });
  }

  Future<void> dispose() async {
    await _stateStreamSubscription?.cancel();
  }

  FronteggState get currentState => _currentState;

  Future<void> login() async {
    await FronteggPlatform.instance.login();
  }

  Stream<FronteggState> get stateChanged => _stateChangedSubscription.stream;

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
