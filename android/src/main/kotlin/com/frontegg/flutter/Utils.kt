package com.frontegg.flutter

import android.content.Context
import android.util.Log


const val TAG: String = "FronteggUtils"


val Context.constants: FronteggConstants
    get() {
        val packageName = this.packageName
        val className = "$packageName.BuildConfig"
        try {
            Log.e(TAG, className)
            val buildConfigClass = Class.forName(className)

            // Get the field from BuildConfig class

            val baseUrl =
                safeGetValueFromBuildConfig(buildConfigClass, "FRONTEGG_DOMAIN", "")
            val clientId =
                safeGetValueFromBuildConfig(buildConfigClass, "FRONTEGG_CLIENT_ID", "")

            val useAssetsLinks =
                safeGetValueFromBuildConfig(buildConfigClass, "FRONTEGG_USE_ASSETS_LINKS", true)
            val useChromeCustomTabs =
                safeGetValueFromBuildConfig(
                    buildConfigClass,
                    "FRONTEGG_USE_CHROME_CUSTOM_TABS",
                    false
                )

            return FronteggConstants(
                baseUrl = baseUrl,
                clientId = clientId,
                useAssetsLinks = useAssetsLinks,
                useChromeCustomTabs = useChromeCustomTabs,
                bundleId = this.packageName,
            )
        } catch (e: ClassNotFoundException) {
            Log.e(TAG, "Class not found: $className")
            throw e
        }
    }


fun <T> safeGetValueFromBuildConfig(buildConfigClass: Class<*>, name: String, default: T): T {
    return try {
        val field = buildConfigClass.getField(name)
        field.get(default) as T
    } catch (e: Exception) {
        Log.e(
            TAG,
            "Field '$name' not found in BuildConfig, return default $default"
        )
        default
    }
}