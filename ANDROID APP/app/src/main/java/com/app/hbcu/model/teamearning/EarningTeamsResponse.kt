package com.app.hbcu.model.teamearning

import com.google.gson.annotations.SerializedName

data class EarningTeamsResponse(

    @field:SerializedName("data")
    val data: Data? = null,

    @field:SerializedName("message")
    val message: Message? = null,

    @field:SerializedName("status")
    val status: String? = null
)

data class Data(

    @field:SerializedName("total_earning")
    val totalEarning: Double? = null,

    @field:SerializedName("total_active_mining")
    val totalActiveMining: Int? = null,

    @field:SerializedName("total_team_member")
    val totalTeamMember: Int? = null,

    @field:SerializedName("total_invited")
    val totalInvited: Int? = null,

    @field:SerializedName("parent_user")
    val parentUser: List<ParentUser?>? = null,

    )

data class Message(

    @field:SerializedName("success")
    val success: String? = null
)

data class ParentUser(

    @field:SerializedName("invitation_code")
    val invitationCode: String? = null,

    @field:SerializedName("nationality")
    val nationality: String? = null,

    @field:SerializedName("parent_id")
    val parentId: Int? = null,

    @field:SerializedName("last_name")
    val lastName: String? = null,

    @field:SerializedName("id")
    val id: Int? = null,

    @field:SerializedName("is_start_mining")
    val isStartMining: Int? = null,

    @field:SerializedName("first_name")
    val firstName: String? = null,

    @field:SerializedName("avtar")
    val avtar: String? = null,

    @field:SerializedName("username")
    val username: String? = null,

    @field:SerializedName("is_african_american")
    val isAfricanAmerican: String? = null
)
