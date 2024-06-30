import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter/src/models/frontegg_constants.dart';

import '../../fixtures/test_maps.dart';
import '../../fixtures/test_models.dart';

void main() {
  group('fromMap', () {
    test(
      "should return a valid model",
      () async {
        // Act
        final result = FronteggConstants.fromMap(tFronteggConstantsMap);
        // Assert
        expect(result, equals(tFronteggConstants));
      },
    );

    test(
      "should return a valid iOS model",
      () async {
        // Act
        final result = FronteggConstants.fromMap(tIOSFronteggConstantsMap);
        // Assert
        expect(result, equals(tIOSFronteggConstants));
      },
    );
  });
}
