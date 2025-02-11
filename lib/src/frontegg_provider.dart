import "package:flutter/material.dart";
import "package:frontegg_flutter/src/frontegg_flutter.dart";

/// Provides the [FronteggFlutter] instance to the widget tree.
///
/// This class is an [InheritedWidget] that allows descendant widgets to access
/// the [FronteggFlutter] instance for authentication and user management.
class FronteggProvider extends InheritedWidget {
  /// The singleton instance of [FronteggFlutter] used for authentication.
  final FronteggFlutter value = FronteggFlutter();

  /// Creates a [FronteggProvider] and wraps the given [child] widget.
  FronteggProvider({
    super.key,
    required super.child,
  });

  /// Determines whether the widget should notify dependents when updated.
  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) =>
      this != oldWidget;

  /// Retrieves the nearest [FronteggProvider] instance in the widget tree, if available.
  static FronteggProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FronteggProvider>();
  }

  /// Retrieves the nearest [FronteggProvider] instance in the widget tree.
  ///
  /// Throws an assertion error if no [FronteggProvider] is found.
  static FronteggFlutter of(BuildContext context) {
    final FronteggProvider? result = maybeOf(context);
    assert(result != null, "No FronteggProvider found in context");
    return result!.value;
  }

  /// Creates an [InheritedElement] with a dispose callback for cleanup.
  @override
  InheritedElement createElement() => _FronteggProviderInheritedElement(
        this,
        dispose: () async {
          await value.dispose();
        },
      );
}

/// A custom [InheritedElement] for [FronteggProvider] that ensures proper resource cleanup.
class _FronteggProviderInheritedElement extends InheritedElement {
  /// Callback function to dispose of resources when the widget is unmounted.
  final void Function() dispose;

  /// Creates an [_FronteggProviderInheritedElement] with the given [dispose] function.
  _FronteggProviderInheritedElement(
    super.widget, {
    required this.dispose,
  });

  /// Ensures resources are disposed of when the widget is removed from the tree.
  @override
  void unmount() {
    dispose();
    super.unmount();
  }
}
