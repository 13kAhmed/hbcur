package com.app.hbcu.retrofit

 import com.google.gson.Gson
import com.google.gson.TypeAdapter
 import com.google.gson.stream.JsonReader
 import okhttp3.ResponseBody
import retrofit2.Converter
import java.io.*

class DynamicJsonConverte<T>(
    private val gson: Gson,
    private val adapter: TypeAdapter<T>
) :
    Converter<ResponseBody, T> {

    @Throws(IOException::class) override fun convert(value: ResponseBody): T {
        val reader: Reader = value.charStream()
        var item: Int = reader.read()
        while (item != '('.toInt() && item != -1) {
            item = reader.read()
        }
        val jsonReader: JsonReader = gson.newJsonReader(reader)

        reader.use {
            return adapter.read(jsonReader)
        }

    }

}