@JS('Frontegg')
library frontegg_options;

import 'package:js/js.dart';

@JS()
@anonymous
class ContextOptions {
  external String get baseUrl;

  external String get requestCredentials;

  // Must have an unnamed factory constructor with named arguments.
  external factory ContextOptions({String baseUrl, String requestCredentials});
}

@JS()
@anonymous
class FronteggOptions {
  external ContextOptions get contextOptions;

  external String get version;

  // Must have an unnamed factory constructor with named arguments.
  external factory FronteggOptions({
    ContextOptions contextOptions,
    String version,
    Function(String path) onRedirectTo,
  });
}
