package com.frontegg.demo

import android.content.Context
import org.json.JSONObject
import java.io.File

object DemoEmbeddedTestMode {
    const val BOOTSTRAP_FILE_NAME = "e2e_embedded_bootstrap.json"

    var isEnabled = false
        private set
    var baseUrl: String? = null
        private set
    var clientId: String? = null
        private set
    var resetState: Boolean = true
        private set
    var forceNetworkPathOffline: Boolean = false
        private set
    var enableOfflineMode: Boolean? = null
        private set

    fun consumeBootstrapIfPresent(context: Context): Boolean {
        val file = File(context.filesDir, BOOTSTRAP_FILE_NAME)
        if (!file.exists()) return false

        try {
            val json = JSONObject(file.readText())
            baseUrl = json.optString("baseUrl", null)
            clientId = json.optString("clientId", null)
            resetState = json.optBoolean("resetState", true)
            forceNetworkPathOffline = json.optBoolean("forceNetworkPathOffline", false)
            enableOfflineMode = if (json.has("enableOfflineMode")) json.getBoolean("enableOfflineMode") else null
            isEnabled = baseUrl != null
            file.delete()
            return isEnabled
        } catch (e: Exception) {
            file.delete()
            return false
        }
    }

    fun writeBootstrap(
        context: Context,
        baseUrl: String,
        clientId: String,
        resetState: Boolean = true,
        forceNetworkPathOffline: Boolean = false,
        enableOfflineMode: Boolean? = null,
    ) {
        val json = JSONObject().apply {
            put("baseUrl", baseUrl.trimEnd('/'))
            put("clientId", clientId)
            put("resetState", resetState)
            put("forceNetworkPathOffline", forceNetworkPathOffline)
            if (enableOfflineMode != null) put("enableOfflineMode", enableOfflineMode)
        }
        File(context.filesDir, BOOTSTRAP_FILE_NAME).writeText(json.toString())
    }

    fun applyConfig(
        baseUrl: String,
        clientId: String,
        resetState: Boolean,
        forceNetworkPathOffline: Boolean,
        enableOfflineMode: Boolean?,
    ) {
        this.baseUrl = baseUrl.trimEnd('/')
        this.clientId = clientId
        this.resetState = resetState
        this.forceNetworkPathOffline = forceNetworkPathOffline
        this.enableOfflineMode = enableOfflineMode
        this.isEnabled = true
    }

    fun reset() {
        isEnabled = false
        baseUrl = null
        clientId = null
        resetState = true
        forceNetworkPathOffline = false
        enableOfflineMode = null
    }
}
