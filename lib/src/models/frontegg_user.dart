import "package:flutter/foundation.dart";

import "frontegg_tenant.dart";
import "frontegg_user_role.dart";
import "frontegg_user_role_permission.dart";

class FronteggUser {
  final String id;
  final String email;
  final bool mfaEnrolled;
  final String name;
  final String profilePictureUrl;
  final String? phoneNumber;
  final String? profileImage;
  final List<FronteggUserRole> roles;
  final List<FronteggUserRolePermission> permissions;
  final String tenantId;
  final List<String> tenantIds;
  final List<FronteggTenant> tenants;
  final FronteggTenant activeTenant;
  final bool activatedForTenant;
  final String? metadata;
  final bool verified;
  final bool superUser;

  const FronteggUser({
    required this.id,
    required this.email,
    required this.mfaEnrolled,
    required this.name,
    required this.profilePictureUrl,
    this.phoneNumber,
    this.profileImage,
    required this.roles,
    required this.permissions,
    required this.tenantId,
    required this.tenantIds,
    required this.tenants,
    required this.activeTenant,
    required this.activatedForTenant,
    this.metadata,
    required this.verified,
    required this.superUser,
  });

  factory FronteggUser.fromMap(Map<Object?, Object?> map) {
    return FronteggUser(
      id: map["id"] as String,
      email: map["email"] as String,
      mfaEnrolled: map["mfaEnrolled"] as bool,
      name: map["name"] as String,
      profilePictureUrl: map["profilePictureUrl"] as String,
      phoneNumber: map["phoneNumber"] as String?,
      profileImage: map["profileImage"] as String?,
      roles: (map["roles"] as List<Object?>)
          .map((e) => FronteggUserRole.fromMap(e as Map<Object?, Object?>))
          .toList(),
      permissions: (map["permissions"] as List<Object?>)
          .map((e) => FronteggUserRolePermission.fromMap(e as Map<Object?, Object?>))
          .toList(),
      tenantId: map["tenantId"] as String,
      tenantIds: (map["tenantIds"] as List<Object?>).map((e) => e.toString()).toList(),
      tenants: (map["tenants"] as List<Object?>)
          .map((e) => FronteggTenant.fromMap(e as Map<Object?, Object?>))
          .toList(),
      activeTenant: FronteggTenant.fromMap(map["activeTenant"] as Map<Object?, Object?>),
      activatedForTenant: map["activatedForTenant"] as bool,
      metadata: map["metadata"] as String?,
      verified: map["verified"] as bool,
      superUser: map["superUser"] as bool,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FronteggUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          mfaEnrolled == other.mfaEnrolled &&
          name == other.name &&
          profilePictureUrl == other.profilePictureUrl &&
          phoneNumber == other.phoneNumber &&
          profileImage == other.profileImage &&
          listEquals(roles, other.roles) &&
          listEquals(permissions, other.permissions) &&
          tenantId == other.tenantId &&
          listEquals(tenantIds, other.tenantIds) &&
          listEquals(tenants, other.tenants) &&
          activeTenant == other.activeTenant &&
          activatedForTenant == other.activatedForTenant &&
          metadata == other.metadata &&
          verified == other.verified &&
          superUser == other.superUser;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      mfaEnrolled.hashCode ^
      name.hashCode ^
      profilePictureUrl.hashCode ^
      phoneNumber.hashCode ^
      profileImage.hashCode ^
      roles.hashCode ^
      permissions.hashCode ^
      tenantId.hashCode ^
      tenantIds.hashCode ^
      tenants.hashCode ^
      activeTenant.hashCode ^
      activatedForTenant.hashCode ^
      metadata.hashCode ^
      verified.hashCode ^
      superUser.hashCode;

  @override
  String toString() {
    return 'FronteggUser{id: $id, email: $email, mfaEnrolled: $mfaEnrolled, name: $name, profilePictureUrl: $profilePictureUrl, phoneNumber: $phoneNumber, profileImage: $profileImage, roles: ${roles.map((e) => e.toString()).toList()}, permissions: ${permissions.map((e) => e.toString()).toList()}, tenantId: $tenantId, tenantIds: $tenantIds, tenants: ${tenants.map((e) => e.toString()).toList()}, activeTenant: $activeTenant, activatedForTenant: $activatedForTenant, metadata: $metadata, verified: $verified, superUser: $superUser}';
  }
}
