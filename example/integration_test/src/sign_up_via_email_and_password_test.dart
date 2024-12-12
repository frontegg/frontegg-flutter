import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter_example/main.dart';
import 'package:patrol/patrol.dart';
import 'package:uuid/uuid.dart';

void main() {
  late final String email;
  late final String existsEmail;

  late final String password;
  late final String name;
  late final String organization;

  patrolSetUp(() {
    password = const String.fromEnvironment('LOGIN_PASSWORD');
    email = const String.fromEnvironment('SIGN_UP_TEMPLATE').replaceFirst(
      "{uuid}",
      const Uuid().v4(),
    );

    name = const String.fromEnvironment('SIGN_UP_NAME');
    organization = const String.fromEnvironment('SIGN_UP_ORGANIZATION');
    existsEmail = const String.fromEnvironment('LOGIN_EMAIL');
  });

  patrolTest(
    "Success Sign up via email and password",
    ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));
      await Future.delayed(const Duration(seconds: 5));

      await $.native.tap(Selector(text: "Sign up"));
      await $.native.waitUntilVisible(Selector(text: "Account sign-up"));

      await $.native.enterTextByIndex(
        email,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        name,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        password,
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        organization,
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      // Hide Keyboard
      await $.native.tap(Selector(text: "Account sign-up"));
      await Future.delayed(const Duration(seconds: 1));

      await $.native.tap(Selector(text: "Sign up"));

      await $.waitUntilVisible(find.text("Logout"), timeout: const Duration(seconds: 15),);

      await $.tap(find.byKey(const ValueKey("LogoutButton")));
      await $.pumpAndSettle();
    },
  );

  patrolTest(
    'Failure Sign up with existing user',
    ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));
      await Future.delayed(const Duration(seconds: 5));

      await $.native.tap(Selector(text: "Sign up"));
      await $.native.waitUntilVisible(Selector(text: "Account sign-up"));

      await $.native.enterTextByIndex(
        existsEmail,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        name,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        password,
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        organization,
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      // Hide Keyboard
      await $.native.tap(Selector(text: "Account sign-up"));
      await Future.delayed(const Duration(seconds: 1));

      await $.native.tap(Selector(text: "Sign up"));

      await $.native.waitUntilVisible(Selector(text: "User already exists"));
    },
  );

  patrolTest(
    'Failure Sign up with invalid Email field',
    ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));
      await Future.delayed(const Duration(seconds: 5));

      await $.native.tap(Selector(text: "Sign up"));
      await $.native.waitUntilVisible(Selector(text: "Account sign-up"));

      await $.native.enterTextByIndex(
        "s",
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        name,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        password,
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        organization,
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      // Hide Keyboard
      await $.native.tap(Selector(text: "Account sign-up"));
      await Future.delayed(const Duration(seconds: 1));

      await $.native.tap(Selector(text: "Sign up"));

      await $.native.waitUntilVisible(Selector(text: "Must be a valid email"));
    },
  );

  patrolTest(
    'Failure Sign up with empty Name field',
    ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));
      await Future.delayed(const Duration(seconds: 5));

      await $.native.tap(Selector(text: "Sign up"));
      await $.native.waitUntilVisible(Selector(text: "Account sign-up"));

      await $.native.enterTextByIndex(
        email,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        "",
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        password,
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        organization,
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      // Hide Keyboard
      await $.native.tap(Selector(text: "Account sign-up"));
      await Future.delayed(const Duration(seconds: 1));

      await $.native.tap(Selector(text: "Sign up"));

      await $.native.waitUntilVisible(Selector(text: "Name is required"));
    },
  );

  patrolTest(
    'Failure Sign up with empty Password field',
    ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));
      await Future.delayed(const Duration(seconds: 5));

      await $.native.tap(Selector(text: "Sign up"));
      await $.native.waitUntilVisible(Selector(text: "Account sign-up"));

      await $.native.enterTextByIndex(
        email,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        name,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        "",
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        organization,
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      // Hide Keyboard
      await $.native.tap(Selector(text: "Account sign-up"));
      await Future.delayed(const Duration(seconds: 1));

      await $.native.tap(Selector(text: "Sign up"));

      await $.native.waitUntilVisible(Selector(text: "Password is required"));
    },
  );

  patrolTest(
    'Failure Sign up with empty CompanyName field',
        ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));
      await Future.delayed(const Duration(seconds: 5));

      await $.native.tap(Selector(text: "Sign up"));
      await $.native.waitUntilVisible(Selector(text: "Account sign-up"));

      await $.native.enterTextByIndex(
        email,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        name,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        password,
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        "",
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      // Hide Keyboard
      await $.native.tap(Selector(text: "Account sign-up"));
      await Future.delayed(const Duration(seconds: 1));

      await $.native.tap(Selector(text: "Sign up"));

      await $.native.waitUntilVisible(Selector(text: "Company name is required"));
    },
  );
}
