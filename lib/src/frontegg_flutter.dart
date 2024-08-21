import "dart:async";
import "dart:io";

import "package:frontegg_flutter/src/frontegg_platform_interface.dart";
import "package:frontegg_flutter/src/models/frontegg_constants.dart";
import "package:frontegg_flutter/src/models/frontegg_state.dart";
import "package:rxdart/rxdart.dart";

import "frontegg_exceptions.dart";

class FronteggFlutter {
  static final FronteggFlutter _instance = FronteggFlutter._internal();

  factory FronteggFlutter() {
    return _instance;
  }

  FronteggFlutter._internal();

  static FronteggState _currentState = const FronteggState();

  static final _stateChangedSubscription = BehaviorSubject<FronteggState>.seeded(_currentState);

  FronteggState get currentState => _currentState;

  FronteggConstants? constants;

  bool _isInitialized = false;

  Future<void> init(FronteggConstants constants) async {
    if (_isInitialized) {
      throw const FronteggAlreadyInitializedException();
    }
    if (Platform.isIOS && !constants.baseUrl.startsWith("https://")) {
      constants = constants.copyWith(baseUrl: "https://${constants.baseUrl}");
    }
    await FronteggPlatform.instance.init(constants.toMap());
    FronteggPlatform.instance.stateChanged.listen((state) {
      _currentState = FronteggState.fromMap(state as Map<Object?, Object?>);
      _stateChangedSubscription.add(_currentState);
    });
    this.constants = constants;
    _isInitialized = true;
  }

  Future<void> login() => _run(() => FronteggPlatform.instance.login());

  Stream<FronteggState> get stateChanged => _stateChangedSubscription.stream.distinct();

  Future<void> switchTenant(String tenantId) =>
      _run(() => FronteggPlatform.instance.switchTenant(tenantId));

  Future<void> directLoginAction(String type, String data) =>
      _run(() => FronteggPlatform.instance.directLoginAction(type, data));

  Future<bool> refreshToken() => _run(
        () async {
          final success = await FronteggPlatform.instance.refreshToken();
          return success ?? false;
        },
      );

  Future<void> logout() => _run(() => FronteggPlatform.instance.logout());

  FronteggConstants getConstants() {
    if (!_isInitialized) {
      throw const FronteggNotInitializedException();
    }

    return constants!;
  }

  Future<T> _run<T>(Future<T> Function() run) async {
    if (!_isInitialized) {
      throw const FronteggNotInitializedException();
    }
    return run();
  }
}
