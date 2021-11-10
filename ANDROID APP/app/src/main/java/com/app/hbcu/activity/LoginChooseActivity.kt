package com.app.hbcu.activity

import android.R.string
import android.content.Intent
import android.os.Bundle
import android.text.*
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import android.widget.LinearLayout
import android.widget.TextView
import android.widget.Toast
import com.app.hbcu.R
import com.app.hbcu.model.user.UserLoginResponse
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import com.facebook.*
import com.facebook.GraphRequest.GraphJSONObjectCallback
import com.facebook.login.LoginManager
import com.facebook.login.LoginResult
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.android.gms.common.api.ApiException
import com.google.android.gms.tasks.OnCompleteListener
import com.google.android.gms.tasks.Task
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.OAuthProvider
import com.google.firebase.messaging.FirebaseMessaging
import org.json.JSONException
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*


class LoginChooseActivity : BaseAppCompatActivity(), View.OnClickListener {

    lateinit var flProgress: FrameLayout
    lateinit var llPhoneContinue: LinearLayout
    lateinit var llFacebookContinue: LinearLayout
    lateinit var llGoogleContinue: LinearLayout
    lateinit var llAppleContinue: LinearLayout
    lateinit var tvPrivacy: TextView

    lateinit var callbackManager: CallbackManager

    val RC_SIGN_IN: Int = 107
    lateinit var mGoogleSignInClient: GoogleSignInClient
    lateinit var mGoogleSignInOptions: GoogleSignInOptions
    private var mAuth: FirebaseAuth? = null
    lateinit var providerApple: OAuthProvider.Builder

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_login_choose)
        //FacebookSdk.sdkInitialize(applicationContext)


        /*  var token: String? = Pref.getStringValue(this, Config.PREF_FCM_TOKEN, "-")
          Log.e("TOKEN", ">>" + token)*/
        mAuth = FirebaseAuth.getInstance()

        try {
            mAuth!!.signOut()
        }catch (e: Exception)
        {

        }

        try {
            //FirebaseMessaging.getInstance().token.

            FirebaseMessaging.getInstance().token.addOnCompleteListener(OnCompleteListener { task ->
                if (!task.isSuccessful) {
                    Log.e("ERRR", "Fetching FCM registration token failed", task.exception)
                    return@OnCompleteListener
                }

                // Get new FCM registration token
                val token = task.result

                // Log and toast
                Pref.setStringValue(getBaseContext(), Config.PREF_FCM_TOKEN, token)
                Log.e("AAA", ">>$token")
            })
        } catch (e: Exception) {
            e.printStackTrace()
        }

        init();
    }

    private fun init() {
        llPhoneContinue = findViewById(R.id.llPhoneContinue)
        llFacebookContinue = findViewById(R.id.llFacebookContinue)
        llGoogleContinue = findViewById(R.id.llGoogleContinue)
        llAppleContinue = findViewById(R.id.llAppleContinue)
        flProgress = findViewById(R.id.flProgress)
        tvPrivacy = findViewById(R.id.tvPrivacy)

        llPhoneContinue.setOnClickListener(this)
        llFacebookContinue.setOnClickListener(this)
        llGoogleContinue.setOnClickListener(this)
        llAppleContinue.setOnClickListener(this)

        callbackManager = CallbackManager.Factory.create();


        tvPrivacy.makeLinks(
            Pair("Terms of Service", View.OnClickListener {
               // Toast.makeText(applicationContext, "Terms of Service", Toast.LENGTH_SHORT).show()
                var intent = Intent(this, WebActivity::class.java)
                intent.putExtra("urlWeb", Config.URL_TERMS_SERVICE + "")
                intent.putExtra("title", "Terms of Service")
                startActivity(intent)
            }),
            Pair("Privacy Policy", View.OnClickListener {
               // Toast.makeText(applicationContext, "Privacy Policy", Toast.LENGTH_SHORT).show()
                var intent = Intent(this, WebActivity::class.java)
                intent.putExtra("urlWeb", Config.URL_PRIVACY_POLICY + "")
                intent.putExtra("title", "Privacy Policy")
                startActivity(intent)
            }))

        setupGoogle()
    }

    private fun setupGoogle() {

        try {
            mGoogleSignInOptions = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                .requestEmail()
                .build()
            mGoogleSignInClient = GoogleSignIn.getClient(this, mGoogleSignInOptions)

            mGoogleSignInClient.signOut()

        } catch (e: Exception) {

        }
    }

    override fun onResume() {
        super.onResume()
    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.llPhoneContinue -> {
                var intent = Intent(this, LoginWithPhoneActivity::class.java);
                startActivity(intent);
            }
            R.id.llFacebookContinue -> {
                facebookLogin()
            }
            R.id.llGoogleContinue -> {

                googleLogin()

            }
            R.id.llAppleContinue -> {

                appleLogin()
            }
        }
    }

    private fun appleLogin() {

        providerApple = OAuthProvider.newBuilder("apple.com")
        providerApple.setScopes(arrayOf("email", "name").toMutableList())



        val pending = mAuth!!.pendingAuthResult
        if (pending != null) {
            pending.addOnSuccessListener { authResult ->
                Log.d(">", "checkPending:onSuccess:$authResult")
                // Get the user profile with authResult.getUser() and
                // authResult.getAdditionalUserInfo(), and the ID
                // token from Apple with authResult.getCredential().

                getAppleData(authResult.user)

            }.addOnFailureListener { e ->
                authenticateWithApple()
            }
        } else {
            authenticateWithApple()

        }


    }

    private fun getAppleData(user: FirebaseUser?) {

        var dName: String = user!!.displayName!!
        // var dName: String = authResult.user!!.
        var socialId: String = user!!.uid


        var fName: String = dName + ""
        var lName: String = dName + ""
        try {
            var splitS: List<String> = dName.split(" ", limit = 2)
            fName = splitS[0]
            lName = splitS[1]
        } catch (ex: Exception) {

        }

        checkLogin(fName, lName, socialId, "4")

    }

    private fun authenticateWithApple() {

        mAuth!!.startActivityForSignInWithProvider(this, providerApple.build())
            .addOnSuccessListener { authResult ->
                // Sign-in successful!
                Log.d(">>", "activitySignIn:onSuccess:${authResult.user}")
                val user = authResult.user
                getAppleData(user)

            }
            .addOnFailureListener { e ->
                //Log.w(TAG, "activitySignIn:onFailure", e)
                showToast("" + e.message)
                Log.e("ERRR", ":"+e.toString())

            }

    }

    private fun googleLogin() {

        flProgress.visibility = View.VISIBLE
        val signInIntent: Intent = mGoogleSignInClient.signInIntent
        startActivityForResult(signInIntent, RC_SIGN_IN)
    }

    private fun facebookLogin() {
        flProgress.visibility = View.VISIBLE
        LoginManager.getInstance().logInWithReadPermissions(
            this,
            Arrays.asList("email", "public_profile")
        )
        LoginManager.getInstance().registerCallback(callbackManager, object :
            FacebookCallback<LoginResult?> {
            override fun onSuccess(result: LoginResult?) {
                flProgress.visibility = View.GONE

                val accessToken: AccessToken = result!!.accessToken
                if (accessToken != null && !accessToken.isExpired) {
                    getFacebookDetail(accessToken)
                }

            }

            override fun onCancel() {
                flProgress.visibility = View.GONE
                Log.e("onCancel", "onCancel")


            }

            override fun onError(error: FacebookException?) {
                flProgress.visibility = View.GONE
                Log.e("FacebookException", ">>$error")

            }
        })
    }


    private fun getFacebookDetail(accessToken: AccessToken) {
        val request = GraphRequest.newMeRequest(AccessToken.getCurrentAccessToken(),
            GraphJSONObjectCallback { `object`, response ->
                val json = response.jsonObject
                try {
                    if (json != null) {

                        var facebook_uid: String = json.getString("id")
                        var social_id = json.getString("id")
                        var first_name = json.getString("first_name")
                        var last_name = json.getString("last_name")
                        // var name = json.getString("name")


                      /*  try {
                            var picture =
                                "https://graph.facebook.com/" + facebook_uid.toString() + "/picture?type=large"

                        } catch (e: Exception) {

                        }*/

                        checkLogin(first_name + "", last_name + "", social_id + "", "3")


                    }
                } catch (e: JSONException) {
                    e.printStackTrace()
                    // e.printStackTrace()

                }
            })
        val parameters = Bundle()
        parameters.putString("fields", "id,name,first_name,last_name,link,email,picture")
        request.setParameters(parameters)
        request.executeAsync()
    }

    private fun checkLogin(fname: String, lname: String, sid: String, stype: String) {


        var token: String? = Pref.getStringValue(this, Config.PREF_FCM_TOKEN, "-")
        flProgress.visibility = View.VISIBLE

        val params: HashMap<String, String> = HashMap()

        params.put("signup_type", stype)
        params.put("device_type", "Android")
        params.put("device_token", "" + token!!)
        params.put("username", sid)
        params.put("type", "login")
        params.put("first_name", "-" + fname)
        params.put("last_name", "-" + lname)
        params.put("fcm_token", "" + token)


        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<UserLoginResponse> = service.Socialsignup(params)

        call!!.enqueue(object : Callback<UserLoginResponse> {
            override fun onResponse(
                call: Call<UserLoginResponse>,
                response: Response<UserLoginResponse>
            ) {
                flProgress.visibility = View.GONE

                if (response.isSuccessful) {
                    if (response.body()!!.status!!.equals("200")) {


                        Pref.setIntValue(this@LoginChooseActivity, Config.PREF_IS_LOGIN, 1)
                        Pref.setStringValue(
                            this@LoginChooseActivity, Config.PREF_UID,
                            response.body()!!.data!!.user!!.id.toString()
                        )
                        Pref.setUserLoginData(
                            this@LoginChooseActivity,
                            response.body()!!.data!!.user
                        )
                        Pref.setStringValue(
                            this@LoginChooseActivity, Config.PREF_AUTH_TOKEN,
                            response.body()!!.data!!.token
                        )

                        var intent =
                            Intent(this@LoginChooseActivity, DashboardActivity::class.java);
                        intent.flags =
                            Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK;
                        startActivity(intent);
                        finish()

                    } else {
                        redirectSignup(fname, lname, sid, stype)
                    }

                } else {
                    redirectSignup(fname, lname, sid, stype)

                }

            }

            override fun onFailure(call: Call<UserLoginResponse>, t: Throwable) {

                flProgress.visibility = View.GONE

                redirectSignup(fname, lname, sid, stype)
            }
        })


    }

    private fun redirectSignup(fname: String, lname: String, sid: String, stype: String) {
        var intent = Intent(this, SignupActivity::class.java);
        intent.putExtra("fName", fname + "")
        intent.putExtra("lName", lname + "")
        intent.putExtra("socialID", sid + "")
        intent.putExtra("signupType", stype)
        startActivity(intent)

    }

    private fun getGoogleDetail(account: GoogleSignInAccount) {

        try {

            var dName: String = account.displayName!!
            var socialId: String = account.id!!


            var fName: String = dName + ""
            var lName: String = dName + ""
            try {
                var splitS: List<String> = dName.split(" ", limit = 2)
                fName = splitS[0]
                lName = splitS[1]
            } catch (ex: Exception) {

            }


            checkLogin(fName, lName, socialId, "2")


        } catch (e: Exception) {
        }

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        callbackManager.onActivityResult(requestCode, resultCode, data);
        super.onActivityResult(requestCode, resultCode, data)
        flProgress.visibility = View.GONE
        if (requestCode == RC_SIGN_IN) {
            val task: Task<GoogleSignInAccount> = GoogleSignIn.getSignedInAccountFromIntent(data)
            try {
                val account = task.getResult(ApiException::class.java)

                if (account != null) {
                    getGoogleDetail(account)
                }
            } catch (e: ApiException) {
                Toast.makeText(this, "Google sign in failed", Toast.LENGTH_LONG).show()
            }
        }
    }

    fun TextView.makeLinks(vararg links: Pair<String, View.OnClickListener>) {
        val spannableString = SpannableString(this.text)
        var startIndexOfLink = -1
        for (link in links) {
            val clickableSpan = object : ClickableSpan() {
                override fun updateDrawState(textPaint: TextPaint) {
                    // use this to change the link color
                    textPaint.color = textPaint.linkColor
                    // toggle below value to enable/disable
                    // the underline shown below the clickable text
                    textPaint.isUnderlineText = true
                }

                override fun onClick(view: View) {
                    Selection.setSelection((view as TextView).text as Spannable, 0)
                    view.invalidate()
                    link.second.onClick(view)
                }
            }
            startIndexOfLink = this.text.toString().indexOf(link.first, startIndexOfLink + 1)
//      if(startIndexOfLink == -1) continue // todo if you want to verify your texts contains links text
            spannableString.setSpan(
                clickableSpan, startIndexOfLink, startIndexOfLink + link.first.length,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }
        this.movementMethod =
            LinkMovementMethod.getInstance() // without LinkMovementMethod, link can not click
        this.setText(spannableString, TextView.BufferType.SPANNABLE)
    }
}