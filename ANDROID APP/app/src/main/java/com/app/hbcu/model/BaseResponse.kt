package com.app.hbcu.model

import com.google.gson.annotations.SerializedName

data class BaseResponse(


    @field:SerializedName("message")
    val message: Message? = null,

    @field:SerializedName("status")
    val status: String? = null
)


data class Message(
    @field:SerializedName("error")
    val error: String? = null,

    @field:SerializedName("success")
    val success: String? = null
)


