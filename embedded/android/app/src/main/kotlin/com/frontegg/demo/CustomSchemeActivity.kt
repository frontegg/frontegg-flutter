package com.frontegg.demo

import android.os.Bundle
import android.util.Log
import android.app.Activity
import android.content.Context
import android.content.Intent
import com.frontegg.android.FronteggApp
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.FlutterEngineCache
import io.flutter.embedding.engine.loader.FlutterLoader

//import io.flutter.embedding.engine.loader.FlutterLoader

class CustomSchemeActivity : Activity() {

    companion object {
        private val TAG = CustomSchemeActivity::class.java.canonicalName
    }

    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {

        if(isTaskRoot){
            val intent = intent

            // 2) …and we didn’t come here via the normal launcher (ACTION_MAIN + CATEGORY_LAUNCHER)
            val isLauncher = intent.action == Intent.ACTION_MAIN &&
                    intent.hasCategory(Intent.CATEGORY_LAUNCHER)
            if (!isLauncher) {
                // 3) Grab the real “main launcher” Intent for this package
                val launchIntent = packageManager
                    .getLaunchIntentForPackage(packageName)
                    ?.apply {
                        // wipe any existing history/task and start fresh
                        addFlags(
                            Intent.FLAG_ACTIVITY_NEW_TASK or
                                    Intent.FLAG_ACTIVITY_CLEAR_TASK
                        )
                    }

                // 4) Fire it and kill yourself
                launchIntent?.let { startActivity(it) }
                finish()
                return
            }
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_custom_scheme)



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
