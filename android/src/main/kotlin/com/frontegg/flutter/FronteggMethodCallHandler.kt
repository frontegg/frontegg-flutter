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
    private val constants: FronteggConstants,
) : MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "login" -> login(call, result)
            "switchTenant" -> switchTenant(call, result)
            "directLoginAction" -> directLoginAction(call, result)
            "refreshToken" -> refreshToken(result)
            "logout" -> logout(result)
            "getConstants" -> getConstants(result)
            else -> result.notImplemented()
        }
    }

    private fun login(call: MethodCall, result: MethodChannel.Result) {
        val loginHint = call.argument<String>("loginHint")

        activityProvider.getActivity()?.let {
            FronteggAuth.instance.login(
                activity = it,
                loginHint = loginHint,
                callback = {
                    result.success(null)
                }
            )
        }
        /// Callback never be called if not Embeded Mode
        if (!FronteggApp.getInstance().isEmbeddedMode) {
            result.success(null)
        }
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
        FronteggAuth.instance.logout {
            result.success(null)
        }
    }

    private fun getConstants(result: MethodChannel.Result) {
        result.success(constants.toMap())
    }
}