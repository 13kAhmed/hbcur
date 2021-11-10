package com.app.hbcu.fragment

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.fragment.app.Fragment
import com.app.hbcu.R
import com.app.hbcu.activity.EditProfileActivity
import com.app.hbcu.activity.InvitationActivity
import com.app.hbcu.activity.LoginChooseActivity
import com.app.hbcu.activity.WebActivity
import com.app.hbcu.model.BaseResponse
import com.app.hbcu.model.user.UserLoginResponse
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.AppUtils
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.google.firebase.auth.FirebaseAuth
import de.hdodenhof.circleimageview.CircleImageView
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class MoreProfileFragment : BaseFragment(), View.OnClickListener {

    lateinit var vw: View
    lateinit var rlInvite: RelativeLayout

    lateinit var rlWhitePaper: RelativeLayout
    lateinit var rlFaq: RelativeLayout
    lateinit var rlContact: RelativeLayout
    lateinit var rlLogout: RelativeLayout

    lateinit var ivFacebook: ImageView
    lateinit var ivInsta: ImageView
    lateinit var ivYoutube: ImageView
    lateinit var ivTwitter: ImageView
    lateinit var ivMessage: ImageView
    lateinit var tvName: TextView
    lateinit var tvMobile: TextView
    lateinit var tvUsername2: TextView
    lateinit var tvInvitationCode: TextView
    lateinit var ivPhoneVerify: ImageView
    lateinit var ivFacebookVerify: ImageView
    lateinit var ivGoogleVerify: ImageView
    lateinit var ivAppleVerify: ImageView
    lateinit var ivProfilePic: CircleImageView
    lateinit var flProgress: FrameLayout


    companion object {
        fun newInstance(): Fragment {
            val fragment = MoreProfileFragment()
            val args = Bundle()
            // args.putString(ARG_PARAM1, param1);
            // args.putString(ARG_PARAM2, param2);
            fragment.arguments = args
            return fragment
        }
    }

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {

        vw = inflater.inflate(R.layout.fragment_more_profile, container, false);

        rlInvite = vw.findViewById(R.id.rlInvite)

        rlWhitePaper = vw.findViewById(R.id.rlWhitePaper)
        rlFaq = vw.findViewById(R.id.rlFaq)
        rlContact = vw.findViewById(R.id.rlContact)
        rlLogout = vw.findViewById(R.id.rlLogout)
        flProgress = vw.findViewById(R.id.flProgress)

        ivFacebook = vw.findViewById(R.id.ivFacebook)
        ivInsta = vw.findViewById(R.id.ivInsta)
        ivYoutube = vw.findViewById(R.id.ivYoutube)
        ivTwitter = vw.findViewById(R.id.ivTwitter)
        ivMessage = vw.findViewById(R.id.ivMessage)
        tvName = vw.findViewById(R.id.tvName)
        tvMobile = vw.findViewById(R.id.tvMobile)
        tvUsername2 = vw.findViewById(R.id.tvUsername2)
        tvInvitationCode = vw.findViewById(R.id.tvInvitationCode)
        ivGoogleVerify = vw.findViewById(R.id.ivGoogleVerify)
        ivAppleVerify = vw.findViewById(R.id.ivAppleVerify)
        ivFacebookVerify = vw.findViewById(R.id.ivFacebookVerify)
        ivPhoneVerify = vw.findViewById(R.id.ivPhoneVerify)
        ivProfilePic = vw.findViewById(R.id.ivProfilePic)


        rlInvite.setOnClickListener(this)
        ivFacebook.setOnClickListener(this)
        ivInsta.setOnClickListener(this)
        ivYoutube.setOnClickListener(this)
        ivTwitter.setOnClickListener(this)
        ivMessage.setOnClickListener(this)

        rlWhitePaper.setOnClickListener(this)
        rlFaq.setOnClickListener(this)
        rlContact.setOnClickListener(this)
        rlLogout.setOnClickListener(this)

        tvName.setOnClickListener(this)

        getProfile()
        return vw;
    }

    private fun showAlertLogout() {

        val builder = AlertDialog.Builder(context!!)

        builder.setMessage(R.string.logout_alert)
        //  builder.setIcon(android.R.drawable.ic_dialog_alert)

        //performing positive action
        builder.setPositiveButton(R.string.yes) { dialogInterface, which ->


            logoutCall()

        }
        //performing cancel action

        //performing negative action
        builder.setNegativeButton(R.string.no) { dialogInterface, which ->
            dialogInterface.dismiss()
        }
        // Create the AlertDialog
        val alertDialog: AlertDialog = builder.create()
        // Set other dialog properties
        alertDialog.setCancelable(false)
        alertDialog.show()
    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.rlInvite -> {

                var intent = Intent(activity, InvitationActivity::class.java)
                startActivity(intent)
            }
            R.id.ivFacebook -> {
                val intent = Intent(Intent.ACTION_VIEW)
                intent.data = Uri.parse(Config.URL_FB)
                startActivity(intent)

            }
            R.id.ivInsta -> {
                val intent = Intent(Intent.ACTION_VIEW)
                intent.data = Uri.parse(Config.URL_INSTA)
                startActivity(intent)

            }
            R.id.ivYoutube -> {

                val intent = Intent(Intent.ACTION_VIEW)
                intent.data = Uri.parse(Config.URL_YOUTUBE)
                startActivity(intent)
            }
            R.id.ivTwitter -> {
                val intent = Intent(Intent.ACTION_VIEW)
                intent.data = Uri.parse(Config.URL_TWITTER)
                startActivity(intent)

            }
            R.id.ivMessage -> {


            }

            R.id.rlWhitePaper -> {

                var intent = Intent(activity, WebActivity::class.java)
                intent.putExtra("urlWeb", Config.URL_WHITE_PAPER + "")
                intent.putExtra("title", resources.getString(R.string.lbl_white_paper))
                startActivity(intent)
            }
            R.id.rlFaq -> {
                var intent = Intent(activity, WebActivity::class.java)
                intent.putExtra("urlWeb", Config.URL_FAQ + "")
                intent.putExtra("title", resources.getString(R.string.lbl_faq))
                startActivity(intent)

            }
            R.id.rlContact -> {
                val intent = Intent(Intent.ACTION_SENDTO)
                intent.data = Uri.parse("mailto:") // only email apps should handle this

                intent.putExtra(Intent.EXTRA_EMAIL, arrayOf(Config.EMAIL_CONTACT))
                intent.putExtra(Intent.EXTRA_SUBJECT, "")

                startActivity(intent)


            }
            R.id.tvName -> {
                var intent = Intent(activity, EditProfileActivity::class.java)
                startActivity(intent)

            }
            R.id.rlLogout -> {
                showAlertLogout()

            }

        }
    }

    override fun onResume() {
        super.onResume()

        tvName.text =
            Pref.getUserLoginData(activity!!).firstName + " " + Pref.getUserLoginData(activity!!).lastName
        tvMobile.text = Pref.getUserLoginData(activity!!).mobile
        tvUsername2.text = "@" + Pref.getUserLoginData(activity!!).username
        tvInvitationCode.text = Pref.getUserLoginData(activity!!).invitationCode

        if (!(Pref.getUserLoginData(activity!!)?.avtar + "").equals("")) {
            Glide.with(activity!!)
                .load(Pref.getUserLoginData(activity!!)!!.avtar)
                .centerCrop()
                .placeholder(R.drawable.ic_user_placeholder).error(R.drawable.ic_user_placeholder)
                .diskCacheStrategy(
                    DiskCacheStrategy.NONE
                )
                .into(ivProfilePic)
        }
    }

    private fun getProfile() {
        if (!isConnectedToInternet) {
            return
        }

        var uid: String? = Pref.getStringValue(activity!!, Config.PREF_UID, "")

        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<UserLoginResponse> =
            service.getProfile(AppUtils.getAuthToken(activity!!), uid!!)

        call!!.enqueue(object : Callback<UserLoginResponse> {
            override fun onResponse(
                call: Call<UserLoginResponse>,
                response: Response<UserLoginResponse>
            ) {


                try {
                    if (response.isSuccessful) {

                        if (response.body()!!.status!!.equals("200")) {


                            Pref.setUserLoginData(
                                activity!!,
                                response.body()!!.data!!.user
                            )



                            tvName.text =
                                response.body()!!.data!!.user!!.firstName + " " + response.body()!!.data!!.user!!.lastName
                            tvMobile.text = response.body()!!.data!!.user!!.mobile
                            tvUsername2.text = "@" + response.body()!!.data!!.user!!.username
                            tvInvitationCode.text =
                                "" + response.body()!!.data!!.user!!.invitationCode


                            if (!(Pref.getUserLoginData(activity!!)?.avtar + "").equals("")) {
                                Glide.with(activity!!)
                                    .load(Pref.getUserLoginData(activity!!)!!.avtar)
                                    .centerCrop()
                                    .placeholder(R.drawable.ic_user_placeholder)
                                    .error(R.drawable.ic_user_placeholder).diskCacheStrategy(
                                        DiskCacheStrategy.NONE
                                    )
                                    .into(ivProfilePic)
                            }

                            if ((response.body()!!.data!!.user!!.signupType).equals("2")) {
                                //Google
                                ivGoogleVerify.setImageResource(R.drawable.ic_check)
                                ivFacebookVerify.setImageResource(R.drawable.ic_warning)
                                ivPhoneVerify.setImageResource(R.drawable.ic_warning)
                                ivAppleVerify.setImageResource(R.drawable.ic_warning)

                            } else if ((response.body()!!.data!!.user!!.signupType).equals("3")) {
                                //facebook
                                ivGoogleVerify.setImageResource(R.drawable.ic_warning)
                                ivFacebookVerify.setImageResource(R.drawable.ic_check)
                                ivPhoneVerify.setImageResource(R.drawable.ic_warning)
                                ivAppleVerify.setImageResource(R.drawable.ic_warning)

                            } else if ((response.body()!!.data!!.user!!.signupType).equals("4")) {
                                //Apple
                                ivGoogleVerify.setImageResource(R.drawable.ic_warning)
                                ivFacebookVerify.setImageResource(R.drawable.ic_warning)
                                ivPhoneVerify.setImageResource(R.drawable.ic_warning)
                                ivAppleVerify.setImageResource(R.drawable.ic_check)
                            } else {
                                //phone
                                ivGoogleVerify.setImageResource(R.drawable.ic_warning)
                                ivFacebookVerify.setImageResource(R.drawable.ic_warning)
                                ivPhoneVerify.setImageResource(R.drawable.ic_check)
                                ivAppleVerify.setImageResource(R.drawable.ic_warning)
                            }
                        }

                    }
                } catch (e: Exception) {

                }


            }

            override fun onFailure(call: Call<UserLoginResponse>, t: Throwable) {

                showToast(resources.getString(R.string.msg_somthing_wrong))

            }
        })

    }

    private fun logoutCall() {

        flProgress.visibility = View.VISIBLE
        var uid: String? = Pref.getStringValue(activity!!, Config.PREF_UID, "")

        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<BaseResponse> =
            service.logout(
                AppUtils.getAuthToken(activity!!),
                uid!!,
                Pref.getStringValue(activity!!, Config.PREF_FCM_TOKEN, "")!!
            )

        call!!.enqueue(object : Callback<BaseResponse> {
            override fun onResponse(
                call: Call<BaseResponse>,
                response: Response<BaseResponse>
            ) {

                flProgress.visibility = View.GONE
                logoutAndRedirect()

            }

            override fun onFailure(call: Call<BaseResponse>, t: Throwable) {
                flProgress.visibility = View.GONE
                logoutAndRedirect()


            }
        })

    }

    private fun logoutAndRedirect() {

        showToast(resources.getString(R.string.logout_success))


        try {
            FirebaseAuth.getInstance().signOut()

            var mGoogleSignInOptions =
                GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
                    .requestEmail()
                    .build()
            var mGoogleSignInClient = GoogleSignIn.getClient(activity!!, mGoogleSignInOptions)
            mGoogleSignInClient.signOut()
        } catch (e: Exception) {

        }
        Pref.setIntValue(activity!!, Config.PREF_IS_LOGIN, 0)
        Pref.setStringValue(activity!!, Config.PREF_MINING_TIME, "");

        Pref.clearPref(activity!!)

        var intent = Intent(activity, LoginChooseActivity::class.java);
        intent.flags =
            Intent.FLAG_ACTIVITY_CLEAR_TASK or Intent.FLAG_ACTIVITY_NEW_TASK;
        startActivity(intent);
        activity!!.finish();
    }

}
