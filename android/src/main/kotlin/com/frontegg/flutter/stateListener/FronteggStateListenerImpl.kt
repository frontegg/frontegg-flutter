package com.frontegg.flutter.stateListener

import android.content.Context
import com.frontegg.android.fronteggAuth
import com.frontegg.flutter.toReadableMap
import io.flutter.plugin.common.EventChannel
import io.reactivex.rxjava3.core.Observable
import io.reactivex.rxjava3.disposables.Disposable
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class FronteggStateListenerImpl(
    private val context: Context
) : FronteggStateListener {
    private var disposable: Disposable? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun dispose() {
        disposable?.dispose()
    }

    override fun setEventSink(eventSink: EventChannel.EventSink?) {
        this.eventSink = eventSink
    }

    override fun subscribe() {
        this.disposable?.dispose()

        val fronteggAuth = context.fronteggAuth
        this.disposable = Observable.mergeArray(
            fronteggAuth.accessToken.observable,
            fronteggAuth.refreshToken.observable,
            fronteggAuth.user.observable,
            fronteggAuth.isAuthenticated.observable,
            fronteggAuth.isLoading.observable,
            fronteggAuth.initializing.observable,
            fronteggAuth.showLoader.observable,
            fronteggAuth.refreshingToken.observable,
        ).subscribe {
            notifyChanges()
        }
        notifyChanges()
    }

    /**
     * Force notify changes to Flutter
     * This is useful for hosted mode when state changes don't trigger automatically
     */
    fun forceNotifyChanges() {
        android.util.Log.d("FronteggStateListener", "Force notify changes called")
        notifyChanges()
    }

    /**
     * Force notify changes with special handling for hosted mode
     * This ensures isLoading is properly reset after authentication
     */
    fun forceNotifyChangesForHostedMode() {
        android.util.Log.d("FronteggStateListener", "Force notify changes for hosted mode called")
        val fronteggAuth = context.fronteggAuth
        
        // Check if user is authenticated but still loading
        if (fronteggAuth.isAuthenticated.value && fronteggAuth.isLoading.value) {
            android.util.Log.d("FronteggStateListener", "Detected authenticated user with isLoading=true, forcing state reset")
            // Force reset loading state for hosted mode
            GlobalScope.launch(Dispatchers.Main) {
                // Wait a bit more for SDK to update
                kotlinx.coroutines.delay(100)
                notifyChanges()
            }
        } else {
            notifyChanges()
        }
    }

    /**
     * Create a custom state for hosted mode that forces isLoading to false
     * when user is authenticated
     */
    fun notifyChangesWithHostedModeFix() {
        android.util.Log.d("FronteggStateListener", "=== NOTIFY CHANGES WITH HOSTED MODE FIX STARTED ===")
        val fronteggAuth = context.fronteggAuth
        
        android.util.Log.d("FronteggStateListener", "Current SDK state: isAuthenticated=${fronteggAuth.isAuthenticated.value}, isLoading=${fronteggAuth.isLoading.value}")
        
        val state = FronteggState(
            accessToken = fronteggAuth.accessToken.value,
            refreshToken = fronteggAuth.refreshToken.value,
            user = fronteggAuth.user.value?.toReadableMap(),
            isAuthenticated = fronteggAuth.isAuthenticated.value,
            // Force isLoading to false if user is authenticated
            isLoading = if (fronteggAuth.isAuthenticated.value) {
                android.util.Log.d("FronteggStateListener", "User is authenticated, forcing isLoading to false")
                false
            } else {
                android.util.Log.d("FronteggStateListener", "User is not authenticated, keeping isLoading=${fronteggAuth.isLoading.value}")
                fronteggAuth.isLoading.value
            },
            initializing = fronteggAuth.initializing.value,
            showLoader = fronteggAuth.showLoader.value,
            appLink = fronteggAuth.useAssetsLinks,
            refreshingToken = fronteggAuth.refreshingToken.value,
        )

        android.util.Log.d("FronteggStateListener", "Custom state updated: isAuthenticated=${state.isAuthenticated}, isLoading=${state.isLoading}, initializing=${state.initializing}, showLoader=${state.showLoader}")
        sendState(state)
        android.util.Log.d("FronteggStateListener", "=== NOTIFY CHANGES WITH HOSTED MODE FIX COMPLETED ===")
    }


    private fun notifyChanges() {
        val fronteggAuth = context.fronteggAuth
        
        // Check for hosted mode issue: user is authenticated but still loading
        val isHostedModeIssue = fronteggAuth.isAuthenticated.value && fronteggAuth.isLoading.value
        
        val state = FronteggState(
            accessToken = fronteggAuth.accessToken.value,
            refreshToken = fronteggAuth.refreshToken.value,
            user = fronteggAuth.user.value?.toReadableMap(),
            isAuthenticated = fronteggAuth.isAuthenticated.value,
            // Fix hosted mode issue: force isLoading to false if user is authenticated
            isLoading = if (isHostedModeIssue) {
                android.util.Log.d("FronteggStateListener", "HOSTED MODE ISSUE DETECTED: User authenticated but isLoading=true, forcing to false")
                false
            } else {
                fronteggAuth.isLoading.value
            },
            initializing = fronteggAuth.initializing.value,
            showLoader = fronteggAuth.showLoader.value,
            appLink = fronteggAuth.useAssetsLinks,
            refreshingToken = fronteggAuth.refreshingToken.value,
        )

        android.util.Log.d("FronteggStateListener", "State updated: isAuthenticated=${state.isAuthenticated}, isLoading=${state.isLoading}, initializing=${state.initializing}, showLoader=${state.showLoader}")
        sendState(state)
        
        // If we detected hosted mode issue, schedule another update to ensure it sticks
        if (isHostedModeIssue) {
            android.util.Log.d("FronteggStateListener", "Scheduling additional state update for hosted mode fix")
            GlobalScope.launch(Dispatchers.Main) {
                kotlinx.coroutines.delay(100)
                notifyChanges()
            }
        }
    }

    private fun sendState(state: FronteggState) {
        GlobalScope.launch(Dispatchers.Main) {
            eventSink?.success(state.toMap())
        }
    }
}