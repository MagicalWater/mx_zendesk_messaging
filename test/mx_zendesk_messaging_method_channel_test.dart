import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mx_zendesk_messaging/mx_zendesk_messaging_method_channel.dart';

void main() {
  MethodChannelMxZendeskMessaging platform = MethodChannelMxZendeskMessaging();
  const MethodChannel channel = MethodChannel('mx_zendesk_messaging');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await platform.getPlatformVersion(), '42');
  // });
}
