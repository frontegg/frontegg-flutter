import 'package:flutter/cupertino.dart';
import 'package:frontegg/frontegg.dart';
import 'package:frontegg/provider.dart';

extension FronteggBuildContextEx on BuildContext {
  FronteggFlutter get frontegg => FronteggProvider.of(this);
}
