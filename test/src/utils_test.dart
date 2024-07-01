import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter/frontegg_flutter.dart';

void main() {
  testWidgets(
    'BuildContext.frontegg should return FronteggFlutter instance',
    (WidgetTester tester) async {
      // Act
      final log = <FronteggFlutter>[];
      final provider = FronteggProvider(
        child: Builder(
          builder: (BuildContext context) {
            final provider = context.frontegg;
            log.add(provider);
            return Container();
          },
        ),
      );
      await tester.pumpWidget(provider);
      // Assert
      expect(log.isNotEmpty, equals(true));
      expect(log.first, equals(provider.value));
    },
  );
}
