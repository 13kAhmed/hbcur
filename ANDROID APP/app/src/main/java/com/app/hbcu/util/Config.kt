package com.app.hbcu.util

class Config {
    companion object {

        @kotlin.jvm.JvmField
        // var MAIN_URL: String = "https://hbcu.presslayouts.com/"
        var MAIN_URL: String = "https://hbcucrypto.com/"

        @kotlin.jvm.JvmField
        var BASE_URL: String = MAIN_URL + "admin/api/"
        var IMAGE_BASE_URL: String = MAIN_URL + "admin/public/images/avtar/"
        var IMAGE_BASE_URL_NEWS: String = MAIN_URL + "admin/public/images/news/"

        var URL_FAQ: String = MAIN_URL + "faq.html"
        var URL_WHITE_PAPER: String = MAIN_URL + "White-paper.html"
        var URL_PRIVACY_POLICY: String = MAIN_URL + "privacy-policy.html"
        var URL_TERMS_SERVICE: String = MAIN_URL + "terms-services"
        var URL_DOWNLOAD_LINK: String = "https://play.google.com/store/apps/details?id=com.app.hbcu"


        var URL_FB: String = "https://www.facebook.com/HBCU-Crypto-107240228282653"
        var URL_INSTA: String = "https://www.instagram.com/hbcucrypto/"
        var URL_TWITTER: String = "https://twitter.com/CryptoHbcu"
        var URL_YOUTUBE: String = "https://www.youtube.com/channel/UCW6J58vGprzh0OCpkhM2ryQ"
        var EMAIL_CONTACT: String = "admin@hbcucrypto.com"

        var SERVER_URL_SOCKET: String = "http://144.126.128.150:3000"
        // var SERVER_URL_SOCKET: String = "http://144.126.128.150"

        var EMIT_TEAMS: String = "getTeams"
        var EMIT_LISTENER_TEAMS: String = "getTeamsResponse"

        var EMIT_START_MINING: String = "startMining"
        var EMIT_LISTENER_START_MINING: String = "startMiningResponse"

        var EMIT_MINING_BALANCE: String = "get_mingin_balance"
        var EMIT_LISTENER_MINING_BALANCE: String = "get_mingin_balance_response"

        var EMIT_TRANSACTION_HISTORY: String = "getMiningTransactionHistory"
        var EMIT_LISTENER_TRANSACTION_HISTORY: String = "getMiningTransactionHistoryResponse"

        var EMIT_NEWS: String = "getNews"
        var EMIT_LISTENER_NEWS: String = "getNewsResponse"

        @kotlin.jvm.JvmField
        var SHARED_PREF_NAME: String = "hbcu_pref"

        var PREF_USERDATA: String = "pref_userdata"
        var PREF_UID: String = "pref_userId"
        var PREF_IS_LOGIN: String = "pref_islogin"
        var PREF_AUTH_TOKEN: String = "pref_bearer_token"
        var PREF_FCM_TOKEN: String = "PREF_FCM_TOKEN"
        var PREF_LAST_BALANCE: String = "PREF_LAST_BALANCE"

        var PREF_MINING_TIME: String = "PREF_MINING_TIME"
        var PREF_SPENT_TIME_MILLI: String = "PREF_SPENT_TIME"
        var PREF_USER_RATE: String = "PREF_USER_RATE"

        var STATUS_START: String = "start"
        var STATUS_COMPLETED: String = "completed"

        //2,4
    }
}