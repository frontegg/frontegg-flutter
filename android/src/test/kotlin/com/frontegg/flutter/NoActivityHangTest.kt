package com.frontegg.flutter

import android.app.Activity
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import kotlin.test.assertFalse
import kotlin.test.assertNotNull

/**
 * FR-25943: activity-dependent methods used `activityProvider.getActivity()?.let { … }`
 * with no else branch. When no Activity is attached (backgrounded app / config-change
 * window) the `result` was never invoked, so the Dart `Future` hung forever. The shared
 * `withActivityOrError` guard must instead complete the result with an error.
 */
internal class NoActivityHangTest {

    private class RecordingResult : MethodChannel.Result {
        var errorCode: String? = null
        var successCalled = false
        override fun success(result: Any?) { successCalled = true }
        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            this.errorCode = errorCode
        }
        override fun notImplemented() {}
    }

    @Test
    fun withActivityOrError_noActivity_completesResultWithError_andSkipsBlock() {
        val noActivity = object : ActivityProvider {
            override fun getActivity(): Activity? = null
        }
        val result = RecordingResult()
        var blockRan = false

        withActivityOrError(noActivity, result) { blockRan = true }

        assertFalse(blockRan, "the activity block must not run when no Activity is attached")
        assertNotNull(
            result.errorCode,
            "result must be completed with an error when no Activity is attached — otherwise the Dart Future hangs forever",
        )
    }
}
