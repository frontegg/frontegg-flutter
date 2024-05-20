import 'package:flutter/cupertino.dart';
import 'package:frontegg/src/frontegg_flutter.dart';
import 'package:frontegg/src/frontegg_provider.dart';

extension FronteggBuildContextEx on BuildContext {
  FronteggFlutter get frontegg => FronteggProvider.of(this);
}
