package com.frontegg.demo

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class E2EMethodChannel(private val context: Context) : MethodChannel.MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "writeBootstrap" -> writeBootstrap(call, result)
            "consumeBootstrap" -> consumeBootstrap(result)
            "initializeForE2E" -> initializeForE2E(call, result)
            "resetForTesting" -> resetForTesting(result)
            else -> result.notImplemented()
        }
    }

    private fun writeBootstrap(call: MethodCall, result: MethodChannel.Result) {
        val baseUrl = call.argument<String>("baseUrl") ?: return result.error("MISSING_PARAM", "baseUrl required", null)
        val clientId = call.argument<String>("clientId") ?: return result.error("MISSING_PARAM", "clientId required", null)
        val resetState = call.argument<Boolean>("resetState") ?: true
        val forceNetworkPathOffline = call.argument<Boolean>("forceNetworkPathOffline") ?: false
        val enableOfflineMode = call.argument<Boolean>("enableOfflineMode")

        DemoEmbeddedTestMode.writeBootstrap(
            context = context,
            baseUrl = baseUrl,
            clientId = clientId,
            resetState = resetState,
            forceNetworkPathOffline = forceNetworkPathOffline,
            enableOfflineMode = enableOfflineMode,
        )
        result.success(null)
    }

    private fun consumeBootstrap(result: MethodChannel.Result) {
        if (DemoEmbeddedTestMode.consumeBootstrapIfPresent(context)) {
            result.success(mapOf(
                "baseUrl" to DemoEmbeddedTestMode.baseUrl,
                "clientId" to DemoEmbeddedTestMode.clientId,
                "resetState" to DemoEmbeddedTestMode.resetState,
                "forceNetworkPathOffline" to DemoEmbeddedTestMode.forceNetworkPathOffline,
                "enableOfflineMode" to DemoEmbeddedTestMode.enableOfflineMode,
            ))
        } else {
            result.success(null)
        }
    }

    private fun initializeForE2E(call: MethodCall, result: MethodChannel.Result) {
        val baseUrl = call.argument<String>("baseUrl") ?: return result.error("MISSING_PARAM", "baseUrl required", null)
        val clientId = call.argument<String>("clientId") ?: return result.error("MISSING_PARAM", "clientId required", null)
        val resetState = call.argument<Boolean>("resetState") ?: true
        val forceNetworkPathOffline = call.argument<Boolean>("forceNetworkPathOffline") ?: false
        val enableOfflineMode = call.argument<Boolean>("enableOfflineMode")

        DemoEmbeddedTestMode.applyConfig(
            baseUrl = baseUrl,
            clientId = clientId,
            resetState = resetState,
            forceNetworkPathOffline = forceNetworkPathOffline,
            enableOfflineMode = enableOfflineMode,
        )

        try {
            FronteggE2eEmbeddedInitializer.rebindSingletonToMockServer(context, baseUrl, clientId)
            result.success(null)
        } catch (e: Exception) {
            result.error("E2E_INIT_FAILED", e.message, null)
        }
    }

    private fun resetForTesting(result: MethodChannel.Result) {
        try {
            FronteggE2eEmbeddedInitializer.clearSingletonInstance()
            DemoEmbeddedTestMode.reset()
            result.success(null)
        } catch (e: Exception) {
            result.error("RESET_FAILED", e.message, null)
        }
    }
}
