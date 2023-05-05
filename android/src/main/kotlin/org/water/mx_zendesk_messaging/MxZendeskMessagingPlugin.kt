package org.water.mx_zendesk_messaging

import android.app.Activity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlinx.coroutines.runBlocking

/** MxZendeskMessagingPlugin */
class MxZendeskMessagingPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private val tag = "[MxZendeskMessagingPlugin]"
    private lateinit var channel: MethodChannel
    private lateinit var zendeskMessaging: MxZendeskMessaging
    private var activity: Activity? = null
    private var isInitialized: Boolean = false

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val method = ZendeskChannelMethod.fromRawValue(call.method)!!
        val callId = call.argument<Int>("callId")

        when (method) {
            ZendeskChannelMethod.Initialize -> {
                if (isInitialized) {
                    val content = "$tag - Messaging is already initialized!"
                    channel.invokeMethod(
                        method.rawValue,
                        mapOf("content" to content, "callId" to callId)
                    )
                } else if (activity == null) {
                    contextEmptyBack(method, callId!!)
                } else {
                    val channelKey = call.argument<String>("channelKey")!!
                    zendeskMessaging.initialize(activity!!, channelKey, callId!!) { success ->
                        this.isInitialized = success
                    }
                }
            }
            ZendeskChannelMethod.Show -> {
                if (!isInitialized) {
                    initErrorBack(method, callId!!)
                } else if (activity == null) {
                    contextEmptyBack(method, callId!!)
                } else {
                    zendeskMessaging.show(activity!!, callId!!)
                }
            }
            ZendeskChannelMethod.LoginUser -> {
                if (!isInitialized) {
                    initErrorBack(method, callId!!)
                } else {
                    val jwt = call.argument<String>("jwt")!!
                    zendeskMessaging.loginUser(jwt, callId!!)
                }
            }
            ZendeskChannelMethod.LogoutUser -> {
                if (!isInitialized) {
                    initErrorBack(method, callId!!)
                } else {
                    // 開啟協程執行
                    GlobalScope.launch(Dispatchers.Main) {
                        zendeskMessaging.logoutUser(callId!!)
                    }
                }
            }
            ZendeskChannelMethod.GetUnreadMessageCount -> {
                if (!isInitialized) {
                    initErrorBack(method, callId!!)
                } else {
                    result.success(zendeskMessaging.getUnreadMessageCount())
                    return
                }
            }
            else -> {
                result.notImplemented()
            }
        }

        result.success(0)
    }

    private fun contextEmptyBack(method: ZendeskChannelMethod, callId: Int) {
        val errorContent = "$tag - Context is empty.\n"
        channel.invokeMethod(method.rawValue, mapOf("error" to errorContent, "callId" to callId))
    }

    private fun initErrorBack(method: ZendeskChannelMethod, callId: Int) {
        val errorContent = "$tag - Messaging needs to be initialized first.\n"
        channel.invokeMethod(method.rawValue, mapOf("error" to errorContent, "callId" to callId))
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "mx_zendesk_messaging")
        zendeskMessaging = MxZendeskMessaging(channel)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

}