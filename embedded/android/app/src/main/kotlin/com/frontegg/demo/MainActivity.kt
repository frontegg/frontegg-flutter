package com.frontegg.demo

import android.content.res.ColorStateList
import android.graphics.Color
import android.os.Bundle
import android.widget.ProgressBar
import com.frontegg.android.ui.DefaultLoader
import io.flutter.embedding.android.FlutterActivity


class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Setup Loader for Frontegg Embedded Activity Loading
        DefaultLoader.setLoaderProvider {
            val progressBar = ProgressBar(it)
            val colorStateList = ColorStateList.valueOf(Color.GREEN)
            progressBar.indeterminateTintList = colorStateList

            progressBar
        }
    }
}
