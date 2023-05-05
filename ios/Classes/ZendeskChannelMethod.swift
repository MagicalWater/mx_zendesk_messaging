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
}
