import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontegg_flutter_example/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  const appleButtonLabel = "continue with apple";

  late final String email;
  late final String password;

  patrolSetUp(() {
    email = const String.fromEnvironment('APPLE_EMAIL');
    password = const String.fromEnvironment('APPLE_PASSWORD');

    assert(email.isNotEmpty && password.isNotEmpty);
  });

  patrolTest(
    'Success Login via Apple Provider',
    ($) async {
      await $.pumpWidget(const MyApp());
      await $.pumpAndSettle();

      await $.tap(find.byKey(const ValueKey("LoginButton")));

      await $.native.tap(
        Selector(text: appleButtonLabel),
        timeout: const Duration(seconds: 10),
      );
      await Future.delayed(const Duration(seconds: 3));
      if (Platform.isIOS) {
        await $.native.tap(Selector(text: "Continue"));
        await Future.delayed(const Duration(seconds: 7));
      }

      await $.native2.enterText(
        NativeSelector(
          ios: IOSSelector(
            label: "Email or Phone Number",
          ),
          android: AndroidSelector(
            resourceName: "account_name_text_field",
          ),
        ),
        text: email,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      if (Platform.isAndroid) {
        await $.native.tap(Selector(resourceId: "sign-in"));
      }
      await Future.delayed(const Duration(seconds: 3));

      await $.native2.enterText(
        NativeSelector(
          ios: IOSSelector(
            label: "password",
          ),
          android: AndroidSelector(
            resourceName: "password_text_field",
          ),
        ),
        text: password,
        keyboardBehavior: KeyboardBehavior.alternative,
      );
      if (Platform.isAndroid) {
        await $.native.tap(Selector(resourceId: "sign-in"));
      }

      await $.native.waitUntilVisible(Selector(textStartsWith: "Do you want to continue using"));
      await Future.delayed(const Duration(seconds: 2));
        await $.native2.tap(
          NativeSelector(
            ios: IOSSelector(
              label: "Continue",
              instance: 1,
            ),
            android: AndroidSelector(
              textContains: "Continue",
              isClickable: true,
            ),
          ),
        );

      await $.pumpAndSettle();
      await $.waitUntilVisible(find.text("Logout"), timeout: const Duration(seconds: 15),);

      await $.tap(find.byKey(const ValueKey("LogoutButton")));
      await $.pumpAndSettle();
      await $.waitUntilVisible(find.text("Not Authenticated"));
    },
  );
}
