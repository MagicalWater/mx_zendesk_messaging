//
//  MxZendeskMessaging.swift
//  mx_zendesk_messaging
//
//  Created by Magical Water on 2023/5/5.
//

import Flutter
import UIKit
import ZendeskSDKMessaging
import ZendeskSDK

public class MxZendeskMessaging: NSObject {
    let TAG = "[MxZendeskMessaging]"
    
    private var channel: FlutterMethodChannel
    
    init(channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    func initialize(channelKey: String, callId: Int?, onComplete: @escaping (Bool) -> Void) {
        printLog("\(self.TAG) - Channel Key - \(channelKey)\n")
        Zendesk.initialize(withChannelKey: channelKey, messagingFactory: DefaultMessagingFactory()) { result -> Void in
            
            var argsMap: [String: Any] = ["callId": callId!]
            if case let .failure(error) = result {
                onComplete(false)
                self.printLog("\(self.TAG) - initialize failure - \(error.localizedDescription)\n")
                argsMap["error"] = error.localizedDescription
            } else {
                // 初始化成功後加入事件觀察
                self.setEventObservable()
                onComplete(true)
                self.printLog("\(self.TAG) - initialize success")
            }
            
            self.channel.invokeMethod(ZendeskChannelMethod.initialize.rawValue, arguments: argsMap)
        }
    }
    
    func show(rootViewController: UIViewController?, callId: Int?) {
        
        let messagingViewController = Zendesk.instance?.messaging?.messagingViewController()
        
        var argsMap: [String: Any] = ["callId": callId!]
        
        if (rootViewController == nil) {
            argsMap["error"] = "rootViewController is nil"
        } else if (messagingViewController == nil) {
            argsMap["error"] = "messagingViewController is nil"
        } else {
            rootViewController!.present(messagingViewController!, animated: true, completion: nil)
        }
        
        printLog("\(self.TAG) - show")
        channel.invokeMethod(ZendeskChannelMethod.show.rawValue, arguments: argsMap)
    }
    
    func loginUser(jwt: String, callId: Int?) {
        Zendesk.instance?.loginUser(with: jwt) { result in
            var argsMap: [String: Any] = ["callId": callId!]
            switch result {
            case .success(let user):
                argsMap["id"] = user.id
                argsMap["externalId"] = user.externalId
                break
            case .failure(let error):
                argsMap["error"] = error.localizedDescription
                self.printLog("\(self.TAG) - login failure - \(error.localizedDescription)\n")
                break
            }
            
            self.channel.invokeMethod(ZendeskChannelMethod.loginUser.rawValue, arguments: argsMap)
        }
    }
    
    func logoutUser(callId: Int?) {
        Zendesk.instance?.logoutUser { result in
            var argsMap: [String: Any] = ["callId": callId!]
            
            switch result {
            case .success:
                break
            case .failure(let error):
                argsMap["error"] = error.localizedDescription
                self.printLog("\(self.TAG) - logout failure - \(error.localizedDescription)\n")
                break
            }
            
            self.channel.invokeMethod(ZendeskChannelMethod.logoutUser.rawValue, arguments: argsMap)
        }
    }
    
    func getUnreadMessageCount() -> Int {
        return Zendesk.instance?.messaging?.getUnreadMessageCount() ?? 0
    }
    
    // 設置事件觀察
    func setEventObservable() {
        removeEventObservable()
        printLog("\(self.TAG) - 加入事件觀察 \(Zendesk.instance != nil)")
        Zendesk.instance?.addEventObserver(self) { event in
            switch event {
            case .unreadMessageCountChanged(let unreadCount):
                self.channel.invokeMethod(ZendeskChannelMethod.eventUnreadCount.rawValue, arguments: ["content": unreadCount])
                break
            case .authenticationFailed(let error as NSError):
                print("Authentication error received: \(error)")
                print("Domain: \(error.domain)")
                print("Error code: \(error.code)")
                print("Localized Description: \(error.localizedDescription)")
                self.channel.invokeMethod(ZendeskChannelMethod.eventAuthFail.rawValue, arguments: ["code": error.code, "domain": error.domain, "error": error.localizedDescription])
                break
            @unknown default:
                self.channel.invokeMethod(ZendeskChannelMethod.eventUnknown.rawValue, arguments: ["content": "\(event)"])
                break
            }
        }
    }
    
    func removeEventObservable() {
        Zendesk.instance?.removeEventObserver(self)
    }
    
    func printLog(_ text: String) {
        channel.invokeMethod(ZendeskChannelMethod.printLog.rawValue, arguments: ["content": text])
    }
}
