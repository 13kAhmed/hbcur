package com.app.hbcu.retrofit

import com.google.gson.Gson
import okhttp3.ResponseBody
import retrofit2.Converter
import retrofit2.Retrofit
import java.lang.reflect.Type
 class GsonPConverterFactory private constructor(private val gson: Gson) : Converter.Factory() {

   /* override fun responseBodyConverter(
        type: Type,
        annotations: Array<Annotation>,
        retrofit: Retrofit
    ): Converter<ResponseBody, *>? {
        val adapter = gson.getAdapter(TypeToken.get(type))
        return GsonPConverterFactory(gson, adapter)

    }*/

    companion object {
        fun create() = GsonPConverterFactory(Gson())

        fun create(gson: Gson?): GsonPConverterFactory {
            if (gson == null) {
                throw NullPointerException("gson==null")
            }
            return GsonPConverterFactory(gson)
        }
    }
}