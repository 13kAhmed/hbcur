package com.app.hbcu.activity

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.*
import com.app.hbcu.R
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseException
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException
import com.google.firebase.auth.PhoneAuthCredential
import com.google.firebase.auth.PhoneAuthProvider
import java.util.concurrent.TimeUnit


class OTPcodeVerifyActivity : BaseAppCompatActivity(), View.OnClickListener {
    lateinit var btnSubmit: Button
    lateinit var ivBack: ImageView
    lateinit var etOtp: EditText
    lateinit var tvResend: TextView
    lateinit var flProgress: FrameLayout


    var mobileWithCode: String? = null
    var phone: String? = null
    var cCode: String? = null

    var mAuth: FirebaseAuth? = null
    var mVerificationId = ""
    private var mResendToken: PhoneAuthProvider.ForceResendingToken? = null
    private var mCallbacks: PhoneAuthProvider.OnVerificationStateChangedCallbacks? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        FirebaseApp.initializeApp(this)
        setContentView(R.layout.activity_otp_code_verify)

        init()
    }

    private fun init() {

        mAuth = FirebaseAuth.getInstance()
        mAuth!!.setLanguageCode("en")
        mAuth!!.signOut()

        btnSubmit = findViewById(R.id.btnSubmit)
        ivBack = findViewById(R.id.ivBack)
        etOtp = findViewById(R.id.etOtp)
        tvResend = findViewById(R.id.tvResend)
        flProgress = findViewById(R.id.flProgress)

        btnSubmit.setOnClickListener(this)
        ivBack.setOnClickListener(this)
        tvResend.setOnClickListener(this)

        phone = intent.getStringExtra("mobile")
        cCode = intent.getStringExtra("cCode")
        mobileWithCode = "+" + cCode + phone


        flProgress.setVisibility(View.VISIBLE)

        setupAuth()

    }

    private fun setupAuth() {

        mCallbacks = object : PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
            override fun onVerificationCompleted(phoneAuthCredential: PhoneAuthCredential) {

                signInWithPhoneAuthCredential(phoneAuthCredential)

            }

            override fun onVerificationFailed(e: FirebaseException) {
                flProgress.setVisibility(View.GONE)
                showToast(resources.getString(R.string.failed_sent_otp))
                Log.e("Err", e.toString() + "<");
            }

            override fun onCodeSent(
                verificationId: String,
                token: PhoneAuthProvider.ForceResendingToken
            ) {
                Log.e("onCodeSent", "<");

                flProgress.setVisibility(View.GONE)
                // Save verification ID and resending token so we can use them later
                mVerificationId = verificationId
                mResendToken = token


                // ...
            }
        }


        PhoneAuthProvider.getInstance().verifyPhoneNumber(
            mobileWithCode!!,  // Phone number to verify
            60,  // Timeout duration
            TimeUnit.SECONDS,  // Unit of timeout
            this,  // Activity (for callback binding)
            mCallbacks!!
        )

    }

    private fun signInWithPhoneAuthCredential(credential: PhoneAuthCredential) {
        flProgress.setVisibility(View.GONE)
        mAuth!!.signInWithCredential(credential)
            .addOnCompleteListener(this) { task ->
                if (task.isSuccessful) {
                    // Sign in success, update UI with the signed-in user's information

                    flProgress.setVisibility(View.GONE)

                    val user = mAuth!!.currentUser
                    flProgress.visibility = View.VISIBLE;
                    user!!.getIdToken(true)
                        .addOnCompleteListener { task ->
                            flProgress.visibility = View.GONE;
                            if (task.isSuccessful) {
                                val idToken =
                                    task.result!!.token

                                showToast(resources.getString(R.string.varified_success) + "")

                                val intent = Intent()
                                setResult(RESULT_OK, intent)
                                finish()

                            } else {
                                showToast(resources.getString(R.string.msg_somthing_wrong) + "")

                            }
                        }


                    // ...
                } else {

                    flProgress.setVisibility(View.GONE)

                    if (task.exception is FirebaseAuthInvalidCredentialsException) {
                        showToast(resources.getString(R.string.invalid_credential))
                    }
                }

            }
    }

    private fun verify() {

        flProgress.setVisibility(View.VISIBLE)

        try {
            val verificationCode: String = etOtp.getText().toString()
            Log.e("verfy", "verfy$verificationCode $mVerificationId");


            val credential = PhoneAuthProvider.getCredential(mVerificationId, verificationCode)
            Log.e("credential", ">>$credential")
            signInWithPhoneAuthCredential(credential)
        }catch (e:Exception)
        {
            showToast(resources.getString(R.string.msg_somthing_wrong_resend))
            flProgress.visibility = View.GONE
        }


    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.btnSubmit -> {
                if ((etOtp.text.toString()).equals("")) {
                    etOtp.error = resources.getString(R.string.lbl_required)
                } else if ((etOtp.text.toString().length) != 6) {
                    etOtp.error = resources.getString(R.string.lbl_invalid)
                } else {

                    verify()
                }
            }
            R.id.tvResend -> {
                setupAuth()
            }
            R.id.ivBack -> {
                finish()
            }
        }
    }
}