package com.app.hbcu.activity

import android.Manifest
import android.content.pm.PackageManager
import android.database.Cursor
import android.os.AsyncTask
import android.os.Bundle
import android.provider.ContactsContract
import android.text.Editable
import android.text.TextWatcher
import android.util.Log
import android.view.View
import android.widget.*
import androidx.core.app.ActivityCompat
import androidx.recyclerview.widget.DividerItemDecoration
import androidx.recyclerview.widget.LinearLayoutManager
import androidx.recyclerview.widget.RecyclerView
import com.app.hbcu.R
import com.app.hbcu.adapter.ContactListAdapter
import com.app.hbcu.model.contact.ContactModel
import com.app.hbcu.util.AppUtils
import java.util.*


class ContactListInviteActivity : BaseAppCompatActivity(), View.OnClickListener {
    val REQUEST_PERMISSIONS_CODE_CONTACT = 121
    var listData: ArrayList<ContactModel> = ArrayList()

    var adapterTeams: ContactListAdapter? = null

    lateinit var tvNo: TextView
    lateinit var ivBack: ImageView
    lateinit var rlData: RecyclerView
    lateinit var etSearch: EditText
    lateinit var flProgress: FrameLayout

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_contact_invite)

        init()
    }

    private fun init() {

        ivBack = findViewById(R.id.ivBack)
        tvNo = findViewById(R.id.tvNo)
        rlData = findViewById(R.id.rlData)
        etSearch = findViewById(R.id.etSearch)
        flProgress = findViewById(R.id.flProgress)

        ivBack.setOnClickListener(this)

        val layoutManager: RecyclerView.LayoutManager = LinearLayoutManager(this)
        rlData.setLayoutManager(layoutManager)
        rlData.addItemDecoration(DividerItemDecoration(this, DividerItemDecoration.VERTICAL));
        adapterTeams = ContactListAdapter(this, listData)
        rlData.setAdapter(adapterTeams)

        checkPermision()
        listener()
    }

    private fun listener() {

        etSearch.addTextChangedListener(object : TextWatcher {
            override fun afterTextChanged(s: Editable?) {
                adapterTeams?.filter?.filter(s.toString())
            }

            override fun beforeTextChanged(s: CharSequence?, start: Int, count: Int, after: Int) {
            }

            override fun onTextChanged(s: CharSequence?, start: Int, before: Int, count: Int) {
            }
        })
    }

    fun checkPermision() {
        if (!AppUtils.CheckContactPermission(this)) {
            val listPermissionsNeeded: MutableList<String> = ArrayList()
            listPermissionsNeeded.add(Manifest.permission.READ_CONTACTS)
            ActivityCompat.requestPermissions(
                this,
                listPermissionsNeeded.toTypedArray(),
                REQUEST_PERMISSIONS_CODE_CONTACT
            )

        } else {

            ContactTask(this).execute()

            /*  val handler = Handler()
              handler.postDelayed(Runnable {
                  getContactList()

              }, 200)*/

        }
    }


    override fun onClick(p0: View?) {
        when (p0?.id) {

            R.id.ivBack -> {
                finish()
            }
        }
    }

    class ContactTask(private var activity: ContactListInviteActivity?) :
        AsyncTask<Void, Void, String>() {

        override fun onPreExecute() {
            super.onPreExecute()
            activity?.flProgress?.visibility = View.VISIBLE
            activity?.listData?.clear()
        }

        override fun doInBackground(vararg params: Void?): String? {
            // ...


            val cr = activity!!.contentResolver
            val cur: Cursor? = cr.query(
                ContactsContract.Contacts.CONTENT_URI,
                null, null, null, null
            )
            if ((if (cur != null) cur.getCount() else 0) > 0) {
                while (cur != null && cur.moveToNext()) {

                    try {
                        val id: String = cur.getString(
                            cur.getColumnIndex(ContactsContract.Contacts._ID)
                        )
                        val name: String = cur.getString(
                            cur.getColumnIndex(
                                ContactsContract.Contacts.DISPLAY_NAME
                            )
                        )
                        if (cur.getInt(
                                cur.getColumnIndex(
                                    ContactsContract.Contacts.HAS_PHONE_NUMBER
                                )
                            ) > 0
                        ) {
                            val pCur: Cursor? = cr.query(
                                ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                                null,
                                ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?",
                                arrayOf(id),
                                null
                            )
                            while (pCur!!.moveToNext()) {
                                val phoneNo: String = pCur.getString(
                                    pCur.getColumnIndex(
                                        ContactsContract.CommonDataKinds.Phone.NUMBER
                                    )
                                )

                                var cm: ContactModel = ContactModel()
                                cm.name = name
                                cm.phoneNumber = phoneNo
                                activity!!.listData.add(cm)

                            }
                            pCur.close()
                        }
                    } catch (e: Exception) {

                    }

                }


            }
            if (cur != null) {
                cur.close()
            }

            return null
        }

        override fun onPostExecute(result: String?) {
            super.onPostExecute(result)

            activity?.flProgress?.visibility = View.GONE
            activity?.adapterTeams!!.notifyDataSetChanged()
            if (activity?.listData!!.isEmpty()) {
                activity?.tvNo!!.visibility = View.VISIBLE
            } else {
                activity?.tvNo!!.visibility = View.GONE

            }
            // ...
        }
    }


    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)

        when (requestCode) {
            REQUEST_PERMISSIONS_CODE_CONTACT -> if (grantResults.size > 0
                && grantResults[0] == PackageManager.PERMISSION_GRANTED
            ) {
                //  getContactList()
                ContactTask(this).execute()

                Log.e("GRANT", "Permission Granted!")

            } else {
                Toast.makeText(this, "Permission Denied!", Toast.LENGTH_SHORT).show()
            }
        }
    }


    /* private class AsyncTaskRunner :
         AsyncTask<String?, String?, String?>() {
         private val resp: String? = null
         var progressDialog: ProgressDialog? = null
         protected override fun doInBackground(vararg params: String): String? {
             var contactVO: ContactVO
             val contentResolver: ContentResolver = getContentResolver()
             val cursor = contentResolver.query(
                 ContactsContract.Contacts.CONTENT_URI,
                 null,
                 null,
                 null,
                 ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME + " ASC"
             )
             if (cursor!!.count > 0) {
                 while (cursor.moveToNext()) {
                     val hasPhoneNumber =
                         cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.HAS_PHONE_NUMBER))
                             .toInt()
                     if (hasPhoneNumber > 0) {
                         val id =
                             cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts._ID))
                         val name =
                             cursor.getString(cursor.getColumnIndex(ContactsContract.Contacts.DISPLAY_NAME))
                         contactVO = ContactVO()
                         contactVO.setContactName(name)
                         val phoneCursor = contentResolver.query(
                             ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                             null,
                             ContactsContract.CommonDataKinds.Phone.CONTACT_ID + " = ?", arrayOf(id),
                             null
                         )
                         if (phoneCursor!!.moveToNext()) {
                             val phoneNumber =
                                 phoneCursor.getString(phoneCursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER))
                             contactVO.setContactNumber(phoneNumber)
                         }
                         phoneCursor.close()
                         val emailCursor = contentResolver.query(
                             ContactsContract.CommonDataKinds.Email.CONTENT_URI,
                             null,
                             ContactsContract.CommonDataKinds.Email.CONTACT_ID + " = ?",
                             arrayOf(id),
                             null
                         )
                         while (emailCursor!!.moveToNext()) {
                             val emailId =
                                 emailCursor.getString(emailCursor.getColumnIndex(ContactsContract.CommonDataKinds.Email.DATA))
                         }
                         contactVOList.add(contactVO)
                     }
                 }
             }
             return null
         }

         override fun onPostExecute(result: String?) {
             // execution of result of Long time consuming operation
             hideProgressBar()
             setContactAdapter()
         }

         override fun onPreExecute() {
             showProgressBar()
         }
     }
     private fun getContacts(): Observable<MutableList<ContactModel>> {
         return Observable.create { emitter ->
             val list: MutableList<ContactModel> = ArrayList()
             val contentResolver: ContentResolver = contentResolver

             val projection = arrayOf(
                 ContactsContract.CommonDataKinds.Phone.CONTACT_ID,
                 ContactsContract.CommonDataKinds.Phone.CUSTOM_RINGTONE,
                 ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME,
                 ContactsContract.CommonDataKinds.Phone.NUMBER
             )
             val cursor =
                 contentResolver.query(
                     ContactsContract.CommonDataKinds.Phone.CONTENT_URI,
                     projection,
                     ContactsContract.Contacts.HAS_PHONE_NUMBER + ">0 AND LENGTH(" + ContactsContract.CommonDataKinds.Phone.NUMBER + ")>0",
                     null,
                     "display_name ASC"
                 )

             if (cursor != null && cursor.count > 0) {
                 var lastHeader = ""
                 while (cursor.moveToNext()) {
                     val id =
                         cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.CONTACT_ID))
                     val person =
                         ContentUris.withAppendedId(
                             ContactsContract.Contacts.CONTENT_URI,
                             id.toLong()
                         )
                     val ring =
                         cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.CUSTOM_RINGTONE))
                     val name =
                         cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.DISPLAY_NAME))
                     val mobileNumber =
                         cursor.getString(cursor.getColumnIndex(ContactsContract.CommonDataKinds.Phone.NUMBER))

                     val header = getFirstChar(name)
                     if (header != lastHeader) {
                         lastHeader = header
                         list.add(
                             ContactItemViewState(
                                 header,
                                 View.GONE,
                                 View.VISIBLE,
                                 "",
                                 name,
                                 "",
                                 "",
                                 null
                             )
                         )
                     }

                     list.add(
                         ContactItemViewState(
                             header,
                             View.VISIBLE,
                             View.GONE,
                             id,
                             name,
                             mobileNumber,
                             title,
                             person
                         )
                     )
                 }
                 cursor.close()
             }
             emitter.onNext(list)
             emitter.onComplete()
         }
     }*/
}