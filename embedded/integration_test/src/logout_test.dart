import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter_embedded_example/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  late final String email;
  late final String password;

  patrolSetUp(() {
    email = const String.fromEnvironment('LOGIN_EMAIL');
    password = const String.fromEnvironment('LOGIN_PASSWORD');
  });

  patrolTest(
    'Success Logout',
    ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));
      await Future.delayed(const Duration(seconds: 5));

      await $.native.enterTextByIndex(
        email,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.tap(Selector(text: "Continue"));

      await $.native.enterTextByIndex(
        password,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.tap(Selector(text: "Sign in"));

      await $.waitUntilVisible(
        find.text("Logout"),
        timeout: const Duration(seconds: 15),
      );

      await $.tap(find.byKey(const ValueKey("LogoutButton")));
      await $.pumpAndSettle();
      await $.waitUntilVisible(find.text("Not Authenticated"));
    },
  );
}
