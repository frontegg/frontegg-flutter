package com.frontegg.demo

import android.os.Bundle
import android.util.Log
import android.app.Activity
import io.flutter.embedding.engine.loader.FlutterLoader

class CustomSchemeActivity : Activity() {

    companion object {
        private val TAG = CustomSchemeActivity::class.java.canonicalName
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_custom_scheme)

        val loader = FlutterLoader()
        if (!loader.initialized()) {
            loader.startInitialization(applicationContext)
            loader.ensureInitializationComplete(applicationContext, null)
        }

        // Handle the custom scheme URL
        val url = intent?.data?.toString()
        if (url != null) {
            Log.d(TAG, "Custom scheme URL: $url")
            // Process the URL as needed
        } else {
            Log.d(TAG, "No custom scheme URL found")
        }
    }


}
