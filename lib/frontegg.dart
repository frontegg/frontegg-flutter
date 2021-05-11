@JS('Frontegg')
library frontegg;

import 'package:js/js.dart';

@JS()
@anonymous
class ContextOptions {
  external String get baseUrl;

  // Must have an unnamed factory constructor with named arguments.
  external factory ContextOptions({String baseUrl});
}

@JS()
@anonymous
class FronteggOptions {
  external ContextOptions get contextOptions;
  external String get version;

  // Must have an unnamed factory constructor with named arguments.
  external factory FronteggOptions({
    ContextOptions contextOptions,
    String version
  });
}

class FronteggApp {}

@JS('initialize')
external FronteggApp initialize(FronteggOptions options);
