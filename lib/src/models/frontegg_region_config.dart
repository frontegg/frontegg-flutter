/// The configuration of one region in a multi-region Frontegg setup.
class FronteggRegionConfig {
  /// The unique key of the region, for example `"eu"` or `"us"`.
  final String key;

  /// The Frontegg base URL of the region.
  final String baseUrl;

  /// The Frontegg client ID of the region.
  final String clientId;

  /// The optional Frontegg application ID of the region.
  final String? applicationId;

  /// Creates a [FronteggRegionConfig] instance.
  const FronteggRegionConfig({
    required this.key,
    required this.baseUrl,
    required this.clientId,
    this.applicationId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FronteggRegionConfig &&
          runtimeType == other.runtimeType &&
          key == other.key &&
          baseUrl == other.baseUrl &&
          clientId == other.clientId &&
          applicationId == other.applicationId;

  @override
  int get hashCode =>
      key.hashCode ^
      baseUrl.hashCode ^
      clientId.hashCode ^
      applicationId.hashCode;

  Map<String, dynamic> toMap() {
    return {
      "key": key,
      "baseUrl": baseUrl,
      "clientId": clientId,
      "applicationId": applicationId,
    };
  }

  factory FronteggRegionConfig.fromMap(Map<Object?, Object?> map) {
    return FronteggRegionConfig(
      key: map["key"] as String,
      baseUrl: map["baseUrl"] as String,
      clientId: map["clientId"] as String,
      applicationId: map["applicationId"] as String?,
    );
  }

  @override
  String toString() {
    return 'FronteggRegionConfig{key: $key, baseUrl: $baseUrl, clientId: $clientId, applicationId: $applicationId}';
  }
}
