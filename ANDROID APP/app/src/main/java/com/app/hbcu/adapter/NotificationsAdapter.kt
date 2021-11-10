package com.app.hbcu.adapter

import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.model.notification.NotificationItem
import java.text.SimpleDateFormat
import java.util.*

class NotificationsAdapter(val activity: Activity, val listData: ArrayList<NotificationItem>) :
    RecyclerView.Adapter<NotificationsAdapter.ViewHolders>() {

    var dateFormat_convert = SimpleDateFormat("dd-MMM yyyy, hh:mm:a")
    var dateFormat_UTC = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")


    class ViewHolders(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var tvTitle: TextView? = null
        var ivBanner: ImageView? = null
        var tvTime: TextView? = null

        init {

            tvTitle = itemView.findViewById(R.id.tvTitle);
            ivBanner = itemView.findViewById(R.id.ivBanner);
            tvTime = itemView.findViewById(R.id.tvTime);


        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolders {

        val view =
            LayoutInflater.from(parent.context).inflate(R.layout.item_notifications, parent, false)
        return ViewHolders(view)

    }

    override fun getItemCount(): Int {
        return listData.size
    }

    override fun onBindViewHolder(holder: ViewHolders, position: Int) {
        holder?.tvTitle?.text = listData.get(position).message
        holder?.tvTime?.text = listData.get(position).created_at

        try {
            dateFormat_convert.setTimeZone(TimeZone.getDefault());
            dateFormat_UTC.setTimeZone(TimeZone.getTimeZone("UTC"));
            val dt: Date = dateFormat_UTC.parse(listData.get(position).created_at)
            val formatedTime: String = dateFormat_convert.format(dt)
            holder?.tvTime?.text = formatedTime
        } catch (e: Exception) {
        }


    }


}

