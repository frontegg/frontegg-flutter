@JS('Frontegg')
library frontegg_app;

import './state.dart';
import './options.dart';
import 'package:js/js.dart';

@JS()
@anonymous
class FronteggApp {
  external mountAdminPortal();

  external onLoad(Function() callback);

  external onStoreChanged(Function(FronteggState state) callback);
}

@JS('initialize')
external FronteggApp initialize(FronteggOptions options);
