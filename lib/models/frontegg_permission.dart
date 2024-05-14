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

import 'package:frontegg/utils.dart';

class FronteggPermission {
  final String id;
  final String key;
  final String name;
  final String categoryId;
  final String description;
  final bool fePermission;
  final DateTime createdAt;
  final DateTime updatedAt;

  FronteggPermission({
    required this.id,
    required this.key,
    required this.name,
    required this.categoryId,
    required this.description,
    required this.fePermission,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'name': name,
      'categoryId': categoryId,
      'description': description,
      'fePermission': fePermission,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory FronteggPermission.fromMap(Map<Object?, Object?> map) {
    return FronteggPermission(
      id: map['id'] as String,
      key: map['key'] as String,
      name: map['name'] as String,
      categoryId: map['categoryId'] as String,
      description: map['description'] as String,
      fePermission: map['fePermission'] as bool,
      createdAt: (map['createdAt'] as String).toDateTime(),
      updatedAt: (map['updatedAt'] as String).toDateTime(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FronteggPermission &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          key == other.key &&
          name == other.name &&
          categoryId == other.categoryId &&
          description == other.description &&
          fePermission == other.fePermission &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      key.hashCode ^
      name.hashCode ^
      categoryId.hashCode ^
      description.hashCode ^
      fePermission.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
