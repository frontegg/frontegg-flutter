import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg/frontegg_flutter.dart';

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
      () async {
        // Act
        final result = FronteggState.fromMap(tLoadedFronteggStateMap);
        // Assert
        expect(result, equals(tLoadedFronteggState));
      },
    );
  });
}
