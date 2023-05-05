import Flutter
import UIKit

public class MxZendeskMessagingPlugin: NSObject, FlutterPlugin {
    let TAG = "[SwiftZendeskMessagingPlugin]"
    private var channel: FlutterMethodChannel
    var isInitialized = false
    private var zendeskMessaging: MxZendeskMessaging
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
        self.zendeskMessaging = MxZendeskMessaging(channel: channel)
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "mx_zendesk_messaging", binaryMessenger: registrar.messenger())
        let instance = MxZendeskMessagingPlugin(channel: channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let method = ZendeskChannelMethod.init(rawValue: call.method)
        let arguments = call.arguments as? Dictionary<String, Any>
        let callId = arguments?["callId"] as? Int
        
        switch(method) {
        case .initialize:
            if (isInitialized) {
                let content = "\(TAG) - Messaging is already initialize!\n"
                channel.invokeMethod(method!.rawValue, arguments: ["content": content,"callId": callId!])
            } else {
                let channelKey: String = (arguments?["channelKey"] ?? "") as! String
                zendeskMessaging.initialize(channelKey: channelKey, callId: callId) { result in
                    self.isInitialized = result
                }
            }
            break
        case .show:
            if (!isInitialized) {
                initErrorBack(method: method!, callId: callId!)
            } else {
                zendeskMessaging.show(rootViewController: UIApplication.shared.delegate?.window??.rootViewController, callId: callId)
            }
            break
        case .loginUser:
            if (!isInitialized) {
                initErrorBack(method: method!, callId: callId!)
            } else {
                let jwt: String = arguments?["jwt"] as! String
                zendeskMessaging.loginUser(jwt: jwt, callId: callId)
            }
            break
        case .logoutUser:
            if (!isInitialized) {
                initErrorBack(method: method!, callId: callId!)
            } else {
                zendeskMessaging.logoutUser(callId: callId)
            }
            break
        case .getUnreadMessageCount:
            result(zendeskMessaging.getUnreadMessageCount())
            return
        case .printLog:
            break
        case .none:
            break
        }
        
        result(nil)
    }
    
    private func initErrorBack(method: ZendeskChannelMethod, callId: Int) {
        let errorContent = "\(TAG) - Messaging needs to be initialized first.\n"
        channel.invokeMethod(method.rawValue, arguments: ["error": errorContent, "callId": callId])
    }
}
