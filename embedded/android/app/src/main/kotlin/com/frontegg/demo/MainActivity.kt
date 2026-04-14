package com.frontegg.demo

import android.content.res.ColorStateList
import android.graphics.Color
import android.os.Bundle
import android.widget.ProgressBar
import com.frontegg.android.ui.DefaultLoader
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        DefaultLoader.setLoaderProvider {
            val progressBar = ProgressBar(it)
            val colorStateList = ColorStateList.valueOf(Color.GREEN)
            progressBar.indeterminateTintList = colorStateList
            progressBar
        }
    }

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "frontegg_e2e")
            .setMethodCallHandler(E2EMethodChannel(applicationContext))
    }
}
