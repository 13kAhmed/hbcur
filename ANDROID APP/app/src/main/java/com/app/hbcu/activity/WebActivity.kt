package com.app.hbcu.activity

import android.os.Bundle
import android.os.Handler
import android.view.View
import android.webkit.WebView
import android.webkit.WebViewClient
import android.widget.ImageView
import android.widget.TextView
import com.app.hbcu.R


class WebActivity : BaseAppCompatActivity(), View.OnClickListener {
    lateinit var ivBack: ImageView
    lateinit var webview: WebView;
    lateinit var tvTitle: TextView;
    var urlWeb: String? = null
    var title: String? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_web)

        init()
    }

    private fun init() {

        ivBack = findViewById(R.id.ivBack)
        webview = findViewById(R.id.webview)
        tvTitle = findViewById(R.id.tvTitle)

        ivBack.setOnClickListener(this)

        urlWeb = intent.getStringExtra("urlWeb")
        title = intent.getStringExtra("title")

        tvTitle.setText(title!!)
       


        Handler().postDelayed({
            webview.settings.loadsImagesAutomatically = true
            webview.settings.javaScriptEnabled = true
            webview.scrollBarStyle = View.SCROLLBARS_INSIDE_OVERLAY

            val settings = webview.settings
            settings.domStorageEnabled = true
            
            webview.webViewClient = object : WebViewClient() {
                override fun shouldOverrideUrlLoading(view: WebView, url: String): Boolean {
                    view.loadUrl(url)
                    return false // then it is not handled by default action
                }
            }

            webview.loadUrl(urlWeb!!)
        }, 200)



    }


    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.ivBack -> {
                finish()
            }
        }
    }
}