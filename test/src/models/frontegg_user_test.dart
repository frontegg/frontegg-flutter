import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import '../../fixtures/test_maps.dart';
import '../../fixtures/test_models.dart';

void main() {
  group('fromMap', () {
    test(
      "should return a valid model",
      () {
        final result = FronteggUser.fromMap(tFronteggUserMap);
        expect(result, equals(tFronteggUser));
      },
    );

    test(
      "should parse iOS platform-channel bools encoded as ints",
      () {
        final map = Map<Object?, Object?>.from(tFronteggUserMap);
        map["mfaEnrolled"] = 0;
        map["verified"] = 1;
        map["activatedForTenant"] = 1;
        map["superUser"] = 0;
        final tenant = Map<Object?, Object?>.from(map["activeTenant"] as Map);
        tenant["isReseller"] = 0;
        map["activeTenant"] = tenant;
        final tenants = [
          Map<Object?, Object?>.from((map["tenants"] as List).first as Map)
            ..["isReseller"] = 0,
        ];
        map["tenants"] = tenants;

        final result = FronteggUser.fromMap(map);

        expect(result.mfaEnrolled, isFalse);
        expect(result.verified, isTrue);
        expect(result.activatedForTenant, isTrue);
        expect(result.superUser, isFalse);
        expect(result.activeTenant.isReseller, isFalse);
      },
    );
  });
}
