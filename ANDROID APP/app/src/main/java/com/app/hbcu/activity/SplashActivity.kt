package com.app.hbcu.activity

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import com.app.hbcu.R
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions

 class SplashActivity : BaseAppCompatActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_splash)


        redirectNext()

    }

    override fun onResume() {
        super.onResume()
    }

    private fun redirectNext() {
        val SPLASH_TIME_OUT = 3000
        Handler().postDelayed({

            intent = Intent(this, LoginChooseActivity::class.java)

            if (Pref.getintValue(this, Config.PREF_IS_LOGIN, 0) == 1) {
                intent = Intent(this, DashboardActivity::class.java)

            }

            intent.flags = Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK;
            startActivity(intent)
            finish();

        }, SPLASH_TIME_OUT.toLong())
    }
}