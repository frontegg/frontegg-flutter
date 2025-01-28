// Mocks generated by Mockito 5.4.5 from annotations
// in frontegg_flutter/test/src/frontegg_provider_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:frontegg_flutter/frontegg_flutter.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeFronteggState_0 extends _i1.SmartFake implements _i2.FronteggState {
  _FakeFronteggState_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

class _FakeFronteggConstants_1 extends _i1.SmartFake
    implements _i2.FronteggConstants {
  _FakeFronteggConstants_1(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [FronteggFlutter].
///
/// See the documentation for Mockito's code generation for more information.
class MockFronteggFlutter extends _i1.Mock implements _i2.FronteggFlutter {
  MockFronteggFlutter() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.FronteggState get currentState =>
      (super.noSuchMethod(
            Invocation.getter(#currentState),
            returnValue: _FakeFronteggState_0(
              this,
              Invocation.getter(#currentState),
            ),
          )
          as _i2.FronteggState);

  @override
  _i3.Stream<_i2.FronteggState> get stateChanged =>
      (super.noSuchMethod(
            Invocation.getter(#stateChanged),
            returnValue: _i3.Stream<_i2.FronteggState>.empty(),
          )
          as _i3.Stream<_i2.FronteggState>);

  @override
  _i3.Future<void> dispose() =>
      (super.noSuchMethod(
            Invocation.method(#dispose, []),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> login({String? loginHint}) =>
      (super.noSuchMethod(
            Invocation.method(#login, [], {#loginHint: loginHint}),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> registerPasskeys() =>
      (super.noSuchMethod(
            Invocation.method(#registerPasskeys, []),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> loginWithPasskeys() =>
      (super.noSuchMethod(
            Invocation.method(#loginWithPasskeys, []),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> switchTenant(String? tenantId) =>
      (super.noSuchMethod(
            Invocation.method(#switchTenant, [tenantId]),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<void> directLoginAction(
    String? type,
    String? data, {
    bool? ephemeralSession = true,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #directLoginAction,
              [type, data],
              {#ephemeralSession: ephemeralSession},
            ),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<bool> refreshToken() =>
      (super.noSuchMethod(
            Invocation.method(#refreshToken, []),
            returnValue: _i3.Future<bool>.value(false),
          )
          as _i3.Future<bool>);

  @override
  _i3.Future<void> logout() =>
      (super.noSuchMethod(
            Invocation.method(#logout, []),
            returnValue: _i3.Future<void>.value(),
            returnValueForMissingStub: _i3.Future<void>.value(),
          )
          as _i3.Future<void>);

  @override
  _i3.Future<_i2.FronteggConstants> getConstants() =>
      (super.noSuchMethod(
            Invocation.method(#getConstants, []),
            returnValue: _i3.Future<_i2.FronteggConstants>.value(
              _FakeFronteggConstants_1(
                this,
                Invocation.method(#getConstants, []),
              ),
            ),
          )
          as _i3.Future<_i2.FronteggConstants>);

  @override
  _i3.Future<_i2.FronteggUser?> requestAuthorize({
    required String? refreshToken,
    String? deviceTokenCookie,
  }) =>
      (super.noSuchMethod(
            Invocation.method(#requestAuthorize, [], {
              #refreshToken: refreshToken,
              #deviceTokenCookie: deviceTokenCookie,
            }),
            returnValue: _i3.Future<_i2.FronteggUser?>.value(),
          )
          as _i3.Future<_i2.FronteggUser?>);
}
