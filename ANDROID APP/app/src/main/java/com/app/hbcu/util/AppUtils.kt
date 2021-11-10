package com.app.hbcu.util

import android.Manifest
import android.content.Context
import android.content.pm.PackageManager
import androidx.core.content.ContextCompat
import java.text.DecimalFormat

object AppUtils {

    fun getAuthToken(context: Context): String {
        return "Bearer " + Pref.getStringValue(context, Config.PREF_AUTH_TOKEN, "")
    }

    fun CheckStorageREADPermission(context: Context?): Boolean {
        return if (ContextCompat.checkSelfPermission(
                context!!,
                Manifest.permission.READ_EXTERNAL_STORAGE
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            false
        } else true
    }

    fun CheckContactPermission(context: Context?): Boolean {
        return if (ContextCompat.checkSelfPermission(
                context!!,
                Manifest.permission.READ_CONTACTS
            ) != PackageManager.PERMISSION_GRANTED
        ) {
            false
        } else true
    }

    fun formatDoubleToString(value: Double?): String? {
        /*remove extrs zero and two digit only*/
        val formater = DecimalFormat("0.##")
        var returnValue: String? = ""
        returnValue = formater.format(value) ///15.5400 == 15.54
        return (returnValue.replace(",","."))
    }

    fun formatDoubleTo_4_DigitString(value: Double?): String? {
        /*remove extrs zero and two digit only*/
        val formater = DecimalFormat("0.####")
        var returnValue: String? = ""
        returnValue = formater.format(value) ///15.5400 == 15.54
        return (returnValue.replace(",","."))
    }
}