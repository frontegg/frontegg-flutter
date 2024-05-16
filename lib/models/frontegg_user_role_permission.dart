// {
// categoryId: 0c587ef6-eb9e-4a10-b888-66ec4bcb1548,
// createdAt: 2024-03-21T07:27:46.000Z,
// description: View all applications in the account,
//     fePermission: true,
// id: 0e8c0103-feb1-4ae0-8230-00de5fd0f857,
// key: fe.account-settings.read.app,
// name: Read application,
//     updatedAt: 2024-03-21T07:27:46.000Z
// },

import 'package:frontegg/inner_utils.dart';

class FronteggUserRolePermission {
  final String id;
  final String key;
  final String name;
  final String? description;
  final String categoryId;
  final bool fePermission;
  final DateTime createdAt;
  final DateTime updatedAt;

  FronteggUserRolePermission({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.fePermission,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'fePermission': fePermission,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory FronteggUserRolePermission.fromMap(Map<Object?, Object?> map) {
    return FronteggUserRolePermission(
      id: map['id'] as String,
      key: map['key'] as String,
      name: map['name'] as String,
      categoryId: map['categoryId'] as String,
      description: map['description'] as String?,
      fePermission: map['fePermission'] as bool,
      createdAt: (map['createdAt'] as String).toDateTime(),
      updatedAt: (map['updatedAt'] as String).toDateTime(),
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
}
