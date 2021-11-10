package com.app.hbcu.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.fragment.app.Fragment
import com.app.hbcu.R
import com.app.hbcu.model.teamearning.EarningTeamsResponse
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.AppUtils
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class EarningTeamFragment : BaseFragment() {

    lateinit var vw: View
    lateinit var tvVisioner: TextView
    lateinit var tvMember: TextView
    lateinit var tvActiveMember: TextView




    companion object {
        fun newInstance(): Fragment {
            val fragment = EarningTeamFragment()
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

        vw = inflater.inflate(R.layout.fragment_earning_team, container, false);


        tvVisioner = vw.findViewById(R.id.tvVisioner)
        tvMember = vw.findViewById(R.id.tvMember)
        tvActiveMember = vw.findViewById(R.id.tvActiveMember)

        getEarningTeam()
        return vw;
    }

    private fun getEarningTeam() {


        tvActiveMember.setText("0")
        tvMember.setText("0")
        tvActiveMember.setText("0")

        var uid: String? = Pref.getStringValue(activity!!, Config.PREF_UID, "")
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
                        tvVisioner.text = (response.body()!!.data!!.totalInvited).toString();
                        tvMember.text = (response.body()!!.data!!.totalTeamMember).toString();
                        tvActiveMember.text =
                            (response.body()!!.data!!.totalActiveMining).toString();

                        // (parentFragment as UsersFragment).setTeamsEarningTotal(response.body()!!.data!!.totalEarning)
                    } catch (E: Exception) {

                    }


                }

            }

            override fun onFailure(call: Call<EarningTeamsResponse>, t: Throwable) {


            }
        })


    }

}
