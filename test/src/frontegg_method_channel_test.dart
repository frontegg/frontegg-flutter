import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter/src/frontegg_method_channel.dart';

import '../fixtures/test_maps.dart';

class MockStateStreamHandler extends MockStreamHandler {
  MockStreamHandlerEventSink? states;

  @override
  void onCancel(Object? arguments) {
    states = null;
  }

  @override
  void onListen(Object? arguments, MockStreamHandlerEventSink events) {
    states = events;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final platform = FronteggMethodChannel();
  const channel = MethodChannel(FronteggMethodChannel.methodChannelName);
  const eventChannel =
      EventChannel(FronteggMethodChannel.stateEventChannelName);
  final streamHandler = MockStateStreamHandler();
  late final Stream stateEventChannelStream;

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
      (MethodCall methodCall) async {
        switch (methodCall.method) {
          case FronteggMethodChannel.getConstantsMethodName:
            return tFronteggConstantsMap;
          case FronteggMethodChannel.refreshTokenMethodName:
            return true;
          case FronteggMethodChannel.loginMethodName:
            return null;
          case FronteggMethodChannel.logoutMethodName:
            return null;
          case FronteggMethodChannel.switchTenantMethodName:
            return null;
          case FronteggMethodChannel.directLoginActionMethodName:
            return null;
          case FronteggMethodChannel.directLoginMethodName:
            return null;
          case FronteggMethodChannel.socialLoginMethodName:
            return null;
          case FronteggMethodChannel.customSocialLoginMethodName:
            return null;
          case FronteggMethodChannel.registerPasskeysMethodName:
            return null;
          case FronteggMethodChannel.loginWithPasskeysMethodName:
            return null;
          case FronteggMethodChannel.requestAuthorizeMethodName:
            return null;
          case FronteggMethodChannel.isSteppedUpMethodName:
            return null;
          case FronteggMethodChannel.stepUpMethodName:
            return null;
        }
        throw Exception("${methodCall.method} Not Implemented");
      },
    );

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, streamHandler);

    stateEventChannelStream = eventChannel.receiveBroadcastStream();
  });

  test('refreshToken()', () async {
    expect(await platform.refreshToken(), true);
  });

  test('getConstants()', () async {
    expect(await platform.getConstants(), tFronteggConstantsMap);
  });

  test('login()', () async {
    await platform.login();
  });

  test('logout()', () async {
    await platform.logout();
  });

  test('switchTenant(tenantId)', () async {
    await platform.switchTenant("tenantId");
  });

  test('directLoginAction(type, data)', () async {
    await platform.directLoginAction("type", "data");
  });

  test('directLoginAction(type, data)', () async {
    await platform.directLoginAction("type", "data");
  });

  test('socialLogin(provider)', () async {
    await platform.socialLogin(provider: "google");
  });

  test('customSocialLogin(id)', () async {
    await platform.customSocialLogin(id: "Test Id");
  });

  test('registerPasskeys()', () async {
    await platform.registerPasskeys();
  });

  test('loginWithPasskeys()', () async {
    await platform.loginWithPasskeys();
  });

  test('requestAuthorize(refreshToken, deviceTokenCookie)', () async {
    await platform.requestAuthorize(
        refreshToken: "Test Token",
        deviceTokenCookie: "Test Device Token Cookie");
  });

  test('isSteppedUp()', () async {
    await platform.isSteppedUp();
  });

  test('stepUP()', () async {
    await platform.stepUp();
  });

  group('StateEventChannel', () {
    test('should return valid FronteggState Map', () async {
      // Asser Later
      expectLater(stateEventChannelStream, emits(tFronteggStateMap));
      // Act
      streamHandler.states?.success(tFronteggStateMap);
    });

    test('should return valid Loading FronteggState', () async {
      // Asser Later
      expectLater(stateEventChannelStream, emits(tLoadingFronteggStateMap));
      // Act
      streamHandler.states?.success(tLoadingFronteggStateMap);
    });

    test('should return valid Loading FronteggState Map', () async {
      // Asser Later
      expectLater(stateEventChannelStream, emits(tLoadedFronteggStateMap));
      // Act
      streamHandler.states?.success(tLoadedFronteggStateMap);
    });

    test(
        'should return valid FronteggState, Loading FronteggState, Loaded FronteggState Maps',
        () async {
      // Asser Later
      final expected = [
        tFronteggStateMap,
        tLoadingFronteggStateMap,
        tLoadedFronteggStateMap,
      ];
      expectLater(stateEventChannelStream, emitsInOrder(expected));
      // Act
      streamHandler.states?.success(tFronteggStateMap);
      streamHandler.states?.success(tLoadingFronteggStateMap);
      streamHandler.states?.success(tLoadedFronteggStateMap);
    });
  });
}
