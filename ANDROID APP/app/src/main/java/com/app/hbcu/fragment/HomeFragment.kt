package com.app.hbcu.fragment

import android.content.Intent
import android.os.Bundle
import android.os.CountDownTimer
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.*
import androidx.fragment.app.Fragment
import androidx.viewpager.widget.ViewPager
import com.app.hbcu.R
import com.app.hbcu.activity.InvitationActivity
import com.app.hbcu.activity.MiningDetailsActivity
import com.app.hbcu.activity.NotificationsActivity
import com.app.hbcu.activity.RankingActivity
import com.app.hbcu.adapter.PagerStatePagerAdapter
import com.app.hbcu.model.mining.Mining
import com.app.hbcu.model.mining.MiningResponse
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.AppUtils
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import com.google.android.material.tabs.TabLayout
import com.google.gson.Gson
import io.socket.client.IO
import io.socket.client.Socket
import io.socket.emitter.Emitter
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.text.SimpleDateFormat
import java.util.*
import java.util.concurrent.TimeUnit
import kotlin.math.abs


class HomeFragment : BaseFragment(), View.OnClickListener {

    lateinit var vw: View
    var pagerStatePagerAdapter: PagerStatePagerAdapter? = null
    lateinit var tabTabs: TabLayout;
    lateinit var viewPager: ViewPager;
    lateinit var rlInvite: RelativeLayout;
    lateinit var ivNotification: ImageView;
    lateinit var ivRank: ImageView;
    lateinit var progressBar: ProgressBar;
    lateinit var loaderMining: ProgressBar;
    lateinit var tvCount: TextView;
    lateinit var tvPerHour: TextView;
    lateinit var tvBalance: TextView;
    lateinit var btnStart: Button;
    lateinit var tvTimeSpent: TextView;
    lateinit var llDetails: LinearLayout;
    var dateFormat_all = SimpleDateFormat("yyyy-MM-dd HH:mm:ss",Locale.US)
    var minute_of_24Hrs: Int = 1440
    var totalBalance: Double = 0.0
    lateinit var timer: CountDownTimer;
    lateinit var mSocket: Socket
    var uid: String? = ""

    companion object {
        fun newInstance(): Fragment {
            val fragment = HomeFragment()
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

        vw = inflater.inflate(R.layout.fragment_home, container, false);

        viewPager = vw.findViewById(R.id.viewPager)
        tabTabs = vw.findViewById(R.id.tabTabs)
        rlInvite = vw.findViewById(R.id.rlInvite)
        ivNotification = vw.findViewById(R.id.ivNotification)
        ivRank = vw.findViewById(R.id.ivRank)
        loaderMining = vw.findViewById(R.id.loaderMining)
        progressBar = vw.findViewById(R.id.progressBar)
        tvTimeSpent = vw.findViewById(R.id.tvTimeSpent)

        tvCount = vw.findViewById(R.id.tvCount)
        tvPerHour = vw.findViewById(R.id.tvPerHour)
        tvBalance = vw.findViewById(R.id.tvBalance)
        btnStart = vw.findViewById(R.id.btnStart)
        llDetails = vw.findViewById(R.id.llDetails)


        rlInvite.setOnClickListener(this)
        ivNotification.setOnClickListener(this)
        ivRank.setOnClickListener(this)
        btnStart.setOnClickListener(this)
        llDetails.setOnClickListener(this)

        dateFormat_all.setTimeZone(TimeZone.getTimeZone("UTC"))
        uid = Pref.getStringValue(activity!!, Config.PREF_UID, "")


        progressBar.max = minute_of_24Hrs // 24 hrs
        totalBalance = 0.0;



        llDetails.isEnabled = false
        setupPager()

        connectSocket()
        //getSocketMiningData()
        return vw;
    }


    private fun connectSocket() {

        try {

            // var opts = IO.Options()
            //opts.host = Config.SERVER_IP!!
            // opts.port = Config.SERVER_PORT!!
            mSocket = IO.socket(Config.SERVER_URL_SOCKET)
            mSocket.on(
                Socket.EVENT_CONNECT, onconnecteTodResponse
            )
                .on(
                    Config.EMIT_LISTENER_MINING_BALANCE, onMiningBalanceResponse
                ).on(
                    Config.EMIT_LISTENER_START_MINING, onStartMiningResponse
                )
                .on(
                    Socket.EVENT_DISCONNECT,
                    Emitter.Listener { Log.e("EVENT_DISCONNECT", "EVENT_DISCONNECT") }
                )
                .on(
                    Socket.EVENT_CONNECT_ERROR,
                    Emitter.Listener { Log.e("EVENT_CONNECT_ERROR", "EVENT_CONNECT_ERROR") }
                )
                .on("error", Emitter.Listener { Log.e("error w", "error w") })

            mSocket.connect();


        } catch (e: Exception) {
            Log.e("ERrr", ">>" + e)

        }

    }

    private val onconnecteTodResponse: Emitter.Listener = object : Emitter.Listener {
        override fun call(vararg args: Any) {
            activity!!.runOnUiThread(Runnable {

                val obj = JSONObject()
                obj.put("user_id", uid)
                mSocket.emit(Config.EMIT_MINING_BALANCE, obj)

            })
        }
    }
    private val onMiningBalanceResponse: Emitter.Listener = object : Emitter.Listener {
        override fun call(vararg args: Any) {

            activity!!.runOnUiThread(Runnable {


                try {

                    var objMain: JSONObject = args[0] as JSONObject

                    var userID: String = objMain.optString("userID")
                    if ((userID + "").equals(uid)) {
                        val gson = Gson()
                        val responseMining: MiningResponse =
                            gson.fromJson(objMain.toString(), MiningResponse::class.java)
                        var status: String = objMain.optString("status")


                        totalBalance = responseMining.data!!.availBalance!!
                        tvBalance.text =
                            AppUtils.formatDoubleToString(responseMining!!.data!!.availBalance)
                        Pref.setStringValue(
                            activity!!,
                            Config.PREF_LAST_BALANCE,
                            AppUtils.formatDoubleToString(responseMining!!.data!!.availBalance)
                        )
                        btnStart.visibility = View.VISIBLE
                        llDetails.isEnabled = false

                        if (status!!.equals("200")) {

                            var mining: Mining = responseMining.data!!.mining!!
                            var currentStatus: String = mining.status!!


                            tvPerHour.text = AppUtils.formatDoubleToString(mining.rate) + " HBCU/hr"
                            if (currentStatus.equals(Config.STATUS_START, true)) {

                                btnStart.visibility = View.GONE
                                llDetails.isEnabled = true

                                setupTimerProgress(mining.spent_time, mining.user_rate)
                            } else {

                                /**remove prefrencce and cancel timer if completed**/
                                stopAndClearTimer()

                                //setupTimerProgress(mining.spent_time, mining.user_rate)
                                btnStart.visibility = View.VISIBLE
                                llDetails.isEnabled = false


                            }

                        } else {
                            btnStart.visibility = View.VISIBLE
                            llDetails.isEnabled = false
                            progressBar.setProgress(0)
                        }
                    }
                } catch (e: Exception) {
                    btnStart.visibility = View.VISIBLE
                    llDetails.isEnabled = false
                    progressBar.setProgress(0)
                }


            })
        }
    }
    private val onStartMiningResponse: Emitter.Listener = object : Emitter.Listener {
        override fun call(vararg args: Any) {

            activity!!.runOnUiThread(Runnable {


                try {
                    Log.e(">Start", args[0].toString())
                    var objMain: JSONObject = args[0] as JSONObject
                    var userID: String = objMain.optString("userID")
                    if ((userID + "").equals(uid)) {
                        val obj = JSONObject()
                        obj.put("user_id", uid)
                        mSocket.emit(Config.EMIT_MINING_BALANCE, obj)
                    }
                } catch (w: Exception) {
                    w.printStackTrace()
                }
            })
        }
    }


    override fun onDestroy() {
        try {
            mSocket.disconnect();
        } catch (e: java.lang.Exception) {

        }
        super.onDestroy()
    }


    private fun setupPager() {

        pagerStatePagerAdapter = PagerStatePagerAdapter(childFragmentManager)
        pagerStatePagerAdapter!!.addFragment(
            TeamHomeFragment.newInstance(),
            resources.getString(R.string.lbl_team)
        )
        pagerStatePagerAdapter!!.addFragment(
            NewsHomeFragment.newInstance(),
            resources.getString(R.string.lbl_news)
        )

        viewPager.setAdapter(pagerStatePagerAdapter)
        tabTabs.setupWithViewPager(viewPager)
    }

    override fun onClick(p: View?) {

        when (p!!.id) {
            R.id.rlInvite -> {
                var intent = Intent(activity, InvitationActivity::class.java)
                startActivity(intent)
            }
            R.id.ivNotification -> {
                var intent = Intent(activity, NotificationsActivity::class.java)
                startActivity(intent)
            }
            R.id.ivRank -> {
                var intent = Intent(activity, RankingActivity::class.java)
                startActivity(intent)
            }
            R.id.btnStart -> {

                // startmining();
                // startmining();
                if (!mSocket.isActive) {
                    mSocket.connect()
                }

                val obj = JSONObject()
                obj.put("user_id", uid)
                mSocket.emit(Config.EMIT_START_MINING, obj)

            }
            R.id.llDetails -> {

                var intent = Intent(activity, MiningDetailsActivity::class.java)
                startActivity(intent)
            }
        }
    }

    override fun onResume() {
        super.onResume()

        var lb: String? = Pref.getStringValue(activity!!, Config.PREF_LAST_BALANCE, "0.0")
        tvBalance.setText(lb)
        try {
            totalBalance = lb!!.toDouble()
        } catch (e: Exception) {

        }


        setupPreviosMining()
        //getMiningDetail()
    }

    private fun setupPreviosMining() {

        try {
            var currntTime: String? = getUtcTime()
            var oldTime: String? = Pref.getStringValue(activity!!, Config.PREF_MINING_TIME, "")

            if (!(oldTime + "").equals("")) {
                /** if old Data Stored to pref **/
                var spentTimeOld: Long = (Pref.getStringValue(
                    activity!!,
                    Config.PREF_SPENT_TIME_MILLI, "0"
                ))!!.toLong();

                var rateHourly: Double =
                    (Pref.getStringValue(activity!!, Config.PREF_USER_RATE, "0"))!!.toDouble();

                val dateCurrent: Date
                val dateOld: Date
                dateCurrent = dateFormat_all.parse(currntTime)
                dateOld = dateFormat_all.parse(oldTime)
                val difference: Long = abs(dateCurrent.time - dateOld.time)
                //  val differenceDates = difference / (260 * 60 * 1000)

                val totalSpentTime: Long = spentTimeOld + difference;
                // setupTimerProgress(totalSpentTime)
                val minutes: Int = ((totalSpentTime / (60 * 1000)).toInt())

                if (minutes <= minute_of_24Hrs)//24 hours
                {

                    progressBar.setProgress(minutes.toInt())
                    setCountDownTimer(totalSpentTime, rateHourly)
                } else {

                    tvTimeSpent.setText("00:00:00")
                    progressBar.setProgress(minute_of_24Hrs)

                }
            }

        } catch (e: Exception) {

        }
    }


    private fun setupTimerProgress(spentTime: String?, rateHourly: Double?) {

        try {

            val currentUtcTime: String = getUtcTime()

            val time: List<String> = spentTime!!.split(":")
            //val time: List<String> = ("23:59:58").split(":")


            /** convert time To millisecnds*/
            val minutes = (((time[0].trim()).toInt()) * 60) + ((time[1].trim()).toInt())
            val secondsRemains = ((time[2].trim()).toInt())
            val milliseconds = (((minutes * 60) * 1000).toLong()) + (secondsRemains * 1000)

            Pref.setStringValue(activity!!, Config.PREF_MINING_TIME, currentUtcTime);
            Pref.setStringValue(
                activity!!,
                Config.PREF_SPENT_TIME_MILLI,
                milliseconds.toString() + ""
            );
            Pref.setStringValue(activity!!, Config.PREF_USER_RATE, rateHourly.toString() + "");


            if (minutes <= minute_of_24Hrs)//24 hours
            {

                progressBar.setProgress(minutes.toInt())
                setCountDownTimer(milliseconds, rateHourly)
            } else {

                stopAndClearTimer()

            }


        } catch (e: Exception) {
            progressBar.setProgress(0)
        }
    }

    private fun stopAndClearTimer() {

        Pref.setStringValue(activity!!, Config.PREF_MINING_TIME, "");

        try {
            if (timer != null) {
                timer.cancel()
            }
        } catch (e: java.lang.Exception) {

        }
        tvTimeSpent.setText("00:00:00")
        progressBar.setProgress(minute_of_24Hrs)

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
                        /**Convet remaining millisecond to format time**/
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

                        progressBar.setProgress(((((minute_of_24Hrs - (remainTimeInMilli / 1000 / 60)))).toInt()))

                        /** Here we just set progress at 2 (if user just clicked to start)
                         * for just better user experience (user can view that progress is starting)**/
                        if (((((minute_of_24Hrs - (remainTimeInMilli / 1000 / 60)))).toInt()) < 2) {
                            progressBar.setProgress(2)
                        }

                        tvTimeSpent.setText(hms)


                        totalBalance = (totalBalance + rateSecondly)
                        tvBalance.setText(AppUtils.formatDoubleToString(totalBalance))

                    } catch (ee: Exception) {
                        //ee.printStackTrace()
                    }

                }

                override fun onFinish() {
                    progressBar.setProgress(minute_of_24Hrs)
                    tvTimeSpent.setText("00:00:00")

                    try {
                        /**  on finish re call mining detail**/
                        val obj = JSONObject()
                        obj.put("user_id", uid)
                        mSocket.emit(Config.EMIT_MINING_BALANCE, obj)
                    } catch (e: Exception) {

                    }


                }
            }
            timer.start()

        } else {
            stopAndClearTimer()

        }


    }

    private fun getUtcTime(): String {

        val cal = Calendar.getInstance()
        try {

            val currentD: String = dateFormat_all.format(cal.time)
            return currentD
        } catch (e: Exception) {
            return ""
        }
    }

    /* override fun setUserVisibleHint(isVisibleToUser: Boolean) {
         super.setUserVisibleHint(isVisibleToUser)
         if (isVisibleToUser) {
             Log.e("HOME VVVVVVVVVVVVV", "setUserVisibleHint")

             try {

                 val obj = JSONObject()
                 obj.put("user_id", uid)
                 mSocket.emit(Config.EMIT_MINING_BALANCE, obj)

             } catch (e: Exception) {
                 connectSocket()
             }
         }
     }*/

}
