import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter_example/main.dart';
import 'package:patrol/patrol.dart';

import '../fixtures/const.dart';

void main() {
  patrolTest(
    'Success Logout',
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
      await $.waitUntilVisible(find.text("Not Authenticated"));
    },
  );
}
