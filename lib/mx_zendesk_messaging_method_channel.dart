import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'mx_zendesk_messaging_platform_interface.dart';
import 'src/model/model.dart';

/// An implementation of [MxZendeskMessagingPlatform] that uses method channels.
class MethodChannelMxZendeskMessaging extends MxZendeskMessagingPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('mx_zendesk_messaging');

  /// 當前排到的請求id, 當到達100000以上以後重置
  int _requestId = 0;

  /// 當前是否已初始化
  bool _isInit = false;

  /// 當前登入的用戶
  ZendeskAuthUser? _loginUser;

  /// 等待回調
  final _waitCallbacks = <int, void Function(MethodCall call)>{};

  @override
  Future<void> initialize({
    String? androidChannelKey,
    String? iosChannelKey,
  }) {
    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isIos = defaultTargetPlatform == TargetPlatform.iOS;

    // 只支援android以及ios
    assert((isAndroid &&
            androidChannelKey != null &&
            androidChannelKey.isNotEmpty) ||
        (isIos && iosChannelKey != null && iosChannelKey.isNotEmpty));

    methodChannel.setMethodCallHandler(_onMethodCall);

    if (!_isInit) {
      final callId = _getCallId();
      return _waitCallback(callId, () {
        return methodChannel.invokeMethod(
          ZendeskChannelMethod.initialize.name,
          {
            'channelKey': isAndroid ? androidChannelKey : iosChannelKey,
            'callId': callId,
          },
        );
      }).then((value) {
        _isInit = true;
      });
    } else {
      return Future.value();
    }
  }

  @override
  Future<void> show() {
    final callId = _getCallId();
    return _waitCallback(callId, () {
      return methodChannel.invokeMethod(
        ZendeskChannelMethod.show.name,
        {'callId': callId},
      );
    });
  }

  @override
  Future<ZendeskAuthUser> loginUser(String jwt) async {
    assert(jwt.isNotEmpty);

    final callId = _getCallId();
    return _waitCallback(callId, () {
      return methodChannel.invokeMethod(
        ZendeskChannelMethod.loginUser.name,
        {
          'jwt': jwt,
          'callId': callId,
        },
      );
    }).then((value) {
      return _loginUser = ZendeskAuthUser(
        id: value.arguments?["id"],
        externalId: value.arguments?["externalId"],
      );
    });
  }

  @override
  Future<void> logoutUser() async {
    final callId = _getCallId();
    return _waitCallback(callId, () {
      return methodChannel.invokeMethod(
        ZendeskChannelMethod.logoutUser.name,
        {
          'callId': callId,
        },
      );
    }).then((value) {
      _loginUser = null;
    });
  }

  @override
  Future<int> getUnreadMessageCount() async {
    return methodChannel
        .invokeMethod(ZendeskChannelMethod.getUnreadMessageCount.name)
        .then((value) => value as int);
  }

  @override
  bool isInitialized() {
    return _isInit;
  }

  @override
  bool isLogin() {
    return _loginUser != null;
  }

  /// Handle incoming message from platforms (iOS and Android)
  Future<dynamic> _onMethodCall(final MethodCall call) async {
    final callId = call.arguments?['callId'] as int?;
    // print('回調: ${call.method}, id = ${callId}, args = ${call.arguments}');
    if (callId != null) {
      _waitCallbacks[callId]?.call(call);
    }
  }

  /// 等待執行回調
  /// [execute] - 需要執行的內容
  Future<MethodCall> _waitCallback(
    int id,
    FutureOr Function() execute,
  ) async {
    // print('新增回調id: ${id}');
    final completer = Completer<MethodCall>();
    _waitCallbacks[id] = (call) {
      _waitCallbacks.remove(id);
      final args = call.arguments as Map?;
      if (args?.containsKey('error') ?? false) {
        completer.completeError(args!['error'].toString());
      } else {
        completer.complete(call);
      }
    };
    try {
      await execute();
    } catch (e, s) {
      completer.completeError(e, s);
    }
    return completer.future;
  }

  int _getCallId() {
    if (_requestId > 100000) {
      _requestId = 0;
    }
    return _requestId++;
  }
}
