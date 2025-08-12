package com.frontegg.flutter

import android.app.Activity

interface ActivityProvider {
    fun getActivity(): Activity?
}