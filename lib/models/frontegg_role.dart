// {
// createdAt:2024-05-13T11:59:55.000Z,
// id: 12c36cb2-67a7-4468-ad8f-c1a0e812805c,
// isDefault: true,
// key: Admin,
// name: Admin,
// permissions: [0e8c0103-feb1-4ae0-8230-00de5fd0f857, 502b112e-50fd-4e8d-875e-3abda628d94a, da015508-7cb1-4dcd-9436-d0518a2ecd21],
// updatedAt: 2024-05-13T11:59:55.000Z,
// vendorId: 392b348b-a37c-471f-8f1b-2c35d23aa7e6}

import 'package:frontegg/utils.dart';

class FronteggRole {
  final String id;
  final String vendorId;
  final String key;
  final String name;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> permissions;

  FronteggRole({
    required this.id,
    required this.vendorId,
    required this.key,
    required this.name,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
    required this.permissions,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vendorId': vendorId,
      'key': key,
      'name': name,
      'isDefault': isDefault,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'permissions': permissions,
    };
  }

  factory FronteggRole.fromMap(Map<Object?, Object?> map) {
    return FronteggRole(
      id: map['id'] as String,
      vendorId: map['vendorId'] as String,
      key: map['key'] as String,
      name: map['name'] as String,
      isDefault: map['isDefault'] as bool,
      createdAt: (map['createdAt'] as String).toDateTime(),
      updatedAt: (map['updatedAt'] as String).toDateTime(),
      permissions: map['permissions'] as List<String>,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FronteggRole &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          vendorId == other.vendorId &&
          key == other.key &&
          name == other.name &&
          isDefault == other.isDefault &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          permissions == other.permissions;

  @override
  int get hashCode =>
      id.hashCode ^
      vendorId.hashCode ^
      key.hashCode ^
      name.hashCode ^
      isDefault.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      permissions.hashCode;
}
