package com.app.hbcu.adapter

import android.app.Activity
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.model.mininghistory.MiningTransactionHistoryItem
import com.app.hbcu.util.AppUtils
import com.app.hbcu.util.Config
import java.text.SimpleDateFormat
import java.util.*

class TransactionAdapter(
    val activity: Activity,
    val listData: ArrayList<MiningTransactionHistoryItem>
) :
    RecyclerView.Adapter<TransactionAdapter.ViewHolders>() {
    var dateFormat_convert = SimpleDateFormat("dd MMM, yyyy hh:mm:a")
    //var dateFormat_UTC = SimpleDateFormat("yyyy-MM-dd HH:mm:ss")
    var dateFormat_UTC = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")

    class ViewHolders(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var tvTitle: TextView? = null
        var tvTime: TextView? = null
        var tvMoney: TextView? = null

        init {

            tvTitle = itemView.findViewById(R.id.tvTitle);
            tvTime = itemView.findViewById(R.id.tvTime);
            tvMoney = itemView.findViewById(R.id.tvMoney);

        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolders {

        val view =
            LayoutInflater.from(parent.context).inflate(R.layout.item_transaction, parent, false)
        return ViewHolders(view)

    }

    override fun getItemCount(): Int {
        return listData.size
    }

    override fun onBindViewHolder(holder: ViewHolders, position: Int) {

        if ((listData.get(position).type + "").equals("mining", true)) {
            holder?.tvTitle?.text = activity.resources.getString(R.string.lbl_daily_mining)
        } else {
            holder?.tvTitle?.text = activity.resources.getString(R.string.lbl_daily_mining)
        }

        if ((listData.get(position).status + "").equals(Config.STATUS_START, true)) {
            holder?.tvTime?.text = activity.resources.getString(R.string.lbl_currently_mining)
            holder?.tvTime?.setTextColor(activity.resources.getColor(R.color.yellow))
        } else {

            holder?.tvTime?.setTextColor(activity.resources.getColor(R.color.grayText))

            try {
                val dt: Date = dateFormat_UTC.parse(listData.get(position).transCreated)
                val formatedTime: String = dateFormat_convert.format(dt)
                holder?.tvTime?.text = formatedTime
            } catch (e: Exception) {
                holder?.tvTime?.text = ""

                Log.e("ERR", ">>$e")
            }
        }

        if ((listData.get(position).creditAmount)!! > 0) {
            holder?.tvMoney?.text =
                "+" + AppUtils.formatDoubleTo_4_DigitString(listData.get(position).creditAmount)
            holder?.tvMoney?.setTextColor(activity.resources.getColor(R.color.green))
        } else if ((listData.get(position).debitAmount)!! > 0) {
            holder?.tvMoney?.text =
                "-" + AppUtils.formatDoubleTo_4_DigitString(listData.get(position).debitAmount)
            holder?.tvMoney?.setTextColor(activity.resources.getColor(R.color.red))

        } else {
            holder?.tvMoney?.text = "00"
            holder?.tvMoney?.setTextColor(activity.resources.getColor(R.color.black))
        }

    }


}

