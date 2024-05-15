package com.frontegg.flutter

import com.frontegg.android.FronteggAuth
import com.frontegg.flutter.stateListener.FronteggStateListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class FronteggMethodCallHandler(
    private val stateListener: FronteggStateListener,
    private val activityPluginBindingGetter: ActivityPluginBindingGetter,
    private val constants: FronteggConstants
) : MethodCallHandler {

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "login" -> login(result)
            "subscribe" -> stateListener.subscribe(result)
            "switchTenant" -> switchTenant(call, result)
            "directLoginAction" -> directLoginAction(call, result)
            "refreshToken" -> refreshToken(result)
            "logout" -> logout(result)
            "getConstants" -> getConstants(result)
            else -> result.notImplemented()
        }
    }

    private fun login(result: MethodChannel.Result) {
        activityPluginBindingGetter.getActivityPluginBinding()?.let {
            FronteggAuth.instance.login(it.activity)
        }
        result.success(null)
    }

    private fun switchTenant(call: MethodCall, result: MethodChannel.Result) {
        val tenantId =
            call.argument<String>("tenantId") ?: throw ArgumentNotFindException("tenantId")

        FronteggAuth.instance.switchTenant(tenantId) {
            result.success(null)
        }
    }

    private fun directLoginAction(call: MethodCall, result: MethodChannel.Result) {
        val type =
            call.argument<String>("type") ?: throw ArgumentNotFindException("type")
        val data =
            call.argument<String>("data") ?: throw ArgumentNotFindException("data")

        val activity = activityPluginBindingGetter.getActivityPluginBinding()?.activity
        activity?.let {
            FronteggAuth.instance.directLoginAction(it, type, data)
        }
        result.success(null)
    }

    private fun refreshToken(result: MethodChannel.Result) {
        FronteggAuth.instance.refreshTokenIfNeeded()
        result.success(null)
    }

    private fun logout(result: MethodChannel.Result) {
        FronteggAuth.instance.logout()
        result.success(null)
    }    
    
    private fun getConstants(result: MethodChannel.Result) {
        result.success(constants.toMap())
    }
}