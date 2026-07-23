package com.frontegg.flutter.stateListener

import io.flutter.plugin.common.EventChannel


interface FronteggStateListener {
    fun setEventSink(eventSink: EventChannel.EventSink?)
    fun subscribe()
    fun dispose()

    /** Emit the current auth state to Flutter on demand (used by `forceStateUpdate`, FR-25944). */
    fun forceNotifyChanges()
}
