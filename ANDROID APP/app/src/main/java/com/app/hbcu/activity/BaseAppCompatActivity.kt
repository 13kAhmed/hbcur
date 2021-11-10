package com.app.hbcu.activity

import android.content.Context
import android.net.ConnectivityManager
import android.net.NetworkInfo
import android.os.Bundle
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.appcompat.app.AppCompatActivity
import androidx.appcompat.widget.Toolbar
import androidx.fragment.app.FragmentManager
import com.app.hbcu.R
import com.app.hbcu.util.Config
import io.github.inflationx.viewpump.ViewPumpContextWrapper
import io.socket.client.IO
import io.socket.client.Socket

open class BaseAppCompatActivity : AppCompatActivity() {
    // public ProgressDialog mProgressDialog;
    var mContext: Context? = null
    var onDialogClickListener: OnDialogClickListener? = null
    private val TAG = BaseAppCompatActivity::class.java.name

    //lateinit var mySocket: Socket

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        mContext = this

       // mySocket = IO.socket(Config.SERVER_URL_SOCKET)
       // mySocket.connect()

    }

    override fun attachBaseContext(newBase: Context?) {
        super.attachBaseContext(ViewPumpContextWrapper.wrap(newBase!!))
    }


    fun setToolbar(
        toolbar: Toolbar,
        title: String?,
        isbackenable: Boolean
    ) {
        toolbar.title = title
        setSupportActionBar(toolbar)
        if (isbackenable) {
            toolbar.setNavigationIcon(R.drawable.ic_back)
            toolbar.setNavigationOnClickListener { finish() }
        }
    }

    /**
     * Popup message and after short time this popup will automatically destroy.
     *
     * @param message Message for display in popup.
     */
    fun showToast(message: String?) {
        Toast.makeText(this, message, Toast.LENGTH_LONG).show()
    }

    /**
     * Hide keyboard
     */
    protected fun hideKeyboard() {
        val viewGroup =
            findViewById<View>(R.id.content) as ViewGroup
        val imm =
            getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm?.hideSoftInputFromWindow(viewGroup.windowToken, 0)
    }

    /**
     * Open Keyboard.
     */
    fun showKeyboard() {
        val viewGroup =
            findViewById<View>(R.id.content) as ViewGroup
        val imm =
            getSystemService(Context.INPUT_METHOD_SERVICE) as InputMethodManager
        imm?.toggleSoftInputFromWindow(
            viewGroup.applicationWindowToken,
            InputMethodManager.SHOW_FORCED,
            0
        )
    }

    fun clearBackStack() {
        val manager = supportFragmentManager
        if (manager.backStackEntryCount > 0) {
            val first =
                manager.getBackStackEntryAt(0)
            manager.popBackStackImmediate(
                first.id,
                FragmentManager.POP_BACK_STACK_INCLUSIVE
            )
        }
    }

    fun showOKAlert(
        messageString: String?,
        onDialogClickListener1: OnDialogClickListener?
    ) {
        onDialogClickListener = onDialogClickListener1
        val builder =
            AlertDialog.Builder(this@BaseAppCompatActivity)
        builder.setMessage(messageString)
        builder.setPositiveButton("Ok") { dialog, which ->
            dialog.dismiss()
            onDialogClickListener!!.onPositive()
        }
        val alert = builder.create()
        alert.show()
    }

    fun showPositiveNegativeAlert(
        messageString: String?,
        yes: Int,
        no: Int,
        onDialogClickListener1: OnDialogClickListener?
    ) {
        onDialogClickListener = onDialogClickListener1
        val builder =
            AlertDialog.Builder(this@BaseAppCompatActivity)
        builder.setMessage(messageString)
        builder.setPositiveButton(yes) { dialog, which ->
            dialog.dismiss()
            onDialogClickListener!!.onPositive()
        }
        builder.setNegativeButton(no) { dialog, which ->
            dialog.dismiss()
            onDialogClickListener!!.onNegative()
        }
        val alert = builder.create()
        alert.show()
    }

    val isConnectedToInternet: Boolean
        get() {
            val cm =
                this@BaseAppCompatActivity.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
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
        }

    interface OnDialogClickListener {
        fun onPositive()
        fun onNegative()
    }

    override fun onDestroy() {
        super.onDestroy()
    }


}