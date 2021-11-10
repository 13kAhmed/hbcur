package com.app.hbcu.fragment

import android.os.Bundle
import android.os.CountDownTimer
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.View.GONE
import android.view.View.VISIBLE
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.LinearLayout
import android.widget.TextView
import androidx.appcompat.app.AlertDialog
import androidx.cardview.widget.CardView
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.app.hbcu.R
import com.app.hbcu.adapter.PagerStatePagerAdapter
import com.app.hbcu.model.BaseResponse
import com.app.hbcu.model.mining.Mining
import com.app.hbcu.model.mining.MiningResponse
import com.app.hbcu.model.teamearning.EarningTeamsResponse
import com.app.hbcu.model.teamearning.ParentUser
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.AppUtils
import com.app.hbcu.util.Config
import com.app.hbcu.util.NonSwipeableViewPager
import com.app.hbcu.util.Pref
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.google.android.material.tabs.TabLayout
import de.hdodenhof.circleimageview.CircleImageView
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*
import java.util.concurrent.TimeUnit


class UsersFragment : BaseFragment(), View.OnClickListener {

    lateinit var vw: View
    var pagerStatePagerAdapter: PagerStatePagerAdapter? = null
    lateinit var tabTabs: TabLayout;
    lateinit var viewPager: NonSwipeableViewPager;
    lateinit var llFeature: LinearLayout;
    lateinit var cardRefer: CardView;
    lateinit var tvPing: TextView;

    lateinit var ivActiveStatus: ImageView;
    lateinit var ivProfile: CircleImageView;
    lateinit var tvName: TextView;
    lateinit var tvUsername: TextView;
    lateinit var tvStatusUser: TextView;

    lateinit var tvTotalTeamsEarning: TextView;
    var isRefereAvailable: Boolean = false

    lateinit var timer: CountDownTimer;
    var totalBalance: Double = 0.0
    var minute_of_24Hrs: Int = 1440
    var userIdPing: String = ""


    companion object {
        fun newInstance(): Fragment {
            val fragment = UsersFragment()
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

        vw = inflater.inflate(R.layout.fragment_users, container, false);

        viewPager = vw.findViewById(R.id.viewPager)
        tabTabs = vw.findViewById(R.id.tabTabs)
        llFeature = vw.findViewById(R.id.llFeature)
        cardRefer = vw.findViewById(R.id.cardRefer)
        tvTotalTeamsEarning = vw.findViewById(R.id.tvTotalTeamsEarning)

        ivActiveStatus = vw.findViewById(R.id.ivActiveStatus)
        ivProfile = vw.findViewById(R.id.ivProfile)
        tvName = vw.findViewById(R.id.tvName)
        tvUsername = vw.findViewById(R.id.tvUsername)
        tvStatusUser = vw.findViewById(R.id.tvStatusUser)

        tvPing = vw.findViewById(R.id.tvPing)

        tvPing.setOnClickListener(this)
        setupPager()
        getEarningTeam()
        getMiningDetail()
        return vw;
    }

    private fun setupPager() {

        pagerStatePagerAdapter = PagerStatePagerAdapter(childFragmentManager)
        pagerStatePagerAdapter!!.addFragment(
            EarningTeamFragment.newInstance(),
            resources.getString(R.string.lbl_earning_team)
        )
        pagerStatePagerAdapter!!.addFragment(
            SecurityCircleFragment.newInstance(),
            resources.getString(R.string.lbl_security_circle)
        )



        viewPager.setAdapter(pagerStatePagerAdapter)
        tabTabs.addTab(tabTabs.newTab().setText(resources.getString(R.string.lbl_earning_team)))
        tabTabs.addTab(tabTabs.newTab().setText(resources.getString(R.string.lbl_security_circle)))
        // tabTabs.setupWithViewPager(viewPager)

        listener()
    }

    private fun listener() {

        viewPager.addOnPageChangeListener(object : ViewPager.OnPageChangeListener {
            override fun onPageScrolled(
                position: Int,
                positionOffset: Float,
                positionOffsetPixels: Int
            ) {
            }

            override fun onPageSelected(position: Int) {

                if (position == 0) {
                    llFeature.visibility = GONE
                    if (isRefereAvailable) {
                        cardRefer.visibility = VISIBLE
                    }
                } else {
                    llFeature.visibility = VISIBLE
                    cardRefer.visibility = GONE
                }
            }

            override fun onPageScrollStateChanged(state: Int) {

            }
        })

        tabTabs.addOnTabSelectedListener(object : TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab?) {
                if (tab!!.position == 1) {
                    showOKAlert(resources.getString(R.string.lbl_security_feature_next))
                }
            }

            override fun onTabUnselected(tab: TabLayout.Tab?) {
             }

            override fun onTabReselected(tab: TabLayout.Tab?) {

            }

        })
    }

    fun showOKAlert(messageString: String?) {
        val builder =
            AlertDialog.Builder(activity!!)
        builder.setMessage(messageString)
        builder.setCancelable(false)
        builder.setPositiveButton("Ok") { dialog, which ->
            dialog.dismiss()
            tabTabs.getTabAt(0)!!.select();

        }
        val alert = builder.create()
        alert.show()
    }

    fun setTeamsEarningTotal(erning: Double?) {

        tvTotalTeamsEarning.setText(AppUtils.formatDoubleTo_4_DigitString(erning) + "")

    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.tvPing -> {
                pingUser(userIdPing)

            }
        }
    }

    private fun pingUser(uid: String?) {

        if (!isConnectedToInternet) {
            return
        }


        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<BaseResponse> =
            service.sendNotification(AppUtils.getAuthToken(activity!!), uid!!)

//Send notification successfully.
        call!!.enqueue(object : Callback<BaseResponse> {
            override fun onResponse(
                call: Call<BaseResponse>,
                response: Response<BaseResponse>
            ) {

                if (response.isSuccessful) {

                    if (response.body()!!.status!!.equals("200")) {

                        showToast(response.body()!!.message!!.success)
                    } else {
                        showToast(response.body()!!.message!!.error)

                    }

                } else {
                    showToast(resources.getString(R.string.lbl_ping_error))

                }


            }

            override fun onFailure(call: Call<BaseResponse>, t: Throwable) {

                showToast(resources.getString(R.string.lbl_ping_error))

            }
        })

    }

    private fun getEarningTeam() {


        var uid: String? = Pref.getStringValue(requireActivity(), Config.PREF_UID, "")
        // var uid: String? = "5"


        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<EarningTeamsResponse> =
            service.getTeamsEarning(AppUtils.getAuthToken(activity!!), uid!!)

        call!!.enqueue(object : Callback<EarningTeamsResponse> {
            override fun onResponse(
                call: Call<EarningTeamsResponse>,
                response: Response<EarningTeamsResponse>
            ) {


                if (response.body()!!.status!!.equals("200")) {


                    try {

                        setTeamsEarningTotal(response.body()!!.data!!.totalEarning)

                        if ((response.body()!!.data!!.parentUser!!) != null) {
                            var listParent: ArrayList<ParentUser> =
                                (response.body()!!.data!!.parentUser as ArrayList<ParentUser>?)!!
                            if (listParent.size > 0) {

                                isRefereAvailable = true
                                if (viewPager.currentItem == 0) {
                                    cardRefer.visibility = VISIBLE

                                    userIdPing = listParent.get(0)?.id.toString()
                                    tvName.text =
                                        listParent.get(0).firstName + " " + listParent.get(0).lastName



                                    try {
                                        val userNameMain = "" + listParent.get(0)?.username;
                                        val printUser = userNameMain.substring(0, 3) + "******"
                                        tvUsername.setText("@$printUser")
                                    } catch (e: Exception) {
                                        tvUsername.setText("@${listParent.get(0)?.username}")
                                    }


                                    if ((listParent.get(0)?.isStartMining) == 0) {
                                        tvStatusUser.setText("Inactive")
                                        ivActiveStatus.setImageResource(R.drawable.bg_circle_inactive_red)
                                    } else {
                                        tvStatusUser.setText("Active")
                                        ivActiveStatus.setImageResource(R.drawable.bg_circle_active_green)
                                    }
                                    if (!(listParent.get(0)?.avtar + "").equals("", true)) {
                                        Glide.with(activity!!)
                                            .load(Config.IMAGE_BASE_URL + listParent.get(0)!!.avtar)
                                            .centerCrop()
                                            .placeholder(R.drawable.ic_user_placeholder)
                                            .error(R.drawable.ic_user_placeholder)
                                            .diskCacheStrategy(
                                                DiskCacheStrategy.NONE
                                            )
                                            .into(ivProfile!!)
                                    }
                                }
                            }
                        }
                    } catch (E: Exception) {

                    }


                }

            }

            override fun onFailure(call: Call<EarningTeamsResponse>, t: Throwable) {


            }
        })

    }

    private fun getMiningDetail() {


        if (!isConnectedToInternet) {
            return
        }

        var uid: String? = Pref.getStringValue(activity!!, Config.PREF_UID, "")


        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<MiningResponse> =
            service.getMiningDetails(AppUtils.getAuthToken(activity!!), uid!!)

        call!!.enqueue(object : Callback<MiningResponse> {
            override fun onResponse(
                call: Call<MiningResponse>,
                response: Response<MiningResponse>
            ) {


                try {
                    totalBalance = response.body()!!.data!!.availBalance!!
                    tvTotalTeamsEarning.text =
                        AppUtils.formatDoubleTo_4_DigitString(response.body()!!.data!!.availBalance)




                    if (response.body()!!.status!!.equals("200")) {

                        var mining: Mining = response.body()!!.data!!.mining!!

                        var currentStatus: String = mining.status!!



                        if (currentStatus.equals(Config.STATUS_START, true)) {


                            setupTimerProgress(mining.spent_time, mining.user_rate)
                        } else {
                            // progressBar.setProgress(0)
                            setupTimerProgress(mining.spent_time, mining.user_rate)


                        }

                    }


                } catch (e: Exception) {

                }


            }

            override fun onFailure(call: Call<MiningResponse>, t: Throwable) {
                Log.e("exception ", "ex$t")

            }
        })

    }

    private fun setupTimerProgress(spentTime: String?, rateHourly: Double?) {


        try {


            val time: List<String> = spentTime!!.split(":")
            //val time: List<String> = ("23:59:58").split(":")


            val minutes = (((time[0].trim()).toInt()) * 60) + ((time[1].trim()).toInt())
            val secondsRemains = ((time[2].trim()).toInt())
            val milliseconds = (((minutes * 60) * 1000).toLong()) + (secondsRemains * 1000)


            if (minutes <= minute_of_24Hrs)//24 hours
            {


                setCountDownTimer(milliseconds, rateHourly)
            }

        } catch (e: Exception) {

        }
    }

    private fun setCountDownTimer(spentTimeInMilli: Long, rateHourly: Double?) {

        val remainTimeInMilli = Math.abs(((minute_of_24Hrs * 60 * 1000)) - spentTimeInMilli)
        var rateSecondly: Double = ((rateHourly!! / 60 / 60))
        var creditedValue: Double = ((spentTimeInMilli / 1000) * rateSecondly)
        totalBalance = totalBalance + creditedValue

        if (remainTimeInMilli > 1000) {

            try {
                if (timer != null) {

                    timer.cancel()
                }
            } catch (e: java.lang.Exception) {

            }


            timer = object : CountDownTimer(remainTimeInMilli, 1000) {
                override fun onTick(millisUntilFinished: Long) {

                    try {
                        val hms = java.lang.String.format(
                            "%02d:%02d:%02d", TimeUnit.MILLISECONDS.toHours(millisUntilFinished),
                            TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished) - TimeUnit.HOURS.toMinutes(
                                TimeUnit.MILLISECONDS.toHours(
                                    millisUntilFinished
                                )
                            ),
                            TimeUnit.MILLISECONDS.toSeconds(millisUntilFinished) - TimeUnit.MINUTES.toSeconds(
                                TimeUnit.MILLISECONDS.toMinutes(millisUntilFinished)
                            )
                        )



                        totalBalance = (totalBalance + rateSecondly)
                        tvTotalTeamsEarning.setText(
                            AppUtils.formatDoubleTo_4_DigitString(
                                totalBalance
                            )
                        )

                    } catch (ee: Exception) {
                        //ee.printStackTrace()
                    }

                }

                override fun onFinish() {

                    getMiningDetail()

                }
            }
            timer.start()

        }


    }
}
