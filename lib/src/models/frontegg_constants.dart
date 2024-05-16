class FronteggConstants {
  final String baseUrl;
  final String clientId;
  final bool? useAssetsLinks;
  final bool? useChromeCustomTabs;
  final String bundleId;

  FronteggConstants({
    required this.baseUrl,
    required this.clientId,
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
          useAssetsLinks == other.useAssetsLinks &&
          useChromeCustomTabs == other.useChromeCustomTabs &&
          bundleId == other.bundleId;

  @override
  int get hashCode =>
      baseUrl.hashCode ^
      clientId.hashCode ^
      useAssetsLinks.hashCode ^
      useChromeCustomTabs.hashCode ^
      bundleId.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "baseUrl": baseUrl,
      "clientId": clientId,
      "useAssetsLinks": useAssetsLinks,
      "useChromeCustomTabs": useChromeCustomTabs,
      "bundleId": bundleId,
    };
  }

  factory FronteggConstants.fromMap(Map<Object?, Object?> map) {
    return FronteggConstants(
      baseUrl: map["baseUrl"] as String,
      clientId: map["clientId"] as String,
      useAssetsLinks: map["useAssetsLinks"] as bool?,
      useChromeCustomTabs: map["useChromeCustomTabs"] as bool?,
      bundleId: map["bundleId"] as String,
    );
  }
}
