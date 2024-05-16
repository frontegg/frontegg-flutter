import 'package:frontegg/inner_utils.dart';

class FronteggTenant {
  final String id;
  final String name;
  final String? creatorEmail;
  final String? creatorName;
  final String tenantId;
  final String vendorId;
  final bool isReseller;
  final String metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? website;

  FronteggTenant({
    required this.id,
    required this.name,
    this.creatorEmail,
    this.creatorName,
    required this.tenantId,
    required this.vendorId,
    required this.isReseller,
    required this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.website,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tenantId': tenantId,
      'name': name,
      'creatorEmail': creatorEmail,
      'creatorName': creatorName,
      'vendorId': vendorId,
      'isReseller': isReseller,
      'metadata': metadata,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'website': website,
    };
  }

  factory FronteggTenant.fromMap(Map<Object?, Object?> map) {
    return FronteggTenant(
      id: map['id'] as String,
      tenantId: map['tenantId'] as String,
      name: map['name'] as String,
      creatorEmail: map['creatorEmail'] as String?,
      creatorName: map['creatorName'] as String?,
      vendorId: map['vendorId'] as String,
      isReseller: map['isReseller'] as bool,
      metadata: map['metadata'] as String,
      createdAt: (map['createdAt'] as String).toDateTime(),
      updatedAt: (map['updatedAt'] as String).toDateTime(),
      website: map['website'] as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FronteggTenant &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          tenantId == other.tenantId &&
          name == other.name &&
          creatorEmail == other.creatorEmail &&
          creatorName == other.creatorName &&
          vendorId == other.vendorId &&
          isReseller == other.isReseller &&
          metadata == other.metadata &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      tenantId.hashCode ^
      name.hashCode ^
      creatorEmail.hashCode ^
      creatorName.hashCode ^
      vendorId.hashCode ^
      isReseller.hashCode ^
      metadata.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
