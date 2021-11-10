package com.app.hbcu.model.ranking

import com.google.gson.annotations.SerializedName

data class RankingResponse(

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

	@field:SerializedName("total")
	val total: Int? = null,

	@field:SerializedName("last_page")
	val lastPage: Int? = null,

	@field:SerializedName("ranking")
	val ranking: List<RankingItem?>? = null,

	@field:SerializedName("page")
	val page: String? = null
)

data class RankingItem(

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

	@field:SerializedName("fullname")
	val fullname: String? = null,

	@field:SerializedName("available_balance")
	val availableBalance: Double? = null,

	@field:SerializedName("first_name")
	val firstName: String? = null,

	@field:SerializedName("avtar")
	val avtar: String? = null,

	@field:SerializedName("username")
	val username: String? = null,

	@field:SerializedName("is_african_american")
	val isAfricanAmerican: String? = null
)
