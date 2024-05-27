import "package:frontegg/src/inner_utils.dart";

class FronteggUserRolePermission {
  final String id;
  final String key;
  final String name;
  final String? description;
  final String categoryId;
  final bool fePermission;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FronteggUserRolePermission({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.fePermission,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FronteggUserRolePermission.fromMap(Map<Object?, Object?> map) {
    return FronteggUserRolePermission(
      id: map["id"] as String,
      key: map["key"] as String,
      name: map["name"] as String,
      categoryId: map["categoryId"] as String,
      description: map["description"] as String?,
      fePermission: map["fePermission"] as bool,
      createdAt: (map["createdAt"] as String).toDateTime(),
      updatedAt: (map["updatedAt"] as String).toDateTime(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FronteggUserRolePermission &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          key == other.key &&
          name == other.name &&
          description == other.description &&
          categoryId == other.categoryId &&
          fePermission == other.fePermission &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      key.hashCode ^
      name.hashCode ^
      description.hashCode ^
      categoryId.hashCode ^
      fePermission.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;

  @override
  String toString() {
    return 'FronteggUserRolePermission{id: $id, key: $key, name: $name, description: $description, categoryId: $categoryId, fePermission: $fePermission, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
