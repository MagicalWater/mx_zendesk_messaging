import 'package:mx_zendesk_messaging/src/model/model.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'mx_zendesk_messaging_method_channel.dart';

abstract class MxZendeskMessagingPlatform extends PlatformInterface {
  /// Constructs a MxZendeskMessagingPlatform.
  MxZendeskMessagingPlatform() : super(token: _token);

  static final Object _token = Object();

  static MxZendeskMessagingPlatform _instance = MethodChannelMxZendeskMessaging();

  /// The default instance of [MxZendeskMessagingPlatform] to use.
  ///
  /// Defaults to [MethodChannelMxZendeskMessaging].
  static MxZendeskMessagingPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [MxZendeskMessagingPlatform] when
  /// they register themselves.
  static set instance(MxZendeskMessagingPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// 當前的未讀訊息數量
  /// 此數量會跟隨著以下兩點更新
  /// 1. [unreadCountStream] 未讀訊息數量變更事件通知
  /// 2. 呼叫[getUnreadMessageCount]跟伺服器獲取實際未讀訊息後更新
  int get unreadCount;

  /// 未讀訊息數量變更串流
  Stream<int> get unreadCountStream;

  /// 初始化
  /// 詳情參閱官方文件 [URL](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/advanced_integration/)
  Future<void> initialize({
    String? androidChannelKey,
    String? iosChannelKey,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// 展示對話視窗
  /// 詳情參閱官方文件 [URL](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/advanced_integration/)
  Future<void> show() {
    throw UnimplementedError('show() has not been implemented.');
  }

  /// 登入驗證用戶
  /// 詳情參閱官方文件 [URL](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/advanced_integration/)
  Future<ZendeskAuthUser> loginUser(String jwt) {
    throw UnimplementedError('loginUser() has not been implemented.');
  }

  /// 登出用戶
  /// 詳情參閱官方文件 [URL](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/advanced_integration/)
  Future<void> logoutUser() {
    throw UnimplementedError('logoutUser() has not been implemented.');
  }

  /// 取得未讀訊息數量
  /// 詳情參閱官方文件 [URL](https://developer.zendesk.com/documentation/zendesk-web-widget-sdks/sdks/android/advanced_integration/)
  Future<int> getUnreadMessageCount() {
    throw UnimplementedError('getUnreadMessageCount() has not been implemented.');
  }

  bool isInitialized() {
    throw UnimplementedError('isInitialized() has not been implemented.');
  }

  bool isLogin() {
    throw UnimplementedError('isLogin() has not been implemented.');
  }
}
