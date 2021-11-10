package com.app.hbcu.adapter

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.widget.Filter
import android.widget.Filterable
import android.widget.LinearLayout
import android.widget.TextView
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.model.contact.ContactModel
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref


class ContactListAdapter(val activity: Activity, val listData: ArrayList<ContactModel>) :
    RecyclerView.Adapter<ContactListAdapter.ViewHolders>(), Filterable {

    var listFilterData: ArrayList<ContactModel> = ArrayList()

    init {
        listFilterData = listData as ArrayList<ContactModel>
    }

    class ViewHolders(itemView: View) : RecyclerView.ViewHolder(itemView) {

        var tvTitle: TextView? = null
        var tvPhone: TextView? = null
        var llMain: LinearLayout? = null

        init {

            tvTitle = itemView.findViewById(R.id.tvTitle);
            tvPhone = itemView.findViewById(R.id.tvPhone);
            llMain = itemView.findViewById(R.id.llMain);

        }
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): ViewHolders {

        val view = LayoutInflater.from(parent.context).inflate(R.layout.item_contact, parent, false)
        return ViewHolders(view)

    }

    override fun getItemCount(): Int {
        return listFilterData.size
    }

    override fun onBindViewHolder(holder: ViewHolders, position: Int) {
        holder?.tvTitle?.text = listFilterData.get(position).name
        holder?.tvPhone?.text = listFilterData.get(position).phoneNumber

        holder?.llMain!!.setOnClickListener {
            // Log.e(">>", listData.get(position).name + " " +  listData.get(position).phoneNumber)

            try {
                var shareText: String =
                    activity.resources.getString(R.string.lbl_here_my_invitation_link) +
                            " " + Pref.getUserLoginData(activity).invitationCode + "\nDownload at " + Config.URL_DOWNLOAD_LINK


                val uri = Uri.parse("smsto:"+listFilterData.get(position).phoneNumber)
                val intent = Intent(Intent.ACTION_SENDTO)
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                intent.data = uri // This ensures only SMS apps respond

                intent.putExtra("sms_body", shareText)
                activity.startActivity(intent)

                //  val smsIntent: Intent = Intent(Intent.ACTION_VIEW)
                /* val smsIntent: Intent = Intent(Intent.ACTION_VIEW)
                 smsIntent.setType("vnd.android-dir/mms-sms")
                 smsIntent.putExtra("address", "sms:" + listFilterData.get(position).phoneNumber)
                 smsIntent.putExtra("sms_body", shareText)
                 activity.startActivity(smsIntent)*/

            } catch (e: Exception) {
                e.printStackTrace()
            }

        }
    }

    override fun getFilter(): Filter {
        return object : Filter() {
            override fun performFiltering(constraint: CharSequence?): FilterResults {
                val charSearch = constraint.toString()
                if (charSearch.isEmpty()) {
                    listFilterData = listData as ArrayList<ContactModel>
                } else {
                    val resultList = ArrayList<ContactModel>()
                    for (row in listData) {
                        if ((row.name + "")?.toLowerCase()!!
                                .contains(constraint.toString().toLowerCase()) ||
                            (row.phoneNumber + "")?.toLowerCase()
                                .contains(constraint.toString().toLowerCase())
                        ) {
                            resultList.add(row)
                        }
                    }
                    listFilterData = resultList
                }
                val filterResults = FilterResults()
                filterResults.values = listFilterData
                return filterResults
            }

            override fun publishResults(constraint: CharSequence?, results: FilterResults?) {
                listFilterData = results?.values as ArrayList<ContactModel>
                notifyDataSetChanged()
            }
        }
    }

}

