package com.app.hbcu.activity

import android.os.Bundle
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.adapter.NotificationsAdapter
import com.app.hbcu.model.notification.NotificationItem
import com.app.hbcu.model.notification.NotificationResponse
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.AppUtils
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*


class NotificationsActivity : BaseAppCompatActivity(), View.OnClickListener {
    lateinit var rvData: RecyclerView
    lateinit var ivBack: ImageView
    lateinit var flProgress: FrameLayout
    lateinit var tvNo: TextView
    var listData: ArrayList<NotificationItem> = ArrayList()
    var adapter: NotificationsAdapter? = null

    var isLoading = false
    var page = 1
    var last_page = 1

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_notifications)

        init()
    }

    private fun init() {
        rvData = findViewById(R.id.rvData)
        ivBack = findViewById(R.id.ivBack)
        flProgress = findViewById(R.id.flProgress)
        tvNo = findViewById(R.id.tvNo)

        ivBack.setOnClickListener(this)


        val layoutManager: RecyclerView.LayoutManager = LinearLayoutManager(this)
        rvData.setLayoutManager(layoutManager)
        rvData.addItemDecoration(DividerItemDecoration(this, DividerItemDecoration.VERTICAL));
        adapter = NotificationsAdapter(this, listData)
        rvData.setAdapter(adapter)

        page = 1
        last_page = 1

        addMorePrograsbar()
        getNotifications()
        listener()

    }

    private fun listener() {

        rvData.addOnScrollListener(object : RecyclerView.OnScrollListener() {
            override fun onScrollStateChanged(recyclerView: RecyclerView, newState: Int) {
                super.onScrollStateChanged(recyclerView, newState)
            }

            override fun onScrolled(recyclerView: RecyclerView, dx: Int, dy: Int) {
                super.onScrolled(recyclerView, dx, dy)
                val linearLayoutManager = recyclerView.layoutManager as LinearLayoutManager?
                if (!isLoading) {
                    if (linearLayoutManager != null && linearLayoutManager.findLastCompletelyVisibleItemPosition() == listData.size - 1
                        && page <= last_page && last_page > 0
                    ) {
                        //bottom of list!
                        addMorePrograsbar()
                        getNotifications()
                    }
                }
            }
        })
    }

    private fun addMorePrograsbar() {
        isLoading = true
        //listData.add(null)
        // wallpapersAdapter.notifyItemInserted(listData.size - 1)
    }

    private fun getNotifications() {

        if (!isConnectedToInternet) {
            return
        }

        var uid: String? = Pref.getStringValue(this, Config.PREF_UID, "")
        flProgress.visibility = View.VISIBLE

        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<NotificationResponse> =
            service.getUsersNotification(AppUtils.getAuthToken(this), uid!!, page.toString())


        call!!.enqueue(object : Callback<NotificationResponse> {
            override fun onResponse(
                call: Call<NotificationResponse>,
                response: Response<NotificationResponse>
            ) {
                flProgress.visibility = View.GONE
                page = page + 1
                if (response.isSuccessful) {

                    if (response.body()!!.status!!.equals("200")) {

                        last_page = response.body()!!.data!!.lastPage!!
                        var listC: List<NotificationItem>? =
                            response.body()!!.data!!.notification as List<NotificationItem>?
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

            override fun onFailure(call: Call<NotificationResponse>, t: Throwable) {

                isLoading = true
                flProgress.visibility = View.GONE
            }
        })

    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.ivBack -> {
                finish()
            }
        }
    }
}