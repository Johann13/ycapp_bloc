import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:ycapp_bloc/bloc/data_blocs/web/bool_pref_web.dart';

class BoolPrefMobile extends BoolPrefWeb {
  AndroidDeviceInfo androidInfo;

  Future<Null> init() async {
    await super.init();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    androidInfo = await deviceInfo.androidInfo;
  }

  get isOreo {
    if (!Platform.isAndroid) {
      return false;
    }
    if (androidInfo == null) {
      return false;
    }
    return androidInfo.version.sdkInt >= 26;
  }
}
