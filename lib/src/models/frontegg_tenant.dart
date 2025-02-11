import "package:frontegg_flutter/src/inner_utils.dart";

/// Represents a tenant in the Frontegg authentication system.
class FronteggTenant {
  /// Unique identifier for the tenant.
  final String id;

  /// Name of the tenant.
  final String name;

  /// Email of the tenant's creator, if available.
  final String? creatorEmail;

  /// Name of the tenant's creator, if available.
  final String? creatorName;

  /// Unique identifier for the tenant within the Frontegg system.
  final String tenantId;

  /// Unique identifier for the vendor associated with this tenant.
  final String vendorId;

  /// Indicates whether the tenant is a reseller.
  final bool isReseller;

  /// Metadata associated with the tenant.
  final String metadata;

  /// The date and time when the tenant was created.
  final DateTime createdAt;

  /// The date and time when the tenant was last updated.
  final DateTime updatedAt;

  /// The website URL associated with the tenant, if available.
  final String? website;

  /// Creates a [FronteggTenant] instance with the given parameters.
  const FronteggTenant({
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

  factory FronteggTenant.fromMap(Map<Object?, Object?> map) {
    return FronteggTenant(
      id: map["id"] as String,
      tenantId: map["tenantId"] as String,
      name: map["name"] as String,
      creatorEmail: map["creatorEmail"] as String?,
      creatorName: map["creatorName"] as String?,
      vendorId: map["vendorId"] as String,
      isReseller: map["isReseller"] as bool,
      metadata: map["metadata"] as String,
      createdAt: (map["createdAt"] as String).toDateTime(),
      updatedAt: (map["updatedAt"] as String).toDateTime(),
      website: map["website"] as String?,
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

  @override
  String toString() {
    return 'FronteggTenant{id: $id, name: $name, creatorEmail: $creatorEmail, creatorName: $creatorName, tenantId: $tenantId, vendorId: $vendorId, isReseller: $isReseller, metadata: $metadata, createdAt: $createdAt, updatedAt: $updatedAt, website: $website}';
  }
}
