package com.frontegg.flutter.stateListener

import java.util.Objects

data class FronteggState(
    val accessToken: String?,
    val refreshToken: String?,
    val user: MutableMap<String, Any?>?,
    val isAuthenticated: Boolean,
    val isLoading: Boolean,
    val initializing: Boolean,
    val showLoader: Boolean,
    val appLink: Boolean,
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            Pair("accessToken", accessToken),
            Pair("refreshToken", refreshToken),
            Pair("user", user),
            Pair("isAuthenticated", isAuthenticated),
            Pair("isLoading", isLoading),
            Pair("initializing", initializing),
            Pair("showLoader", showLoader),
            Pair("appLink", appLink),
        )
    }

    override fun hashCode(): Int {
        return Objects.hash(
            accessToken,
            refreshToken,
            user,
            isAuthenticated,
            isLoading,
            initializing,
            appLink,
            showLoader
        )
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true;
        if (other == null || javaClass != other.javaClass) return false
        val state = other as FronteggState
        return Objects.equals(accessToken, state.accessToken) &&
                Objects.equals(refreshToken, state.refreshToken) &&
                Objects.equals(user, state.user) &&
                isAuthenticated == state.isAuthenticated &&
                isLoading == state.isLoading &&
                initializing == state.initializing &&
                appLink == state.appLink &&
                showLoader == state.showLoader;
    }
}