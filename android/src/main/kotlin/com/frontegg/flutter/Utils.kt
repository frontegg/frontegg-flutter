package com.frontegg.flutter

import android.app.Activity
import android.content.Context
import android.util.Log


const val TAG: String = "FronteggUtils"


interface ActivityProvider {
    fun getActivity(): Activity?
}

val Context.constants: FronteggConstants
    get() {
        val mainActivity = getLaunchActivityName(this)
        Log.d(TAG, "packageName: ${packageName}, mainActivity: $mainActivity")
        val buildConfigClass =
            getBuildConfigClass(mainActivity?.substringBeforeLast('.') ?: this.packageName)

        val baseUrl = safeGetValueFromBuildConfig(buildConfigClass, "FRONTEGG_DOMAIN", "")
        val clientId = safeGetValueFromBuildConfig(buildConfigClass, "FRONTEGG_CLIENT_ID", "")

        val applicationId =
            safeGetNullableValueFromBuildConfig(buildConfigClass, "FRONTEGG_APPLICATION_ID", "")

        val useAssetsLinks =
            safeGetValueFromBuildConfig(buildConfigClass, "FRONTEGG_USE_ASSETS_LINKS", true)
        val useChromeCustomTabs = safeGetValueFromBuildConfig(
            buildConfigClass, "FRONTEGG_USE_CHROME_CUSTOM_TABS", true
        )

        return FronteggConstants(
            baseUrl = baseUrl,
            clientId = clientId,
            applicationId = applicationId,
            useAssetsLinks = useAssetsLinks,
            useChromeCustomTabs = useChromeCustomTabs,
            bundleId = this.packageName,
        )
    }

fun getLaunchActivityName(context: Context): String? {
    val launcherIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
    val launchActivityInfo = launcherIntent!!.resolveActivityInfo(context.packageManager, 0)
    return try {
        launchActivityInfo.name
    } catch (e: Exception) {
        null
    }
}

fun getBuildConfigClass(packageName: String): Class<*> {
    if (!packageName.contains('.')) {
        throw ClassNotFoundException("Invalid package name: $packageName. Failed to retrieve BuildConfig class.")
    }

    val className = "$packageName.BuildConfig"

    return try {
        Class.forName(className)
    } catch (e: ClassNotFoundException) {
        Log.d(TAG, "Class not found: $className, checking parent namespace")

        val parentPackageName = packageName.substringBeforeLast('.')

        if (parentPackageName.isNotEmpty()) {
            getBuildConfigClass(parentPackageName)
        } else {
            throw ClassNotFoundException("Failed to retrieve BuildConfig class for package: $packageName after checking all namespaces.")
        }
    }
}

fun <T> safeGetNullableValueFromBuildConfig(
    buildConfigClass: Class<*>,
    name: String,
    default: T,
): T? {
    return try {
        val field = buildConfigClass.getField(name)
        field.get(default) as T
    } catch (e: Exception) {
        Log.e(
            TAG, "Field '$name' not found in BuildConfig, return null"
        )
        null
    }
}


fun <T> safeGetValueFromBuildConfig(buildConfigClass: Class<*>, name: String, default: T): T {
    return try {
        val field = buildConfigClass.getField(name)
        field.get(default) as T
    } catch (e: Exception) {
        Log.e(
            TAG, "Field '$name' not found in BuildConfig, return default $default"
        )
        default
    }
}