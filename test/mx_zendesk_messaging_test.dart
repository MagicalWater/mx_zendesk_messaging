import 'package:flutter_test/flutter_test.dart';
import 'package:mx_zendesk_messaging/mx_zendesk_messaging.dart';
import 'package:mx_zendesk_messaging/mx_zendesk_messaging_platform_interface.dart';
import 'package:mx_zendesk_messaging/mx_zendesk_messaging_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockMxZendeskMessagingPlatform
    with MockPlatformInterfaceMixin
    implements MxZendeskMessagingPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<int> getUnreadMessageCount() {
    throw UnimplementedError();
  }

  @override
  Future<void> initialize({String? androidChannelKey, String? iosChannelKey}) {
    throw UnimplementedError();
  }

  @override
  bool isInitialized() {
    throw UnimplementedError();
  }

  @override
  bool isLogin() {
    throw UnimplementedError();
  }

  @override
  Future<ZendeskAuthUser> loginUser(String jwt) {
    throw UnimplementedError();
  }

  @override
  Future<void> logoutUser() {
    throw UnimplementedError();
  }

  @override
  Future<void> show() {
    throw UnimplementedError();
  }
}

void main() {
  final MxZendeskMessagingPlatform initialPlatform = MxZendeskMessagingPlatform.instance;

  test('$MethodChannelMxZendeskMessaging is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelMxZendeskMessaging>());
  });

  // test('getPlatformVersion', () async {
  //   MxZendeskMessaging mxZendeskMessagingPlugin = MxZendeskMessaging();
  //   MockMxZendeskMessagingPlatform fakePlatform = MockMxZendeskMessagingPlatform();
  //   MxZendeskMessagingPlatform.instance = fakePlatform;
  //
  //   expect(await mxZendeskMessagingPlugin.getPlatformVersion(), '42');
  // });
}
