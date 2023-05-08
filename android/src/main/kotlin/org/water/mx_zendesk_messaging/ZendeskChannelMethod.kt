package org.water.mx_zendesk_messaging

enum class ZendeskChannelMethod(val rawValue: String) {
    Initialize("initialize"),
    Show("show"),
    LoginUser("loginUser"),
    LogoutUser("logoutUser"),
    GetUnreadMessageCount("getUnreadMessageCount"),
    PrintLog("printLog"),
    EventUnreadCount("eventUnreadCount"),
    EventAuthFail("eventAuthFail"),
    EventUnknown("eventUnknown");

    companion object {
        fun fromRawValue(rawValue: String): ZendeskChannelMethod? {
            return values().find { it.rawValue == rawValue }
        }
    }
}