import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter_embedded_example/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  const googleButtonLabel = "continue with google";
  late final String email;
  patrolSetUp(() {
    email = const String.fromEnvironment('GOOGLE_EMAIL');

    assert(email.isNotEmpty);
  });

  patrolTest(
    'Success Login via Google Provider',
    ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));
      await Future.delayed(const Duration(seconds: 5));

      await $.native.tap(Selector(text: googleButtonLabel));
      await Future.delayed(const Duration(seconds: 5));
      if (Platform.isIOS) {
        await $.native.tap(Selector(text: "Continue"));
        await Future.delayed(const Duration(seconds: 7));
      }
      await $.native.tap(Selector(text: email));

      await $.waitUntilVisible(find.text("Logout"), timeout: const Duration(seconds: 15),);

      await $.tap(find.byKey(const ValueKey("LogoutButton")));
      await $.pumpAndSettle();
      await $.waitUntilVisible(find.text("Not Authenticated"));
    },
  );
}
