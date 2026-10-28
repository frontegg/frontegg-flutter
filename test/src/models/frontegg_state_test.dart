import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import '../../fixtures/test_maps.dart';
import '../../fixtures/test_models.dart';

void main() {
  group('fromMap', () {
    test(
      "should return a valid model",
      () async {
        // Act
        final result = FronteggState.fromMap(tFronteggStateMap);
        // Assert
        expect(result, equals(tFronteggState));
      },
    );

    test(
      "should return a valid Loading model",
      () async {
        // Act
        final result = FronteggState.fromMap(tLoadingFronteggStateMap);
        // Assert
        expect(result, equals(tLoadingFronteggState));
      },
    );

    test(
      "should return a valid Loaded model",
      () {
        final result = FronteggState.fromMap(tLoadedFronteggStateMap);
        expect(result, equals(tLoadedFronteggState));
      },
    );

    test(
      "should parse iOS platform-channel bools encoded as ints",
      () {
        final map = Map<Object?, Object?>.from(tLoadedFronteggStateMap);
        map["isAuthenticated"] = 1;
        map["isLoading"] = 0;
        map["initializing"] = 0;
        map["showLoader"] = 0;
        map["isOfflineMode"] = 0;

        final result = FronteggState.fromMap(map);

        expect(result.isAuthenticated, isTrue);
        expect(result.isLoading, isFalse);
        expect(result.user, isNotNull);
      },
    );

    test(
      "should parse the selected region",
      () {
        final map = Map<Object?, Object?>.from(tFronteggStateMap);
        map["selectedRegion"] = tFronteggRegionConfigMap;

        final result = FronteggState.fromMap(map);

        expect(result.selectedRegion, equals(tFronteggRegionConfig));
      },
    );

    test(
      "should have no selected region when the platform sends none",
      () {
        final result = FronteggState.fromMap(tFronteggStateMap);
        expect(result.selectedRegion, isNull);
      },
    );
  });

  group('toMap', () {
    test(
      "should round-trip the selected region",
      () {
        const state = FronteggState(selectedRegion: tFronteggRegionConfig);

        final result = FronteggState.fromMap(state.toMap());

        expect(result.selectedRegion, equals(tFronteggRegionConfig));
      },
    );
  });
}
