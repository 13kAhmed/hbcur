package com.app.hbcu.adapter

import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ImageView
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.model.team.TeamsItem
import com.app.hbcu.util.Config
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import de.hdodenhof.circleimageview.CircleImageView

class TeamsAdapter(val activity: Activity, val listData: ArrayList<TeamsItem>) :


    RecyclerView.Adapter<TeamsAdapter.ViewHolders>() {

    class ViewHolders(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var tvTitle: TextView? = null
        var ivProfile: CircleImageView? = null
        var ivActive: ImageView? = null


        init {

            tvTitle = itemView.findViewById(R.id.tvTitle);
            ivProfile = itemView.findViewById(R.id.ivProfile);
            ivActive = itemView.findViewById(R.id.ivActive);

        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolders {

        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_team, parent, false)
        return ViewHolders(view)

    }

    override fun getItemCount(): Int {
        return listData.size
    }

    override fun onBindViewHolder(holder: ViewHolders, position: Int) {
        holder?.tvTitle?.text =
            listData.get(position).firstName + " " + listData.get(position).lastName
        if (!(listData.get(position)?.avtar + "").equals("", true)) {
            Glide.with(activity).load(Config.IMAGE_BASE_URL + listData.get(position)!!.avtar)
                .centerCrop()
                .placeholder(R.drawable.ic_user_placeholder).error(R.drawable.ic_user_placeholder)
                .diskCacheStrategy(
                    DiskCacheStrategy.NONE
                )
                .into(holder.ivProfile!!)
        }
    }


}

