import 'dart:async';

import 'package:flutter/services.dart';

class Ycappbloc {
  static const MethodChannel _channel =
      const MethodChannel('ycappbloc');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
