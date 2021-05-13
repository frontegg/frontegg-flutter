@JS('Frontegg')
library frontegg;

import 'dart:js';
import 'package:js/js.dart';

@JS()
@anonymous
class ContextOptions {
  external String get baseUrl;

  String requestCredentials = 'include';

  // Must have an unnamed factory constructor with named arguments.
  external factory ContextOptions({String baseUrl});
}

@JS()
@anonymous
class FronteggOptions {
  external ContextOptions get contextOptions;

  external String get version;

  external String get cred;


  // Must have an unnamed factory constructor with named arguments.
  external factory FronteggOptions(
      {ContextOptions contextOptions, String version});
}

@JS()
@anonymous
class User {
  external String get id;

  external String get email;

  external String get name;

  external String get accessToken;

  external String get refreshToken;

  external bool get mfaEnrolled;

  external String get phoneNumber;

  external String get profilePictureUrl;

  external String get tenantId;

  external JsArray<String> get tenantIds;

  external bool get activatedForTenant;

  external JsObject get metadata;

  external JsArray<String> get roleIds;

  external bool get verified;
}

@JS()
@anonymous
class AuthState {
  external User get user;

  external bool get isAuthenticated;

  external bool get isLoading;
}

@JS()
@anonymous
class FronteggState {
  external AuthState get authState;
}

@JS()
@anonymous
class FronteggApp {
  external mountAdminPortal();

  external onLoad(Function() callback);

  external onStoreChange(Function(FronteggState state) callback);
}

@JS('initialize')
external FronteggApp initialize(FronteggOptions options);
