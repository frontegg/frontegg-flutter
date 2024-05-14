package com.frontegg.flutter


import android.app.Activity
import android.content.Context
import com.frontegg.android.FronteggApp
import com.frontegg.android.FronteggAuth
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** FronteggFlutterPlugin */
class FronteggFlutterPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "frontegg_flutter")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
        val constants = context!!.constants
        FronteggApp.init(
            context = context!!,
            fronteggDomain = constants.baseUrl,
            clientId = constants.clientId,
            useAssetsLinks = constants.useAssetsLinks,
            useChromeCustomTabs = constants.useChromeCustomTabs,
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "login") {
            result.success(login())
        } else {
            result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    private fun login() {
        FronteggAuth.instance.login(activity!!)
    }

    companion object {
        val TAG: String = FronteggFlutterPlugin.Companion::class.java.simpleName
    }
}
