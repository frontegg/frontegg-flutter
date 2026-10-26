package com.frontegg.demo

import android.app.Application
import com.frontegg.android.FronteggApp
import com.frontegg.android.regions.RegionConfig

class App : Application() {
    override fun onCreate() {
        super.onCreate()
        if (BuildConfig.FRONTEGG_MULTI_REGION) {
            FronteggApp.initWithRegions(
                regions = listOf(
                    RegionConfig("eu", BuildConfig.FRONTEGG_DOMAIN, BuildConfig.FRONTEGG_CLIENT_ID),
                    RegionConfig("us", BuildConfig.FRONTEGG_DOMAIN_2, BuildConfig.FRONTEGG_CLIENT_ID_2),
                ),
                context = this,
                useAssetsLinks = true,
                useChromeCustomTabs = true,
            )
        }
    }
}
