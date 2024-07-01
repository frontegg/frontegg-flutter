import 'package:flutter/cupertino.dart';
import 'package:frontegg_flutter/src/frontegg_flutter.dart';
import 'package:frontegg_flutter/src/frontegg_provider.dart';

extension FronteggBuildContextEx on BuildContext {
  FronteggFlutter get frontegg => FronteggProvider.of(this);
}
