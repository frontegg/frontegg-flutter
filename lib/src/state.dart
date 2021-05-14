@JS('Frontegg')
library frontegg_state;

import 'dart:js';
import 'package:js/js.dart';

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

  external String get metadata;

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
  external AuthState get auth;
}
