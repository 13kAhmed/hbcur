package com.app.hbcu.model.country

import com.google.gson.annotations.SerializedName

data class CountryResponse(

	@field:SerializedName("data")
	val data: Data? = null,

	@field:SerializedName("message")
	val message: Message? = null,

	@field:SerializedName("status")
	val status: String? = null
)

data class CountrysItem(

	@field:SerializedName("iso_code_2")
	val isoCode2: String? = null,

	@field:SerializedName("address_format")
	val addressFormat: Any? = null,

	@field:SerializedName("iso_code_3")
	val isoCode3: String? = null,

	@field:SerializedName("updated_at")
	val updatedAt: Any? = null,

	@field:SerializedName("name")
	val name: String? = null,

	@field:SerializedName("created_at")
	val createdAt: String? = null,

	@field:SerializedName("id")
	val id: Int? = null,

	@field:SerializedName("phone_code")
	val phoneCode: String? = null,

	@field:SerializedName("status")
	val status: String? = null
)

data class Data(

	@field:SerializedName("countrys")
	val countrys: ArrayList<CountrysItem?>? = null
)

data class Message(

	@field:SerializedName("success")
	val success: String? = null
)
