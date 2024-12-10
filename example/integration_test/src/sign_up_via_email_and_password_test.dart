import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter_example/main.dart';
import 'package:patrol/patrol.dart';
import 'package:uuid/uuid.dart';

import '../fixtures/const.dart';

void main() {
  late final String userEmail;

  patrolSetUp(() {
    userEmail = signUpEmailTemplate.replaceFirst("{uuid}", const Uuid().v4());
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
        userEmail,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        signUpName,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        loginPassword,
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        signUpOrganization,
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.tap(Selector(text: "Sign up"));

      await $.waitUntilVisible(find.text("Logout"));

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
        loginEmail,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        signUpName,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        loginPassword,
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        signUpOrganization,
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

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
        signUpName,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        loginPassword,
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        signUpOrganization,
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

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
        loginEmail,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        "",
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        loginPassword,
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        signUpOrganization,
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

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
        loginEmail,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        signUpName,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        "",
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        signUpOrganization,
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

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
        loginEmail,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        signUpName,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        loginPassword,
        index: 2,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      await $.native.enterTextByIndex(
        "",
        index: 3,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.tap(Selector(text: "Sign up"));

      await $.native.waitUntilVisible(Selector(text: "Company name is required"));
    },
  );
}
