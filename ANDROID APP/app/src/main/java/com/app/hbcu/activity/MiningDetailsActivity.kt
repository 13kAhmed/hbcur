package com.app.hbcu.activity

import android.content.Intent
import android.os.Bundle
import android.os.CountDownTimer
import android.util.Log
import android.view.View
import android.view.View.GONE
import android.view.View.VISIBLE
import android.widget.*
import androidx.core.view.isVisible
import com.app.hbcu.R
import com.app.hbcu.model.BaseResponse
import com.app.hbcu.model.mining.Mining
import com.app.hbcu.model.mining.MiningResponse
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.AppUtils
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.concurrent.TimeUnit


class MiningDetailsActivity : BaseAppCompatActivity(), View.OnClickListener {
    lateinit var ivBack: ImageView

    lateinit var ivArrowVisioner: ImageView
    lateinit var rlVisioner: RelativeLayout
    lateinit var llDetailVisioner: LinearLayout

    lateinit var ivArrowAmbasador: ImageView
    lateinit var rlAmbasador: RelativeLayout
    lateinit var llDetailAmbasador: LinearLayout

    lateinit var ivArrowVerifier: ImageView
    lateinit var rlVerifier: RelativeLayout
    lateinit var llDetailVerifier: LinearLayout

    lateinit var tvRateVisioner: TextView
    lateinit var tvRateAmbasador: TextView
    lateinit var tvRateVerifier: TextView
    lateinit var tvVisionerInvited: TextView
    lateinit var tvMember: TextView

    lateinit var tvActiveRate: TextView
    lateinit var tvInActiveUser: TextView
    lateinit var tvActiveUser: TextView
    lateinit var tvTimeSpent: TextView
    lateinit var tvTotalRate: TextView
    lateinit var tvBalanceTotal: TextView
    lateinit var tvLearnMore: TextView
    lateinit var tvPing: TextView
    lateinit var btnViewTeam: Button
    lateinit var btnInviteUser: Button
    lateinit var flProgress: FrameLayout

    lateinit var timer: CountDownTimer;
    var totalBalance: Double = 0.0
    var minute_of_24Hrs: Int = 1440


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_mining_detail)

        init()
    }

    private fun init() {

        ivBack = findViewById(R.id.ivBack)
        tvLearnMore = findViewById(R.id.tvLearnMore)
        tvPing = findViewById(R.id.tvPing)
        btnViewTeam = findViewById(R.id.btnViewTeam)
        btnInviteUser = findViewById(R.id.btnInviteUser)
        tvBalanceTotal = findViewById(R.id.tvBalanceTotal)

        rlVisioner = findViewById(R.id.rlVisioner)
        llDetailVisioner = findViewById(R.id.llDetailVisioner)
        ivArrowVisioner = findViewById(R.id.ivArrowVisioner)

        rlAmbasador = findViewById(R.id.rlAmbasador)
        ivArrowAmbasador = findViewById(R.id.ivArrowAmbasador)
        llDetailAmbasador = findViewById(R.id.llDetailAmbasador)

        rlVerifier = findViewById(R.id.rlVerifier)
        ivArrowVerifier = findViewById(R.id.ivArrowVerifier)
        llDetailVerifier = findViewById(R.id.llDetailVerifier)
        flProgress = findViewById(R.id.flProgress)
        tvTotalRate = findViewById(R.id.tvTotalRate)
        tvTimeSpent = findViewById(R.id.tvTimeSpent)
        tvRateVisioner = findViewById(R.id.tvRateVisioner)
        tvRateAmbasador = findViewById(R.id.tvRateAmbasador)
        tvRateVerifier = findViewById(R.id.tvRateVerifier)
        tvActiveUser = findViewById(R.id.tvActiveUser)
        tvInActiveUser = findViewById(R.id.tvInActiveUser)
        tvActiveRate = findViewById(R.id.tvActiveRate)
        tvMember = findViewById(R.id.tvMember)
        tvVisionerInvited = findViewById(R.id.tvVisionerInvited)


        ivBack.setOnClickListener(this)
        tvLearnMore.setOnClickListener(this)
        tvPing.setOnClickListener(this)
        btnViewTeam.setOnClickListener(this)
        btnInviteUser.setOnClickListener(this)

        rlVisioner.setOnClickListener(this)
        rlAmbasador.setOnClickListener(this)
        rlVerifier.setOnClickListener(this)

        getMiningDetail()
    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.rlVisioner -> {

                hideShowView(ivArrowVisioner, llDetailVisioner)
            }
            R.id.rlAmbasador -> {

                hideShowView(ivArrowAmbasador, llDetailAmbasador)
            }
            R.id.rlVerifier -> {
                hideShowView(ivArrowVerifier, llDetailVerifier)
            }

            R.id.tvLearnMore -> {
                var intent = Intent(this, WebActivity::class.java)
                intent.putExtra("urlWeb", Config.URL_WHITE_PAPER + "")
                intent.putExtra("title", resources.getString(R.string.lbl_white_paper))
                startActivity(intent)
            }
            R.id.tvPing -> {
                var uid: String? =  Pref.getStringValue(this, Config.PREF_UID, "")
                pingUser(uid)
            }
            R.id.btnViewTeam -> {
                var intent = Intent(this, TeamsViewActivity::class.java)
                startActivity(intent)
            }
            R.id.btnInviteUser -> {
                var intent = Intent(this, InvitationActivity::class.java)
                startActivity(intent)
            }
            R.id.ivBack -> {
                finish()
            }
        }
    }

    private fun pingUser(uid: String?) {

        if (!isConnectedToInternet) {
            return
        }


        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<BaseResponse> =
            service.sendNotificationInActiveUsers(AppUtils.getAuthToken(this), uid!!)

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

    private fun hideShowView(ivArrow: ImageView, llDetail: LinearLayout) {

        if (llDetail.isVisible) {
            llDetail.visibility = GONE
            ivArrow.setImageResource(R.drawable.ic_arrow_down)
        } else {
            llDetail.visibility = VISIBLE
            ivArrow.setImageResource(R.drawable.ic_arrow_up)
        }
    }

    private fun getMiningDetail() {


        if (!isConnectedToInternet) {
            return
        }

        var uid: String? = Pref.getStringValue(this, Config.PREF_UID, "")

        flProgress.visibility = View.VISIBLE

        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<MiningResponse> =
            service.getMiningDetails(AppUtils.getAuthToken(this), uid!!)

        call!!.enqueue(object : Callback<MiningResponse> {
            override fun onResponse(
                call: Call<MiningResponse>,
                response: Response<MiningResponse>
            ) {
                flProgress.visibility = View.GONE


                try {
                    totalBalance = response.body()!!.data!!.availBalance!!
                    tvBalanceTotal.text =
                        AppUtils.formatDoubleTo_4_DigitString(response.body()!!.data!!.availBalance)

                    tvActiveUser.text =
                        "Active (" + (response.body()!!.data!!.total_active_mining).toString() + ")"
                    tvInActiveUser.text =
                        "Inactive (" + (response.body()!!.data!!.total_inactive_mining).toString() + ")"
                    tvVisionerInvited.text =
                        (response.body()!!.data!!.total_invited).toString()
                    tvMember.text = (response.body()!!.data!!.total_team_member).toString()


                    if (response.body()!!.status!!.equals("200")) {

                        var mining: Mining = response.body()!!.data!!.mining!!

                        var currentStatus: String = mining.status!!


                        tvTotalRate.text = AppUtils.formatDoubleToString(mining.rate) + "/hr"
                        tvRateVisioner.text =
                            AppUtils.formatDoubleToString(mining.user_rate) + "/hr"
                        tvRateAmbasador.text =
                            AppUtils.formatDoubleToString(mining.parent_rate) + "/hr"
                        tvActiveRate.text =
                            AppUtils.formatDoubleToString(mining.parent_rate) + "/hr"

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
                flProgress.visibility = View.GONE
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
            } else {
                tvTimeSpent.setText("00:00:00")


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

                        tvTimeSpent.setText(hms)


                        totalBalance = (totalBalance + rateSecondly)
                        tvBalanceTotal.setText(AppUtils.formatDoubleTo_4_DigitString(totalBalance))

                    } catch (ee: Exception) {
                        //ee.printStackTrace()
                    }

                }

                override fun onFinish() {

                    tvTimeSpent.setText("00:00:00")
                    getMiningDetail()

                }
            }
            timer.start()

        } else {

            tvTimeSpent.setText("00:00:00")
        }


    }

}