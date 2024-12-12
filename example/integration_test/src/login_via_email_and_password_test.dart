import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter_example/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  late final String email;
  late final String wrongEmail;

  late final String password;
  late final String wrongPassword;

  patrolSetUp(() {
    email = const String.fromEnvironment('LOGIN_EMAIL');
    password = const String.fromEnvironment('LOGIN_PASSWORD');

    wrongEmail = const String.fromEnvironment('LOGIN_WRONG_EMAIL');
    wrongPassword = const String.fromEnvironment('LOGIN_WRONG_PASSWORD');
  });

  patrolTest(
    'Success Login via email and password',
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

      await $.waitUntilVisible(find.text("Logout"), timeout: const Duration(seconds: 15),);

      await $.tap(find.byKey(const ValueKey("LogoutButton")));
      await $.pumpAndSettle();
    },
  );

  patrolTest(
    'Failure Login via wrong email and password',
    ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));
      await Future.delayed(const Duration(seconds: 5));

      await $.native.enterTextByIndex(
        wrongEmail,
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

      await $.native.waitUntilVisible(Selector(text: "Incorrect email or password"));
    },
  );

  patrolTest(
    'Failure Login via email and wrong password',
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
        wrongPassword,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.tap(Selector(text: "Sign in"));

      await $.native.waitUntilVisible(Selector(text: "Incorrect email or password"));
    },
  );
}
