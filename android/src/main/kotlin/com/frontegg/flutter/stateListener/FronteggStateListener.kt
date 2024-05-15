package com.frontegg.flutter.stateListener

import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel


interface FronteggStateListener {
    fun setEventSink(eventSink: EventChannel.EventSink?)
    fun subscribe(result: MethodChannel.Result)
    fun dispose()
}
