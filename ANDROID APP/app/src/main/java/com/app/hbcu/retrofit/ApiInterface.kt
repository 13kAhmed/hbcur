package com.app.hbcu.retrofit

import com.app.hbcu.model.BaseResponse
import com.app.hbcu.model.country.CountryResponse
import com.app.hbcu.model.mining.MiningResponse
import com.app.hbcu.model.mininghistory.MiningHistoryResponse
import com.app.hbcu.model.news.NewsResponse
import com.app.hbcu.model.notification.NotificationResponse
import com.app.hbcu.model.ranking.RankingResponse
import com.app.hbcu.model.team.TeamsResponse
import com.app.hbcu.model.teamearning.EarningTeamsResponse
import com.app.hbcu.model.user.UserLoginResponse
import okhttp3.MultipartBody
import okhttp3.RequestBody
import retrofit2.Call
import retrofit2.http.*

interface ApiInterface {


    @FormUrlEncoded
    @POST("signin")
    fun signin(
        @Field("signup_type") signup_type: String,
        @Field("mobile") mobile: String,
        @Field("country_code") country_code: String,
        @Field("device_type") device_type: String,
        @Field("device_token") device_token: String
    ): Call<UserLoginResponse>

    @FormUrlEncoded
    @POST("signin")
    fun signinUser(
        @FieldMap fields: Map<String, String>
    ): Call<UserLoginResponse>

    @FormUrlEncoded
    @POST("signup")
    fun signup(
        @FieldMap fields: Map<String, String>
    ): Call<UserLoginResponse>

    @FormUrlEncoded
    @POST("Social")
    fun Socialsignup(
        @FieldMap fields: Map<String, String>
    ): Call<UserLoginResponse>

    @FormUrlEncoded
    @POST("getProfile")
    fun getProfile(
        @Header("Authorization") headerAuth: String,
        @Field("user_id") user_id: String
    ): Call<UserLoginResponse>

    @Multipart
    @POST("updateProfile")
    fun updateProfile(
        @Header("Authorization") headerAuth: String,
        @Part("user_id") user_id: RequestBody,
        @Part("first_name") first_name: RequestBody,
        @Part("last_name") last_name: RequestBody,
        @Part image: MultipartBody.Part?
    ): Call<UserLoginResponse>

    @FormUrlEncoded
    @POST("getTeams")
    fun getTeams(
        @Header("Authorization") headerAuth: String,
        @Field("user_id") user_id: String,
        @Field("page") page: String
    ): Call<TeamsResponse>

    @FormUrlEncoded
    @POST("getUsersNotification")
    fun getUsersNotification(
        @Header("Authorization") headerAuth: String,
        @Field("user_id") user_id: String,
        @Field("page") page: String
    ): Call<NotificationResponse>

    @FormUrlEncoded
    @POST("getRanking")
    fun getRanking(
        @Header("Authorization") headerAuth: String,
        @Field("user_id") user_id: String,
        @Field("type") type: String,
        @Field("page") page: String
    ): Call<RankingResponse>

    @FormUrlEncoded
    @POST("news")
    fun getNews(
        @Header("Authorization") headerAuth: String,
        @Field("page") page: String
    ): Call<NewsResponse>

    @FormUrlEncoded
    @POST("getMiningDetails")
    fun getMiningDetails(
        @Header("Authorization") headerAuth: String,
        @Field("user_id") user_id: String
    ): Call<MiningResponse>

    @FormUrlEncoded
    @POST("startMining")
    fun startMining(
        @Header("Authorization") headerAuth: String,
        @Field("user_id") user_id: String
    ): Call<MiningResponse>

    @FormUrlEncoded
    @POST("getTeamsEarning")
    fun getTeamsEarning(
        @Header("Authorization") headerAuth: String,
        @Field("user_id") user_id: String
    ): Call<EarningTeamsResponse>

    // @FormUrlEncoded
    @POST("getMetaData")
    fun getMetaData(): Call<CountryResponse>

    @POST("getCountryList")
    fun getCountryList(): Call<CountryResponse>

    @FormUrlEncoded
    @POST("getMiningTransactionHistory")
    fun getMiningTransactionHistory(
        @Header("Authorization") headerAuth: String,
        @Field("user_id") user_id: String
    ): Call<MiningHistoryResponse>

    @FormUrlEncoded
    @POST("sendNotification")
    fun sendNotification(
        @Header("Authorization") headerAuth: String,
        @Field("user_id") user_id: String
    ): Call<BaseResponse>

    @FormUrlEncoded
    @POST("sendNotificationInActiveUsers")
    fun sendNotificationInActiveUsers(
        @Header("Authorization") headerAuth: String,
        @Field("user_id") user_id: String
    ): Call<BaseResponse>

    @FormUrlEncoded
    @POST("logout")
    fun logout(
        @Header("Authorization") headerAuth: String,
        @Field("user_id") user_id: String,
        @Field("device_token") device_token: String
    ): Call<BaseResponse>
}