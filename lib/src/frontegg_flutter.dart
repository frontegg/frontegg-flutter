import "dart:async";

import "package:flutter/services.dart";
import "package:frontegg_flutter/frontegg_flutter.dart";
import "package:frontegg_flutter/src/frontegg_platform_interface.dart";
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

  Future<void> login({
    String? loginHint,
  }) =>
      FronteggPlatform.instance.login(
        loginHint: loginHint,
      );

  Future<void> registerPasskeys() async {
    try {
      await FronteggPlatform.instance.registerPasskeys();
    } on PlatformException catch (e) {
      throw FronteggException(message: e.message);
    }
  }

  Future<void> loginWithPasskeys() async {
    try {
      await FronteggPlatform.instance.loginWithPasskeys();
    } on PlatformException catch (e) {
      throw FronteggException(message: e.message);
    }
  }

  Stream<FronteggState> get stateChanged => _stateChangedSubscription.stream.distinct();

  Future<void> switchTenant(String tenantId) => FronteggPlatform.instance.switchTenant(tenantId);

  Future<void> directLoginAction(
    String type, 
    String data, {
      bool ephemeralSession = true, 
      Map<String, String>? additionalQueryParams,
    }) =>
      FronteggPlatform.instance.directLoginAction(
        type, 
        data, 
        ephemeralSession: ephemeralSession, 
        additionalQueryParams: additionalQueryParams
      );

  Future<bool> refreshToken() async {
    final success = await FronteggPlatform.instance.refreshToken();
    return success ?? false;
  }

  Future<void> logout() => FronteggPlatform.instance.logout();

  Future<FronteggConstants> getConstants() async {
    final constants = await FronteggPlatform.instance.getConstants();
    return FronteggConstants.fromMap(constants!);
  }

  Future<FronteggUser?> requestAuthorize({
    required String refreshToken,
    String? deviceTokenCookie,
  }) async {
    final userMap = await FronteggPlatform.instance.requestAuthorize(
      refreshToken: refreshToken,
      deviceTokenCookie: deviceTokenCookie,
    );
    if (userMap != null) {
      return FronteggUser.fromMap(userMap);
    }
    return null;
  }
}
