import 'package:mx_zendesk_messaging/src/model/model.dart';

import 'mx_zendesk_messaging_platform_interface.dart';

export 'src/model/zendesk_auth_user.dart';

class MxZendeskMessaging {
  /// 初始化
  /// 詳情參閱官方文件 [URL](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/advanced_integration/)
  Future<void> initialize({
    String? androidChannelKey,
    String? iosChannelKey,
  }) => MxZendeskMessagingPlatform.instance.initialize(
      androidChannelKey: androidChannelKey,
      iosChannelKey: iosChannelKey,
    );

  /// 展示對話視窗
  /// 詳情參閱官方文件 [URL](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/advanced_integration/)
  Future<void> show() => MxZendeskMessagingPlatform.instance.show();

  /// 登入驗證用戶
  /// 詳情參閱官方文件 [URL](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/advanced_integration/)
  Future<ZendeskAuthUser> loginUser(String jwt) => MxZendeskMessagingPlatform.instance.loginUser(jwt);

  /// 登出用戶
  /// 詳情參閱官方文件 [URL](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/advanced_integration/)
  Future<void> logoutUser() => MxZendeskMessagingPlatform.instance.logoutUser();

  /// 取得未讀訊息數量
  /// 詳情參閱官方文件 [URL](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/advanced_integration/)
  Future<int> getUnreadMessageCount() => MxZendeskMessagingPlatform.instance.getUnreadMessageCount();

  /// 是否已初始化
  bool isInitialized() => MxZendeskMessagingPlatform.instance.isInitialized();

  /// 是否登入
  bool isLogin() => MxZendeskMessagingPlatform.instance.isLogin();
}
