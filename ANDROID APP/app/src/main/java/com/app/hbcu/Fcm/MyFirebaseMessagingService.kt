package com.app.hbcu.Fcm

import android.app.ActivityManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.text.Html
import android.util.Log
import androidx.core.app.NotificationCompat
import com.app.hbcu.R
import com.app.hbcu.activity.SplashActivity
import com.app.hbcu.util.Config
import com.app.hbcu.util.Pref
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage
import java.io.IOException
import java.net.URL
import java.util.*
import javax.net.ssl.HttpsURLConnection

/*MyFirebaseMessagingService onMessageReceived
2021-05-29 18:07:04.466 29140-29620/com.app.hbcu E/FCMPlugin: ==> 6
2021-05-29 18:07:04.466 29140-29620/com.app.hbcu E/FCMPlugin: ==> com.google.firebase.messaging.RemoteMessage@a66483b
2021-05-29 18:07:04.467 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: priority Value: high
2021-05-29 18:07:04.467 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: body Value: Testing Manish
2021-05-29 18:07:04.467 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: sound Value: notification_ring_tone
2021-05-29 18:07:04.467 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: title Value: Testing Manish
2021-05-29 18:07:04.467 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: click_action Value: FLUTTER_NOTIFICATION_CLICK
2021-05-29 18:07:04.468 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: content_available Value: true
2021-05-29 18:07:04.473 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: priority Value: high
2021-05-29 18:07:04.474 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: body Value: Testing Manish
2021-05-29 18:07:04.474 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: sound Value: notification_ring_tone
2021-05-29 18:07:04.474 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: title Value: Testing Manish
2021-05-29 18:07:04.474 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: click_action Value: FLUTTER_NOTIFICATION_CLICK
2021-05-29 18:07:04.474 29140-29620/com.app.hbcu E/FCMPlugin: 	Key: content_available Value: true*/
class MyFirebaseMessagingService : FirebaseMessagingService() {
    override fun onNewToken(s: String) {
        super.onNewToken(s)
        Pref.setStringValue(getBaseContext(), Config.PREF_FCM_TOKEN, s)
        Log.e("MessagingService", s + "")


    }

    override fun onMessageReceived(remoteMessage: RemoteMessage) {


        Log.e(TAG, "==> MyFirebaseMessagingService onMessageReceived")
        Log.e(TAG, "==> " + remoteMessage.getData().size)
        Log.e(TAG, "==> $remoteMessage")
        val data: MutableMap<String, Any> = HashMap()
        data["wasTapped"] = false
        for (key in remoteMessage.getData().keys) {
            val value: Any? = remoteMessage.getData().get(key)
            Log.e(TAG, "\tKey: $key Value: $value")
            data[key] = value!!
        }
        if (remoteMessage.getNotification() != null) {

            sendNotification(
                remoteMessage.getNotification()!!.getTitle(),
                remoteMessage.getNotification()!!.getBody(),
                data,
                remoteMessage
            )
        } else {
            sendNotification(
                remoteMessage.getData().get("title"),
                remoteMessage.getData().get("body"),
                data,
                remoteMessage
            )
        }


    }

    /**
     * Create and show a simple notification containing the received FCM message.
     *
     * @param messageBodys FCM message body received.
     */
    private fun sendNotification(
        title: String?,
        messageBodys: String?,
        data: Map<String, Any>,
        rm: RemoteMessage
    ) {
        val random = Random().nextInt(61) + 20
        var notificationType = ""
        var orderType = ""
        var orderID = ""
        var image = ""
        try {
            //uid = data.get("userFromId");

            //  JSONObject jsonObject = new JSONObject(messageBodys);
            image = data["image"].toString()
        } catch (e: Exception) {
        }
        for (key in rm.getData().keys) {
            val value: Any = rm.getData().get(key)!!
            Log.e(TAG, "\tKey: $key Value: $value")
            if ((key + "").equals("notificationType", ignoreCase = true)) {
                notificationType = value.toString() + ""
            }
            if ((key + "").equals("orderType", ignoreCase = true)) {
                orderType = value.toString() + ""
            }
            if ((key + "").equals("orderID", ignoreCase = true)) {
                orderID = value.toString() + ""
            }
        }
        var intent = Intent(this, SplashActivity::class.java)

        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        /*for (String key : data.keySet()) {
            intent.putExtra(key, data.get(key).toString());
        }*/
        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            this, random /* Request code */, intent,
            PendingIntent.FLAG_ONE_SHOT
        )
        if ((image + "").equals("", ignoreCase = true) || (image + "").equals(
                "null",
                ignoreCase = true
            )
        ) {
            showSmallNotification(pendingIntent, messageBodys, title, random)
        } else {
            val bitmap: Bitmap? = getBitmapFromURL(image)
            showBigNotification(bitmap, pendingIntent, messageBodys!!, title!!, image, random)
        }
    }

    private fun sendChatNotification(title: String, messageBodys: String, data: Map<String, Any>) {
        var random = Random().nextInt(61) + 20
        val uid = ""
        var image = ""
        try {
            //uid = data.get("userFromId");
            // JSONObject jsonObject = new JSONObject(messageBodys);
            image = data["image"].toString()
        } catch (e: Exception) {
        }
        try {
            val nId = data["conversationId"].toString().toInt()
            random = nId + 0
        } catch (e: Exception) {
        }
        val intent = Intent(this, SplashActivity::class.java)
        intent.putExtra("conversationID", data["conversationId"].toString() + "")
        intent.putExtra("rName", data["senderName"].toString() + "")
        intent.putExtra("rPhoto", data["senderProfile"].toString() + "")
        intent.putExtra("rToken", data["fcmToken"].toString() + "")
        intent.putExtra("rId", data["senderId"].toString() + "")
        intent.addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
        val pendingIntent: PendingIntent = PendingIntent.getActivity(
            this, random /* Request code */, intent,
            PendingIntent.FLAG_ONE_SHOT
        )
        if ((image + "").equals("", ignoreCase = true)) {
            showSmallNotification(pendingIntent, messageBodys, title, random)
        } else {
            val bitmap: Bitmap? = getBitmapFromURL(image)
            showBigNotification(bitmap, pendingIntent, messageBodys, title, image, random)
        }
    }

    private fun showSmallNotification(
        pendingIntent: PendingIntent?,
        myreciveMsg: String?,
        title: String?,
        notifId: Int?
    ) {


//        int random = new Random().nextInt(61) + 20;
        val defaultSoundUri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val notificationManager: NotificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "channel-01"
        val channelName = "Cable"
        val importance: Int = NotificationManager.IMPORTANCE_HIGH
        val notificationBuilder: NotificationCompat.Builder
        var soundU: Uri
        notificationBuilder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mChannel = NotificationChannel(
                channelId, channelName, importance
            )
            notificationManager.createNotificationChannel(mChannel)
            NotificationCompat.Builder(this, channelId)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title) //.setContentText(myreciveMsg)
                .setAutoCancel(true) //   .setSound(soundU)
                .setStyle(NotificationCompat.BigTextStyle().bigText(myreciveMsg))
                .setContentIntent(pendingIntent)
        } else {
            NotificationCompat.Builder(this).setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title) //.setContentText(myreciveMsg)
                .setAutoCancel(true) // .setSound(soundU)
                .setStyle(NotificationCompat.BigTextStyle().bigText(myreciveMsg))
                .setContentIntent(pendingIntent)
        }
        notificationManager.notify(notifId!! /* ID of notification */, notificationBuilder.build())
    }

    private fun showBigNotification(
        bitmap: Bitmap?,
        pendingIntent: PendingIntent,
        myreciveMsg: String,
        title: String,
        image: String,
        notifId: Int
    ) {
        val defaultSoundUri: Uri = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val notificationManager: NotificationManager =
            getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channelId = "channel-01"
        val channelName = "Cable"
        val importance: Int = NotificationManager.IMPORTANCE_HIGH
        val notificationBuilder: NotificationCompat.Builder
        var soundU: Uri
        val bigPictureStyle: NotificationCompat.BigPictureStyle =
            NotificationCompat.BigPictureStyle()
        bigPictureStyle.setBigContentTitle(title)
        bigPictureStyle.setSummaryText(Html.fromHtml(myreciveMsg).toString())
        bigPictureStyle.bigPicture(bitmap)
        notificationBuilder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val mChannel = NotificationChannel(
                channelId, channelName, importance
            )
            notificationManager.createNotificationChannel(mChannel)
            NotificationCompat.Builder(this, channelId)
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(myreciveMsg)
                .setAutoCancel(true)
                .setStyle(bigPictureStyle) //   .setSound(soundU)
                .setContentIntent(pendingIntent)
        } else {
            NotificationCompat.Builder(this).setSmallIcon(R.mipmap.ic_launcher)
                .setContentTitle(title)
                .setContentText(myreciveMsg)
                .setAutoCancel(true)
                .setStyle(bigPictureStyle) // .setSound(soundU)
                .setContentIntent(pendingIntent)
        }
        notificationManager.notify(notifId /* ID of notification */, notificationBuilder.build())
    }

    fun getBitmapFromURL(strURL: String?): Bitmap? {
        return try {
            val url = URL(strURL)
            //  HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            val connection =
                url.openConnection() as HttpsURLConnection
            connection.doInput = true
            connection.connect()
            val input = connection.inputStream
            BitmapFactory.decodeStream(input)
        } catch (e: IOException) {
            e.printStackTrace()
            null
        }
    }

    companion object {
        //APPROVED ORDER
        private const val TAG = "FCMPlugin"
        fun isAppIsInBackground(context: Context): Boolean {
            var isInBackground = true
            val am: ActivityManager =
                context.getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            if (Build.VERSION.SDK_INT > Build.VERSION_CODES.KITKAT_WATCH) {
                val runningProcesses: List<ActivityManager.RunningAppProcessInfo> =
                    am.getRunningAppProcesses()
                for (processInfo in runningProcesses) {
                    if (processInfo.importance == ActivityManager.RunningAppProcessInfo.IMPORTANCE_FOREGROUND) {
                        for (activeProcess in processInfo.pkgList) {
                            if (activeProcess == context.packageName) {
                                isInBackground = false
                            }
                        }
                    }
                }
            } else {
                val taskInfo: List<ActivityManager.RunningTaskInfo> = am.getRunningTasks(1)
                val componentInfo: ComponentName = taskInfo[0].topActivity!!
                if (componentInfo.getPackageName() == context.packageName) {
                    isInBackground = false
                }
            }
            return isInBackground
        }

        fun showDownloadNotification(
            context: Context,
            pendingIntent: PendingIntent?,
            myreciveMsg: String?,
            title: String?,
            notifId: Int
        ) {

            //Log.e("n?ID", notifId + "");
            val defaultSoundUri: Uri =
                RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
            val notificationManager: NotificationManager =
                context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            val channelId = "channel-02"
            val channelName = "csvDownload"
            val importance: Int = NotificationManager.IMPORTANCE_HIGH
            val notificationBuilder: NotificationCompat.Builder
            var soundU: Uri
            notificationBuilder = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                val mChannel = NotificationChannel(
                    channelId, channelName, importance
                )
                notificationManager.createNotificationChannel(mChannel)
                NotificationCompat.Builder(context, channelId)
                    .setSmallIcon(R.mipmap.ic_launcher)
                    .setContentTitle(title)
                    .setAutoCancel(true)
                    .setStyle(NotificationCompat.BigTextStyle().bigText(myreciveMsg))
                    .setDefaults(NotificationCompat.DEFAULT_ALL)
                    .setContentIntent(pendingIntent)
            } else {
                NotificationCompat.Builder(context).setSmallIcon(R.mipmap.ic_launcher)
                    .setContentTitle(title)
                    .setAutoCancel(true)
                    .setStyle(NotificationCompat.BigTextStyle().bigText(myreciveMsg))
                    .setPriority(NotificationCompat.PRIORITY_HIGH)
                    .setDefaults(NotificationCompat.DEFAULT_ALL)
                    .setContentIntent(pendingIntent)
            }
            notificationManager.notify(
                notifId /* ID of notification */,
                notificationBuilder.build()
            )
        }
    }
}