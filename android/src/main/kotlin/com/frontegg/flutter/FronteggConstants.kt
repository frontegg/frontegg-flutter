package com.frontegg.flutter

data class FronteggConstants(
    val baseUrl: String,
    val clientId: String,
    val applicationId: String?,
    val useAssetsLinks: Boolean,
    val useChromeCustomTabs: Boolean,
    val bundleId: String,
    val deepLinkScheme: String,
    val useDiskCacheWebview: Boolean
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            Pair("baseUrl", baseUrl),
            Pair("clientId", clientId),
            Pair("applicationId", applicationId),
            Pair("useAssetsLinks", useAssetsLinks),
            Pair("useChromeCustomTabs", useChromeCustomTabs),
            Pair("bundleId", bundleId),
            Pair("deepLinkScheme", deepLinkScheme),
            Pair("useDiskCacheWebview", useDiskCacheWebview),
        )
    }
}