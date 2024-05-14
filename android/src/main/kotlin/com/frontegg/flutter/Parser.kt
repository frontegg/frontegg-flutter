package com.frontegg.flutter

import com.frontegg.android.models.User
import com.google.gson.Gson
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject

fun User.toReadableMap(): MutableMap<String, Any?> {
    val jsonStr = Gson().toJson(this, User::class.java)
    val jsonObject = JSONObject(jsonStr)
    return convertJsonToMap(jsonObject)
}

@Throws(JSONException::class)
fun convertJsonToArray(jsonArray: JSONArray): ArrayList<Any?> {
    val array = arrayListOf<Any?>()
    for (i in 0 until jsonArray.length()) {
        when (val value = jsonArray[i]) {
            is JSONObject -> {
                array.add(convertJsonToMap(value))
            }

            is JSONArray -> {
                array.add(convertJsonToArray(value))
            }

            else -> {
                array.add(value)
            }
        }
    }
    return array
}

@Throws(JSONException::class)
fun convertJsonToMap(jsonObject: JSONObject): MutableMap<String, Any?> {
    val map = mutableMapOf<String, Any?>()
    val iterator = jsonObject.keys()
    while (iterator.hasNext()) {
        val key = iterator.next()
        when (val value = jsonObject[key]) {
            is JSONObject -> {
                map[key] = convertJsonToMap(value)
            }

            is JSONArray -> {
                map[key] = convertJsonToArray(value)
            }

            else -> {
                map[key] = value
            }
        }
    }
    return map
}
