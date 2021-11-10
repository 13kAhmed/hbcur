package com.app.hbcu.fragment

import android.os.Bundle
import android.os.CountDownTimer
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.RelativeLayout
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.activity.DashboardActivity
import com.app.hbcu.adapter.TransactionAdapter
import com.app.hbcu.model.mining.Mining
import com.app.hbcu.model.mining.MiningResponse
import com.app.hbcu.model.mininghistory.MiningHistoryResponse
import com.app.hbcu.model.mininghistory.MiningTransactionHistoryItem
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.AppUtils
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import com.google.gson.Gson
import io.socket.client.IO
import io.socket.client.Socket
import io.socket.emitter.Emitter
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*
import java.util.concurrent.TimeUnit


class TransactionFragment : BaseFragment() {

    lateinit var vw: View
    lateinit var rvData: RecyclerView
    lateinit var flProgress: FrameLayout
    lateinit var tvNo: TextView
    lateinit var tvBalanceTotal: TextView
    lateinit var tvMoney: TextView
    lateinit var rlCurrentMining: RelativeLayout
    var listData: ArrayList<MiningTransactionHistoryItem> = ArrayList()
    var adapter: TransactionAdapter? = null

    var totalBalance: Double = 0.0
    var creditedMining: Double = 0.0
    var minute_of_24Hrs: Int = 1440
    lateinit var timer: CountDownTimer;
    lateinit var mSocket: Socket
    var uid: String? = ""
    var isMainingStart: Boolean? = false


    companion object {
        fun newInstance(): Fragment {
            val fragment = TransactionFragment()
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

        vw = inflater.inflate(R.layout.fragment_transactions, container, false);
        rvData = vw.findViewById(R.id.rvData)
        flProgress = vw.findViewById(R.id.flProgress)
        tvNo = vw.findViewById(R.id.tvNo)
        tvBalanceTotal = vw.findViewById(R.id.tvBalanceTotal)
        tvMoney = vw.findViewById(R.id.tvMoney)
        rlCurrentMining = vw.findViewById(R.id.rlCurrentMining)
        uid = Pref.getStringValue(activity!!, Config.PREF_UID, "")

        val obj = JSONObject()
        obj.put("user_id", uid)

      /*  if ((activity as DashboardActivity).mySocket.isActive)
        {
            (activity as DashboardActivity).mySocket.on(
                Config.EMIT_LISTENER_TEAMS, onHistoryResponse
            ).emit(Config.EMIT_TEAMS, obj)
        }*/
        init()

        return vw;
    }

    private fun init() {

        val layoutManager: RecyclerView.LayoutManager = LinearLayoutManager(activity)
        rvData.setLayoutManager(layoutManager)
        rvData.addItemDecoration(DividerItemDecoration(activity, DividerItemDecoration.VERTICAL));
        adapter = TransactionAdapter(activity!!, listData)
        rvData.setAdapter(adapter)
        rvData.isNestedScrollingEnabled = false

        // getMiningDetail()

        // getTransactions()
        //  flProgress.visibility = View.VISIBLE

        connectSocket()
    }

    private fun connectSocket() {

        try {


            /* var opts = IO.Options()
             opts.host = Config.SERVER_IP!!
             opts.port = Config.SERVER_PORT!!*/
            mSocket = IO.socket(Config.SERVER_URL_SOCKET)
            mSocket.on(
                Socket.EVENT_CONNECT, onconnecteToResponse
            )
                .on(
                    Config.EMIT_LISTENER_TRANSACTION_HISTORY, onHistoryResponse
                ).on(
                    Config.EMIT_LISTENER_MINING_BALANCE, onMiningBalanceResponse
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

            val obj = JSONObject()
            obj.put("user_id", uid)
            /* mSocket.emit(Config.EMIT_TRANSACTION_HISTORY, obj)
             mSocket.emit(Config.EMIT_MINING_BALANCE, obj)*/

            mSocket.connect().emit(Config.EMIT_MINING_BALANCE, obj)
                .emit(Config.EMIT_TRANSACTION_HISTORY, obj)


        } catch (e: Exception) {
            Log.e("ERrr", ">>" + e)

        }

    }


    /*   private fun getMiningDetail() {

           totalBalance = 0.0;
           creditedMining = 0.0;
           if (!isConnectedToInternet) {
               return
           }

           var uid: String? = Pref.getStringValue(activity!!, Config.PREF_UID, "")
           //var uid: String? = "5"
           // flProgress.visibility = View.VISIBLE

           val service = ApiClient.client.create(ApiInterface::class.java)
           val call: Call<MiningResponse> =
               service.getMiningDetails(AppUtils.getAuthToken(activity!!), uid!!)

           call!!.enqueue(object : Callback<MiningResponse> {
               override fun onResponse(
                   call: Call<MiningResponse>,
                   response: Response<MiningResponse>
               ) {
                   // flProgress.visibility = View.GONE


                   try {
                       totalBalance = response.body()!!.data!!.availBalance!!


                       if (response.body()!!.status!!.equals("200")) {

                           var mining: Mining = response.body()!!.data!!.mining!!
                           var currentStatus: String = mining.status!!

                           if (currentStatus.equals(Config.STATUS_START, true)) {

                               rlCurrentMining.visibility = View.VISIBLE

                               setupTimerProgress(mining.spent_time, mining.user_rate)
                           } else {
                               // progressBar.setProgress(0)
                               setupTimerProgress(mining.spent_time, mining.user_rate)
                               rlCurrentMining.visibility = View.GONE

                           }

                       } else {
                           rlCurrentMining.visibility = View.GONE
                       }


                   } catch (e: Exception) {
                       rlCurrentMining.visibility = View.GONE
                   }


               }

               override fun onFailure(call: Call<MiningResponse>, t: Throwable) {
                   rlCurrentMining.visibility = View.GONE

               }
           })

       }
   */

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

    private val onMiningBalanceResponse: Emitter.Listener = object : Emitter.Listener {
        override fun call(vararg args: Any) {

            activity!!.runOnUiThread(Runnable {


                try {


                    var objMain: JSONObject = args[0] as JSONObject

                    var userID: String = objMain.optString("userID")
                    if ((userID + "").equals(uid)) {
                         isMainingStart = false
                        totalBalance = 0.0;
                        creditedMining = 0.0;

                        val gson = Gson()
                        val responseMining: MiningResponse =
                            gson.fromJson(objMain.toString(), MiningResponse::class.java)
                        var status: String = objMain.optString("status")


                        totalBalance = responseMining.data!!.availBalance!!


                        if (status!!.equals("200")) {
                            var mining: Mining = responseMining.data!!.mining!!
                            var currentStatus: String = mining.status!!

                            if (currentStatus.equals(Config.STATUS_START, true)) {
                                isMainingStart = true
                                rlCurrentMining.visibility = View.VISIBLE

                                setupTimerProgress(mining.spent_time, mining.user_rate)
                            } else {

                                try {
                                    //clear timer if started
                                    if (timer != null) {

                                        timer.cancel()
                                    }
                                } catch (e: java.lang.Exception) {

                                }

                                rlCurrentMining.visibility = View.GONE
                                tvBalanceTotal.setText(
                                    AppUtils.formatDoubleTo_4_DigitString(
                                        totalBalance
                                    )
                                )


                            }
                        } else {
                            tvBalanceTotal.setText(
                                AppUtils.formatDoubleTo_4_DigitString(
                                    totalBalance
                                )
                            )
                            rlCurrentMining.visibility = View.GONE

                        }
                    }
                } catch (e: Exception) {
                    rlCurrentMining.visibility = View.GONE
                }


            })
        }
    }

    private val onHistoryResponse: Emitter.Listener = object : Emitter.Listener {
        override fun call(vararg args: Any) {


            activity!!.runOnUiThread(Runnable {


                try {

                     var objMain: JSONObject = args[0] as JSONObject
                    var userID: String = objMain.optString("userID")
                    if ((userID + "").equals(uid)) {

                        listData.clear()
                        flProgress.visibility = View.GONE
                        val gson = Gson()
                        val response: MiningHistoryResponse =
                            gson.fromJson(objMain.toString(), MiningHistoryResponse::class.java)
                        var status: String = objMain.optString("status")


                        if (response.status!!.equals("200")) {


                            var listC: List<MiningTransactionHistoryItem>? =
                                response.data!!.miningTransactionHistory as List<MiningTransactionHistoryItem>?

                            listData.addAll(listC!!)

                            /*  try {
                                  tvBalanceTotal.setText(
                                      AppUtils.formatDoubleTo_4_DigitString(
                                          response.data!!.available_balance
                                      )
                                  )

                              } catch (e: Exception) {

                              }*/
                        }


                        adapter!!.notifyDataSetChanged()
                        if (listData.isEmpty() && !isMainingStart!!) {
                            tvNo.visibility = View.VISIBLE
                        } else {
                            tvNo.visibility = View.GONE

                        }

                    }
                } catch (e: Exception) {
                    e.printStackTrace()
                }


            })
        }
    }
    private val onconnecteToResponse: Emitter.Listener = object : Emitter.Listener {
        override fun call(vararg args: Any) {
            if (isAdded) {
                activity!!.runOnUiThread(Runnable {


                    val obj = JSONObject()
                    obj.put("user_id", uid)
                    /*  mSocket.emit(Config.EMIT_TRANSACTION_HISTORY, obj)
                      mSocket.emit(Config.EMIT_MINING_BALANCE, obj)*/


                })
            }
        }
    }

    override fun onDestroy() {
        try {
            mSocket.disconnect();
        } catch (e: java.lang.Exception) {

        }
        super.onDestroy()
    }

    private fun setCountDownTimer(spentTimeInMilli: Long, rateHourly: Double?) {

        val remainTimeInMilli = Math.abs(((minute_of_24Hrs * 60 * 1000)) - spentTimeInMilli)
        var rateSecondly: Double = ((rateHourly!! / 60 / 60))
        var creditedValue: Double = ((spentTimeInMilli / 1000) * rateSecondly)
        creditedMining = creditedValue + 0
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



                        creditedMining = (creditedMining + rateSecondly)
                        totalBalance = (totalBalance + rateSecondly)
                        tvBalanceTotal.setText(AppUtils.formatDoubleTo_4_DigitString(totalBalance))
                        tvMoney.setText("+" + AppUtils.formatDoubleTo_4_DigitString(creditedMining))

                    } catch (ee: Exception) {
                        //ee.printStackTrace()
                    }

                }

                override fun onFinish() {
                    //getMiningDetail()
                    try {
                        val obj = JSONObject()
                        obj.put("user_id", uid)
                        mSocket.emit(Config.EMIT_MINING_BALANCE, obj)
                    } catch (e: Exception) {

                    }

                }
            }
            timer.start()

        }


    }

    private fun getTransactions() {

        if (!isConnectedToInternet) {
            return
        }
        listData.clear()
        var uid: String? = Pref.getStringValue(activity!!, Config.PREF_UID, "")
        flProgress.visibility = View.VISIBLE

        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<MiningHistoryResponse> =
            service.getMiningTransactionHistory(AppUtils.getAuthToken(activity!!), uid!!)


        call!!.enqueue(object : Callback<MiningHistoryResponse> {
            override fun onResponse(
                call: Call<MiningHistoryResponse>,
                response: Response<MiningHistoryResponse>
            ) {
                flProgress.visibility = View.GONE

                if (response.isSuccessful) {

                    if (response.body()!!.status!!.equals("200")) {

                        var listC: List<MiningTransactionHistoryItem>? =
                            response.body()!!.data!!.miningTransactionHistory as List<MiningTransactionHistoryItem>?

                        listData.addAll(listC!!)

                    }
                    try {
                        tvBalanceTotal.setText(AppUtils.formatDoubleTo_4_DigitString(response.body()!!.data!!.available_balance))

                    } catch (e: Exception) {

                    }


                }

                adapter!!.notifyDataSetChanged()


                if (listData.isEmpty()) {
                    tvNo.visibility = View.VISIBLE
                } else {
                    tvNo.visibility = View.GONE
                }


            }

            override fun onFailure(call: Call<MiningHistoryResponse>, t: Throwable) {

                flProgress.visibility = View.GONE
            }
        })

    }

    override fun setUserVisibleHint(isVisibleToUser: Boolean) {
        super.setUserVisibleHint(isVisibleToUser)
        if (isVisibleToUser) {

            try {

                val obj = JSONObject()
                obj.put("user_id", uid)
                mSocket.emit(Config.EMIT_TRANSACTION_HISTORY, obj)
                mSocket.emit(Config.EMIT_MINING_BALANCE, obj)
            } catch (e: Exception) {
                connectSocket()
            }
        }
    }

}
