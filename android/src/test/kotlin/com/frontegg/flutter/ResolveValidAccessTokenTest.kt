package com.frontegg.flutter

import com.frontegg.android.FronteggAuth
import com.frontegg.android.utils.ObservableValue
import kotlinx.coroutines.runBlocking
import java.lang.reflect.InvocationHandler
import java.lang.reflect.Proxy
import java.util.Base64
import kotlin.concurrent.thread
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertNull

internal class ResolveValidAccessTokenTest {

    private val expiredAccessToken = jwtExpiringAt(epochSeconds = 1)
    private val validAccessToken = jwtExpiringAt(epochSeconds = System.currentTimeMillis() / 1000 + 3600)

    private fun jwtExpiringAt(epochSeconds: Long): String {
        val encoder = Base64.getUrlEncoder().withoutPadding()
        val header = encoder.encodeToString("""{"alg":"none"}""".toByteArray())
        val payload = encoder.encodeToString("""{"exp":$epochSeconds}""".toByteArray())
        return "$header.$payload.signature"
    }

    private val accessTokenValue = ObservableValue<String?>(null)
    private val refreshTokenValue = ObservableValue<String?>(null)
    private val refreshingTokenValue = ObservableValue(false)
    private var refreshCount = 0

    private fun authWithSession(
        accessToken: String?,
        refreshToken: String? = "refresh-token",
        isMultiRegion: Boolean = false,
        refresh: (attempt: Int) -> Boolean = { false },
    ): FronteggAuth {
        accessTokenValue.value = accessToken
        refreshTokenValue.value = refreshToken
        val handler = InvocationHandler { _, method, _ ->
            when (method.name) {
                "isMultiRegion" -> isMultiRegion
                "getSelectedRegion" -> null
                "getInitializing" -> ObservableValue(false)
                "getRefreshingToken" -> refreshingTokenValue
                "getAccessToken" -> accessTokenValue
                "getRefreshToken" -> refreshTokenValue
                "refreshTokenAndWait" -> refresh(++refreshCount)
                else -> throw UnsupportedOperationException(method.name)
            }
        }
        return Proxy.newProxyInstance(javaClass.classLoader, arrayOf(FronteggAuth::class.java), handler) as FronteggAuth
    }

    @Test
    fun offlineModeOn_noNetwork_returnsCachedTokenWithoutRefreshing() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = expiredAccessToken)

        val accessToken = resolveValidAccessToken(auth, isOfflineModeEnabled = true) { false }

        assertEquals(expiredAccessToken, accessToken)
        assertEquals(0, refreshCount)
    }

    @Test
    fun offlineModeOff_noNetwork_failsWithoutRefreshing() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = expiredAccessToken)

        assertFailsWith<IllegalStateException> {
            resolveValidAccessToken(auth, isOfflineModeEnabled = false) { false }
        }
        assertEquals(0, refreshCount)
    }

    @Test
    fun validAccessToken_isReturnedWithoutRefreshing() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = validAccessToken)

        val accessToken = resolveValidAccessToken(auth, isOfflineModeEnabled = false) { false }

        assertEquals(validAccessToken, accessToken)
        assertEquals(0, refreshCount)
    }

    @Test
    fun noRefreshToken_returnsNull() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = null, refreshToken = null)

        assertNull(resolveValidAccessToken(auth, isOfflineModeEnabled = true) { true })
    }

    @Test
    fun multiRegionWithoutSelectedRegion_returnsNull() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = validAccessToken, isMultiRegion = true)

        assertNull(resolveValidAccessToken(auth, isOfflineModeEnabled = true) { true })
    }

    @Test
    fun refreshSucceeds_returnsNewToken() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = expiredAccessToken) {
            accessTokenValue.value = validAccessToken
            true
        }

        assertEquals(validAccessToken, resolveValidAccessToken(auth, isOfflineModeEnabled = false) { true })
        assertEquals(1, refreshCount)
    }

    @Test
    fun refreshReportsSuccessDuringBackgroundRefresh_waitsForNewToken() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = expiredAccessToken) {
            refreshingTokenValue.value = true
            thread {
                Thread.sleep(300)
                accessTokenValue.value = validAccessToken
                refreshingTokenValue.value = false
            }
            true
        }

        assertEquals(validAccessToken, resolveValidAccessToken(auth, isOfflineModeEnabled = false) { true })
        assertEquals(1, refreshCount)
    }

    @Test
    fun refreshReportsSuccessWithStaleToken_retriesOnce() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = expiredAccessToken) { attempt ->
            if (attempt == 2) accessTokenValue.value = validAccessToken
            true
        }

        assertEquals(validAccessToken, resolveValidAccessToken(auth, isOfflineModeEnabled = false) { true })
        assertEquals(2, refreshCount)
    }

    @Test
    fun refreshFails_refreshTokenCleared_returnsNull() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = expiredAccessToken) {
            refreshTokenValue.value = null
            false
        }

        assertNull(resolveValidAccessToken(auth, isOfflineModeEnabled = true) { true })
    }

    @Test
    fun refreshFails_offlineModeOn_networkLost_returnsCachedToken() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = expiredAccessToken) { false }
        var networkChecks = 0

        val accessToken = resolveValidAccessToken(auth, isOfflineModeEnabled = true) { networkChecks++ == 0 }

        assertEquals(expiredAccessToken, accessToken)
    }

    @Test
    fun refreshFails_otherwise_throws() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = expiredAccessToken) { false }

        assertFailsWith<IllegalStateException> {
            resolveValidAccessToken(auth, isOfflineModeEnabled = false) { true }
        }
    }
}
