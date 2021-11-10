package com.app.hbcu.adapter

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ArrayAdapter
import android.widget.TextView
import com.app.hbcu.R

class SpinnerCustomAdater(var mContext: Context, list: List<String?>?) : ArrayAdapter<String?>(
    mContext, R.layout.item_spinner_text, R.id.text1, list!!
) {
    var flater: LayoutInflater? = null


    override fun getView(position: Int, convertView: View?, parent: ViewGroup): View {
        val rowItem = getItem(position)
        val holder: viewHolder
        var rowview: View? = null
        if (convertView == null) {
            holder = viewHolder()
            flater =
                mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
            rowview = flater!!.inflate(R.layout.item_spinner_text, null,false)
            holder.txtTitle = rowview.findViewById(R.id.text1)
            rowview.tag = holder
        } else {
            holder = convertView.tag as viewHolder
        }
        if (position == 0) {
            holder.txtTitle!!.setTextColor(mContext.resources.getColor(R.color.grayText))
        } else {
            holder.txtTitle!!.setTextColor(Color.BLACK)
        }


        holder.txtTitle!!.text = rowItem + ""
        return rowview!!
    }

    override fun getDropDownView(position: Int, convertView: View?, parent: ViewGroup): View {
        val rowItem = getItem(position)
        val holder: viewHolder
        var rowview: View? =  convertView
        if (rowview == null) {
            holder = viewHolder()
            val inflater = LayoutInflater.from(mContext)
            rowview = inflater.inflate(R.layout.item_spinner_text, parent, false)
            holder.txtTitle = rowview.findViewById(R.id.text1)
            rowview.tag = holder
        } else {
            holder = rowview.tag as viewHolder
        }
        if (position == 0) {
            holder.txtTitle!!.setTextColor(mContext.resources.getColor(R.color.app_color_primary))
        } else {
            holder.txtTitle!!.setTextColor(Color.BLACK)
        }


        holder.txtTitle!!.text = rowItem + ""
        return rowview!!
    }

    override fun isEnabled(position: Int): Boolean {
        return if (position == 0) {
            false
        } else {
            true
        }
    }

    private fun rowview(convertView: View, position: Int): View {
        val rowItem = getItem(position)
        val holder: viewHolder
        var rowview: View? = null
        if (convertView == null) {
            holder = viewHolder()
            flater =
                mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE) as LayoutInflater
            rowview = flater!!.inflate(R.layout.item_spinner_text, null,false)
            holder.txtTitle = rowview.findViewById(R.id.text1)
            rowview.tag = holder
        } else {
            holder = convertView.tag as viewHolder
        }
        if (position == 0) {
            holder.txtTitle!!.setTextColor(mContext.resources.getColor(R.color.grayText))
        } else {
            holder.txtTitle!!.setTextColor(mContext.resources.getColor(R.color.app_color_primary))
        }

        holder.txtTitle!!.text = rowItem + ""
        return rowview!!
    }

    private inner class viewHolder {
        var txtTitle: TextView? = null
    }
}