package com.app.hbcu.model.mininghistory

import com.google.gson.annotations.SerializedName

data class MiningHistoryResponse(

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

    @field:SerializedName("mining_transaction_history")
    val miningTransactionHistory: List<MiningTransactionHistoryItem?>? = null,

    @field:SerializedName("last_page")
    val lastPage: Int? = null,

    @field:SerializedName("page")
    val page: Int? = null,

    @field:SerializedName("available_balance")
    val available_balance: Double? = null
)

data class MiningTransactionHistoryItem(

    @field:SerializedName("credit_amount")
    val creditAmount: Double? = null,

    @field:SerializedName("end_time")
    val endTime: String? = null,


    @field:SerializedName("avail_balance")
    val availBalance: Double? = null,

    @field:SerializedName("trans_id")
    val transId: String? = null,

    @field:SerializedName("debit_amount")
    val debitAmount: Double? = null,

    @field:SerializedName("spent_time")
    val spentTime: String? = null,

    @field:SerializedName("type")
    val type: String? = null,

    @field:SerializedName("start_time")
    val startTime: String? = null,

    @field:SerializedName("user_id")
    val userId: Int? = null,

    @field:SerializedName("id")
    val id: Int? = null,

    @field:SerializedName("trans_created")
    val transCreated: String? = null,

    @field:SerializedName("trans_status")
    val transStatus: String? = null,

    @field:SerializedName("status")
    val status: String? = null
)
