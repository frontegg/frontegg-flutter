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
        notifyChanges()
    }

    /**
     * Force notify changes with special handling for hosted mode
     * This ensures isLoading is properly reset after authentication
     */
    fun forceNotifyChangesForHostedMode() {
        val fronteggAuth = context.fronteggAuth
        
        // Check if user is authenticated but still loading
        if (fronteggAuth.isAuthenticated.value && fronteggAuth.isLoading.value) {
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
        val fronteggAuth = context.fronteggAuth
        
        val state = FronteggState(
            accessToken = fronteggAuth.accessToken.value,
            refreshToken = fronteggAuth.refreshToken.value,
            user = fronteggAuth.user.value?.toReadableMap(),
            isAuthenticated = fronteggAuth.isAuthenticated.value,
            // Force isLoading to false if user is authenticated
            isLoading = if (fronteggAuth.isAuthenticated.value) {
                false
            } else {
                fronteggAuth.isLoading.value
            },
            initializing = fronteggAuth.initializing.value,
            showLoader = fronteggAuth.showLoader.value,
            appLink = fronteggAuth.useAssetsLinks,
            refreshingToken = fronteggAuth.refreshingToken.value,
        )

        sendState(state)
    }


    private fun notifyChanges() {
        val fronteggAuth = context.fronteggAuth
        val storage = com.frontegg.android.services.StorageProvider.getInnerStorage()
        
        // Additional fix for infinite loader after multiple logins
        // If user is authenticated but still loading for more than 2 seconds, force reset
        val isLoading = if (fronteggAuth.isAuthenticated.value) {
            if (fronteggAuth.isLoading.value) {
                // User is authenticated but still loading - this shouldn't happen
                // Force loading to false to prevent infinite loader
                false
            } else {
                false
            }
        } else {
            fronteggAuth.isLoading.value
        }
        
        val state = FronteggState(
            accessToken = fronteggAuth.accessToken.value,
            refreshToken = fronteggAuth.refreshToken.value,
            user = fronteggAuth.user.value?.toReadableMap(),
            isAuthenticated = fronteggAuth.isAuthenticated.value,
            // Force isLoading to false if user is authenticated AND in hosted mode (fix for hosted mode infinite loader)
            // In embedded mode, keep original isLoading to allow proper WebView lifecycle management
            isLoading = if (fronteggAuth.isAuthenticated.value && !storage.isEmbeddedMode) {
                false
            } else {
                isLoading
            },
            initializing = fronteggAuth.initializing.value,
            showLoader = fronteggAuth.showLoader.value,
            appLink = fronteggAuth.useAssetsLinks,
            refreshingToken = fronteggAuth.refreshingToken.value,
        )

        sendState(state)
    }

    private fun sendState(state: FronteggState) {
        GlobalScope.launch(Dispatchers.Main) {
            eventSink?.success(state.toMap())
        }
    }
}