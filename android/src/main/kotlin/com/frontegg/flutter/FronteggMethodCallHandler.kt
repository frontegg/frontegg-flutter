package com.frontegg.flutter

import com.frontegg.android.FronteggAuth
import com.frontegg.flutter.stateListener.FronteggStateListener
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler

class FronteggMethodCallHandler(
    private val stateListener: FronteggStateListener,
    private val activityPluginBindingGetter: ActivityPluginBindingGetter,
) : MethodCallHandler {
    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "login" -> result.success(login())
            "subscribe" -> result.success(stateListener.subscribe())
            else -> result.notImplemented()
        }
    }

    private fun login(): Unit? {
        activityPluginBindingGetter.getActivityPluginBinding()?.let {
            FronteggAuth.instance.login(it.activity)
        }
        return null
    }

}