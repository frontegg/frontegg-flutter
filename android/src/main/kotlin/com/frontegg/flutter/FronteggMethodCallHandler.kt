package com.frontegg.flutter

import com.frontegg.android.FronteggApp
import com.frontegg.android.FronteggAuth
import com.frontegg.android.exceptions.FronteggException
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlin.time.DurationUnit
import kotlin.time.toDuration

class FronteggMethodCallHandler(
    private val activityProvider: ActivityProvider,
    private val constants: FronteggConstants,
) : MethodCallHandler {

    companion object {
        private const val ERROR_CODE = "frontegg.error"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "login" -> login(call, result)
            "switchTenant" -> switchTenant(call, result)
            "refreshToken" -> refreshToken(result)
            "logout" -> logout(result)
            "getConstants" -> getConstants(result)
            "registerPasskeys" -> registerPasskeys(result)
            "loginWithPasskeys" -> loginWithPasskeys(result)
            "requestAuthorize" -> requestAuthorize(call, result)

            "directLoginAction" -> directLoginAction(call, result)
            "directLogin" -> directLogin(call, result)
            "socialLogin" -> socialLogin(call, result)
            "customSocialLogin" -> customSocialLogin(call, result)

            "isSteppedUp" -> isSteppedUp(call, result)
            "stepUp" -> stepUp(call, result)

            else -> result.notImplemented()
        }
    }


    private fun isSteppedUp(call: MethodCall, result: MethodChannel.Result) {
        val maxAge = call.argument<Int>("maxAge")

        val isSteppedUp = FronteggApp.getInstance().auth.isSteppedUp(
            maxAge = maxAge?.toDuration(DurationUnit.SECONDS)
        )
        result.success(isSteppedUp)
    }

    private fun stepUp(call: MethodCall, result: MethodChannel.Result) {
        val maxAge = call.argument<Int>("maxAge")

        activityProvider.getActivity()?.let {
            FronteggApp.getInstance().auth.stepUp(
                activity = it,
                maxAge = maxAge?.toDuration(DurationUnit.SECONDS)
            ) { error: Exception? ->
                if (error == null) {
                    result.success(null)
                } else {
                    if (error is FronteggException) {
                        result.error(
                            error.message ?: "unknown",
                            error.message ?: "Unknown error occurred during step up",
                            null
                        )
                    } else {
                        result.error(
                            "unknown",
                            error.localizedMessage ?: "Unknown error occurred during step up",
                            null
                        )
                    }
                }
            }
        }
    }

    private fun directLoginAction(call: MethodCall, result: MethodChannel.Result) {
        val type = call.argument<String>("type") ?: throw ArgumentNotFoundException("type")
        val data = call.argument<String>("data") ?: throw ArgumentNotFoundException("data")
        if (FronteggApp.getInstance().auth.isEmbeddedMode) {
            activityProvider.getActivity()?.let {
                FronteggAuth.instance.directLoginAction(it, type, data) {
                    result.success(null)
                }
            }
        } else {
            result.error(
                "REQUEST_AUTHORIZE_ERROR",
                "'directLoginAction' can be used only when EmbeddedActivity is enabled.",
                null,
            )
        }
    }

    private fun directLogin(call: MethodCall, result: MethodChannel.Result) {
        val url = call.argument<String>("url") ?: throw ArgumentNotFoundException("url")
        if (FronteggApp.getInstance().auth.isEmbeddedMode) {
            activityProvider.getActivity()?.let {
                FronteggAuth.instance.directLoginAction(it, "direct", url) {
                    result.success(null)
                }
            }
        } else {
            result.error(
                "REQUEST_AUTHORIZE_ERROR",
                "'directLogin' can be used only when EmbeddedActivity is enabled.",
                null,
            )
        }
    }

    private fun socialLogin(call: MethodCall, result: MethodChannel.Result) {
        val provider =
            call.argument<String>("provider") ?: throw ArgumentNotFoundException("provider")
        if (FronteggApp.getInstance().auth.isEmbeddedMode) {
            activityProvider.getActivity()?.let {
                FronteggAuth.instance.directLoginAction(it, "social-login", provider) {
                    result.success(null)
                }
            }
        } else {
            result.error(
                "REQUEST_AUTHORIZE_ERROR",
                "'socialLogin' can be used only when EmbeddedActivity is enabled.",
                null,
            )
        }
    }

    private fun customSocialLogin(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<String>("id") ?: throw ArgumentNotFoundException("id")

        if (FronteggApp.getInstance().auth.isEmbeddedMode) {
            activityProvider.getActivity()?.let {
                FronteggAuth.instance.directLoginAction(it, "custom-social-login", id) {
                    result.success(null)
                }
            }
        } else {
            result.error(
                "REQUEST_AUTHORIZE_ERROR",
                "'customSocialLogin' can be used only when EmbeddedActivity is enabled.",
                null,
            )
        }
    }

    private fun requestAuthorize(call: MethodCall, result: MethodChannel.Result) {
        val refreshToken = call.argument<String>("refreshToken")
            ?: throw ArgumentNotFoundException("refreshToken")
        val deviceTokenCookie = call.argument<String>("deviceTokenCookie")

        FronteggAuth.instance.requestAuthorize(refreshToken, deviceTokenCookie) { authResult ->
            authResult.onSuccess { user ->
                result.success(user.toReadableMap())
            }.onFailure { error ->
                if (error is FronteggException) {
                    result.error(
                        error.message ?: "unknown",
                        error.message ?: "Unknown error occurred during step up",
                        null
                    )
                } else {
                    result.error(
                        "unknown",
                        error.localizedMessage ?: "Unknown error occurred during step up",
                        null
                    )
                }
            }
        }
    }

    private fun registerPasskeys(result: MethodChannel.Result) {
        activityProvider.getActivity()?.let {
            FronteggAuth.instance.registerPasskeys(it) { error ->
                if (error == null) {
                    result.success(null)
                } else {
                    if (error is FronteggException) {
                        result.error(
                            error.message ?: "unknown",
                            error.message ?: "Unknown error occurred during step up",
                            null
                        )
                    } else {
                        result.error(
                            "unknown",
                            error.localizedMessage ?: "Unknown error occurred during step up",
                            null
                        )
                    }
                }
            }
        }
    }

    private fun loginWithPasskeys(result: MethodChannel.Result) {
        activityProvider.getActivity()?.let {
            FronteggAuth.instance.loginWithPasskeys(it) { error ->
                if (error == null) {
                    result.success(null)
                } else {
                    if (error is FronteggException) {
                        result.error(
                            error.message ?: "unknown",
                            error.message ?: "Unknown error occurred during step up",
                            null
                        )
                    } else {
                        result.error(
                            "unknown",
                            error.localizedMessage ?: "Unknown error occurred during step up",
                            null
                        )
                    }
                }
            }
        }
    }

    private fun login(call: MethodCall, result: MethodChannel.Result) {
        val loginHint = call.argument<String>("loginHint")

        activityProvider.getActivity()?.let {
            FronteggAuth.instance.login(
                activity = it,
                loginHint = loginHint,
                callback = {
                    result.success(null)
                }
            )
        }
    }

    private fun switchTenant(call: MethodCall, result: MethodChannel.Result) {
        val tenantId =
            call.argument<String>("tenantId") ?: throw ArgumentNotFoundException("tenantId")

        FronteggAuth.instance.switchTenant(tenantId) {
            result.success(null)
        }
    }

    private fun refreshToken(result: MethodChannel.Result) {
        GlobalScope.launch(Dispatchers.IO) {
            val success = FronteggAuth.instance.refreshTokenIfNeeded()
            GlobalScope.launch(Dispatchers.Main) {
                result.success(success)
            }
        }
    }

    private fun logout(result: MethodChannel.Result) {
        FronteggAuth.instance.logout {
            result.success(null)
        }
    }

    private fun getConstants(result: MethodChannel.Result) {
        result.success(constants.toMap())
    }
}