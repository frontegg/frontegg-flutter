package com.frontegg.flutter.stateListener

import com.frontegg.android.FronteggAuth
import com.frontegg.flutter.FronteggConstants
import com.frontegg.flutter.toReadableMap
import io.flutter.plugin.common.EventChannel
import io.reactivex.rxjava3.core.Observable
import io.reactivex.rxjava3.disposables.Disposable
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch

class FronteggStateListenerImpl(
    private val constants: FronteggConstants
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

        this.disposable = Observable.mergeArray(
            FronteggAuth.instance.accessToken.observable,
            FronteggAuth.instance.refreshToken.observable,
            FronteggAuth.instance.user.observable,
            FronteggAuth.instance.isAuthenticated.observable,
            FronteggAuth.instance.isLoading.observable,
            FronteggAuth.instance.initializing.observable,
            FronteggAuth.instance.showLoader.observable,
        ).subscribe {
            notifyChanges()
        }
        notifyChanges()
    }


    private fun notifyChanges() {
        val state = FronteggState(
            accessToken = FronteggAuth.instance.accessToken.value,
            refreshToken = FronteggAuth.instance.refreshToken.value,
            user = FronteggAuth.instance.user.value?.toReadableMap(),
            isAuthenticated = FronteggAuth.instance.isAuthenticated.value,
            isLoading = FronteggAuth.instance.isLoading.value,
            initializing = FronteggAuth.instance.initializing.value,
            showLoader = FronteggAuth.instance.showLoader.value,
            appLink = constants.useAssetsLinks,
        )

        sendState(state)
    }

    private fun sendState(state: FronteggState) {
        GlobalScope.launch(Dispatchers.Main) {
            eventSink?.success(state.toMap())
        }
    }
}