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
        final result = FronteggState.fromMap(tFronteggTenantMap);
        // Assert
        expect(result, equals(tFronteggTenant));
      },
    );
  });
}
