//
//  ZendeskChannelMethod.swift
//  mx_zendesk_messaging
//
//  Created by Magical Water on 2023/5/5.
//

import Foundation

enum ZendeskChannelMethod: String {
    case initialize = "initialize"
    case show = "show"
    case loginUser = "loginUser"
    case logoutUser = "logoutUser"
    case getUnreadMessageCount = "getUnreadMessageCount"
    case printLog = "printLog"
    
    // 事件觀察的未讀訊息數量變更
    case eventUnreadCount = "eventUnreadCount"
    
    // 事件觀察的調用api的驗證訊息錯誤
    case eventAuthFail = "eventAuthFail"
    
    // 事件觀察的未知錯誤
    case eventUnknown = "eventUnknown"
}
