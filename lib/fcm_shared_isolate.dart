import 'dart:async';

import 'package:flutter/services.dart';

class FcmSharedIsolate {
  final _channel = MethodChannel('fcm_shared_isolate');
  final _msg = <Map<dynamic, dynamic>>[];
  void Function(Map<dynamic, dynamic>) _onMessage;
  void Function(String) _onNewToken;

  FcmSharedIsolate() {
    _channel.setMethodCallHandler(handle);
  }

  Future<dynamic> handle(MethodCall call) {
    if (call.method == 'message') {
      final Map<dynamic, dynamic> data = call.arguments;
      if (_onMessage != null) {
        _onMessage(data);
      } else {
        _msg.add(data);
      }
    } else if (call.method == 'token') {
      final String newToken = call.arguments;
      _onNewToken?.call(newToken);
    }
  }

  Future<String> getToken() async {
    return await _channel.invokeMethod('getToken');
  }

  void setListeners({
    void Function(Map<dynamic, dynamic>) onMessage,
    void Function(String) onNewToken,
  }) {
    _onMessage = onMessage;
    _onNewToken = onNewToken;
    if (_onMessage != null) {
      _msg.forEach(_onMessage);
      _msg.clear();
    }
  }
}
