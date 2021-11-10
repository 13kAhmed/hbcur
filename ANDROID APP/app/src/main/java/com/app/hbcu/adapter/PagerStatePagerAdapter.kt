package com.app.hbcu.adapter

import androidx.fragment.app.Fragment
import androidx.fragment.app.FragmentManager
import androidx.fragment.app.FragmentStatePagerAdapter
import java.util.*

class PagerStatePagerAdapter(manager: FragmentManager?) : FragmentStatePagerAdapter(
    manager!!
) {
    private val mFragmentList: MutableList<Fragment> = ArrayList()
    private val mFragmentTitleList: MutableList<String> = ArrayList()
    override fun getItem(position: Int): Fragment {
        return mFragmentList[position]
    }

    override fun getCount(): Int {
        return mFragmentList.size
    }

    fun addFragment(fragment: Fragment, title: String, position: Int) {
        mFragmentList.add(position, fragment)
        mFragmentTitleList.add(position, title)
    }

    fun addFragment(fragment: Fragment, title: String) {
        mFragmentList.add(fragment)
        mFragmentTitleList.add(title)
    }

    fun removeFragment(fragment: Fragment?, position: Int) {
        mFragmentList.removeAt(position)
        mFragmentTitleList.removeAt(position)
    }

    fun clearFragment() {
        mFragmentList.clear()
        mFragmentTitleList.clear()
    }

    //this is called when notifyDataSetChanged() is called
    override fun getItemPosition(`object`: Any): Int {
        // refresh all fragments when data set changed
        return POSITION_NONE
    }

    override fun getPageTitle(position: Int): CharSequence? {
        return mFragmentTitleList[position]
    }
}