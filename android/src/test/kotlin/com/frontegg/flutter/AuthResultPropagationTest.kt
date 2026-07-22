package com.frontegg.flutter

import com.frontegg.android.exceptions.FronteggException
import io.flutter.plugin.common.MethodChannel
import kotlin.test.Test
import kotlin.test.assertEquals
import kotlin.test.assertFalse
import kotlin.test.assertNull
import kotlin.test.assertTrue

/**
 * FR-25942: login/directLoginAction native callbacks are `((Exception?) -> Unit)?`, but the
 * plugin ignored the `Exception?` and always called `result.success(null)`. A cancelled or
 * failed authentication therefore looked like success to Dart. `completeAuthResult` must route
 * a non-null error through `result.error(...)` and only call `onSuccess` when there is no error.
 */
internal class AuthResultPropagationTest {

    private class RecordingResult : MethodChannel.Result {
        var errorCode: String? = null
        var errorMessage: String? = null
        var successCalled = false
        override fun success(result: Any?) { successCalled = true }
        override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
            this.errorCode = errorCode
            this.errorMessage = errorMessage
        }
        override fun notImplemented() {}
    }

    @Test
    fun nullError_callsOnSuccess_notError() {
        val result = RecordingResult()
        var onSuccessRan = false

        completeAuthResult(null, result) { onSuccessRan = true }

        assertTrue(onSuccessRan, "onSuccess must run when there is no error")
        assertNull(result.errorCode, "result.error must not be called on success")
    }

    @Test
    fun genericError_completesResultWithError_andSkipsOnSuccess() {
        val result = RecordingResult()
        var onSuccessRan = false

        completeAuthResult(RuntimeException("boom"), result) { onSuccessRan = true }

        assertFalse(onSuccessRan, "onSuccess must not run when the callback reports an error")
        assertEquals("unknown", result.errorCode)
        assertEquals("boom", result.errorMessage)
    }

    @Test
    fun fronteggException_usesItsMessageAsErrorCode() {
        val result = RecordingResult()

        completeAuthResult(FronteggException("frontegg.error.mfa_required"), result) {}

        assertEquals("frontegg.error.mfa_required", result.errorCode)
    }
}
