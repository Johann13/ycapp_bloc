import 'dart:async';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:ycapp_bloc/pref/bool/bool_pref.dart';
import 'package:ycapp_connectivity/ycappconnectivity.dart';
import 'package:ycapp_foundation/model/channel/image_quality.dart';

class BoolPrefMobile extends BoolPref {
  AndroidDeviceInfo androidInfo;

  bool _wifi;
  YConnectivityResult _connected = YConnectivityResult.none;

  StreamSubscription<YConnectivityResult> _connectivitySub;

  Future<Null> init() async {
    await super.init();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    androidInfo = await deviceInfo.androidInfo;

    _connectivitySub =
        YConnectivity().onConnectivityChanged.listen((result) async {
      _wifi = (result == YConnectivityResult.wifiSlow) ||
          (result == YConnectivityResult.wifiMedium) ||
          (result == YConnectivityResult.wifiFast);
      print('pref.$result');
      _connected = result;
    });
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

  bool get connected {
    return _connected != YConnectivityResult.none;
  }

  Quality get quality {
    if (lowQualityImages || (!_wifi && saveData)) {
      return Quality.low;
    } else {
      return Quality.high;
    }
  }

  TwitchQuality get twitchQuality {
    switch (_connected) {
      case YConnectivityResult.wifiFast:
        return TwitchQuality.high;
        break;
      case YConnectivityResult.wifiMedium:
        return TwitchQuality.medium;
        break;
      case YConnectivityResult.wifiSlow:
        return TwitchQuality.low;
        break;
      case YConnectivityResult.mobileFast:
        if (lowQualityImages || saveData || twitchSmallThumb) {
          return TwitchQuality.medium;
        } else {
          return TwitchQuality.high;
        }
        break;
      case YConnectivityResult.mobileMedium:
        if (lowQualityImages || saveData || twitchSmallThumb) {
          return TwitchQuality.low;
        } else {
          return TwitchQuality.medium;
        }
        break;
      case YConnectivityResult.mobileSlow:
      case YConnectivityResult.none:
      default:
        return TwitchQuality.low;
        break;
    }
  }

  YoutubeQuality get youtubeQuality {
    switch (_connected) {
      case YConnectivityResult.wifiFast:
        return YoutubeQuality.high;
        break;
      case YConnectivityResult.wifiMedium:
        return YoutubeQuality.medium;
        break;
      case YConnectivityResult.wifiSlow:
        return YoutubeQuality.low;
        break;
      case YConnectivityResult.mobileFast:
        if (lowQualityImages || saveData || youtubeSmallThumb) {
          return YoutubeQuality.medium;
        } else {
          return YoutubeQuality.high;
        }
        break;
      case YConnectivityResult.mobileMedium:
        if (lowQualityImages || saveData || youtubeSmallThumb) {
          return YoutubeQuality.low;
        } else {
          return YoutubeQuality.medium;
        }
        break;
      case YConnectivityResult.mobileSlow:
      case YConnectivityResult.none:
      default:
        return YoutubeQuality.low;
        break;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySub?.cancel();
  }
}
