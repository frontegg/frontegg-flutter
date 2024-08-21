class FronteggConstants {
  final String baseUrl;
  final String clientId;
  final String? applicationId;

  /// Android Only
  final bool? useAssetsLinks;

  /// Android Only
  final bool? useChromeCustomTabs;

  /// iOS Only
  final bool? handleLoginWithSocialLogin;

  /// iOS Only
  final bool? handleLoginWithSSO;

  const FronteggConstants({
    required this.baseUrl,
    required this.clientId,
    this.applicationId,
    this.useAssetsLinks,
    this.useChromeCustomTabs,
    this.handleLoginWithSocialLogin,
    this.handleLoginWithSSO,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FronteggConstants &&
          runtimeType == other.runtimeType &&
          baseUrl == other.baseUrl &&
          clientId == other.clientId &&
          applicationId == other.applicationId &&
          useAssetsLinks == other.useAssetsLinks &&
          useChromeCustomTabs == other.useChromeCustomTabs &&
          handleLoginWithSocialLogin == other.handleLoginWithSocialLogin &&
          handleLoginWithSSO == other.handleLoginWithSSO;

  @override
  int get hashCode =>
      baseUrl.hashCode ^
      clientId.hashCode ^
      useAssetsLinks.hashCode ^
      useChromeCustomTabs.hashCode ^
      handleLoginWithSocialLogin.hashCode ^
      handleLoginWithSSO.hashCode;

  factory FronteggConstants.fromMap(Map<Object?, Object?> map) {
    return FronteggConstants(
      baseUrl: map["baseUrl"] as String,
      clientId: map["clientId"] as String,
      useAssetsLinks: map["useAssetsLinks"] as bool?,
      useChromeCustomTabs: map["useChromeCustomTabs"] as bool?,
      handleLoginWithSocialLogin: map["handleLoginWithSocialLogin"] as bool?,
      handleLoginWithSSO: map["handleLoginWithSSO"] as bool?,
    );
  }

  @override
  String toString() {
    return 'FronteggConstants{baseUrl: $baseUrl, clientId: $clientId, useAssetsLinks: $useAssetsLinks, useChromeCustomTabs: $useChromeCustomTabs}';
  }

  Map<String, dynamic> toMap() {
    return {
      'baseUrl': baseUrl,
      'clientId': clientId,
      'useAssetsLinks': useAssetsLinks,
      'useChromeCustomTabs': useChromeCustomTabs,
      'applicationId': applicationId,
      'handleLoginWithSocialLogin': handleLoginWithSocialLogin,
      'handleLoginWithSSO': handleLoginWithSSO,
    };
  }

  FronteggConstants copyWith({
    String? baseUrl,
    String? clientId,
    String? applicationId,
    bool? useAssetsLinks,
    bool? useChromeCustomTabs,
    bool? handleLoginWithSocialLogin,
    bool? handleLoginWithSSO,
  }) {
    return FronteggConstants(
      baseUrl: baseUrl ?? this.baseUrl,
      clientId: clientId ?? this.clientId,
      applicationId: applicationId ?? this.applicationId,
      useAssetsLinks: useAssetsLinks ?? this.useAssetsLinks,
      useChromeCustomTabs: useChromeCustomTabs ?? this.useChromeCustomTabs,
      handleLoginWithSocialLogin: handleLoginWithSocialLogin ?? this.handleLoginWithSocialLogin,
      handleLoginWithSSO: handleLoginWithSSO ?? this.handleLoginWithSSO,
    );
  }
}
