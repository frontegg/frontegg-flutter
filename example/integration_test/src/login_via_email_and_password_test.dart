import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter_example/main.dart';
import 'package:patrol/patrol.dart';

import '../fixtures/const.dart';

void main() {
  patrolTest(
    'Success Login via email and password',
        ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));
      await Future.delayed(const Duration(seconds: 5));

      await $.native.enterTextByIndex(
          loginEmail,
          index: 0,
          keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.enterTextByIndex(
          loginPassword,
          index: 1,
          keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.tap(Selector(text: "Sign in"));

      await $.waitUntilVisible(find.text("Logout"));

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
        loginWrongEmail,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.enterTextByIndex(
        loginPassword,
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
        loginEmail,
        index: 0,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.enterTextByIndex(
        loginWrongPassword,
        index: 1,
        keyboardBehavior: KeyboardBehavior.alternative,
      );

      await $.native.tap(Selector(text: "Sign in"));

      await $.native.waitUntilVisible(Selector(text: "Incorrect email or password"));
    },
  );
}
