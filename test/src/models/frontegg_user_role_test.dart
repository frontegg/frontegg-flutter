import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg/src/models/frontegg_user_role.dart';

import '../../fixtures/test_maps.dart';
import '../../fixtures/test_models.dart';

void main() {
  group('fromMap', () {
    test(
      "should return a valid model",
      () async {
        // Act
        final result = FronteggUserRole.fromMap(tFronteggUserRoleMap);
        // Assert
        expect(result, equals(tFronteggUserRole));
      },
    );
  });
}
