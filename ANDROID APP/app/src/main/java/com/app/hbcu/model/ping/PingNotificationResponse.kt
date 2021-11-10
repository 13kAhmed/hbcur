package com.app.hbcu.model.ping

import com.google.gson.annotations.SerializedName

data class PingNotificationResponse(

	@field:SerializedName("data")
	val data: Data? = null,

	@field:SerializedName("message")
	val message: Message? = null,

	@field:SerializedName("status")
	val status: String? = null
)

data class Data(

	@field:SerializedName("Notification")
	val notification: Notification? = null
)

data class Message(

	@field:SerializedName("success")
	val success: String? = null
)

data class Notification(

	@field:SerializedName("invitation_code")
	val invitationCode: String? = null,

	@field:SerializedName("mobile")
	val mobile: String? = null,

	@field:SerializedName("last_name")
	val lastName: String? = null,

	@field:SerializedName("created_at")
	val createdAt: String? = null,

	@field:SerializedName("is_suspend")
	val isSuspend: String? = null,

	@field:SerializedName("signup_type")
	val signupType: String? = null,

	@field:SerializedName("country_code")
	val countryCode: String? = null,

	@field:SerializedName("nationality")
	val nationality: String? = null,

	@field:SerializedName("updated_at")
	val updatedAt: String? = null,

	@field:SerializedName("parent_id")
	val parentId: Int? = null,

	@field:SerializedName("id")
	val id: Int? = null,

	@field:SerializedName("first_name")
	val firstName: String? = null,

	@field:SerializedName("avtar")
	val avtar: String? = null,

	@field:SerializedName("username")
	val username: String? = null,

	@field:SerializedName("is_african_american")
	val isAfricanAmerican: String? = null,

	@field:SerializedName("status")
	val status: String? = null
)
