package com.app.hbcu.adapter

import android.app.Activity
import android.content.Intent
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.activity.WebActivity
import com.app.hbcu.model.news.NewsItem
import com.app.hbcu.util.Config
import com.bumptech.glide.Glide
import java.text.SimpleDateFormat
import java.util.*

class NewsAdapter(val activity: Activity, val listData: ArrayList<NewsItem>) :
    RecyclerView.Adapter<NewsAdapter.ViewHolders>() {

    var dateFormat_convert: SimpleDateFormat = SimpleDateFormat("dd-MMM yyyy, hh:mm:a")
    var dateFormat_UTC = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")

    class ViewHolders(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var tvTitle: TextView? = null
        var ivBanner: ImageView? = null
        var tvTime: TextView? = null
        var tvMore: TextView? = null

        init {

            tvTitle = itemView.findViewById(R.id.tvTitle);
            ivBanner = itemView.findViewById(R.id.ivBanner);
            tvTime = itemView.findViewById(R.id.tvTime);
            tvMore = itemView.findViewById(R.id.tvMore);


        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolders {

        val view =
            LayoutInflater.from(parent.context).inflate(R.layout.item_news, parent, false)
        return ViewHolders(view)

    }

    override fun getItemCount(): Int {
        return listData.size
    }

    override fun onBindViewHolder(holder: ViewHolders, position: Int) {
        holder?.tvTitle?.text = listData.get(position).title
        Glide.with(activity)
            .load(Config.IMAGE_BASE_URL_NEWS + listData.get(position).image)
            .placeholder(R.drawable.ic_placeholde_img)
            .error(R.drawable.ic_placeholde_img)
            .into(holder.ivBanner!!)

        try {
            val tz = TimeZone.getDefault()

            dateFormat_convert.setTimeZone(tz);
            dateFormat_UTC.setTimeZone(TimeZone.getTimeZone("UTC"));
            val dt: Date = dateFormat_UTC.parse(listData.get(position).updatedAt)
            val formatedTime: String = dateFormat_convert.format(dt)
            holder?.tvTime?.text = formatedTime


        } catch (e: Exception) {
            holder?.tvTime?.text = ""

            Log.e("ERR", ">>$e")
        }


        holder?.tvMore?.setOnClickListener(View.OnClickListener {
            var intent = Intent(activity, WebActivity::class.java)
            intent.putExtra("urlWeb", listData.get(position).url + "")
            intent.putExtra("title", activity.resources.getString(R.string.lbl_news))
            activity.startActivity(intent)
        })
    }


}

