package com.app.hbcu.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ProgressBar
import android.widget.TextView
import androidx.fragment.app.Fragment
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.adapter.RankingCountryAdapter
import com.app.hbcu.model.country.CountryResponse
import com.app.hbcu.model.country.CountrysItem
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.util.*


class RankingUserByRegionragment : BaseFragment() {

    lateinit var vw: View
    lateinit var rvData: RecyclerView
    lateinit var tvNo: TextView
    lateinit var progressBar: ProgressBar
    var listData: ArrayList<CountrysItem?> = ArrayList()

    var adapterTeams: RankingCountryAdapter? = null

    companion object {
        fun newInstance(): Fragment {
            val fragment = RankingUserByRegionragment()
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

        vw = inflater.inflate(R.layout.fragment_rank_user_by_region_by, container, false);
        rvData = vw.findViewById(R.id.rvData)
        progressBar = vw.findViewById(R.id.progressBar)
        tvNo = vw.findViewById(R.id.tvNo)

        init()


        return vw;
    }

    private fun init() {

        val layoutManager: RecyclerView.LayoutManager = LinearLayoutManager(activity)
        rvData.setLayoutManager(layoutManager)
        rvData.addItemDecoration(DividerItemDecoration(activity, DividerItemDecoration.VERTICAL));
        adapterTeams = RankingCountryAdapter(activity!!, listData)
        rvData.setAdapter(adapterTeams)

        getCountryList()
        listener()

    }

    private fun listener() {

    }

    private fun getCountryList() {

        listData.clear()

        progressBar.visibility = View.VISIBLE


        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<CountryResponse> = service.getCountryList()

        call!!.enqueue(object : Callback<CountryResponse> {
            override fun onResponse(
                call: Call<CountryResponse>,
                response: Response<CountryResponse>
            ) {
                progressBar.visibility = View.GONE

                if (response.isSuccessful) {
                    if (response.body()!!.status!!.equals("200")) {

                        var listC: ArrayList<CountrysItem?> = response.body()!!.data!!.countrys!!
                        listData.addAll(listC)

                    }
                }

                adapterTeams!!.notifyDataSetChanged()

                if (listData.isEmpty()) {
                    tvNo.visibility = View.VISIBLE
                } else {
                    tvNo.visibility = View.GONE

                }
            }

            override fun onFailure(call: Call<CountryResponse>, t: Throwable) {

                progressBar.visibility = View.GONE
            }
        })

    }
}
