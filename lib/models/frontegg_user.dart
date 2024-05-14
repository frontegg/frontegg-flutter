import 'frontegg_permission.dart';
import 'frontegg_tenant.dart';

class FronteggUser {
  final String id;
  final String email;
  final String name;
  final String profilePictureUrl;
  final bool activatedForTenant;
  final bool mfaEnrolled;
  final bool superUser;
  final bool verified;
  final List<FronteggPermission> permissions;
  final FronteggTenant activeTenant;
  final String tenantId;
  final List<String> tenantIds;
  final List<FronteggTenant> tenants;

  FronteggUser({
    required this.id,
    required this.email,
    required this.name,
    required this.profilePictureUrl,
    required this.activatedForTenant,
    required this.mfaEnrolled,
    required this.superUser,
    required this.verified,
    required this.permissions,
    required this.activeTenant,
    required this.tenantId,
    required this.tenantIds,
    required this.tenants,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'profilePictureUrl': profilePictureUrl,
      'activatedForTenant': activatedForTenant,
      'mfaEnrolled': mfaEnrolled,
      'superUser': superUser,
      'verified': verified,
      'permissions': permissions,
      'activeTenant': activeTenant,
      'tenantId': tenantId,
      'tenantIds': tenantIds,
      'tenants': tenants,
    };
  }

  factory FronteggUser.fromMap(Map<Object?, Object?> map) {
    return FronteggUser(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      profilePictureUrl: map['profilePictureUrl'] as String,
      activatedForTenant: map['activatedForTenant'] as bool,
      mfaEnrolled: map['mfaEnrolled'] as bool,
      superUser: map['superUser'] as bool,
      verified: map['verified'] as bool,
      permissions: (map['permissions'] as List<Object?>)
          .map((e) => FronteggPermission.fromMap(e as Map<Object?, Object?>))
          .toList(),
      activeTenant: FronteggTenant.fromMap(map['activeTenant'] as Map<Object?, Object?>),
      tenantId: map['tenantId'] as String,
      tenantIds: (map['tenantIds'] as List<Object?>).map((e) => e.toString()).toList(),
      tenants: (map['tenants'] as List<Object?>)
          .map((e) => FronteggTenant.fromMap(e as Map<Object?, Object?>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FronteggUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          name == other.name &&
          profilePictureUrl == other.profilePictureUrl &&
          activatedForTenant == other.activatedForTenant &&
          mfaEnrolled == other.mfaEnrolled &&
          superUser == other.superUser &&
          verified == other.verified &&
          permissions == other.permissions &&
          activeTenant == other.activeTenant &&
          tenantId == other.tenantId &&
          tenantIds == other.tenantIds &&
          tenants == other.tenants;

  @override
  int get hashCode =>
      id.hashCode ^
      email.hashCode ^
      name.hashCode ^
      profilePictureUrl.hashCode ^
      activatedForTenant.hashCode ^
      mfaEnrolled.hashCode ^
      superUser.hashCode ^
      verified.hashCode ^
      permissions.hashCode ^
      activeTenant.hashCode ^
      tenantId.hashCode ^
      tenantIds.hashCode ^
      tenants.hashCode;
}
