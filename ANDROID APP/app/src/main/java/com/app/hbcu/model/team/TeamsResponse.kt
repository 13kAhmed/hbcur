package com.app.hbcu.model.team

import com.google.gson.annotations.SerializedName

data class TeamsResponse(

    @field:SerializedName("data")
    val data: Data? = null,

    @field:SerializedName("message")
    val message: Message? = null,

    @field:SerializedName("status")
    val status: String? = null
)

data class TeamsItem(

    @field:SerializedName("mobile")
    val mobile: String? = null,

    @field:SerializedName("last_name")
    val lastName: String? = null,

    @field:SerializedName("id")
    val id: Int? = null,

    @field:SerializedName("first_name")
    val firstName: String? = null,

    @field:SerializedName("username")
    val username: String? = null,

    @field:SerializedName("avtar")
    val avtar: String? = null
)

data class Message(

    @field:SerializedName("success")
    val success: String? = null
)

data class Data(

    @field:SerializedName("total")
    val total: Int? = null,

    @field:SerializedName("teams")
    val teams: List<TeamsItem?>? = null,

    @field:SerializedName("parent")
    val parent: List<TeamsItem?>? = null,

    @field:SerializedName("last_page")
    val lastPage: Int? = null,

    @field:SerializedName("page")
    val page: Int? = null
)
