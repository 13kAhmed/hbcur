package com.app.hbcu.activity

import android.content.Intent
import android.graphics.PorterDuff
import android.os.Bundle
import android.view.View
import android.widget.*
import androidx.core.widget.NestedScrollView
import com.app.hbcu.R
import com.app.hbcu.adapter.SpinnerCustomAdater
import com.app.hbcu.model.country.CountryResponse
import com.app.hbcu.model.user.UserLoginResponse
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*

class SignupActivity : BaseAppCompatActivity(), View.OnClickListener,
    CompoundButton.OnCheckedChangeListener {

    lateinit var etFirstName: EditText
    lateinit var etLastName: EditText
    lateinit var etInvitation: EditText
    lateinit var cbAA: CheckBox
    lateinit var spnNationality: Spinner
    lateinit var btnYes: Button
    lateinit var btnNo: Button
    lateinit var btnYesAlumni: Button
    lateinit var btnNoAlumni: Button
    lateinit var btnSubmit: Button
    lateinit var llSupportSocial: LinearLayout
    lateinit var rlNationality: LinearLayout
    lateinit var ivBack: ImageView
    lateinit var flProgress: FrameLayout
    lateinit var nestedScroll: NestedScrollView

    lateinit var adapterSpinner: SpinnerCustomAdater
    var listCountry: ArrayList<String> = ArrayList()
    var cCode: String = ""
    var mobile: String = ""
    var fName: String = ""
    var lName: String = ""
    var socialID: String = ""
    var signupType: String = ""
    var isVarified: Boolean = false

    var isQut1: Int = -1
    var isQut2: Int = -1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_signup)

        isVarified = false
        init();
    }

    private fun init() {

        etLastName = findViewById(R.id.etLastName)
        etFirstName = findViewById(R.id.etFirstName)
        etInvitation = findViewById(R.id.etInvitation)
        nestedScroll = findViewById(R.id.nestedScroll)

        cbAA = findViewById(R.id.cbAA)
        spnNationality = findViewById(R.id.spnNationality)
        btnYes = findViewById(R.id.btnYes)
        btnNo = findViewById(R.id.btnNo)
        btnSubmit = findViewById(R.id.btnSubmit)
        llSupportSocial = findViewById(R.id.llSupportSocial)
        rlNationality = findViewById(R.id.rlNationality)
        ivBack = findViewById(R.id.ivBack)
        flProgress = findViewById(R.id.flProgress)
        btnYesAlumni = findViewById(R.id.btnYesAlumni)
        btnNoAlumni = findViewById(R.id.btnNoAlumni)


        setSpinnerCountry()


        signupType = intent.getStringExtra("signupType")!!
        if (signupType.equals("1")) {
            cCode = intent.getStringExtra("cCode")!!
            mobile = intent.getStringExtra("mobile")!!
        } else {
            fName = intent.getStringExtra("fName")!!
            lName = intent.getStringExtra("lName")!!
            socialID = intent.getStringExtra("socialID")!!

            etFirstName.setText(fName)
            etLastName.setText(lName)
        }

        getCountryList();
        listener()
    }

    private fun getCountryList() {

        listCountry.clear()
        listCountry.add(resources.getString(R.string.lbl_choose_nationality))

        flProgress.visibility = View.VISIBLE


        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<CountryResponse> = service.getMetaData()

        call!!.enqueue(object : Callback<CountryResponse> {
            override fun onResponse(
                call: Call<CountryResponse>,
                response: Response<CountryResponse>
            ) {
                flProgress.visibility = View.GONE

                if (response.isSuccessful) {
                    if (response.body()!!.status!!.equals("200")) {


                        for (item in (response.body().data!!.countrys)!!) {
                            listCountry.add(item!!.name!!)
                        }
                    }
                }

                adapterSpinner.notifyDataSetChanged()
            }

            override fun onFailure(call: Call<CountryResponse>, t: Throwable) {

                flProgress.visibility = View.GONE
            }
        })

    }

    private fun listener() {
        btnYes.setOnClickListener(this)
        btnNo.setOnClickListener(this)
        btnSubmit.setOnClickListener(this)
        ivBack.setOnClickListener(this)
        btnYesAlumni.setOnClickListener(this)
        btnNoAlumni.setOnClickListener(this)

        cbAA.setOnCheckedChangeListener(this)


        /*    spnNationality.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
                override fun onNothingSelected(parent: AdapterView<*>?) {
                }

                override fun onItemSelected(
                    parent: AdapterView<*>?,
                    view: View?,
                    position: Int,
                    id: Long
                ) {
                    val value = parent!!.getItemAtPosition(position).toString()
                    if (value == listCountry.get(0)) {
                        (view as TextView).setTextColor(Color.GRAY)
                    }
                }

            }*/


    }

    fun setSpinnerCountry() {
        adapterSpinner = SpinnerCustomAdater(this, listCountry)
        spnNationality.setAdapter(adapterSpinner)
    }


    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.ivBack -> {
                finish()
            }
            R.id.btnSubmit -> {

                if ((etFirstName.text.toString().trim()).equals("")) {
                    etFirstName.error = resources.getString(R.string.lbl_required)
                } else if ((etLastName.text.toString().trim()).equals("")) {
                    etLastName.error = resources.getString(R.string.lbl_required)
                } else if ((etInvitation.text.toString().trim()).equals("")) {
                    etInvitation.error = resources.getString(R.string.lbl_required)
                } else {

                    //if (!cbAA.isChecked) {
                    if (spnNationality.selectedItemPosition <= 0) {
                        showToast(resources.getString(R.string.msg_choose_nationality))
                        return
                    }
                    // }

                    if (signupType.equals("1")) {
                        signupUser()
                    } else {
                        socialSignupUser()
                    }

                }
            }
            R.id.btnYes -> {
                isQut2 = 1
                // btnYes.setBackgroundTintList(ColorStateList.valueOf(resources.getColor(R.color.yellow)));
                btnYes.getBackground()
                    .setColorFilter(resources.getColor(R.color.yellow), PorterDuff.Mode.SRC_ATOP);
                btnNo.getBackground()
                    .setColorFilter(resources.getColor(R.color.white), PorterDuff.Mode.SRC_ATOP);

                visibleSubmitButton()

            }
            R.id.btnNo -> {
                isQut2 = 0
                btnNo.getBackground()
                    .setColorFilter(resources.getColor(R.color.yellow), PorterDuff.Mode.SRC_ATOP);
                btnYes.getBackground()
                    .setColorFilter(resources.getColor(R.color.white), PorterDuff.Mode.SRC_ATOP);

                visibleSubmitButton()
            }
            R.id.btnYesAlumni -> {
                isQut1 = 1

                btnYesAlumni.getBackground()
                    .setColorFilter(resources.getColor(R.color.yellow), PorterDuff.Mode.SRC_ATOP);
                btnNoAlumni.getBackground()
                    .setColorFilter(resources.getColor(R.color.white), PorterDuff.Mode.SRC_ATOP);
                visibleSubmitButton()
            }
            R.id.btnNoAlumni -> {
                isQut1 = 0
                btnNoAlumni.getBackground()
                    .setColorFilter(resources.getColor(R.color.yellow), PorterDuff.Mode.SRC_ATOP);
                btnYesAlumni.getBackground()
                    .setColorFilter(resources.getColor(R.color.white), PorterDuff.Mode.SRC_ATOP);
                visibleSubmitButton()

            }
        }
    }

    fun visibleSubmitButton() {
        if (isQut1 >= 0 && isQut2 >= 0) {
            btnSubmit.visibility = View.VISIBLE
            nestedScroll.fullScroll(View.FOCUS_DOWN);
            nestedScroll.postDelayed(Runnable() {
                kotlin.run {
                    nestedScroll.smoothScrollTo(0, btnSubmit.getBottom());

                }
            }, 100);
        }
    }

    override fun onCheckedChanged(p0: CompoundButton?, p1: Boolean) {

        /*  if (p1) {
              rlNationality.visibility = GONE
          } else {
              rlNationality.visibility = VISIBLE

          }*/
    }


    private fun signupUser() {

        var nationality: String = "African American"
        var isAfrican_American: Int = 1

        nationality = listCountry.get(spnNationality.selectedItemPosition)

        if (!cbAA.isChecked) {
            isAfrican_American = 0

        }


        var token: String? = Pref.getStringValue(this, Config.PREF_FCM_TOKEN, "-")

        if ((token!!).equals("")) {
            token = "-"
        }

        var is_hbcu_alumni: String? = "No"

        if (isQut1 == 1) {
            is_hbcu_alumni = "Yes"
        }
        flProgress.visibility = View.VISIBLE

        val params: HashMap<String, String> = HashMap()
        params.put("first_name", etFirstName.text.toString())
        params.put("last_name", etLastName.text.toString())
        params.put("signup_type", signupType)
        params.put("invitation_code", etInvitation.text.toString())//PCPZN50V13
        params.put("nationality", nationality)
        params.put("device_type", "Android")
        params.put("device_token", token!!)
        params.put("fcm_token", token!!)
        params.put("is_african_american ", isAfrican_American.toString())
        params.put("is_hbcu_alumni", is_hbcu_alumni!!)

        if (signupType.equals("1")) {
            params.put("mobile", mobile)
            params.put("country_code", cCode)

        } else {
            params.put("username", "$socialID")
        }


        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<UserLoginResponse> = service.signup(params)

        call!!.enqueue(object : Callback<UserLoginResponse> {
            override fun onResponse(
                call: Call<UserLoginResponse>,
                response: Response<UserLoginResponse>
            ) {
                flProgress.visibility = View.GONE

                if (response.isSuccessful) {
                    if (response.body()!!.status!!.equals("200")) {

                        showToast(resources.getString(R.string.msg_register_success))

                        Pref.setIntValue(this@SignupActivity, Config.PREF_IS_LOGIN, 1)
                        Pref.setStringValue(
                            this@SignupActivity, Config.PREF_UID,
                            response.body()!!.data!!.user!!.id.toString()
                        )
                        Pref.setUserLoginData(
                            this@SignupActivity,
                            response.body()!!.data!!.user
                        )
                        Pref.setStringValue(
                            this@SignupActivity, Config.PREF_AUTH_TOKEN,
                            response.body()!!.data!!.token
                        )

                        var intent =
                            Intent(this@SignupActivity, DashboardActivity::class.java);
                        intent.flags =
                            Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK;
                        startActivity(intent);
                        finish()

                    } else {
                        showToast(response.body()!!.message!!.error)
                    }

                } else {
                    showToast(resources.getString(R.string.msg_somthing_wrong))

                }

            }

            override fun onFailure(call: Call<UserLoginResponse>, t: Throwable) {

                showToast(resources.getString(R.string.msg_somthing_wrong))
                flProgress.visibility = View.GONE
            }
        })

    }

    private fun socialSignupUser() {

        var nationality: String = "African American"
        var isAfrican_American: Int = 1

        nationality = listCountry.get(spnNationality.selectedItemPosition)

        if (!cbAA.isChecked) {
            isAfrican_American = 0
        }


        var token: String? = Pref.getStringValue(this, Config.PREF_FCM_TOKEN, "-")
        if ((token!!).equals("")) {
            token = "-"
        }
        var is_hbcu_alumni: String? = "No"

        if (isQut1 == 1) {
            is_hbcu_alumni = "Yes"
        }

        flProgress.visibility = View.VISIBLE

        val params: HashMap<String, String> = HashMap()
        params.put("first_name", etFirstName.text.toString())
        params.put("last_name", etLastName.text.toString())
        params.put("signup_type", signupType)
        params.put("invitation_code", etInvitation.text.toString())//PCPZN50V13
        params.put("nationality", nationality)
        params.put("device_type", "Android")
        params.put("device_token", "" + token!!)
        params.put("fcm_token", "" + token!!)
        params.put("is_african_american ", isAfrican_American.toString())
        params.put("is_hbcu_alumni", is_hbcu_alumni!!)

        params.put("username", socialID)
        params.put("type", "signup")


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

                        showToast(resources.getString(R.string.msg_register_success))

                        Pref.setIntValue(this@SignupActivity, Config.PREF_IS_LOGIN, 1)
                        Pref.setStringValue(
                            this@SignupActivity, Config.PREF_UID,
                            response.body()!!.data!!.user!!.id.toString()
                        )
                        Pref.setUserLoginData(
                            this@SignupActivity,
                            response.body()!!.data!!.user
                        )
                        Pref.setStringValue(
                            this@SignupActivity, Config.PREF_AUTH_TOKEN,
                            response.body()!!.data!!.token
                        )

                        var intent =
                            Intent(this@SignupActivity, DashboardActivity::class.java);
                        intent.flags =
                            Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK;
                        startActivity(intent);
                        finish()

                    } else {
                        showToast(response.body()!!.message!!.error)
                    }

                } else {
                    showToast(resources.getString(R.string.msg_somthing_wrong))

                }

            }

            override fun onFailure(call: Call<UserLoginResponse>, t: Throwable) {

                showToast(resources.getString(R.string.msg_somthing_wrong))
                flProgress.visibility = View.GONE
            }
        })

    }

}