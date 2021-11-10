package com.app.hbcu.fragment

import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.adapter.NewsAdapter
import com.app.hbcu.model.news.NewsItem
import com.app.hbcu.model.news.NewsResponse
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


class NewsHomeFragment : BaseFragment() {

    lateinit var vw: View
    lateinit var rvData: RecyclerView
    lateinit var tvNo: TextView

    var listData: ArrayList<NewsItem> = ArrayList()
    var adapter: NewsAdapter? = null
    lateinit var flProgress: FrameLayout

    var isLoading = false
    var page = 1
    var last_page = 1
    lateinit var mSocket: Socket
    var uid: String? = ""

    companion object {
        fun newInstance(): Fragment {
            val fragment = NewsHomeFragment()
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
        adapter = NewsAdapter(activity!!, listData)
        rvData.setAdapter(adapter)
        listData.clear()

        //  getNews()
        // flProgress.visibility = View.VISIBLE

        connectSocket()
        listener()
    }

    private fun listener() {


        /*  rvData.addOnScrollListener(object : RecyclerView.OnScrollListener() {
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
                          getNews()
                      }
                  }
              }
          })*/
    }

    private fun addMorePrograsbar() {
        isLoading = true

    }

    private fun connectSocket() {

        try {


            /*  var opts = IO.Options()
              opts.host = Config.SERVER_IP!!
              opts.port = Config.SERVER_PORT!!*/
            mSocket = IO.socket(Config.SERVER_URL_SOCKET)
            mSocket.on(
                Socket.EVENT_CONNECT, onconnecteToResponse
            )
                .on(
                    Config.EMIT_LISTENER_NEWS, onNewsResponse
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

    private val onNewsResponse: Emitter.Listener = object : Emitter.Listener {
        override fun call(vararg args: Any) {
            //   Log.e("222", ">>ddddd")

            activity!!.runOnUiThread(Runnable {
                // flProgress.visibility = View.GONE

                listData.clear()

                try {


                    var objMain: JSONObject = args[0] as JSONObject

                    val gson = Gson()
                    val responseNews: NewsResponse =
                        gson.fromJson(objMain.toString(), NewsResponse::class.java)
                    var status: String = objMain.optString("status")


                    if (responseNews.status!!.equals("200")) {

                        //last_page = responseNews.data!!.lastPage!!
                        var listC: List<NewsItem>? =
                            responseNews.data!!.news as List<NewsItem>?

                        listData.addAll(listC!!)
                    }


                    adapter!!.notifyDataSetChanged()
                    /*  if (listData.isEmpty()) {
                          tvNo.visibility = View.VISIBLE
                      } else {
                          tvNo.visibility = View.GONE

                      }*/


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
                    mSocket.emit(Config.EMIT_NEWS, obj)

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

    private fun getNews() {

        if (!isConnectedToInternet) {
            return
        }


        flProgress.visibility = View.VISIBLE

        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<NewsResponse> =
            service.getNews(AppUtils.getAuthToken(activity!!), page.toString())

        call!!.enqueue(object : Callback<NewsResponse> {
            override fun onResponse(
                call: Call<NewsResponse>,
                response: Response<NewsResponse>
            ) {
                page = page + 1
                flProgress.visibility = View.GONE

                if (response.isSuccessful) {

                    if (response.body()!!.status!!.equals("200")) {

                        last_page = response.body()!!.data!!.lastPage!!
                        var listC: List<NewsItem>? =
                            response.body()!!.data!!.news as List<NewsItem>?
                        if (listC!!.size > 0) {

                            isLoading = false

                        } else {
                            isLoading = true
                        }

                        listData.addAll(listC!!)
                    }

                }

                adapter!!.notifyDataSetChanged()
                if (listData.isEmpty()) {
                    tvNo.visibility = View.VISIBLE
                } else {
                    tvNo.visibility = View.GONE

                }
            }

            override fun onFailure(call: Call<NewsResponse>, t: Throwable) {
                isLoading = true
                flProgress.visibility = View.GONE
            }
        })

    }


}
