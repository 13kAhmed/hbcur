package com.app.hbcu.activity

import android.os.Bundle
import android.view.View
import android.view.View.GONE
import android.view.View.VISIBLE
import android.widget.*
import androidx.core.view.isVisible
import com.app.hbcu.R


class TeamViewActivity : BaseAppCompatActivity(), View.OnClickListener {
    lateinit var ivBack: ImageView

    lateinit var ivArrowVisioner: ImageView
    lateinit var rlVisioner: RelativeLayout
    lateinit var llDetailVisioner: LinearLayout

    lateinit var ivArrowAmbasador: ImageView
    lateinit var rlAmbasador: RelativeLayout
    lateinit var llDetailAmbasador: LinearLayout

    lateinit var ivArrowVerifier: ImageView
    lateinit var rlVerifier: RelativeLayout
    lateinit var llDetailVerifier: LinearLayout

    lateinit var tvLearnMore: TextView
    lateinit var tvPing: TextView
    lateinit var btnViewTeam: Button
    lateinit var btnInviteUser: Button

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_team_view)

        init()
    }

    private fun init() {

        ivBack = findViewById(R.id.ivBack)
        tvLearnMore = findViewById(R.id.tvLearnMore)
        tvPing = findViewById(R.id.tvPing)
        btnViewTeam = findViewById(R.id.btnViewTeam)
        btnInviteUser = findViewById(R.id.btnInviteUser)

        rlVisioner = findViewById(R.id.rlVisioner)
        llDetailVisioner = findViewById(R.id.llDetailVisioner)
        ivArrowVisioner = findViewById(R.id.ivArrowVisioner)

        rlAmbasador = findViewById(R.id.rlAmbasador)
        ivArrowAmbasador = findViewById(R.id.ivArrowAmbasador)
        llDetailAmbasador = findViewById(R.id.llDetailAmbasador)

        rlVerifier = findViewById(R.id.rlVerifier)
        ivArrowVerifier = findViewById(R.id.ivArrowVerifier)
        llDetailVerifier = findViewById(R.id.llDetailVerifier)


        ivBack.setOnClickListener(this)
        tvLearnMore.setOnClickListener(this)
        tvPing.setOnClickListener(this)
        btnViewTeam.setOnClickListener(this)
        btnInviteUser.setOnClickListener(this)

        rlVisioner.setOnClickListener(this)
        rlAmbasador.setOnClickListener(this)
        rlVerifier.setOnClickListener(this)

    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.rlVisioner -> {

                hideShowView(ivArrowVisioner, llDetailVisioner)
            }
            R.id.rlAmbasador -> {

                hideShowView(ivArrowAmbasador, llDetailAmbasador)
            }
            R.id.rlVerifier -> {
                hideShowView(ivArrowVerifier, llDetailVerifier)
            }

            R.id.tvLearnMore -> {

            }
            R.id.tvPing -> {

            }
            R.id.btnViewTeam -> {

            }
            R.id.btnInviteUser -> {

            }
            R.id.ivBack -> {
                finish()
            }
        }
    }

    private fun hideShowView(ivArrow: ImageView, llDetail: LinearLayout) {

        if (llDetail.isVisible) {
            llDetail.visibility = GONE
            ivArrow.setImageResource(R.drawable.ic_arrow_down)
        } else {
            llDetail.visibility = VISIBLE
            ivArrow.setImageResource(R.drawable.ic_arrow_up)
        }
    }
}