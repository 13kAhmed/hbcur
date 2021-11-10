package com.app.hbcu.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.adapter.RankingPeopleAdapter
import com.app.hbcu.model.ranking.RankingItem
import com.app.hbcu.model.ranking.RankingResponse
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.AppUtils
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*


class RankingHBCUFragment : BaseFragment(), View.OnClickListener {

    lateinit var vw: View
    lateinit var rvData: RecyclerView
    lateinit var llRegional: LinearLayout
    lateinit var llGlobal: LinearLayout
    lateinit var tvRegional: TextView
    lateinit var tvGlobal: TextView
    lateinit var tvNo: TextView

    var listData: ArrayList<RankingItem?> = ArrayList()
    var adapterTeams: RankingPeopleAdapter? = null

    var isLoading = false
    var page = 1
    var last_page = 1
    var type = "regional"

    companion object {
        fun newInstance(): Fragment {
            val fragment = RankingHBCUFragment()
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

        vw = inflater.inflate(R.layout.fragment_rank_hbcu, container, false);

        rvData = vw.findViewById(R.id.rvData)
        llRegional = vw.findViewById(R.id.llRegional)
        llGlobal = vw.findViewById(R.id.llGlobal)
        tvNo = vw.findViewById(R.id.tvNo)

        tvRegional = vw.findViewById(R.id.tvRegional)
        tvGlobal = vw.findViewById(R.id.tvGlobal)

        llRegional.setOnClickListener(this)
        llGlobal.setOnClickListener(this)

        init()

        return vw;
    }

    private fun init() {


        val layoutManager: RecyclerView.LayoutManager = LinearLayoutManager(activity)
        rvData.setLayoutManager(layoutManager)
        rvData.addItemDecoration(DividerItemDecoration(activity, DividerItemDecoration.VERTICAL));
        adapterTeams = RankingPeopleAdapter(activity!!, listData)
        rvData.setAdapter(adapterTeams)



        page = 1
        last_page = 1
        addMorePrograsbar()
        getRanking()
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
                        getRanking()
                    }
                }
            }
        })
    }

    private fun addMorePrograsbar() {
        isLoading = true

        listData.add(null)
        adapterTeams!!.notifyItemInserted(listData.size - 1)
    }

    override fun onClick(p0: View?) {

        when (p0?.id) {
            R.id.llRegional -> {
                type = "regional"
                llRegional.setBackgroundResource(R.drawable.bg_rounded_primary_left)
                llGlobal.background = null
                tvRegional.setTextColor(resources.getColor(R.color.white))
                tvGlobal.setTextColor(resources.getColor(R.color.app_color_primary))
                listData.clear()
                adapterTeams!!.notifyDataSetChanged()
                last_page = 1
                page = 1
                addMorePrograsbar()
                getRanking()
            }
            R.id.llGlobal -> {
                type = "global"
                llGlobal.setBackgroundResource(R.drawable.bg_rounded_primary_right)
                llRegional.background = null
                tvGlobal.setTextColor(resources.getColor(R.color.white))
                tvRegional.setTextColor(resources.getColor(R.color.app_color_primary))
                listData.clear()
                adapterTeams!!.notifyDataSetChanged()
                last_page = 1
                page = 1
                addMorePrograsbar()
                getRanking()
            }

        }
    }

    private fun getRanking() {

        if (!isConnectedToInternet) {
            return
        }

        var uid: String? = Pref.getStringValue(activity!!, Config.PREF_UID, "")


        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<RankingResponse> =
            service.getRanking(AppUtils.getAuthToken(activity!!), uid!!, type, page.toString())


        call!!.enqueue(object : Callback<RankingResponse> {
            override fun onResponse(
                call: Call<RankingResponse>,
                response: Response<RankingResponse>
            ) {
                page = page + 1
                listData.removeAt(listData.size - 1)
                val scrollPosition = listData.size
                adapterTeams!!.notifyItemRemoved(scrollPosition)
                if (response.isSuccessful) {

                    if (response.body()!!.status!!.equals("200")) {

                        last_page = response.body()!!.data!!.lastPage!!
                        var listC: List<RankingItem>? =
                            response.body()!!.data!!.ranking as List<RankingItem>?
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
                    tvNo.visibility = View.VISIBLE
                } else {
                    tvNo.visibility = View.GONE

                }


            }

            override fun onFailure(call: Call<RankingResponse>, t: Throwable) {
                listData.removeAt(listData.size - 1)
                val scrollPosition = listData.size
                adapterTeams!!.notifyItemRemoved(scrollPosition)
                isLoading = true

            }
        })

    }
}
