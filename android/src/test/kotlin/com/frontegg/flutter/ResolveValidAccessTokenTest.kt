package com.frontegg.flutter

import com.frontegg.android.FronteggAuth
import com.frontegg.android.utils.ObservableValue
import kotlinx.coroutines.runBlocking
import org.mockito.Mockito.mock
import org.mockito.Mockito.mockingDetails
import org.mockito.Mockito.`when`
import java.util.Base64
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFailsWith
import kotlin.test.assertFalse
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

    private fun authWithSession(accessToken: String?, refreshToken: String? = "refresh-token"): FronteggAuth {
        val auth = mock(FronteggAuth::class.java)
        `when`(auth.isMultiRegion).thenReturn(false)
        `when`(auth.initializing).thenReturn(ObservableValue(false))
        `when`(auth.refreshingToken).thenReturn(ObservableValue(false))
        `when`(auth.accessToken).thenReturn(ObservableValue(accessToken))
        `when`(auth.refreshToken).thenReturn(ObservableValue(refreshToken))
        return auth
    }

    private fun refreshWasRequested(auth: FronteggAuth): Boolean =
        mockingDetails(auth).invocations.any { it.method.name == "refreshTokenAndWait" }

    @Test
    fun offlineModeOn_noNetwork_returnsCachedTokenWithoutRefreshing() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = expiredAccessToken)

        val accessToken = resolveValidAccessToken(auth, isOfflineModeEnabled = true) { false }

        assertEquals(expiredAccessToken, accessToken)
        assertFalse(refreshWasRequested(auth))
    }

    @Test
    fun offlineModeOff_noNetwork_failsWithoutRefreshing() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = expiredAccessToken)

        assertFailsWith<IllegalStateException> {
            resolveValidAccessToken(auth, isOfflineModeEnabled = false) { false }
        }
        assertFalse(refreshWasRequested(auth))
    }

    @Test
    fun validAccessToken_isReturnedWithoutRefreshing() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = validAccessToken)

        val accessToken = resolveValidAccessToken(auth, isOfflineModeEnabled = false) { false }

        assertEquals(validAccessToken, accessToken)
        assertFalse(refreshWasRequested(auth))
    }

    @Test
    fun noRefreshToken_returnsNull() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = null, refreshToken = null)

        assertNull(resolveValidAccessToken(auth, isOfflineModeEnabled = true) { true })
    }

    @Test
    fun multiRegionWithoutSelectedRegion_returnsNull() = runBlocking<Unit> {
        val auth = authWithSession(accessToken = validAccessToken)
        `when`(auth.isMultiRegion).thenReturn(true)
        `when`(auth.selectedRegion).thenReturn(null)

        assertNull(resolveValidAccessToken(auth, isOfflineModeEnabled = true) { true })
    }
}
