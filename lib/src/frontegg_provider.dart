import "package:flutter/material.dart";
import "package:frontegg/src/frontegg_flutter.dart";

class FronteggProvider extends InheritedWidget {
  final _value = FronteggFlutter();

  FronteggProvider({
    super.key,
    required super.child,
  });

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;

  static FronteggProvider? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FronteggProvider>();
  }

  static FronteggFlutter of(BuildContext context) {
    final FronteggProvider? result = maybeOf(context);
    assert(result != null, "No FronteggProvider found in context");
    return result!._value;
  }

  @override
  InheritedElement createElement() => _FronteggProviderInheritedElement(
        this,
        dispose: () async {
          await _value.dispose();
        },
      );
}

class _FronteggProviderInheritedElement extends InheritedElement {
  final void Function() dispose;

  _FronteggProviderInheritedElement(
    super.widget, {
    required this.dispose,
  });

  @override
  void unmount() {
    dispose();
    super.unmount();
  }
}
