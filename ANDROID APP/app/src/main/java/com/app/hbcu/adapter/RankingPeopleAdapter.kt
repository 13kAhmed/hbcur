package com.app.hbcu.adapter

import android.app.Activity
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.ProgressBar
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.model.ranking.RankingItem
import com.app.hbcu.util.Config
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import de.hdodenhof.circleimageview.CircleImageView
import java.util.*

class RankingPeopleAdapter(val activity: Activity, val listData: ArrayList<RankingItem?>) :
    RecyclerView.Adapter<RecyclerView.ViewHolder>() {
    val VIEW_ITEM = 0
    val VIEW_LOADING = 1


    override fun onCreateViewHolder(viewGroup: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        return if (viewType == VIEW_ITEM) {
            val view: View = LayoutInflater.from(viewGroup.context)
                .inflate(R.layout.item_ranking, viewGroup, false)
            ItemViewHolder(view)
        } else {
            val view = LayoutInflater.from(viewGroup.context)
                .inflate(R.layout.layout_progress_more, viewGroup, false)
            LoadingViewHolder(view)
        }


    }

    /* override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolders {

         val view = LayoutInflater.from(parent.context).inflate(R.layout.item_ranking, parent, false)
         return ViewHolders(view)

     }*/
    /* class ViewHolders(itemView: View) : RecyclerView.ViewHolder(itemView) {

         var tvTitle: TextView? = null
         var ivProfile: ImageView? = null


         init {

             tvTitle = itemView.findViewById(R.id.tvTitle);
             ivProfile = itemView.findViewById(R.id.ivProfile);


         }
     }
 */

    /* override fun getItemCount(): Int {
         return listData.size
     }*/
    override fun getItemCount(): Int {
        return if (listData == null) 0 else listData.size
    }

    override fun getItemViewType(position: Int): Int {
        return if (listData.get(position) == null) VIEW_LOADING else VIEW_ITEM
    }


    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        if (holder is ItemViewHolder) {
            populateItemRows(
                holder as ItemViewHolder,
                position
            )
        } else if (holder is LoadingViewHolder) {
            showLoadingView(
                holder as LoadingViewHolder,
                position
            )
        }
    }

    private fun showLoadingView(viewHolder: LoadingViewHolder, position: Int) {
        //ProgressBar would be displayed
    }

    private fun populateItemRows(viewHolder: ItemViewHolder, position: Int) {

        viewHolder.tvRank.setText("${(position + 1)}")
        viewHolder.tvTitle.setText(listData.get(position)?.fullname)


        try {
            val userNameMain = ""+listData.get(position)?.username;
            val printUser = userNameMain.substring(0, 3)+"******"
            viewHolder.tvMobile.setText("@$printUser")
        }catch (e:Exception)
        {
            viewHolder.tvMobile.setText("@${listData.get(position)?.username}")
        }

        if (!(listData.get(position)?.avtar + "").equals("", true)) {
            Glide.with(activity).load(Config.IMAGE_BASE_URL +listData.get(position)!!.avtar).centerCrop()
                .placeholder(R.drawable.ic_user_placeholder).error(R.drawable.ic_user_placeholder).diskCacheStrategy(
                    DiskCacheStrategy.NONE)
                .into(viewHolder.ivProfile)
        }
        /*viewHolder.rlMain.setOnClickListener(View.OnClickListener {
            if (listener != null) {
                listener.onItemClickd(position)
            }
        })*/
    }


    /*  override fun onBindViewHolder(holder: ViewHolders, position: Int) {
          holder?.tvTitle?.text = listData.get(position).name

      }
  */
    class ItemViewHolder internal constructor(itemView: View) : RecyclerView.ViewHolder(
        itemView!!
    ) {

        var tvTitle: TextView
        var tvRank: TextView
        var tvMobile: TextView
        var ivProfile: CircleImageView

        init {
            tvTitle = itemView.findViewById(R.id.tvTitle)
            ivProfile = itemView.findViewById(R.id.ivProfile)
            tvRank = itemView.findViewById(R.id.tvRank)
            tvMobile = itemView.findViewById(R.id.tvMobile)
        }
    }

    class LoadingViewHolder internal constructor(itemView: View) :
        RecyclerView.ViewHolder(itemView) {
        var progressBar: ProgressBar

        init {
            progressBar = itemView.findViewById(R.id.progressBar)
        }
    }
}

