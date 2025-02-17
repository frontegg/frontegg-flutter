import 'package:flutter/cupertino.dart';
import 'package:frontegg_flutter/src/frontegg_flutter.dart';
import 'package:frontegg_flutter/src/frontegg_provider.dart';

/// An extension on [BuildContext] to provide easy access to [FronteggFlutter].
extension FronteggBuildContextEx on BuildContext {
  /// Retrieves the [FronteggFlutter] instance from the nearest [FronteggProvider].
  ///
  /// This allows accessing Frontegg's authentication and user management
  /// functionalities directly from any widget using:
  /// ```dart
  /// context.frontegg
  /// ```
  ///
  /// Throws an assertion error if no [FronteggProvider] is found in the widget tree.
  FronteggFlutter get frontegg => FronteggProvider.of(this);
}
