package com.frontegg.demo

import android.content.Context
import com.frontegg.android.EmbeddedAuthActivity
import com.frontegg.android.services.FronteggAppService
import com.frontegg.android.utils.FronteggConstantsProvider
import com.frontegg.android.utils.SentryHelper
import com.frontegg.android.utils.isActivityEnabled

/**
 * Mirrors [com.frontegg.android.FronteggApp.initializeEmbeddedForLocalE2E] for published SDKs
 * that do not yet expose that API (e.g. Maven 1.3.24).
 */
object FronteggE2eEmbeddedInitializer {

    fun clearSingletonInstance() {
        runCatching {
            val companion = fronteggCompanion()
            val f = companion.javaClass.getDeclaredField("instance").apply { isAccessible = true }
            f.set(companion, null)
        }
    }

    fun rebindSingletonToMockServer(context: Context, baseUrl: String, clientId: String) {
        clearSingletonInstance()
        val appCtx = context.applicationContext
        val normalized = if (baseUrl.startsWith("http://") || baseUrl.startsWith("https://")) {
            baseUrl
        } else {
            "https://$baseUrl"
        }
        val isEmbedded = appCtx.isActivityEnabled(EmbeddedAuthActivity::class.java.name)
        runCatching {
            val constants = FronteggConstantsProvider.fronteggConstants(appCtx)
            SentryHelper.prepare(appCtx, constants)
        }
        val service = FronteggAppService(
            context = appCtx,
            baseUrl = normalized,
            clientId = clientId,
            applicationId = null,
            isEmbeddedMode = isEmbedded,
            handleLoginWithSocialLogin = true,
            handleLoginWithSocialLoginProvider = true,
            handleLoginWithCustomSocialLoginProvider = true,
            handleLoginWithSSO = true,
            shouldPromptSocialLoginConsent = false,
            useAssetsLinks = false,
            useChromeCustomTabs = false,
            mainActivityClass = null,
            deepLinkScheme = null,
            useDiskCacheWebview = false,
            disableAutoRefresh = false,
            enableSessionPerTenant = false,
            entitlementsEnabled = false,
            tenantResolver = null,
        )
        val companion = fronteggCompanion()
        val f = companion.javaClass.getDeclaredField("instance").apply { isAccessible = true }
        f.set(companion, service)
    }

    private fun fronteggCompanion(): Any {
        runCatching {
            return Class.forName("com.frontegg.android.FronteggApp\$Companion")
                .getDeclaredField("INSTANCE")
                .apply { isAccessible = true }
                .get(null)!!
        }
        val iface = Class.forName("com.frontegg.android.FronteggApp")
        return iface.getDeclaredField("Companion").apply { isAccessible = true }.get(null)!!
    }
}
