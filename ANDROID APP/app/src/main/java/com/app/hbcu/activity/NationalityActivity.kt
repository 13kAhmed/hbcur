package com.app.hbcu.activity

import android.content.Intent
import android.graphics.Color
import android.os.Bundle
import android.view.View
import android.view.View.*
import android.view.ViewGroup
import android.widget.*
import com.app.hbcu.R
import java.util.*

class NationalityActivity : BaseAppCompatActivity(), View.OnClickListener,
    CompoundButton.OnCheckedChangeListener {

    lateinit var etFirstName: EditText
    lateinit var etLastName: EditText
    lateinit var cbAA: CheckBox
    lateinit var spnNationality: Spinner
    lateinit var btnYes: Button
    lateinit var btnNo: Button
    lateinit var btnSubmit: Button
    lateinit var llSupportSocial: LinearLayout
    lateinit var rlNationality: LinearLayout
    lateinit var ivBack: ImageView

    var listCountry: ArrayList<String> = ArrayList()


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_nationality)

        init();
    }

    private fun init() {

        etLastName = findViewById(R.id.etLastName)
        etFirstName = findViewById(R.id.etFirstName)

        cbAA = findViewById(R.id.cbAA)
        spnNationality = findViewById(R.id.spnNationality)
        btnYes = findViewById(R.id.btnYes)
        btnNo = findViewById(R.id.btnNo)
        btnSubmit = findViewById(R.id.btnSubmit)
        llSupportSocial = findViewById(R.id.llSupportSocial)
        rlNationality = findViewById(R.id.rlNationality)
        ivBack = findViewById(R.id.ivBack)


        listCountry.add(resources.getString(R.string.lbl_choose_nationality))
        listCountry.add("India")
        listCountry.add("Australia")
        listCountry.add("Canada")

        setSpinnerCountry()

        listener()
    }

    private fun listener() {
        btnYes.setOnClickListener(this)
        btnNo.setOnClickListener(this)
        btnSubmit.setOnClickListener(this)
        ivBack.setOnClickListener(this)

        cbAA.setOnCheckedChangeListener(this)


        spnNationality.onItemSelectedListener = object : AdapterView.OnItemSelectedListener {
            override fun onNothingSelected(parent: AdapterView<*>?) {
            }

            override fun onItemSelected(
                parent: AdapterView<*>?,
                view: View?,
                position: Int,
                id: Long
            ) {
                val value = parent!!.getItemAtPosition(position).toString()
                if (value == listCountry.get(0)) {
                    (view as TextView).setTextColor(Color.GRAY)
                }
            }

        }

        /* spnNationality.setOnItemSelectedListener(object : OnItemSelectedListener {
             override fun onItemSelected(
                 parent: AdapterView<*>?,
                 view: View,
                 position: Int,
                 id: Long
             ) {
                 try {

                 } catch (e: Exception) {

                     Log.e("SDFS", ">>>$e")
                 }
                // setSpinnerSelection(parent, view, position)
             }

             override fun onNothingSelected(parent: AdapterView<*>?) {}
         })*/
    }

    fun setSpinnerCountry() {
        val spinnerAdapter =
            object : ArrayAdapter<String>(this, R.layout.item_spinner_text, listCountry) {

                override fun isEnabled(position: Int): Boolean {
                    // Disable the first item from Spinner
                    // First item will be use for hint
                    return position != 0
                }

                override fun getDropDownView(
                    position: Int,
                    convertView: View?,
                    parent: ViewGroup
                ): View {
                    val view: TextView =
                        super.getDropDownView(position, convertView, parent) as TextView
                    //set the color of first item in the drop down list to gray
                    if (position == 0) {
                        view.setTextColor(Color.GRAY)
                    } else {
                        //here is it possible to define color for other items by
                        //view.setTextColor(Color.RED)
                    }
                    return view
                }

            }

        spinnerAdapter.setDropDownViewResource(R.layout.item_spinner_text)
        spnNationality.adapter = spinnerAdapter
    }

    fun setSpinner(spnType2: Spinner, strList: List<String?>?) {
        val dataAdapter: ArrayAdapter<String?> = object : ArrayAdapter<String?>(
            this,
            R.layout.item_spinner_text, strList!!
        ) {
            override fun isEnabled(position: Int): Boolean {
                return if (position == 0) {
                    false
                } else {
                    true
                }
            }

            override fun getDropDownView(
                position: Int,
                convertView: View,
                parent: ViewGroup
            ): View {
                val view = super.getDropDownView(position, convertView, parent)
                val textview = view as TextView
                if (position == 0) {
                    textview.setTextColor(resources.getColor(R.color.grayText))
                } else {
                    textview.setTextColor(Color.BLACK)
                }
                return view
            }
        }
        spnType2.adapter = dataAdapter
    }

    fun setSpinnerSelection(parent: AdapterView<*>?, view: View?, position: Int) {

        /*  if (position > 0) {
                Toast.makeText(getApplicationContext(), "Selected:" + selectedItemText, Toast.LENGTH_SHORT).show();
            }*/
        try {
            val textview = view as TextView?
            if (textview != null) {
                if (position == 0) {
                    textview.setTextColor(resources.getColor(R.color.grayText))
                } else {
                    textview.setTextColor(Color.BLACK)
                }
            }
        } catch (e: Exception) {

        }
    }


    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.ivBack -> {
                finish()
            }
            R.id.btnSubmit -> {

                if ((etFirstName.text.toString()).equals("")) {
                    etFirstName.error = resources.getString(R.string.lbl_required)
                } else if ((etLastName.text.toString()).equals("")) {
                    etLastName.error = resources.getString(R.string.lbl_required)
                } else {

                    if (!cbAA.isChecked) {
                        if (spnNationality.selectedItemPosition <= 0) {
                            showToast(resources.getString(R.string.msg_choose_nationality))
                            return
                        }
                    }

                    var intent = Intent(this, OTPcodeVerifyActivity::class.java);
                    startActivity(intent);
                }
            }
            R.id.btnYes -> {
                llSupportSocial.visibility = GONE
                btnSubmit.visibility = VISIBLE
            }
            R.id.btnNo -> {
                llSupportSocial.visibility = GONE
                btnSubmit.visibility = VISIBLE
            }
        }
    }

    override fun onCheckedChanged(p0: CompoundButton?, p1: Boolean) {

        if (p1) {
            rlNationality.visibility = GONE
        } else {
            rlNationality.visibility = VISIBLE

        }
    }


}