enum ZendeskChannelMethod {
  initialize,
  show,
  loginUser,
  logoutUser,
  getUnreadMessageCount,

  // 原生端的log訊息
  printLog,

  // 事件觀察的未讀訊息數量變更
  eventUnreadCount,

  // 事件觀察的調用api的驗證訊息錯誤
  eventAuthFail,

  // 事件觀察的未知錯誤
  eventUnknown,
}
