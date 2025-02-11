import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter/src/models/frontegg_user_role_permission.dart';

import '../../fixtures/test_maps.dart';
import '../../fixtures/test_models.dart';

void main() {
  group('fromMap', () {
    test(
      "should return a valid model",
      () async {
        // Act
        final result =
            FronteggUserRolePermission.fromMap(tFronteggUserRolePermissionMap);
        // Assert
        expect(result, equals(tFronteggUserRolePermission));
      },
    );
  });
}
