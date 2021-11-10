package com.app.hbcu.model.mining

import com.google.gson.annotations.SerializedName

data class MiningResponse(

    @field:SerializedName("data")
    val data: Data? = null,

    @field:SerializedName("message")
    val message: Message? = null,

    @field:SerializedName("status")
    val status: String? = null
)

data class Mining(

    @field:SerializedName("start_time")
    val startTime: String? = null,

    @field:SerializedName("total_amount")
    val totalAmount: Double? = null,

    @field:SerializedName("rate")
    val rate: Double? = null,

    @field:SerializedName("user_rate")
    val user_rate: Double? = null,

    @field:SerializedName("parent_rate")
    val parent_rate: Double? = null,

    @field:SerializedName("commi_in_per")
    val commi_in_per: Double? = null,

    @field:SerializedName("admin_balanced")
    val admin_balanced: Double? = null,

    @field:SerializedName("id")
    val id: Int? = null,

    @field:SerializedName("status")
    val status: String? = null,

    @field:SerializedName("spent_time")
    val spent_time: String? = null
)

data class Message(

    @field:SerializedName("success")
    val success: String? = null,

    @field:SerializedName("error")
    val error: String? = null
)

data class Data(
    @field:SerializedName("total_active_mining")
    val total_active_mining: Int? = null,

    @field:SerializedName("total_inactive_mining")
    val total_inactive_mining: Int? = null,

    @field:SerializedName("total_invited")
    val total_invited: Int? = null,

    @field:SerializedName("total_team_member")
    val total_team_member: Int? = null,

    @field:SerializedName("avail_balance")
    val availBalance: Double? = null,

    @field:SerializedName("mining")
    val mining: Mining? = null
)
