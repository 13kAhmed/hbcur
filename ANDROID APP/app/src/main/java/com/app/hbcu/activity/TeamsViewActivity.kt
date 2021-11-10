package com.app.hbcu.activity

import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import android.view.View
import android.widget.*
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.adapter.TeamsAdapter
import com.app.hbcu.model.team.TeamsItem
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import io.socket.client.IO
import io.socket.client.Socket
import io.socket.emitter.Emitter
import org.json.JSONArray
import org.json.JSONObject
import java.lang.reflect.Type
import java.util.*


class TeamsViewActivity : BaseAppCompatActivity(), View.OnClickListener {
    var listData: ArrayList<TeamsItem> = ArrayList()
    var adapterTeams: TeamsAdapter? = null
    lateinit var mSocket: Socket
    var uid: String? = ""

    lateinit var tvNo: TextView
    lateinit var ivBack: ImageView
    lateinit var rvData: RecyclerView
    lateinit var flProgress: FrameLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_teams_view)
        uid = Pref.getStringValue(this, Config.PREF_UID, "")



        init()
    }

    private fun init() {

        ivBack = findViewById(R.id.ivBack)
        tvNo = findViewById(R.id.tvNo)
        rvData = findViewById(R.id.rvData)
        flProgress = findViewById(R.id.flProgress)

        ivBack.setOnClickListener(this)

        val layoutManager: RecyclerView.LayoutManager = LinearLayoutManager(this)
        rvData.setLayoutManager(layoutManager)
        rvData.addItemDecoration(DividerItemDecoration(this, DividerItemDecoration.VERTICAL));
        adapterTeams = TeamsAdapter(this, listData)
        rvData.setAdapter(adapterTeams)

        listData.clear()

        connectSocket()
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


    private val onTeamssResponse: Emitter.Listener = object : Emitter.Listener {
        override fun call(vararg args: Any) {

            Handler(Looper.getMainLooper()).post(Runnable { //do stuff like remove view etc



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


                } catch (e: Exception) {
                    e.printStackTrace()
                }


            })
        }
    }
    private val onconnecteTodResponse: Emitter.Listener = object : Emitter.Listener {
        override fun call(vararg args: Any) {
            runOnUiThread(Runnable {

                val obj = JSONObject()
                obj.put("user_id", uid)
                mSocket.emit(Config.EMIT_TEAMS, obj)

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

    override fun onClick(p0: View?) {
        when (p0?.id) {

            R.id.ivBack -> {
                finish()
            }
        }
    }


}