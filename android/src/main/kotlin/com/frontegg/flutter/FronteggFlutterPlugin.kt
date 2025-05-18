package com.frontegg.flutter

import android.app.Activity
import android.content.Context
import com.frontegg.android.FronteggApp
import com.frontegg.flutter.stateListener.FronteggStateListener
import com.frontegg.flutter.stateListener.FronteggStateListenerImpl
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class FronteggFlutterPlugin : FlutterPlugin, ActivityAware, ActivityProvider {
    private lateinit var channel: MethodChannel
    private lateinit var stateEventChannel: EventChannel

    private var context: Context? = null
    private var binding: ActivityPluginBinding? = null
    private var stateListener: FronteggStateListener? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext

        val constants = context!!.constants

        channel = MethodChannel(flutterPluginBinding.binaryMessenger, METHOD_CHANNEL_NAME)
        channel.setMethodCallHandler(FronteggMethodCallHandler(this, constants))

        stateEventChannel =
            EventChannel(flutterPluginBinding.binaryMessenger, STATE_EVENT_CHANNEL_NAME)
        stateListener = FronteggStateListenerImpl(constants)

        FronteggApp.init(
            context = context!!,
            fronteggDomain = constants.baseUrl,
            clientId = constants.clientId,
            applicationId = constants.applicationId,
            useAssetsLinks = constants.useAssetsLinks,
            useChromeCustomTabs = constants.useChromeCustomTabs,
            deepLinkScheme = constants.deepLinkScheme
        )


        stateEventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                stateListener?.setEventSink(events)
                stateListener?.subscribe()
            }

            override fun onCancel(arguments: Any?) {
                stateListener?.setEventSink(null)
            }
        })
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
        stateListener?.dispose()
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

    override fun getActivity(): Activity? {
        return this.binding?.activity
    }

    companion object {
        const val METHOD_CHANNEL_NAME = "frontegg_flutter"
        const val STATE_EVENT_CHANNEL_NAME = "frontegg_flutter/state_stream"
    }
}
