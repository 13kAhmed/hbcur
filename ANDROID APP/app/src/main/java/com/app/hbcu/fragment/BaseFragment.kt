package com.app.hbcu.fragment

import android.app.Activity
import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkInfo
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import android.widget.Toast
import androidx.fragment.app.Fragment
import com.app.hbcu.R

open class BaseFragment : Fragment() {
    protected var mActivity: Activity? = null
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }

    override fun onAttach(context: Context) {
        super.onAttach(context)
        if (context is Activity) {
            mActivity = context
        }
    }

    fun showToast(message: String?) {
        Toast.makeText(context, message, Toast.LENGTH_LONG).show()
    }

    protected fun hideKeyboard() {
        val viewGroup =
            activity!!.findViewById<View>(android.R.id.content) as ViewGroup
        val imm =
            activity!!.getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm?.hideSoftInputFromWindow(viewGroup.windowToken, 0)
    }

    val isConnectedToInternet: Boolean
        get() {
            try {
                val cm =
                    activity!!.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
                var activeNetwork: NetworkInfo? = null
                if (cm != null) {
                    activeNetwork = cm.activeNetworkInfo
                }
                if (activeNetwork != null) {
                    if (activeNetwork.type == ConnectivityManager.TYPE_WIFI) {
                        return true
                    } else if (activeNetwork.type == ConnectivityManager.TYPE_MOBILE) {
                        return true
                    }
                } else {
                    showToast(resources.getString(R.string.msg_no_internet))
                    return false
                }
                return false
            } catch (e: Exception) {
                return true;
            }

        }
}