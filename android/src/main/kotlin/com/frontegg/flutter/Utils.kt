package com.frontegg.flutter

import android.app.Activity
import android.content.Context


const val TAG: String = "FronteggUtils"


interface ActivityProvider {
    fun getActivity(): Activity?
    fun getApplicationContext(): Context?
}