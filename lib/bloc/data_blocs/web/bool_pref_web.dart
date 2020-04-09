import 'dart:async';
import 'dart:core';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:ycapp_bloc/pref/pref_repo.dart';
import 'package:ycapp_connectivity/ycappconnectivity.dart';
import 'package:ycapp_foundation/model/channel/image_quality.dart';
import 'package:ycapp_foundation/prefs/prefs.dart';
import 'package:ycapp_foundation/ui/y_colors.dart';

class BoolPrefWeb extends Pref<bool> {
  YConnectivityResult _connected = YConnectivityResult.none;
  bool _wifi;
  bool _saveData;
  bool _lowQualityImages;
  bool _loadImages;
  bool _loadBanner;
  bool _loadProfile;
  bool _loadTwitchThumbnail;
  bool _loadYoutubeThumbnail;
  bool _youtubeSmallThumb;
  bool _twitchSmallThumb;
  bool _analytics;
  bool _showNotificationIcon;
  bool _showScheduleAnimation;
  bool _useMerchSubTitle;
  bool _darkMode;
  bool _vodIcons;
  bool _scheduleArt;
  bool _useSideMenuDarkModeToggle;
  bool _showYcCountdown;
  bool _useNotificationSystemV2;
  bool _amoledMode;
  bool _useCreatorThemeOnMainPage;
  bool _useCreatorTheme;
  bool _useCreatorThemeDark;

  StreamSubscription<YConnectivityResult> _connectivitySub;
  StreamSubscription sub2;
  StreamSubscription sub3;
  StreamSubscription loadImagesSub;
  StreamSubscription _loadBannerSub;
  StreamSubscription _loadProfileSub;
  StreamSubscription _loadTwitchThumbnailSub;
  StreamSubscription _loadYoutubeThumbnailSub;
  StreamSubscription _youtubeSmallThumbSub;
  StreamSubscription _twitchSmallThumbSub;
  StreamSubscription _analyticsSub;
  StreamSubscription _showNotificationIconSub;
  StreamSubscription _scheduleArtSub;
  StreamSubscription _showScheduleAnimationSub;
  StreamSubscription _useMerchSubTitleSub;
  StreamSubscription darkModeSub;
  StreamSubscription _vodIconsSub;
  StreamSubscription _useSideMenuDarkModeToggleSub;
  StreamSubscription _showYcCountdownSub;
  StreamSubscription _useNotificationSystemV2Sub;
  StreamSubscription _amoledModeSub;
  StreamSubscription _useCreatorThemeOnMainPageSub;
  StreamSubscription _useCreatorThemeSub;
  StreamSubscription _useCreatorThemeDarkSub;

  Future<Null> init() async {
    _connectivitySub =
        YConnectivity().onConnectivityChanged.listen((result) async {
      _wifi = (result == YConnectivityResult.wifiSlow) ||
          (result == YConnectivityResult.wifiMedium) ||
          (result == YConnectivityResult.wifiFast);
      print('pref.$result');
      _connected = result;
    });

    sub2 = getPrefStream('saveData', true).listen((data) {
      _saveData = data;
    });
    sub3 = getPrefStream('lowQualityImages', false).listen((data) {
      _lowQualityImages = data;
    });
    loadImagesSub = getPrefStream('loadImages', true).listen((data) {
      _loadImages = data;
    });
    _loadBannerSub = getPrefStream('loadBanner', true).listen((data) {
      _loadBanner = data;
    });
    _loadProfileSub = getPrefStream('loadProfile', true).listen((data) {
      _loadProfile = data;
    });
    _loadTwitchThumbnailSub =
        getPrefStream('loadTwitchThumbnail', true).listen((data) {
      _loadTwitchThumbnail = data;
    });
    _loadYoutubeThumbnailSub =
        getPrefStream('loadYoutubeThumbnail', true).listen((data) {
      _loadYoutubeThumbnail = data;
    });

    _youtubeSmallThumbSub =
        getPrefStream('youtubeSmallThumb', true).listen((data) {
      _youtubeSmallThumb = data;
    });
    _twitchSmallThumbSub =
        getPrefStream('twitchSmallThumb', false).listen((data) {
      _twitchSmallThumb = data;
    });

    darkModeSub = getPrefStream('darkMode', false).listen((data) {
      _darkMode = data;
      /*
      FlutterStatusbarManager.setColor(
          _darkMode ? Colors.black : YColors.primaryColorPallet[700],
          animated: true);

      FlutterStatusbarManager.setNavigationBarColor(
          _darkMode ? Colors.black : YColors.primaryColor,
          animated: true);
      FlutterStatusbarManager.setNavigationBarStyle(NavigationBarStyle.LIGHT);*/
    });

    _vodIconsSub = getPrefStream('vodIcons', true).listen((data) {
      _vodIcons = data;
    });

    _analyticsSub = getPrefStream('analyticsPermission', false).listen((data) {
      _analytics = data;
    });

    _showNotificationIconSub =
        getPrefStream('showNotificationIcon', true).listen((data) {
      _showNotificationIcon = data;
    });

    _scheduleArtSub = getPrefStream('scheduleArt', true).listen((value) {
      _scheduleArt = value;
    });

    _showScheduleAnimationSub =
        getPrefStream('showScheduleAnimation', true).listen((value) {
      _showScheduleAnimation = value;
    });
    _useMerchSubTitleSub =
        getPrefStream('useMerchSubTitle', true).listen((value) {
      _useMerchSubTitle = value;
    });

    _useSideMenuDarkModeToggleSub =
        getPrefStream('useSideMenuDarkModeToggle', true).listen((value) {
      _useSideMenuDarkModeToggle = value;
    });
    _showYcCountdownSub =
        getPrefStream('showYcCountdown', true).listen((value) {
      _showYcCountdown = value;
    });
    _useNotificationSystemV2Sub =
        getPrefStream('useNotificationSystemV2', false).listen((value) {
      _useNotificationSystemV2 = value;
    });

    _amoledModeSub = getPrefStream("amoledMode", false).listen((value) {
      _amoledMode = value;
    });

    _useCreatorThemeOnMainPageSub =
        getPrefStream('useCreatorThemeOnMainPage', false).listen((value) {
      _useCreatorThemeOnMainPage = value;
    });
    _useCreatorThemeSub =
        getPrefStream('useCreatorTheme', true).listen((value) {
      _useCreatorTheme = value;
    });

    _useCreatorThemeDarkSub =
        getPrefStream('useCreatorThemeDark', true).listen((value) {
      _useCreatorThemeDark = value;
    });

    return null;
  }

  bool get connected {
    return _connected != YConnectivityResult.none;
  }

  get loadImages {
    return _loadImages;
  }

  get loadBanner {
    return _loadBanner || _loadImages;
  }

  get loadProfile {
    return _loadProfile || _loadImages;
  }

  get loadTwitchThumbnail {
    return _loadTwitchThumbnail || _loadImages;
  }

  get loadYoutubeThumbnail {
    return _loadYoutubeThumbnail || _loadImages;
  }

  get youtubeSmallThumb {
    return _youtubeSmallThumb;
  }

  get twitchSmallThumb {
    return _twitchSmallThumb;
  }

  bool get darkMode {
    return _darkMode;
  }

  get amoledMode {
    return _amoledMode;
  }

  get vodIcons {
    return _vodIcons;
  }

  get useSideMenuDarkModeToggle {
    return _useSideMenuDarkModeToggle;
  }

  bool get useCreatorThemeOnMainPage {
    return _useCreatorThemeOnMainPage;
  }

  bool get useCreatorTheme {
    return _useCreatorTheme;
  }

  bool get useCreatorThemeDark {
    return _useCreatorThemeDark;
  }

  Quality get quality {
    if (_lowQualityImages || (!_wifi && _saveData)) {
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
        if (_lowQualityImages || _saveData || _twitchSmallThumb) {
          return TwitchQuality.medium;
        } else {
          return TwitchQuality.high;
        }
        break;
      case YConnectivityResult.mobileMedium:
        if (_lowQualityImages || _saveData || _youtubeSmallThumb) {
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
        if (_lowQualityImages || _saveData || _youtubeSmallThumb) {
          return YoutubeQuality.medium;
        } else {
          return YoutubeQuality.high;
        }
        break;
      case YConnectivityResult.mobileMedium:
        if (_lowQualityImages || _saveData || _youtubeSmallThumb) {
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

  Color get buttonColor {
    return darkMode ? YColors.accentColor : YColors.primaryColor;
  }

  Color get headerColor {
    return darkMode ? YColors.accentColor : YColors.primaryColor;
  }

  Color get textColor {
    return darkMode ? Colors.white : Colors.black;
  }

  get analytics {
    return _analytics;
  }

  get showNotificationIcon {
    return _showNotificationIcon;
  }

  get scheduleArt {
    return _scheduleArt;
  }

  get showScheduleAnimation => _showScheduleAnimation;

  get useMerchSubTitle => _useMerchSubTitle;

  get showYcCountdown => _showYcCountdown;

  get useNotificationSystemV2 => _useNotificationSystemV2;

  @override
  Future<bool> _getPref(String prefName, bool defaultValue) {
    return Prefs.getBool(prefName, defaultValue);
  }

  @override
  Future<Null> _setPref(String prefName, bool value) async {
    await Prefs.setBool(prefName, value);
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySub?.cancel();
    sub2?.cancel();
    sub3?.cancel();
    loadImagesSub?.cancel();
    _loadBannerSub?.cancel();
    _loadProfileSub?.cancel();
    _loadTwitchThumbnailSub?.cancel();
    _loadYoutubeThumbnailSub?.cancel();
    darkModeSub?.cancel();
    _vodIconsSub?.cancel();
    _youtubeSmallThumbSub?.cancel();
    _twitchSmallThumbSub?.cancel();
    _analyticsSub?.cancel();
    _showNotificationIconSub?.cancel();
    _scheduleArtSub?.cancel();
    _showScheduleAnimationSub?.cancel();
    _useMerchSubTitleSub?.cancel();
    _useSideMenuDarkModeToggleSub?.cancel();
    _showYcCountdownSub?.cancel();
    _useNotificationSystemV2Sub?.cancel();
    _amoledModeSub?.cancel();
    _useCreatorThemeOnMainPageSub?.cancel();
    _useCreatorThemeSub?.cancel();
    _useCreatorThemeDarkSub?.cancel();
  }
}