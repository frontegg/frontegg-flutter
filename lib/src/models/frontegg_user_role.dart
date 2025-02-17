import "package:flutter/foundation.dart";
import "package:frontegg_flutter/src/inner_utils.dart";

/// Represents a user role in the Frontegg authentication system.
class FronteggUserRole {
  /// Unique identifier for the role.
  final String id;

  /// Unique key representing the role.
  final String key;

  /// Indicates whether this role is the default role.
  final bool isDefault;

  /// Name of the role.
  final String name;

  /// Optional description of the role.
  final String? description;

  /// List of permission identifiers associated with this role.
  final List<String> permissions;

  /// Optional tenant ID this role is associated with.
  final String? tenantId;

  /// Unique identifier for the vendor associated with this role.
  final String vendorId;

  /// The date and time when the role was created.
  final DateTime createdAt;

  /// The date and time when the role was last updated.
  final DateTime updatedAt;

  /// Creates a [FronteggUserRole] instance with the given parameters.
  const FronteggUserRole({
    required this.id,
    required this.key,
    required this.isDefault,
    required this.name,
    this.description,
    required this.permissions,
    this.tenantId,
    required this.vendorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FronteggUserRole.fromMap(Map<Object?, Object?> map) {
    return FronteggUserRole(
      id: map["id"] as String,
      key: map["key"] as String,
      isDefault: map["isDefault"] as bool,
      name: map["name"] as String,
      description: map["description"] as String?,
      permissions: (map["permissions"] as List<Object?>)
          .map((e) => e.toString())
          .toList(),
      tenantId: map["tenantId"] as String?,
      vendorId: map["vendorId"] as String,
      createdAt: (map["createdAt"] as String).toDateTime(),
      updatedAt: (map["updatedAt"] as String).toDateTime(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FronteggUserRole &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          key == other.key &&
          isDefault == other.isDefault &&
          name == other.name &&
          description == other.description &&
          listEquals(permissions, other.permissions) &&
          tenantId == other.tenantId &&
          vendorId == other.vendorId &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      key.hashCode ^
      isDefault.hashCode ^
      name.hashCode ^
      description.hashCode ^
      permissions.hashCode ^
      tenantId.hashCode ^
      vendorId.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'FronteggUserRole{id: $id, key: $key, isDefault: $isDefault, name: $name, description: $description, permissions: $permissions, tenantId: $tenantId, vendorId: $vendorId, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
