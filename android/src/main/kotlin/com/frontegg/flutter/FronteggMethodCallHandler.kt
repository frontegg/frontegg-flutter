package com.frontegg.flutter

import com.frontegg.android.FronteggApp
import com.frontegg.android.FronteggAuth
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

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
            else -> result.notImplemented()
        }
    }

    private fun directLoginAction(call: MethodCall, result: MethodChannel.Result) {
        val type = call.argument<String>("type") ?: throw ArgumentNotFoundException("type")
        val data = call.argument<String>("data") ?: throw ArgumentNotFoundException("data")
        if (FronteggApp.getInstance().isEmbeddedMode) {
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
        if (FronteggApp.getInstance().isEmbeddedMode) {
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
        if (FronteggApp.getInstance().isEmbeddedMode) {
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

        if (FronteggApp.getInstance().isEmbeddedMode) {
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
                result.error(
                    "REQUEST_AUTHORIZE_ERROR",
                    error.message ?: "Unknown error occurred during authorization",
                    null
                )
            }
        }
    }

    private fun registerPasskeys(result: MethodChannel.Result) {
        activityProvider.getActivity()?.let {
            FronteggAuth.instance.registerPasskeys(it) {
                if (it != null) {
                    result.error(
                        ERROR_CODE,
                        if (it.message != null) it.message!! else "",
                        null,
                    )
                } else {
                    result.success(null)
                }
            }
        }
    }

    private fun loginWithPasskeys(result: MethodChannel.Result) {
        activityProvider.getActivity()?.let {
            FronteggAuth.instance.loginWithPasskeys(it) {
                if (it != null) {
                    result.error(
                        ERROR_CODE,
                        if (it.message != null) it.message!! else "",
                        null,
                    )
                } else {
                    result.success(null)
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