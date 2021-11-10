package com.app.hbcu.fragment

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.fragment.app.Fragment
import com.app.hbcu.R


class SecurityCircleFragment : BaseFragment() {

    lateinit var vw: View
 

    companion object {
        fun newInstance(): Fragment {
            val fragment = SecurityCircleFragment()
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

        vw = inflater.inflate(R.layout.fragment_security_circle, container, false);




        return vw;
    }


}
