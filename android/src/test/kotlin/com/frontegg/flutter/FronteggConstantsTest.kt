package com.frontegg.flutter

import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * FR-25941: the Android constants map omitted `clientId`, but Dart's
 * `FronteggConstants.fromMap` casts `map["clientId"] as String` (non-nullable),
 * so every Android `getConstants()` call threw a TypeError. iOS already returns it.
 */
internal class FronteggConstantsTest {

    @Test
    fun buildFronteggConstants_includesClientId() {
        val constants = buildFronteggConstants(
            baseUrl = "https://base.url.com",
            clientId = "test-client-id",
            applicationId = null,
            useAssetsLinks = false,
            useChromeCustomTabs = false,
            bundleId = "com.example.app",
            deepLinkScheme = null,
            useDiskCacheWebview = false,
        )

        assertTrue(
            constants.containsKey("clientId"),
            "Android constants must include clientId — Dart casts it as a non-null String",
        )
        assertEquals("test-client-id", constants["clientId"])
    }
}
