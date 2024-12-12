#!/bin/sh

cd example

flutter pub global activate patrol_cli

patrol doctor

# iOS run
patrol test -d 'iPhone 16 Pro Max' -t integration_test/src/switch_tenant_test.dart --uninstall


# Android run
patrol test -d emulator-5554 -t integration_test/src/sign_up_via_email_and_password_test.dart



