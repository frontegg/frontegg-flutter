import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter/src/inner_utils.dart';

void main() {
  const tDataTimeString = "2020-12-08T08:59:25.000Z";
  final tDataTime = DateTime.utc(2020, 12, 8, 8, 59, 25);

  group("toDateTime", () {
    test("should return valid DateTime", () {
      // Act
      final result = tDataTimeString.toDateTime();
      //Assert
      expect(result, tDataTime);
    });
  });
}
