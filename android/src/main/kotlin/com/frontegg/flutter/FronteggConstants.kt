package com.frontegg.flutter

data class FronteggConstants(
    val baseUrl: String,
    val clientId: String,
    val useAssetsLinks: Boolean,
    val useChromeCustomTabs: Boolean,
    val bundleId: String
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            Pair("baseUrl", baseUrl),
            Pair("clientId", clientId),
            Pair("useAssetsLinks", useAssetsLinks),
            Pair("useChromeCustomTabs", useChromeCustomTabs),
            Pair("bundleId", bundleId),
        )
    }
}