package com.frontegg.flutter.stateListener

import io.flutter.plugin.common.EventChannel


interface FronteggStateListener {
    fun setEventSink(eventSink: EventChannel.EventSink?)
    fun subscribe()
    fun dispose()
}
