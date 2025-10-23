package com.frontegg.flutter

import android.content.Context
import com.frontegg.android.exceptions.FronteggException
import com.frontegg.android.fronteggAuth
import com.frontegg.android.services.StorageProvider
import com.frontegg.flutter.stateListener.FronteggStateListenerImpl
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
    private val context: Context,
) : MethodCallHandler {

    companion object {
        private const val ERROR_CODE = "frontegg.error"
    }
    
    private var stateListener: FronteggStateListenerImpl? = null
    
    fun setStateListener(listener: FronteggStateListenerImpl) {
        this.stateListener = listener
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
            "forceStateUpdate" -> forceStateUpdate(result)

            else -> result.notImplemented()
        }
    }


    private fun isSteppedUp(call: MethodCall, result: MethodChannel.Result) {
        val maxAge = call.argument<Int>("maxAge")

        val isSteppedUp = context.fronteggAuth.isSteppedUp(
            maxAge = maxAge?.toDuration(DurationUnit.SECONDS)
        )
        result.success(isSteppedUp)
    }

    private fun stepUp(call: MethodCall, result: MethodChannel.Result) {
        val maxAge = call.argument<Int>("maxAge")

        activityProvider.getActivity()?.let {
            context.fronteggAuth.stepUp(
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
        if (context.fronteggAuth.isEmbeddedMode) {
            activityProvider.getActivity()?.let {
                context.fronteggAuth.directLoginAction(it, type, data) {
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
        if (context.fronteggAuth.isEmbeddedMode) {
            activityProvider.getActivity()?.let {
                context.fronteggAuth.directLoginAction(it, "direct", url) {
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
        val ephemeralSession = call.argument<Boolean>("ephemeralSession") ?: true
        val additionalQueryParams = call.argument<Map<String, String>>("additionalQueryParams") ?: emptyMap()
        
        activityProvider.getActivity()?.let { activity ->
            android.util.Log.d("FronteggMethodCallHandler", "Starting social login with provider: $provider")
            // Use directLoginAction for both embedded and hosted modes
            // The Android SDK handles the mode internally
            context.fronteggAuth.directLoginAction(
                activity = activity,
                type = "social-login",
                data = provider,
                callback = {
                    android.util.Log.d("FronteggMethodCallHandler", "=== SOCIAL LOGIN CALLBACK STARTED ===")
                    // Force state update after successful authentication
                    // This is especially important for hosted mode
                    GlobalScope.launch(Dispatchers.Main) {
                        android.util.Log.d("FronteggMethodCallHandler", "Authentication callback completed, forcing state update")
                        // Add a longer delay to ensure state has been updated by the SDK
                        kotlinx.coroutines.delay(500)
                        android.util.Log.d("FronteggMethodCallHandler", "First delay completed, calling notifyChangesWithHostedModeFix")
                        // Force state listener to notify changes with hosted mode fix
                        stateListener?.notifyChangesWithHostedModeFix()
                        // Add another delay and force update again to ensure it sticks
                        kotlinx.coroutines.delay(200)
                        android.util.Log.d("FronteggMethodCallHandler", "Second delay completed, calling notifyChangesWithHostedModeFix again")
                        stateListener?.notifyChangesWithHostedModeFix()
                        android.util.Log.d("FronteggMethodCallHandler", "=== SOCIAL LOGIN CALLBACK COMPLETED ===")
                    }
                    result.success(null)
                }
            )
        }
    }

    private fun customSocialLogin(call: MethodCall, result: MethodChannel.Result) {
        val id = call.argument<String>("id") ?: throw ArgumentNotFoundException("id")
        val ephemeralSession = call.argument<Boolean>("ephemeralSession") ?: true
        val additionalQueryParams = call.argument<Map<String, String>>("additionalQueryParams") ?: emptyMap()

        activityProvider.getActivity()?.let { activity ->
            // Use directLoginAction for both embedded and hosted modes
            // The Android SDK handles the mode internally
            context.fronteggAuth.directLoginAction(activity, "custom-social-login", id) {
                // Force state update after successful authentication
                // This is especially important for hosted mode
                GlobalScope.launch(Dispatchers.Main) {
                    android.util.Log.d("FronteggMethodCallHandler", "Authentication callback completed, forcing state update")
                    // Add a longer delay to ensure state has been updated by the SDK
                    kotlinx.coroutines.delay(500)
                    // Force state listener to notify changes with hosted mode fix
                    stateListener?.notifyChangesWithHostedModeFix()
                    // Add another delay and force update again to ensure it sticks
                    kotlinx.coroutines.delay(200)
                    stateListener?.notifyChangesWithHostedModeFix()
                }
                result.success(null)
            }
        }
    }

    private fun requestAuthorize(call: MethodCall, result: MethodChannel.Result) {
        val refreshToken = call.argument<String>("refreshToken")
            ?: throw ArgumentNotFoundException("refreshToken")
        val deviceTokenCookie = call.argument<String>("deviceTokenCookie")

        context.fronteggAuth.requestAuthorize(refreshToken, deviceTokenCookie) { authResult ->
            authResult.onSuccess { user ->
                result.success(user.toReadableMap())
            }.onFailure { error ->
                if (error is FronteggException) {
                    result.error(
                        error.message ?: "unknown",
                        error.message ?: "Unknown error occurred during authorizetion",
                        null
                    )
                } else {
                    result.error(
                        "unknown",
                        error.localizedMessage ?: "Unknown error occurred during authorizetion",
                        null
                    )
                }
            }
        }
    }

    private fun registerPasskeys(result: MethodChannel.Result) {
        activityProvider.getActivity()?.let {
            context.fronteggAuth.registerPasskeys(it) { error ->
                if (error == null) {
                    result.success(null)
                } else {
                    if (error is FronteggException) {
                        result.error(
                            error.message ?: "unknown",
                            error.message ?: "Unknown error occurred during passkey registration",
                            null
                        )
                    } else {
                        result.error(
                            "unknown",
                            error.localizedMessage
                                ?: "Unknown error occurred during passkey registration",
                            null
                        )
                    }
                }
            }
        }
    }

    private fun loginWithPasskeys(result: MethodChannel.Result) {
        activityProvider.getActivity()?.let {
            context.fronteggAuth.loginWithPasskeys(it) { error ->
                if (error == null) {
                    result.success(null)
                } else {
                    if (error is FronteggException) {
                        result.error(
                            error.message ?: "unknown",
                            error.message ?: "Unknown error occurred during login with passkeys",
                            null
                        )
                    } else {
                        result.error(
                            "unknown",
                            error.localizedMessage
                                ?: "Unknown error occurred during login with passkeys",
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
            context.fronteggAuth.login(
                activity = it,
                loginHint = loginHint,
                callback = {
                    // Force state update after successful authentication
                    // This is especially important for hosted mode
                    GlobalScope.launch(Dispatchers.Main) {
                        // Trigger state listener to update Flutter
                        // The state listener will automatically detect changes
                        // and send updated state to Flutter
                    }
                    result.success(null)
                }
            )
        }
    }

    private fun switchTenant(call: MethodCall, result: MethodChannel.Result) {
        val tenantId =
            call.argument<String>("tenantId") ?: throw ArgumentNotFoundException("tenantId")

        context.fronteggAuth.switchTenant(tenantId) {
            result.success(null)
        }
    }

    private fun refreshToken(result: MethodChannel.Result) {
        GlobalScope.launch(Dispatchers.IO) {
            val success = context.fronteggAuth.refreshTokenIfNeeded()
            GlobalScope.launch(Dispatchers.Main) {
                result.success(success)
            }
        }
    }

    private fun logout(result: MethodChannel.Result) {
        context.fronteggAuth.logout {
            result.success(null)
        }
    }

    private fun getConstants(result: MethodChannel.Result) {
        val storage = StorageProvider.getInnerStorage()
        result.success(
            mapOf(
                Pair("baseUrl", storage.baseUrl),
                Pair("applicationId", storage.applicationId),
                Pair("useAssetsLinks", storage.useAssetsLinks),
                Pair("useChromeCustomTabs", storage.useChromeCustomTabs),
                Pair("bundleId", storage.packageName),
                Pair("deepLinkScheme", storage.deepLinkScheme),
                Pair("useDiskCacheWebview", storage.useDiskCacheWebview),
            )
        )
    }

    private fun forceStateUpdate(result: MethodChannel.Result) {
        // Force update all state properties to trigger state listener
        GlobalScope.launch(Dispatchers.Main) {
            android.util.Log.d("FronteggMethodCallHandler", "Force state update called")
            // Add a longer delay to ensure state has been updated by the SDK
            kotlinx.coroutines.delay(500)
            // Force state listener to notify changes with hosted mode fix
            stateListener?.notifyChangesWithHostedModeFix()
            // Add another delay and force update again to ensure it sticks
            kotlinx.coroutines.delay(200)
            stateListener?.notifyChangesWithHostedModeFix()
            result.success(null)
        }
    }
}