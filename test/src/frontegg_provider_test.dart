import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg/frontegg_flutter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'frontegg_provider_test.mocks.dart';

class MockFronteggProvider extends FronteggProvider {
  @override
  final FronteggFlutter value;

  MockFronteggProvider({super.key, required this.value, required super.child});
}

@GenerateMocks([FronteggFlutter])
void main() {
  late final MockFronteggFlutter frontegg;

  setUpAll(() {
    frontegg = MockFronteggFlutter();
  });

  testWidgets(
    'FronteggProvider notifies dependents',
    (WidgetTester tester) async {
      // Act
      final log = <FronteggProvider>[];

      final builder = Builder(builder: (BuildContext context) {
        final provider = context.dependOnInheritedWidgetOfExactType<FronteggProvider>();
        if (provider != null) {
          log.add(provider);
        }

        return Container();
      });
      final provider = FronteggProvider(child: builder);
      await tester.pumpWidget(provider);
      // Assert
      expect(log, equals(<FronteggProvider>[provider]));

      final provider2 = FronteggProvider(child: builder);
      await tester.pumpWidget(provider2);
      // Assert
      expect(log, equals(<FronteggProvider>[provider, provider2]));
    },
  );

  testWidgets(
    'FronteggProvider.of(BuildContext) should return FronteggFlutter instance',
    (WidgetTester tester) async {
      // Act
      final log = <FronteggFlutter>[];
      final provider = FronteggProvider(
        child: Builder(
          builder: (BuildContext context) {
            final provider = FronteggProvider.of(context);
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

  testWidgets(
    'should call FronteggFlutter.dispose()',
    (WidgetTester tester) async {
      // Arrange
      when(frontegg.dispose()).thenAnswer((realInvocation) => Future.value());
      // Act
      final provider = MockFronteggProvider(
        value: frontegg,
        child: Container(),
      );
      await tester.pumpWidget(provider);
      await tester.pumpAndSettle();
      await tester.pumpWidget(Container());
      // Assert
      verify(frontegg.dispose()).called(1);
    },
  );
}
