package com.app.hbcu.activity

import android.os.Bundle
import android.view.View
import android.widget.ImageView
import androidx.viewpager.widget.ViewPager
import com.app.hbcu.R
import com.app.hbcu.adapter.PagerStatePagerAdapter
import com.app.hbcu.fragment.RankingHBCUFragment
import com.app.hbcu.fragment.RankingUserByRegionragment
import com.app.hbcu.util.NonSwipeableViewPager
import com.google.android.material.tabs.TabLayout


class RankingActivity : BaseAppCompatActivity(), View.OnClickListener {
    lateinit var ivBack: ImageView

    var pagerStatePagerAdapter: PagerStatePagerAdapter? = null
    lateinit var tabTabs: TabLayout;
    lateinit var viewPager: NonSwipeableViewPager;

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_ranking)

        init()
    }

    private fun init() {

        ivBack = findViewById(R.id.ivBack)
        viewPager = findViewById(R.id.viewPager)
        tabTabs = findViewById(R.id.tabTabs)

        ivBack.setOnClickListener(this)

        setupPager()
    }

    private fun setupPager() {

        pagerStatePagerAdapter = PagerStatePagerAdapter(supportFragmentManager)
        pagerStatePagerAdapter!!.addFragment(RankingHBCUFragment.newInstance(), resources.getString(R.string.lbl_hbcu))
        //pagerStatePagerAdapter!!.addFragment(RankingUserByRegionragment.newInstance(), resources.getString(R.string.lbl_user_by_region))

        viewPager.setAdapter(pagerStatePagerAdapter)
        tabTabs.setupWithViewPager(viewPager)

    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.ivBack -> {
                finish()
            }
        }
    }
}