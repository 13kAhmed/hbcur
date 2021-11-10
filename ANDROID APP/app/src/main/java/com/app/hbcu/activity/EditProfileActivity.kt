package com.app.hbcu.activity

import android.Manifest
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.os.Environment
import android.provider.MediaStore
import android.util.Log
import android.view.View
import android.widget.*
import androidx.core.app.ActivityCompat
import com.app.hbcu.R
import com.app.hbcu.model.user.UserLoginResponse
import com.app.hbcu.retrofit.ApiClient
import com.app.hbcu.retrofit.ApiInterface
import com.app.hbcu.util.AppUtils
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import com.bumptech.glide.Glide
import com.bumptech.glide.load.engine.DiskCacheStrategy
import com.esafirm.imagepicker.features.*
import com.esafirm.imagepicker.model.Image
import de.hdodenhof.circleimageview.CircleImageView
import okhttp3.MediaType
import okhttp3.MultipartBody
import okhttp3.RequestBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response
import java.io.File
import java.util.*
import kotlin.collections.HashMap

class EditProfileActivity : BaseAppCompatActivity(), View.OnClickListener {
    val REQUEST_PERMISSIONS_CODE_STORAGE = 121

    lateinit var etFirstName: EditText
    lateinit var etLastName: EditText
    lateinit var ivProfilePic: CircleImageView
    lateinit var rlPic: RelativeLayout

    lateinit var btnSubmit: Button

    lateinit var ivBack: ImageView
    lateinit var flProgress: FrameLayout
    var imagepath: String = ""
    private val images = arrayListOf<Image>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_edit_profile)

        init();
        getProfile()
    }

    private fun init() {

        etLastName = findViewById(R.id.etLastName)
        etFirstName = findViewById(R.id.etFirstName)
        flProgress = findViewById(R.id.flProgress)
        ivProfilePic = findViewById(R.id.ivProfilePic)
        rlPic = findViewById(R.id.rlPic)


        btnSubmit = findViewById(R.id.btnSubmit)

        ivBack = findViewById(R.id.ivBack)

        btnSubmit.setOnClickListener(this)
        ivBack.setOnClickListener(this)
        rlPic.setOnClickListener(this)

        if (Pref.getUserLoginData(this).firstName != null) {
            etFirstName.setText(Pref.getUserLoginData(this).firstName + "")
        }

        if (Pref.getUserLoginData(this).lastName != null) {
            etLastName.setText(Pref.getUserLoginData(this).lastName + "")
        }

        if (!(Pref.getUserLoginData(this)?.avtar + "").equals("")) {
            Glide.with(this).load(Pref.getUserLoginData(this)!!.avtar)
                .centerCrop()
                .placeholder(R.drawable.ic_user_placeholder).error(R.drawable.ic_user_placeholder)
                .diskCacheStrategy(
                    DiskCacheStrategy.NONE
                )
                .into(ivProfilePic)
        }
        //    checkPermision()

    }


    fun checkPermision() {
        if (!AppUtils.CheckStorageREADPermission(this)) {
            val listPermissionsNeeded: MutableList<String> = ArrayList()
            listPermissionsNeeded.add(Manifest.permission.READ_EXTERNAL_STORAGE)
            ActivityCompat.requestPermissions(
                this,
                listPermissionsNeeded.toTypedArray(),
                REQUEST_PERMISSIONS_CODE_STORAGE
            )
            return
        }
    }

    private val imagePickerLauncher = registerImagePicker {
        images.clear()
        images.addAll(it)
        if (images.size > 0) {
            Log.e("IMG", images.get(0).path)
            //if ((Build.VERSION.SDK_INT < Build.VERSION_CODES.Q)) {
            Glide.with(this).load(Uri.fromFile(File(images.get(0).path)))
                .placeholder(R.drawable.ic_user_placeholder)
                .error(R.drawable.ic_user_placeholder)
                .into(ivProfilePic)
            //  }


        }
    }

    fun getPath(uri: Uri?): String? {
        val projection = arrayOf(MediaStore.Images.Media.DATA)
        val cursor = managedQuery(uri, projection, null, null, null)
        startManagingCursor(cursor)
        val column_index = cursor.getColumnIndexOrThrow(MediaStore.Images.Media.DATA)
        cursor.moveToFirst()
        return cursor.getString(column_index)
    }

    override fun onClick(p0: View?) {
        when (p0?.id) {
            R.id.ivBack -> {
                finish()
            }
            R.id.rlPic -> {
                imagePickerLauncher.launch(createConfig())
                // openImageSelection()
            }
            R.id.btnSubmit -> {

                if ((etFirstName.text.toString().trim()).equals("")) {
                    etFirstName.error = resources.getString(R.string.lbl_required)
                } else if ((etLastName.text.toString().trim()).equals("")) {
                    etLastName.error = resources.getString(R.string.lbl_required)
                } else {

                    updateProfile()
                }
            }

        }
    }

    private fun createConfig(): ImagePickerConfig {
        val returnAfterCapture = true
        val isSingleMode = true
        val useCustomImageLoader = false
        val folderMode = true
        val includeVideo = false
        val onlyVideo = false
        val isExclude = false

        /*       ImagePickerComponentsHolder.setInternalComponent(
                   CustomImagePickerComponents(this, useCustomImageLoader)
               )*/

        return ImagePickerConfig {

            mode = if (isSingleMode) {
                ImagePickerMode.SINGLE
            } else {
                ImagePickerMode.MULTIPLE // multi mode (default mode)
            }

            language = "in" // Set image picker language
            theme = R.style.ImagePickerTheme

            // set whether pick action or camera action should return immediate result or not. Only works in single mode for image picker
            returnMode = if (returnAfterCapture) ReturnMode.ALL else ReturnMode.NONE

            isFolderMode = folderMode // set folder mode (false by default)
            isIncludeVideo = includeVideo // include video (false by default)
            isOnlyVideo = onlyVideo // include video (false by default)
            arrowColor = Color.RED // set toolbar arrow up color
            folderTitle = "Folder" // folder selection title
            imageTitle = "Tap to select" // image selection title
            doneButtonText = "DONE" // done button text
            showDoneButtonAlways = true // Show done button always or not
            limit = 1 // max images can be selected (99 by default)
            isShowCamera = true // show camera or not (true by default)
            /* savePath =
                 ImagePickerSavePath("Camera") */// captured image directory name ("Camera" folder by default)
            savePath = ImagePickerSavePath(
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DCIM).toString(),
                // filesDir.path,
                // Environment.getExternalStorageDirectory().path,
                isRelative = false
            ) // can be a full path
            if (isExclude) {
                excludedImages = images.toFiles() // don't show anything on this selected images
            } else {
                selectedImages = images  // original selected images, used in multi mode
            }
        }
    }

    private fun openImageSelection() {
        //  checkPermision()
        /*   ImagePicker.create(this)
               .returnMode(ReturnMode.ALL) // set whether pick and / or camera action should return immediate result or not.
               .folderMode(true) // folder mode (false by default)
               .toolbarFolderTitle("Folder") // folder selection title
               .toolbarImageTitle("Tap to select") // image selection title
               .toolbarArrowColor(resources.getColor(R.color.white)) // Toolbar 'up' arrow color
               .includeVideo(false) // Show video on image picker
               .single() // single mode
               //.multi() // multi mode (default mode)
               .limit(1) // max images can be selected (99 by default)
               .showCamera(true) // show camera or not (true by default)
               .imageDirectory("Camera") // directory name for captured image  ("Camera" folder by default)
               //.origin(images) // original selected images, used in multi mode
               //.exclude(images) // exclude anything that in image.getPath()
               //.excludeFiles(files) // same as exclude but using ArrayList<File>
               // .theme(R.style.CustomImagePickerTheme) // must inherit ef_BaseTheme. please refer to sample
               .enableLog(false) // disabling log
               .start()*/
    }


    private fun getProfile() {
        if (!isConnectedToInternet) {
            return
        }

        var uid: String? = Pref.getStringValue(this, Config.PREF_UID, "")

        flProgress.visibility = View.VISIBLE

        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<UserLoginResponse> = service.getProfile(AppUtils.getAuthToken(this), uid!!)

        call.enqueue(object : Callback<UserLoginResponse> {
            override fun onResponse(
                call: Call<UserLoginResponse>,
                response: Response<UserLoginResponse>
            ) {
                flProgress.visibility = View.GONE

                if (response.isSuccessful) {

                    if (response.body()!!.status!!.equals("200")) {


                        Pref.setUserLoginData(
                            this@EditProfileActivity,
                            response.body()!!.data!!.user
                        )
                        etFirstName.setText(response.body()!!.data!!.user!!.firstName)
                        etLastName.setText(response.body()!!.data!!.user!!.lastName)
                        Glide.with(this@EditProfileActivity)
                            .load(Pref.getUserLoginData(this@EditProfileActivity)!!.avtar)
                            .centerCrop()
                            .placeholder(R.drawable.ic_user_placeholder)
                            .error(R.drawable.ic_user_placeholder).diskCacheStrategy(
                                DiskCacheStrategy.NONE
                            )
                            .into(ivProfilePic)
                    }

                }

            }

            override fun onFailure(call: Call<UserLoginResponse>, t: Throwable) {

                showToast(resources.getString(R.string.msg_somthing_wrong))
                flProgress.visibility = View.GONE
            }
        })

    }

    private fun updateProfile() {

        if (!isConnectedToInternet) {
            return
        }

        var token: String? = Pref.getStringValue(this, Config.PREF_FCM_TOKEN, "-")

        flProgress.visibility = View.VISIBLE

        imagepath = "";
        if (images.size > 0) {
            imagepath = images.get(0).path
        }
        var imagePerfil: MultipartBody.Part? = null
        val output = File(imagepath)
        if (output != null && output.exists()) {

            val requestFile = RequestBody.create(MediaType.parse("multipart/form-data"), output)
            // MultipartBody.Part is used to send also the actual file name
            // MultipartBody.Part is used to send also the actual file name
            imagePerfil = MultipartBody.Part.createFormData("avtar", output.name, requestFile)
        }


        val requestUserId: RequestBody = RequestBody.create(
            MediaType.parse("multipart/form-data"), Pref.getStringValue(this, Config.PREF_UID, "")!!
        )

        val requestfName: RequestBody = RequestBody.create(
            MediaType.parse("multipart/form-data"), etFirstName.text.toString()
        )
        val requestlName: RequestBody = RequestBody.create(
            MediaType.parse("multipart/form-data"), etLastName.text.toString()
        )
        /* val userid: RequestBody = RequestBody.create(
             MediaType.parse("text/plain"),
             AZUtils.getUserId(this)
         )*/
        val params: HashMap<String, String> = HashMap()
        params.put("user_id", Pref.getStringValue(this, Config.PREF_UID, "")!!)
        params.put("first_name", etFirstName.text.toString())
        params.put("last_name", etLastName.text.toString())

        val service = ApiClient.client.create(ApiInterface::class.java)
        val call: Call<UserLoginResponse> =
            service.updateProfile(
                AppUtils.getAuthToken(this), requestUserId,
                requestfName, requestlName, imagePerfil
            )


        call!!.enqueue(object : Callback<UserLoginResponse> {
            override fun onResponse(
                call: Call<UserLoginResponse>,
                response: Response<UserLoginResponse>
            ) {
                flProgress.visibility = View.GONE

                if (response.isSuccessful) {

                    if (response.body()!!.status!!.equals("200")) {

                        showToast(response.body()!!.message!!.success)
                        Pref.setUserLoginData(
                            this@EditProfileActivity,
                            response.body()!!.data!!.user
                        )

                        finish()

                    } else {
                        showToast(response.body()!!.message!!.success)
                    }

                } else {

                    showToast(resources.getString(R.string.msg_somthing_wrong))

                }

            }

            override fun onFailure(call: Call<UserLoginResponse>, t: Throwable) {

                showToast(resources.getString(R.string.msg_somthing_wrong))
                flProgress.visibility = View.GONE
            }
        })

    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        /*if (ImagePicker.shouldHandle(requestCode, resultCode, data)) {
            // Get a list of picked images
            //List<Image> images = ImagePicker.getImages(data);
            // or get a single image only
            val image = ImagePicker.getFirstImageOrNull(data)
            imagepath = image.path
            Glide.with(this).load(Uri.fromFile(File(image.path)))
                .placeholder(R.drawable.ic_user_placeholder).error(R.drawable.ic_user_placeholder)
                .into(ivProfilePic)
        }*/
    }
}