package com.app.hbcu.model.notification

import com.google.gson.annotations.SerializedName

data class NotificationResponse(

    @field:SerializedName("data")
    val data: Data? = null,

    @field:SerializedName("message")
    val message: Message? = null,

    @field:SerializedName("status")
    val status: String? = null
)

data class Message(

    @field:SerializedName("success")
    val success: String? = null
)

data class Data(

    @field:SerializedName("notification")
    val notification: List<NotificationItem?>? = null,

    @field:SerializedName("total")
    val total: Int? = null,

    @field:SerializedName("last_page")
    val lastPage: Int? = null,

    @field:SerializedName("page")
    val page: Int? = null
)

data class NotificationItem(

    @field:SerializedName("id")
    val id: String? = null,

    @field:SerializedName("title")
    val title: String? = null,

    @field:SerializedName("message")
    val message: String? = null,

    @field:SerializedName("created_at")
    val created_at: String? = null,


)
