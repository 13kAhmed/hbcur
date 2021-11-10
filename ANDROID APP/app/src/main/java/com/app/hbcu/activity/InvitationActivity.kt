package com.app.hbcu.activity

import android.content.ClipData
import android.content.ClipboardManager
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.text.*
import android.text.method.LinkMovementMethod
import android.text.style.ClickableSpan
import android.view.View
import android.widget.Button
import android.widget.ImageView
import android.widget.TextView
import com.app.hbcu.R
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref


class InvitationActivity : BaseAppCompatActivity(), View.OnClickListener {
    lateinit var btnContact: Button
    lateinit var btnShare: Button
    lateinit var ivBack: ImageView
    lateinit var ivCopy: ImageView
    lateinit var tvCode: TextView
    lateinit var tvPrivacy: TextView
    var shareText: String = "";

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_invitation)

        shareText =
            resources.getString(R.string.lbl_here_my_invitation_link) +
                    " " + Pref.getUserLoginData(this).invitationCode + "\nDownload at " + Config.URL_DOWNLOAD_LINK

        init()
    }

    private fun init() {
        btnContact = findViewById(R.id.btnContact)
        ivBack = findViewById(R.id.ivBack)
        ivCopy = findViewById(R.id.ivCopy)
        tvCode = findViewById(R.id.tvCode)
        btnShare = findViewById(R.id.btnShare)
        tvPrivacy = findViewById(R.id.tvPrivacy)

        btnContact.setOnClickListener(this)
        ivBack.setOnClickListener(this)
        ivCopy.setOnClickListener(this)
        btnShare.setOnClickListener(this)

        tvCode.setText(Pref.getUserLoginData(this).invitationCode)


        tvPrivacy.makeLinks(
            Pair("Terms of Service", View.OnClickListener {
                // Toast.makeText(applicationContext, "Terms of Service", Toast.LENGTH_SHORT).show()
                var intent = Intent(this, WebActivity::class.java)
                intent.putExtra("urlWeb", Config.URL_TERMS_SERVICE + "")
                intent.putExtra("title", "Terms of Service")
                startActivity(intent)
            }),
            Pair("Privacy Policy", View.OnClickListener {
                // Toast.makeText(applicationContext, "Privacy Policy", Toast.LENGTH_SHORT).show()
                var intent = Intent(this, WebActivity::class.java)
                intent.putExtra("urlWeb", Config.URL_PRIVACY_POLICY + "")
                intent.putExtra("title", "Privacy Policy")
                startActivity(intent)
            })
        )

    }

    fun TextView.makeLinks(vararg links: Pair<String, View.OnClickListener>) {
        val spannableString = SpannableString(this.text)
        var startIndexOfLink = -1
        for (link in links) {
            val clickableSpan = object : ClickableSpan() {
                override fun updateDrawState(textPaint: TextPaint) {
                    // use this to change the link color
                    textPaint.color = textPaint.linkColor
                    // toggle below value to enable/disable
                    // the underline shown below the clickable text
                    textPaint.isUnderlineText = true
                }

                override fun onClick(view: View) {
                    Selection.setSelection((view as TextView).text as Spannable, 0)
                    view.invalidate()
                    link.second.onClick(view)
                }
            }
            startIndexOfLink = this.text.toString().indexOf(link.first, startIndexOfLink + 1)
//      if(startIndexOfLink == -1) continue // todo if you want to verify your texts contains links text
            spannableString.setSpan(
                clickableSpan, startIndexOfLink, startIndexOfLink + link.first.length,
                Spanned.SPAN_EXCLUSIVE_EXCLUSIVE
            )
        }
        this.movementMethod =
            LinkMovementMethod.getInstance() // without LinkMovementMethod, link can not click
        this.setText(spannableString, TextView.BufferType.SPANNABLE)
    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.btnSubmit -> {
                val shareIntent = Intent()
                shareIntent.action = Intent.ACTION_SEND
                shareIntent.type = "text/plain"
                shareIntent.putExtra(
                    Intent.EXTRA_TEXT, shareText
                );
                startActivity(Intent.createChooser(shareIntent, getString(R.string.lbl_share)))
            }
            R.id.ivCopy -> {
                var clipboard = getSystemService(Context.CLIPBOARD_SERVICE) as ClipboardManager
                var clip = ClipData.newPlainText("label", tvCode.text.toString())
                clipboard.setPrimaryClip(clip)

                showToast(getString(R.string.lbl_copid_success))

            }
            R.id.btnShare -> {

                val shareIntent = Intent()
                shareIntent.action = Intent.ACTION_SEND
                shareIntent.type = "text/plain"
                shareIntent.putExtra(
                    Intent.EXTRA_TEXT,shareText
                );
                startActivity(Intent.createChooser(shareIntent, getString(R.string.lbl_share)))

            }
            R.id.btnContact -> {
                var intent = Intent(this, ContactListInviteActivity::class.java)
                startActivity(intent)
            }
            R.id.ivBack -> {
                finish()
            }
        }
    }
}