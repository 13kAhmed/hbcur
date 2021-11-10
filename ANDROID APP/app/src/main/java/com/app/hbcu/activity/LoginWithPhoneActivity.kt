package com.app.hbcu.activity

import android.content.Intent
import android.os.Bundle
import android.util.Log
import android.view.View
import android.widget.*
import com.app.hbcu.R
import com.app.hbcu.model.user.UserLoginResponse
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import com.hbb20.CountryCodePicker
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response

class LoginWithPhoneActivity : BaseAppCompatActivity(), View.OnClickListener,
    CountryCodePicker.OnCountryChangeListener {

    val REQUEST_OTP_LOGIN = 105
    val REQUEST_OTP_SIGNUP = 55
    lateinit var btnSubmit: Button
    lateinit var ivBack: ImageView
    lateinit var etMobile: EditText
    lateinit var tvCountryCode: TextView
    lateinit var ccp: CountryCodePicker
    lateinit var flProgress: FrameLayout

    var selectedCountryCode: String = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login_with_phone)

        init()
    }

    private fun init() {

        btnSubmit = findViewById(R.id.btnSubmit)
        ivBack = findViewById(R.id.ivBack)
        etMobile = findViewById(R.id.etMobile)
        ccp = findViewById(R.id.ccp)
        tvCountryCode = findViewById(R.id.tvCountryCode)
        flProgress = findViewById(R.id.flProgress)

        btnSubmit.setOnClickListener(this)
        ivBack.setOnClickListener(this)

        ccp!!.setDefaultCountryUsingNameCode("US")
        ccp!!.setOnCountryChangeListener(this)
        selectedCountryCode = "+${ccp.selectedCountryCode}"
        tvCountryCode.setText(selectedCountryCode)

    }

    override fun onClick(p0: View?) {

        when (p0?.id) {
            R.id.btnSubmit -> {
                if ((etMobile.text.toString()).equals("")) {
                    etMobile.error = resources.getString(R.string.lbl_required)
                } else if ((etMobile.text.toString().length) != 10) {
                    etMobile.error = resources.getString(R.string.lbl_invalid)
                } else {

                    /* var intent = Intent(this, NationalityActivity::class.java);
                     startActivity(intent);*/

                    loginUser()
                }
            }

            R.id.ivBack -> {
                finish()
            }
        }
    }

    private fun loginUser() {

        if (!isConnectedToInternet) {
            return
        }

        var token: String? = Pref.getStringValue(this, Config.PREF_FCM_TOKEN, "-")
        if ((token!!).equals("")) {
            token = "-"
        }

        flProgress.visibility = View.VISIBLE

        val params: HashMap<String, String> = HashMap()
        params.put("signup_type", "1")
        params.put("mobile", etMobile.text.toString())
        params.put("country_code", ccp.selectedCountryCode)
        params.put("device_type", "Android")
        params.put("device_token", token!!)
        params.put("fcm_token", token!!)

        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<UserLoginResponse> = service.signinUser(params)

        /* val call: Call<UserLoginResponse> = service.signin(
            "1", etMobile.text.toString(),
            ccp.selectedCountryCode, "Android", token!!
        )*/

        call!!.enqueue(object : Callback<UserLoginResponse> {
            override fun onResponse(
                call: Call<UserLoginResponse>,
                response: Response<UserLoginResponse>
            ) {
                flProgress.visibility = View.GONE

                if (response.isSuccessful) {

                    if (response.body()!!.status!!.equals("200")) {


                        Pref.setStringValue(
                            this@LoginWithPhoneActivity, Config.PREF_UID,
                            response.body()!!.data!!.user!!.id.toString()
                        )
                        Pref.setStringValue(
                            this@LoginWithPhoneActivity, Config.PREF_AUTH_TOKEN,
                            response.body()!!.data!!.token
                        )

                        Pref.setUserLoginData(
                            this@LoginWithPhoneActivity,
                            response.body()!!.data!!.user
                        )


                        var intent =
                            Intent(this@LoginWithPhoneActivity, OTPcodeVerifyActivity::class.java);
                        intent.putExtra("cCode", ccp.selectedCountryCode)
                        intent.putExtra("mobile", etMobile.text.toString())
                        startActivityForResult(intent, REQUEST_OTP_LOGIN)

                    } else {

                        redirectSignup()
                    }

                } else {

                    redirectSignup()

                }

            }

            override fun onFailure(call: Call<UserLoginResponse>, t: Throwable) {
                Log.e("exception ", "ex$t")

                redirectSignup()
                flProgress.visibility = View.GONE
            }
        })

    }

    private fun redirectSignup() {

        var intent =
            Intent(this@LoginWithPhoneActivity, OTPcodeVerifyActivity::class.java);
        intent.putExtra("cCode", ccp.selectedCountryCode)
        intent.putExtra("mobile", etMobile.text.toString())
        startActivityForResult(intent, REQUEST_OTP_SIGNUP)


    }

    override fun onCountrySelected() {
        selectedCountryCode = "+${ccp.selectedCountryCode}"
        tvCountryCode.setText(selectedCountryCode)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQUEST_OTP_LOGIN && resultCode == RESULT_OK) {


            Pref.setIntValue(this@LoginWithPhoneActivity, Config.PREF_IS_LOGIN, 1)

            var intent =
                Intent(this@LoginWithPhoneActivity, DashboardActivity::class.java);
            intent.flags =
                Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK;
            startActivity(intent);
            finish()


        } else if (requestCode == REQUEST_OTP_SIGNUP && resultCode == RESULT_OK) {

            var intent = Intent(this, SignupActivity::class.java);
            intent.putExtra("cCode", ccp.selectedCountryCode)
            intent.putExtra("mobile", etMobile.text.toString())
            intent.putExtra("signupType", "1")
            startActivity(intent);

        }
    }

}