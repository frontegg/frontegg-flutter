package com.frontegg.flutter

import com.frontegg.flutter.stateListener.FronteggStateListener
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertTrue

/**
 * FR-25944: `forceStateUpdate` was a comment-only no-op that called `result.success(null)`
 * without ever notifying the state listener, so Dart never received the refreshed state.
 * The extracted `forceStateUpdate(listener, result)` must trigger `forceNotifyChanges()` and
 * still complete the result.
 */
internal class ForceStateUpdateTest {

    private class RecordingResult : MethodChannel.Result {
        var successCalled = false
        override fun success(result: Any?) { successCalled = true }
        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {}
        override fun notImplemented() {}
    }

    private class FakeListener : FronteggStateListener {
        var forceCount = 0
        override fun setEventSink(eventSink: EventChannel.EventSink?) {}
        override fun subscribe() {}
        override fun dispose() {}
        override fun forceNotifyChanges() { forceCount++ }
    }

    @Test
    fun forceStateUpdate_notifiesListener_andCompletesResult() {
        val listener = FakeListener()
        val result = RecordingResult()

        forceStateUpdate(listener, result)

        assertEquals(1, listener.forceCount, "forceStateUpdate must trigger forceNotifyChanges so Dart receives the refreshed state")
        assertTrue(result.successCalled, "result must be completed")
    }

    @Test
    fun forceStateUpdate_noListener_stillCompletesResult() {
        val result = RecordingResult()

        forceStateUpdate(null, result)

        assertTrue(result.successCalled, "result must be completed even when no listener is attached")
    }
}
