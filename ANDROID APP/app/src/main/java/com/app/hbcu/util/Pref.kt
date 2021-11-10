package com.app.hbcu.util

import android.content.Context
import android.content.SharedPreferences
import com.app.hbcu.model.user.User
import com.google.gson.Gson


object Pref {
    var preferences: SharedPreferences? = null
    fun openPref(context: Context) {
        preferences = context.getSharedPreferences(Config.SHARED_PREF_NAME, Context.MODE_PRIVATE)
    }

    fun setStringValue(context: Context, key: String?, value: String?) {
        openPref(context)
        val editor = preferences!!.edit()
        editor.putString(key, value)
        editor.commit()
        preferences = null
    }

    fun setIntValue(
        context: Context,
        key: String?,
        value: Int
    ) {
        openPref(context)
        val editor = preferences!!.edit()
        editor.putInt(key, value)
        editor.commit()
        preferences = null
    }

    fun getStringValue(
        context: Context,
        key: String?,
        defvalue: String?
    ): String? {
        openPref(context)
        val result = preferences!!.getString(key, defvalue)
        preferences = null
        return result
    }

    fun getintValue(context: Context, key: String?, defvalue: Int): Int {
        openPref(context)
        val result = preferences!!.getInt(key, defvalue)
        preferences = null
        return result
    }

    fun clearPref(context: Context) {
        openPref(context)
        val editor = preferences!!.edit()
        editor.clear()
        editor.commit()
    }


    fun setUserLoginData(context: Context, value: User?) {
        openPref(context)
        val editor = preferences!!.edit()

        val gson = Gson()
        val jsonString = gson.toJson(value)

        editor.putString(Config.PREF_USERDATA, jsonString)
        editor.commit()
        preferences = null
    }

    fun getUserLoginData(context: Context): User {
        openPref(context)
        var obj: User = User()
        val result = preferences!!.getString(Config.PREF_USERDATA, "")

        if (!result.equals("")) {
            val gson = Gson()
            obj = gson.fromJson(result, User::class.java)
        }
        preferences = null
        return obj
    }
}