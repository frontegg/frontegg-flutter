import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

import '../../fixtures/test_maps.dart';
import '../../fixtures/test_models.dart';

void main() {
  group('fromMap', () {
    test(
      "should return a valid model",
      () {
        final result = FronteggRegionConfig.fromMap(tFronteggRegionConfigMap);
        expect(result, equals(tFronteggRegionConfig));
      },
    );

    test(
      "should read the optional applicationId",
      () {
        final map = Map<Object?, Object?>.from(tFronteggRegionConfigMap);
        map["applicationId"] = "applicationId1";

        final result = FronteggRegionConfig.fromMap(map);

        expect(result.applicationId, equals("applicationId1"));
      },
    );
  });

  group('toMap', () {
    test(
      "should return the platform map",
      () {
        expect(tFronteggRegionConfig.toMap(), equals(tFronteggRegionConfigMap));
      },
    );
  });
}
