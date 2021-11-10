package com.app.hbcu.fragment

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.View.GONE
import android.view.View.VISIBLE
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.adapter.TeamsAdapter
import com.app.hbcu.model.team.TeamsItem
import com.app.hbcu.model.team.TeamsResponse
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.AppUtils
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import com.app.hbcu.util.RecyclerTouchListener
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import io.socket.client.IO
import io.socket.client.Socket
import io.socket.emitter.Emitter
import org.json.JSONArray
import org.json.JSONObject
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.lang.reflect.Type
import java.util.*


class TeamHomeFragment : BaseFragment() {

    lateinit var vw: View
    lateinit var rvData: RecyclerView
    lateinit var tvNo: TextView
    lateinit var flProgress: FrameLayout
    var listData: ArrayList<TeamsItem> = ArrayList()
    var adapterTeams: TeamsAdapter? = null
    var isLoading = false
    var page = 1
    var last_page = 1
    lateinit var mSocket: Socket
    var uid: String? = ""

    companion object {
        fun newInstance(): Fragment {
            val fragment = TeamHomeFragment()
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

        vw = inflater.inflate(R.layout.fragment_team_home, container, false);
        rvData = vw.findViewById(R.id.rvData)
        flProgress = vw.findViewById(R.id.flProgress)
        tvNo = vw.findViewById(R.id.tvNo)
        uid = Pref.getStringValue(activity!!, Config.PREF_UID, "")

        init()

        return vw;
    }

    private fun init() {

        val layoutManager: RecyclerView.LayoutManager = LinearLayoutManager(activity)
        rvData.setLayoutManager(layoutManager)
        rvData.addItemDecoration(DividerItemDecoration(activity, DividerItemDecoration.VERTICAL));
        adapterTeams = TeamsAdapter(activity!!, listData)
        rvData.setAdapter(adapterTeams)

        listData.clear()

        //getTeams()
        // flProgress.visibility = View.VISIBLE

        connectSocket()
        listener()
    }

    private fun connectSocket() {

        try {

            mSocket = IO.socket(Config.SERVER_URL_SOCKET)
            mSocket.on(
                Socket.EVENT_CONNECT, onconnecteTodResponse
            )
                .on(
                    Config.EMIT_LISTENER_TEAMS, onTeamssResponse
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

    private fun listener() {

        rvData.addOnItemTouchListener(
            RecyclerTouchListener(activity, rvData, object : RecyclerTouchListener.ClickListener {
                override fun onClick(view: View?, position: Int) {
                    // var intent = Intent(activity, MiningDetailsActivity::class.java)
                    // startActivity(intent)
                }

                override fun onLongClick(view: View?, position: Int) {

                }

            })
        )

        /* rvData.addOnScrollListener(object : RecyclerView.OnScrollListener() {
             override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                 super.onScrollStateChanged(recyclerView, newState)
             }

             override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                 super.onScrolled(recyclerView, dx, dy)
                 val linearLayoutManager = recyclerView.layoutManager as LinearLayoutManager?
                 if (!isLoading) {
                     if (linearLayoutManager != null && linearLayoutManager.findLastCompletelyVisibleItemPosition() == listData.size - 1
                         && last_page <= page && last_page > 0
                     ) {
                         //bottom of list!
                         addMorePrograsbar()
                         getTeams()
                     }
                 }
             }
         })*/
    }


    private val onTeamssResponse: Emitter.Listener = object : Emitter.Listener {
        override fun call(vararg args: Any) {

            Handler(Looper.getMainLooper()).post(Runnable { //do stuff like remove view etc

                //  })
                //   activity!!.runOnUiThread(Runnable {

                Log.e("TEAM", args[0].toString());
                if (activity != null) {
                    // flProgress.visibility = View.GONE

                    try {

                        var objMain: JSONObject = args[0] as JSONObject

                        val gson = Gson()
                        /* val response: TeamsResponse =
                             gson.fromJson(objMain.toString(), TeamsResponse::class.java)*/

                        var status: String = objMain.optString("status")
                        var userID: String = objMain.optString("userID")

                        if ((userID + "").equals(uid)) {
                            listData.clear()
                            var objData: JSONObject = objMain.optJSONObject("data") as JSONObject

                            if (status!!.equals("200")) {


                                try {

                                    var arrayParent: JSONArray =
                                        objData.optJSONArray("parent") as JSONArray

                                    /*  var listParent: List<TeamsItem>? =
                                     response.data!!.parent as List<TeamsItem>?  */

                                    val type: Type =
                                        object : TypeToken<List<TeamsItem?>?>() {}.type
                                    val listParent: List<TeamsItem> =
                                        gson.fromJson(arrayParent.toString(), type)


                                    if (listParent!!.size > 0 && listData.size <= 0) {
                                        listData.addAll(0, listParent!!)

                                    }
                                } catch (e: Exception) {

                                }
                                try {
                                    var arrayTeams: JSONArray =
                                        objData.optJSONArray("teams") as JSONArray


                                    val type: Type =
                                        object : TypeToken<List<TeamsItem?>?>() {}.type
                                    val listC: List<TeamsItem> =
                                        gson.fromJson(arrayTeams.toString(), type)


                                    listData.addAll(listC!!)

                                } catch (e: Exception) {

                                }


                            }

                            adapterTeams!!.notifyDataSetChanged()
                        }

                        /*  if (listData.isEmpty()) {
                              tvNo.visibility = VISIBLE
                          } else {
                              tvNo.visibility = GONE

                          }*/


                    } catch (e: Exception) {
                        e.printStackTrace()
                    }

                }
            })
        }
    }
    private val onconnecteTodResponse: Emitter.Listener = object : Emitter.Listener {
        override fun call(vararg args: Any) {
            try {
                if (activity!! != null) {
                    activity!!.runOnUiThread(Runnable {

                        val obj = JSONObject()
                        obj.put("user_id", uid)
                        mSocket.emit(Config.EMIT_TEAMS, obj)

                    })
                }
            } catch (e: Exception) {

            }

        }
    }

    private fun addMorePrograsbar() {
        isLoading = true
        //listData.add(null)
        // wallpapersAdapter.notifyItemInserted(listData.size - 1)
    }

    override fun onDestroy() {
        try {
            mSocket.disconnect();
        } catch (e: java.lang.Exception) {

        }
        super.onDestroy()
    }

    private fun getTeams() {

        if (!isConnectedToInternet) {
            return
        }

        flProgress.visibility = View.VISIBLE

        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<TeamsResponse> =
            service.getTeams(AppUtils.getAuthToken(activity!!), uid!!, page.toString())


        call!!.enqueue(object : Callback<TeamsResponse> {
            override fun onResponse(
                call: Call<TeamsResponse>,
                response: Response<TeamsResponse>
            ) {
                flProgress.visibility = View.GONE
                page = page + 1
                if (response.isSuccessful) {

                    if (response.body()!!.status!!.equals("200")) {

                        last_page = response.body()!!.data!!.lastPage!!
                        var listC: List<TeamsItem>? =
                            response.body()!!.data!!.teams as List<TeamsItem>?

                        var listParent: List<TeamsItem>? =
                            response.body()!!.data!!.parent as List<TeamsItem>?

                        if (listParent!!.size > 0 && listData.size <= 0) {
                            listData.addAll(0, listParent!!)

                        }
                        if (listC!!.size > 0) {

                            isLoading = false

                        } else {
                            isLoading = true
                        }
                        listData.addAll(listC!!)
                    }

                }

                adapterTeams!!.notifyDataSetChanged()
                if (listData.isEmpty()) {
                    tvNo.visibility = VISIBLE
                } else {
                    tvNo.visibility = GONE

                }


            }

            override fun onFailure(call: Call<TeamsResponse>, t: Throwable) {

                isLoading = true
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
                mSocket.emit(Config.EMIT_TEAMS, obj)

            } catch (e: Exception) {
                connectSocket()
            }
        }
    }
}
