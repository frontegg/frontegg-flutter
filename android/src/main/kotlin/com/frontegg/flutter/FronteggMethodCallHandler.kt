package com.frontegg.flutter

import com.frontegg.android.FronteggApp
import com.frontegg.android.FronteggAuth
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class FronteggMethodCallHandler(
    private val activityProvider: ActivityProvider,
) : MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "init" -> initialize(call, result)
            "login" -> login(result)
            "switchTenant" -> switchTenant(call, result)
            "directLoginAction" -> directLoginAction(call, result)
            "refreshToken" -> refreshToken(result)
            "logout" -> logout(result)
            else -> result.notImplemented()
        }
    }

    private fun initialize(call: MethodCall, result: MethodChannel.Result) {
        val baseUrl =
            call.argument<String>("baseUrl") ?: throw ArgumentNotFoundException("baseUrl")
        val clientId =
            call.argument<String>("clientId") ?: throw ArgumentNotFoundException("clientId")
        val applicationId =
            call.argument<String>("applicationId")

        val useAssetsLinks =
            call.argument<Boolean>("useAssetsLinks") ?: true

        val useChromeCustomTabs =
            call.argument<Boolean>("useChromeCustomTabs") ?: true

        FronteggApp.init(
            context = activityProvider.getApplicationContext()!!,
            fronteggDomain = baseUrl,
            clientId = clientId,
            useAssetsLinks = useAssetsLinks,
            useChromeCustomTabs = useChromeCustomTabs,
            applicationId = applicationId,
        )

        result.success(null)
    }

    private fun login(result: MethodChannel.Result) {
        activityProvider.getActivity()?.let {
            FronteggAuth.instance.login(it)
        }
        result.success(null)
    }

    private fun switchTenant(call: MethodCall, result: MethodChannel.Result) {
        val tenantId =
            call.argument<String>("tenantId") ?: throw ArgumentNotFoundException("tenantId")

        FronteggAuth.instance.switchTenant(tenantId) {
            result.success(null)
        }
    }

    private fun directLoginAction(call: MethodCall, result: MethodChannel.Result) {
        val type = call.argument<String>("type") ?: throw ArgumentNotFoundException("type")
        val data = call.argument<String>("data") ?: throw ArgumentNotFoundException("data")

        activityProvider.getActivity()?.let {
            FronteggAuth.instance.directLoginAction(it, type, data)
        }
        result.success(null)
    }

    private fun refreshToken(result: MethodChannel.Result) {
        GlobalScope.launch(Dispatchers.IO) {
            val success = FronteggAuth.instance.refreshTokenIfNeeded()
            GlobalScope.launch(Dispatchers.Main) {
                result.success(success)
            }
        }
    }

    private fun logout(result: MethodChannel.Result) {
        FronteggAuth.instance.logout()
        result.success(null)
    }
}