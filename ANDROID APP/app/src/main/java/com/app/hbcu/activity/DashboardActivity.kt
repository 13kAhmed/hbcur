package com.app.hbcu.activity

import android.os.Bundle
import android.view.View
import androidx.fragment.app.Fragment
import com.app.hbcu.R
import com.app.hbcu.adapter.PagerStatePagerAdapter
import com.app.hbcu.fragment.*
import com.app.hbcu.util.NonSwipeableViewPager
import com.google.android.material.bottomnavigation.BottomNavigationView


class DashboardActivity : BaseAppCompatActivity(), View.OnClickListener {

    lateinit var bottom_navigation: BottomNavigationView
    lateinit var viewPager: NonSwipeableViewPager
    var pagerStatePagerAdapter: PagerStatePagerAdapter? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_dashboard)

        init();
    }

    private fun init() {
        bottom_navigation = findViewById(R.id.bottom_navigation)
        viewPager = findViewById(R.id.viewPager)

        listener()
        /*loadFragment(
            HomeFragment.newInstance(),
            HomeFragment::class.java.getSimpleName(),
            false
        )*/

        pagerStatePagerAdapter = PagerStatePagerAdapter(supportFragmentManager)
        pagerStatePagerAdapter!!.addFragment(
            HomeFragment.newInstance(),
            resources.getString(R.string.lbl_hbcu)
        )
        pagerStatePagerAdapter!!.addFragment(
            TransactionFragment.newInstance(),
            resources.getString(R.string.lbl_user_by_region)
        )
        pagerStatePagerAdapter!!.addFragment(
            UsersFragment.newInstance(),
            resources.getString(R.string.lbl_user_by_region)
        )
        pagerStatePagerAdapter!!.addFragment(
            MoreProfileFragment.newInstance(),
            resources.getString(R.string.lbl_user_by_region)
        )

        viewPager.setAdapter(pagerStatePagerAdapter)
        viewPager.setOffscreenPageLimit(4);
    }

    private fun listener() {
        bottom_navigation.setOnNavigationItemSelectedListener { item ->
            when (item.itemId) {
                R.id.navigation_home -> {

                    loadFragment(
                        HomeFragment.newInstance(),
                        HomeFragment::class.java.getSimpleName(),
                        false,
                        0
                    )
                }
                R.id.navigation_transaction -> {
                    loadFragment(
                        TransactionFragment.newInstance(),
                        TransactionFragment::class.java.getSimpleName(),
                        false, 1
                    )
                }
                R.id.navigation_profile -> {
                    loadFragment(
                        UsersFragment.newInstance(),
                        UsersFragment::class.java.getSimpleName(),
                        false, 2
                    )
                }
                R.id.navigation_more -> {
                    loadFragment(
                        MoreProfileFragment.newInstance(),
                        MoreProfileFragment::class.java.getSimpleName(),
                        false, 3
                    )
                }
            }
            return@setOnNavigationItemSelectedListener true
        }
    }


    fun loadFragment(fragment: Fragment, simpleName: String?, isBack: Boolean, currentItem: Int) {
        /* val ft = supportFragmentManager.beginTransaction()
         ft.replace(R.id.container, fragment, simpleName)
         if (isBack) {
             ft.addToBackStack(null)
         }
         ft.commit()*/
        viewPager.setCurrentItem(currentItem)
    }


    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.llPhoneContinue -> {

            }
        }
    }


}