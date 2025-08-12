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


    private fun notifyChanges() {
        val fronteggAuth = context.fronteggAuth
        val state = FronteggState(
            accessToken = fronteggAuth.accessToken.value,
            refreshToken = fronteggAuth.refreshToken.value,
            user = fronteggAuth.user.value?.toReadableMap(),
            isAuthenticated = fronteggAuth.isAuthenticated.value,
            isLoading = fronteggAuth.isLoading.value,
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