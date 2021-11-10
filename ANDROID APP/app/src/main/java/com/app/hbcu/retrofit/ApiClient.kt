package com.app.hbcu.retrofit

import com.app.hbcu.util.Config
import com.google.gson.GsonBuilder
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.gson.GsonConverterFactory
import java.util.concurrent.TimeUnit

/**
 * Created by root on 1/3/18.
 */

object ApiClient {
    private var retrofit: Retrofit? = null

    //.addConverterFactory(ScalarsConverterFactory.create())
    val client: Retrofit
        get() {
            if (retrofit == null) {
                val logging = HttpLoggingInterceptor()
                logging.level = HttpLoggingInterceptor.Level.BODY
                val httpClient = OkHttpClient.Builder()
                httpClient.connectTimeout(30, TimeUnit.MINUTES)
                httpClient.readTimeout(30, TimeUnit.MINUTES)
                httpClient.writeTimeout(30, TimeUnit.MINUTES)
                httpClient.interceptors().add(logging)
                val gson = GsonBuilder()
                    .setDateFormat("yyyy-MM-dd'T'HH:mm:ssZ")
                    .create()
                retrofit = Retrofit.Builder()
                    .baseUrl(Config.BASE_URL)
                    .client(httpClient.build()) //.addConverterFactory(ScalarsConverterFactory.create())
                    .addConverterFactory(GsonConverterFactory.create(gson))
                    .build()
            }
            return retrofit!!
        }
}