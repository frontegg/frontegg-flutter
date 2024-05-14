package com.frontegg.flutter


import android.content.Context
import android.util.Log
import com.frontegg.android.FronteggApp
import com.frontegg.flutter.stateListener.FronteggStateListener
import com.frontegg.flutter.stateListener.FronteggStateListenerImpl
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

/** FronteggFlutterPlugin */
class FronteggFlutterPlugin : FlutterPlugin, ActivityAware, ActivityPluginBindingGetter {
    private lateinit var channel: MethodChannel
    private lateinit var statesEventChannel: EventChannel

    private var context: Context? = null
    private var binding: ActivityPluginBinding? = null
    private val stateListener: FronteggStateListener = FronteggStateListenerImpl(this)


    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "frontegg_flutter")
        channel.setMethodCallHandler(FronteggMethodCallHandler(stateListener, this))

        statesEventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, "frontegg_flutter_state_changed")

        statesEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                stateListener.setEventSink(events)
            }

            override fun onCancel(arguments: Any?) {
                stateListener.setEventSink(null)
            }

        })

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

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
        stateListener.dispose()
    }

    override fun onDetachedFromActivity() {
        this.binding = null
    }


    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        this.binding = binding
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        this.binding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        this.binding = null
    }

    override fun getActivityPluginBinding(): ActivityPluginBinding? {
        return this.binding
    }

    companion object {
        val TAG: String = FronteggFlutterPlugin.Companion::class.java.simpleName
    }
}
