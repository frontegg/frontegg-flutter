import 'package:frontegg/frontegg_flutter.dart';

class FronteggState {
  final String? accessToken;
  final String? refreshToken;
  final FronteggUser? user;
  final bool isAuthenticated;
  final bool isLoading;
  final bool initializing;
  final bool showLoader;
  final bool appLink;

  const FronteggState({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.isAuthenticated = false,
    this.isLoading = true,
    this.initializing = true,
    this.showLoader = true,
    this.appLink = false,
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
          showLoader == other.showLoader;

  @override
  int get hashCode =>
      accessToken.hashCode ^
      refreshToken.hashCode ^
      user.hashCode ^
      isAuthenticated.hashCode ^
      isLoading.hashCode ^
      initializing.hashCode ^
      appLink.hashCode ^
      showLoader.hashCode;

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
    );
  }

  @override
  String toString() {
    return 'FronteggState{accessToken: $accessToken, refreshToken: $refreshToken, user: $user, isAuthenticated: $isAuthenticated, isLoading: $isLoading, initializing: $initializing, showLoader: $showLoader, appLink: $appLink}';
  }
}
