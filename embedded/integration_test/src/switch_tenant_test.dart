import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter_embedded_example/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  late final String email;
  late final String password;
  late final String tenantId1;
  late final String tenantId2;

  late final String tenantName1;
  late final String tenantName2;

  patrolSetUp(() {
    email = const String.fromEnvironment('LOGIN_EMAIL');
    password = const String.fromEnvironment('LOGIN_PASSWORD');

    tenantId1 = const String.fromEnvironment('TENANT_ID_1');
    tenantId2 = const String.fromEnvironment('TENANT_ID_2');

    tenantName1 = const String.fromEnvironment('TENANT_NAME_1');
    tenantName2 = const String.fromEnvironment('TENANT_NAME_2');
  });

  patrolTest(
    'Success tenant switch',
    ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));
      await Future.delayed(const Duration(seconds: 5));

      await $.native.enterTextByIndex(
        email,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
        timeout: const Duration(seconds: 15),
      );

      await $.native.tap(Selector(text: "Continue"));

      await $.native.enterTextByIndex(
        password,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
        timeout: const Duration(seconds: 15),
      );

      await $.native.tap(Selector(text: "Sign in"));

      await $.waitUntilVisible(
        find.text("Logout"),
        timeout: const Duration(seconds: 15),
      );

      // Switch to Tenant Tab
      await $.tap(find.byKey(const ValueKey("TenantTab")));
      await $.pumpAndSettle();

      // Switch tenant 2
      await $.tap(find.byKey(ValueKey(tenantId2)));
      await $.pumpAndSettle();
      await $.waitUntilVisible(
          find.textContaining("$tenantName2 (active)", findRichText: true));

      // Switch tenant 1
      await $.tap(find.byKey(ValueKey(tenantId1)));
      await $.pumpAndSettle();
      await $.waitUntilVisible(
          find.textContaining("$tenantName1 (active)", findRichText: true));

      // Logout
      await $.tap(find.byKey(const ValueKey("ProfileTab")));
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LogoutButton")));
      await $.pumpAndSettle();
    },
  );
}
