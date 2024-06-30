import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';
import 'package:frontegg_flutter/src/frontegg_platform_interface.dart';
import 'package:mockito/mockito.dart';

import '../fixtures/test_maps.dart';
import '../fixtures/test_models.dart';
import 'frontegg_flutter_test.custom_mocks.dart';

void main() {
  late final FronteggPlatform fronteggPlatform;
  late final FronteggFlutter frontegg;

  final tStreamController = StreamController<Map<Object?, Object?>?>();

  setUpAll(() {
    fronteggPlatform = MockFronteggPlatform();
    FronteggPlatform.instance = fronteggPlatform;
    when(fronteggPlatform.stateChanged).thenAnswer((_) => tStreamController.stream);
    frontegg = FronteggFlutter();
  });

  group('login()', () {
    test('should call FronteggPlatform.instance.login()', () async {
      // Arrange
      when(fronteggPlatform.login()).thenAnswer((_) => Future.value());
      // Act
      await frontegg.login();
      // Assert
      verify(fronteggPlatform.login()).called(1);
    });
  });

  group('logout()', () {
    test('should call FronteggPlatform.instance.logout()', () async {
      // Arrange
      when(fronteggPlatform.logout()).thenAnswer((_) => Future.value());
      // Act
      await frontegg.logout();
      // Assert
      verify(fronteggPlatform.logout()).called(1);
    });
  });

  group('refreshToken()', () {
    test('should call FronteggPlatform.instance.refreshToken()', () async {
      // Arrange
      when(fronteggPlatform.refreshToken()).thenAnswer((_) async => true);
      // Act
      await frontegg.refreshToken();
      // Assert
      verify(fronteggPlatform.refreshToken()).called(1);
    });

    test('should return true', () async {
      // Arrange
      when(fronteggPlatform.refreshToken()).thenAnswer((_) async => true);
      // Act
      final result = await frontegg.refreshToken();
      // Assert
      expect(result, equals(true));
    });

    test('should return false', () async {
      // Arrange
      when(fronteggPlatform.refreshToken()).thenAnswer((_) async => false);
      // Act
      final result = await frontegg.refreshToken();
      // Assert
      expect(result, equals(false));
    });
  });

  group('directLoginAction()', () {
    test('should call FronteggPlatform.instance.directLoginAction()', () async {
      // Arrange
      when(fronteggPlatform.directLoginAction("type", "data")).thenAnswer((_) => Future.value());
      // Act
      await frontegg.directLoginAction("type", "data");
      // Assert
      verify(fronteggPlatform.directLoginAction("type", "data")).called(1);
    });
  });

  group('switchTenant()', () {
    test('should call FronteggPlatform.instance.switchTenant()', () async {
      // Arrange
      when(fronteggPlatform.switchTenant("tenantId")).thenAnswer((_) => Future.value());
      // Act
      await frontegg.switchTenant("tenantId");
      // Assert
      verify(fronteggPlatform.switchTenant("tenantId")).called(1);
    });
  });

  group('getConstants()', () {
    test('should call FronteggPlatform.instance.getConstants()', () async {
      // Arrange
      when(fronteggPlatform.getConstants()).thenAnswer((_) async => tFronteggConstantsMap);
      // Act
      await frontegg.getConstants();
      // Assert
      verify(fronteggPlatform.getConstants()).called(1);
    });

    test('should return valid FronteggConstant', () async {
      // Arrange
      when(fronteggPlatform.getConstants()).thenAnswer((_) async => tFronteggConstantsMap);
      // Act
      final result = await frontegg.getConstants();
      // Assert
      expect(result, tFronteggConstants);
    });

    test('should return valid iOS FronteggConstant', () async {
      // Arrange
      when(fronteggPlatform.getConstants()).thenAnswer((_) async => tIOSFronteggConstantsMap);
      // Act
      final result = await frontegg.getConstants();
      // Assert
      expect(result, tIOSFronteggConstants);
    });
  });

  group('getter stateChanged', () {
    test('should return valid FronteggState', () async {
      tStreamController.add(tEmptyFronteggState.toMap());
      await Future.value();
      // Asser Later
      final expected = [
        tEmptyFronteggState,
        tFronteggState,
      ];
      expectLater(frontegg.stateChanged, emitsInOrder(expected));
      // Act
      tStreamController.add(tFronteggStateMap);
    });

    test('should return valid Loading FronteggState', () async {
      tStreamController.add(tEmptyFronteggState.toMap());
      await Future.value();
      // Asser Later
      final expected = [
        tEmptyFronteggState,
        tLoadingFronteggState,
      ];
      expectLater(frontegg.stateChanged, emitsInOrder(expected));
      // Act
      tStreamController.add(tLoadingFronteggStateMap);
    });

    test('should return valid Loaded FronteggState', () async {
      tStreamController.add(tEmptyFronteggState.toMap());
      await Future.value();
      // Asser Later
      final expected = [
        tEmptyFronteggState,
        tLoadedFronteggState,
      ];
      expectLater(frontegg.stateChanged, emitsInOrder(expected));
      // Act
      tStreamController.add(tLoadedFronteggStateMap);
    });

    test('should return valid FronteggState, Loading FronteggState, Loaded FronteggState',
        () async {
      tStreamController.add(tEmptyFronteggState.toMap());
      await Future.value();
      // Asser Later
      final expected = [
        tEmptyFronteggState,
        tFronteggState,
        tLoadingFronteggState,
        tLoadedFronteggState,
      ];
      expectLater(frontegg.stateChanged, emitsInOrder(expected));
      // Act
      tStreamController.add(tFronteggStateMap);
      tStreamController.add(tLoadingFronteggStateMap);
      tStreamController.add(tLoadedFronteggStateMap);
    });

    test('should not emit two equals states', () async {
      tStreamController.add(tEmptyFronteggState.toMap());
      await Future.value();
      // Asser Later
      final expected = [
        tEmptyFronteggState,
        tLoadingFronteggState,
        tEmptyFronteggState,
      ];
      expectLater(frontegg.stateChanged, emitsInOrder(expected));
      // Act
      tStreamController.add(tLoadingFronteggStateMap);
      tStreamController.add(tLoadingFronteggStateMap);
      tStreamController.add(tEmptyFronteggState.toMap());
    });
  });
}
