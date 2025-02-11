import 'package:frontegg_flutter/frontegg_flutter.dart';

/// Represents the authentication state in the Frontegg system.
class FronteggState {
  /// The access token for authenticated requests, or `null` if not authenticated.
  final String? accessToken;

  /// The refresh token used to obtain a new access token, or `null` if not available.
  final String? refreshToken;

  /// The authenticated user details, or `null` if not logged in.
  final FronteggUser? user;

  /// Whether the user is authenticated.
  final bool isAuthenticated;

  /// Whether an authentication-related operation is currently in progress.
  final bool isLoading;

  /// Whether the authentication state is still initializing.
  final bool initializing;

  /// Whether to show a loader (e.g., during authentication transitions).
  final bool showLoader;

  /// Whether the authentication process involves an app link.
  final bool appLink;

  /// Whether the token is currently being refreshed.
  final bool refreshingToken;

  /// Creates a [FronteggState] instance with the given parameters.
  const FronteggState({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.isAuthenticated = false,
    this.isLoading = true,
    this.initializing = true,
    this.showLoader = true,
    this.appLink = false,
    this.refreshingToken = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FronteggState &&
          runtimeType == other.runtimeType &&
          accessToken == other.accessToken &&
          refreshToken == other.refreshToken &&
          user == other.user &&
          isAuthenticated == other.isAuthenticated &&
          isLoading == other.isLoading &&
          initializing == other.initializing &&
          appLink == other.appLink &&
          showLoader == other.showLoader &&
          refreshingToken == other.refreshingToken;

  @override
  int get hashCode =>
      accessToken.hashCode ^
      refreshToken.hashCode ^
      user.hashCode ^
      isAuthenticated.hashCode ^
      isLoading.hashCode ^
      initializing.hashCode ^
      appLink.hashCode ^
      showLoader.hashCode ^
      refreshingToken.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "accessToken": accessToken,
      "refreshToken": refreshToken,
      "user": user,
      "isAuthenticated": isAuthenticated,
      "isLoading": isLoading,
      "initializing": initializing,
      "appLink": appLink,
      "showLoader": showLoader,
      "refreshingToken": refreshingToken,
    };
  }

  factory FronteggState.fromMap(Map<Object?, Object?> map) {
    var user = map["user"] as Map<Object?, Object?>?;

    return FronteggState(
      accessToken: map["accessToken"] as String?,
      refreshToken: map["refreshToken"] as String?,
      user: user != null ? FronteggUser.fromMap(user) : null,
      isAuthenticated: map["isAuthenticated"] as bool,
      isLoading: map["isLoading"] as bool,
      initializing: map["initializing"] as bool,
      showLoader: map["showLoader"] as bool,
      appLink: map["appLink"] as bool,
      refreshingToken: map["refreshingToken"] as bool,
    );
  }

  @override
  String toString() {
    return 'FronteggState{accessToken: $accessToken, refreshToken: $refreshToken, user: $user, isAuthenticated: $isAuthenticated, isLoading: $isLoading, initializing: $initializing, showLoader: $showLoader, appLink: $appLink, refreshingToken: $refreshingToken}';
  }
}
