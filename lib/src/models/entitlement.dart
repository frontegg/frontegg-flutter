/// Result of an entitlement check via
/// [FronteggFlutter.getFeatureEntitlement] / [FronteggFlutter.getPermissionEntitlement].
///
/// Evaluated on-device from the in-memory entitlements state populated by the last
/// successful [FronteggFlutter.loadEntitlements] call, so a check is cheap and synchronous
/// on the native side.
class Entitlement {
  /// Whether the user is entitled to the requested feature/permission.
  final bool isEntitled;

  /// When [isEntitled] is `false`, the reason code — one of the canonical values mirrored
  /// from `@frontegg/entitlements-javascript-commons` (`MISSING_FEATURE`,
  /// `MISSING_PERMISSION`, `BUNDLE_EXPIRED`) plus the mobile-specific preconditions
  /// (`NOT_AUTHENTICATED`, `ENTITLEMENTS_DISABLED`, `ENTITLEMENTS_NOT_LOADED`). `null` when
  /// [isEntitled] is `true`.
  final String? justification;

  const Entitlement({
    required this.isEntitled,
    this.justification,
  });

  factory Entitlement.fromMap(Map<Object?, Object?> map) {
    return Entitlement(
      isEntitled: map["isEntitled"] as bool? ?? false,
      justification: map["justification"] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Entitlement &&
          runtimeType == other.runtimeType &&
          isEntitled == other.isEntitled &&
          justification == other.justification;

  @override
  int get hashCode => isEntitled.hashCode ^ justification.hashCode;

  @override
  String toString() =>
      "Entitlement(isEntitled: $isEntitled, justification: $justification)";
}
