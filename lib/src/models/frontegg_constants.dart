class FronteggConstants {
  final String baseUrl;
  final String clientId;
  final String? applicationId;
  final bool? useAssetsLinks;
  final bool? useChromeCustomTabs;
  final String bundleId;

  const FronteggConstants({
    required this.baseUrl,
    required this.clientId,
    this.applicationId,
    this.useAssetsLinks,
    this.useChromeCustomTabs,
    required this.bundleId,
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
          bundleId == other.bundleId;

  @override
  int get hashCode =>
      baseUrl.hashCode ^
      clientId.hashCode ^
      applicationId.hashCode ^
      useAssetsLinks.hashCode ^
      useChromeCustomTabs.hashCode ^
      bundleId.hashCode;

  factory FronteggConstants.fromMap(Map<Object?, Object?> map) {
    return FronteggConstants(
      baseUrl: map["baseUrl"] as String,
      clientId: map["clientId"] as String,
      applicationId: map["applicationId"] as String?,
      useAssetsLinks: map["useAssetsLinks"] as bool?,
      useChromeCustomTabs: map["useChromeCustomTabs"] as bool?,
      bundleId: map["bundleId"] as String,
    );
  }

  @override
  String toString() {
    return 'FronteggConstants{baseUrl: $baseUrl, clientId: $clientId, applicationId: $applicationId, useAssetsLinks: $useAssetsLinks, useChromeCustomTabs: $useChromeCustomTabs, bundleId: $bundleId}';
  }
}
