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
        final result = FronteggUser.fromMap(tFronteggUserMap);
        // Assert
        expect(result, equals(tFronteggUser));
      },
    );
  });
}
