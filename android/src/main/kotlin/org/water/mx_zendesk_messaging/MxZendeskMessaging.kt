package org.water.mx_zendesk_messaging

import android.content.Context
import android.content.Intent
import io.flutter.plugin.common.MethodChannel
import zendesk.android.Zendesk
import zendesk.android.ZendeskResult
import zendesk.android.ZendeskUser
import zendesk.android.events.ZendeskEvent
import zendesk.android.events.ZendeskEventListener
import zendesk.messaging.android.DefaultMessagingFactory

class MxZendeskMessaging(
    private val channel: MethodChannel,
) {
    companion object {
        const val tag = "[MxZendeskMessaging]"
    }

    fun initialize(
        context: Context,
        channelKey: String,
        callId: Int,
        onComplete: (Boolean) -> Unit
    ) {
        printLog("$tag - Channel Key - $channelKey")
        Zendesk.initialize(context, channelKey, successCallback = { value ->
            // 初始化成功後加入事件觀察
            setEventObservable()
            val args = mapOf<String, Any?>("callId" to callId)
            onComplete(true)
            printLog("$tag - initialize success - $value")
            channel.invokeMethod(ZendeskChannelMethod.Initialize.rawValue, args)
        }, failureCallback = { error ->
            val args = mapOf<String, Any?>("callId" to callId, "error" to error.message)
            onComplete(false)
            printLog("$tag - initialize failure - $error")
            channel.invokeMethod(ZendeskChannelMethod.Initialize.rawValue, args)
        }, messagingFactory = DefaultMessagingFactory()
        )
    }

    fun show(context: Context, callId: Int?) {
        val args = mutableMapOf<String, Any?>("callId" to callId)
        printLog("$tag - show")
        Zendesk.instance.messaging.showMessaging(context, Intent.FLAG_ACTIVITY_NEW_TASK)
        channel.invokeMethod(ZendeskChannelMethod.Show.rawValue, args)
    }

    fun getUnreadMessageCount(): Int {
        return Zendesk.instance.messaging.getUnreadMessageCount()
    }

    fun loginUser(jwt: String, callId: Int) {
        Zendesk.instance.loginUser(jwt, { value: ZendeskUser? ->
            val args = mapOf<String, Any?>(
                "callId" to callId,
                "id" to value?.id,
                "externalId" to value?.externalId
            )
            channel.invokeMethod(ZendeskChannelMethod.LoginUser.rawValue, args)
        }, { error: Throwable? ->
            val args = mapOf<String, Any?>(
                "callId" to callId,
                "error" to error?.message
            )
            printLog("$tag - Login failure : ${error?.message}")

            channel.invokeMethod(ZendeskChannelMethod.LoginUser.rawValue, args)
        })
    }

    suspend fun logoutUser(callId: Int) {
        val args: MutableMap<String, Any?> = mutableMapOf("callId" to callId)
        val result = Zendesk.instance.logoutUser()
        if (result is ZendeskResult.Failure) {
            args["error"] = result.error.message
        }
        channel.invokeMethod(ZendeskChannelMethod.LogoutUser.rawValue, args)
    }

    // 事件監聽
    private val zendeskEventListener: ZendeskEventListener = ZendeskEventListener { zendeskEvent ->
        when (zendeskEvent) {
            is ZendeskEvent.UnreadMessageCountChanged -> {
                channel.invokeMethod(
                    ZendeskChannelMethod.EventUnreadCount.rawValue,
                    mapOf("content" to zendeskEvent.currentUnreadCount)
                )
            }
            is ZendeskEvent.AuthenticationFailed -> {
                channel.invokeMethod(
                    ZendeskChannelMethod.EventAuthFail.rawValue,
                    mapOf("error" to zendeskEvent.error.message)
                )
            }
            else -> {
                channel.invokeMethod(
                    ZendeskChannelMethod.EventUnknown.rawValue,
                    mapOf("content" to zendeskEvent.toString())
                )
            }
        }
    }

    // 設置事件觀察
    fun setEventObservable() {
        removeEventObservable()
        printLog("$tag - 加入事件觀察")
        Zendesk.instance.addEventListener(zendeskEventListener)
    }

    private fun removeEventObservable() {
        Zendesk.instance.removeEventListener(zendeskEventListener)
    }

    private fun printLog(text: Any?) {
        channel.invokeMethod(
            ZendeskChannelMethod.PrintLog.rawValue, mapOf("content" to text?.toString())
        )
    }
}


