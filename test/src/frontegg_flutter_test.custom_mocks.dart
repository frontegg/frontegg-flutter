// Mocks generated by Mockito 5.4.4 from annotations
// in frontegg/test/src/frontegg_flutter_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i3;

import 'package:frontegg_flutter/src/frontegg_platform_interface.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:plugin_platform_interface/plugin_platform_interface.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

/// A class which mocks [FronteggPlatform].
///
/// See the documentation for Mockito's code generation for more information.
class MockFronteggPlatform extends _i1.Mock
    with _i3.MockPlatformInterfaceMixin
    implements _i2.FronteggPlatform {
  MockFronteggPlatform() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.Stream<dynamic> get stateChanged => (super.noSuchMethod(
        Invocation.getter(#stateChanged),
        returnValue: _i3.Stream<dynamic>.empty(),
      ) as _i3.Stream<dynamic>);

  @override
  _i3.Future<void> login({String? loginHint}) => (super.noSuchMethod(
        Invocation.method(
          #login,
          [loginHint],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> switchTenant(String? tenantId) => (super.noSuchMethod(
        Invocation.method(
          #switchTenant,
          [tenantId],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<void> directLoginAction(
    String? type,
    String? data,
      {bool ephemeralSession = true}
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #directLoginAction,
          [
            type,
            data,
            ephemeralSession
          ],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<bool?> refreshToken() => (super.noSuchMethod(
        Invocation.method(
          #refreshToken,
          [],
        ),
        returnValue: _i3.Future<bool?>.value(),
      ) as _i3.Future<bool?>);

  @override
  _i3.Future<void> logout() => (super.noSuchMethod(
        Invocation.method(
          #logout,
          [],
        ),
        returnValue: _i3.Future<void>.value(),
        returnValueForMissingStub: _i3.Future<void>.value(),
      ) as _i3.Future<void>);

  @override
  _i3.Future<Map<Object?, Object?>?> getConstants() => (super.noSuchMethod(
        Invocation.method(
          #getConstants,
          [],
        ),
        returnValue: _i3.Future<Map<Object?, Object?>?>.value(),
      ) as _i3.Future<Map<Object?, Object?>?>);
}
