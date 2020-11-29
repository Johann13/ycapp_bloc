import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:reactive_preferences/prefs/shared_preference_prefs_impl.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ycapp_foundation/dates/y_date.dart';
import 'package:ycapp_foundation/model/channel/image_quality.dart';
import 'package:ycapp_foundation/ui/y_colors.dart';

class PrefProvider extends InheritedWidget {
  final YcAppPrefs prefs;

  const PrefProvider({
    Key key,
    @required Widget child,
    @required this.prefs,
  })  : assert(child != null),
        super(key: key, child: child);

  static YcAppPrefs of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PrefProvider>().prefs;
  }

  @override
  bool updateShouldNotify(PrefProvider old) {
    return false;
  }
}

class YcAppPrefs extends SharedPreferencePref {
  YcAppPrefs(SharedPreferences preferences) : super(preferences);
}

extension DirectPrefs on YcAppPrefs {
  MaterialColor get primaryColorOnce {
    switch (themeNameOnce) {
      case 'orange':
        return YColors.accentColor;
      default:
        return YColors.primaryColor;
    }
  }

  MaterialColor get accentColorOnce {
    switch (themeNameOnce) {
      case 'orange':
        return YColors.primaryColor;
      default:
        return YColors.accentColor;
    }
  }

  ThemeData get themeOnce {
    String t = themeNameOnce;
    bool dark = darkModeOnce;
    bool amoled = amoledModeOnce;
    if (YDates.useJJTheme) {
      if (dark) {
        return ThemeData(
          brightness: (!dark) ? Brightness.light : Brightness.dark,
          scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
          primarySwatch: YColors.jingleJamAccent,
          accentColor: YColors.jingleJamPrimary,
          cardColor: dark && amoled ? Colors.black : null,
        );
      }
      return ThemeData(
        brightness: (!dark) ? Brightness.light : Brightness.dark,
        scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
        primarySwatch: YColors.jingleJamPrimary,
        accentColor: YColors.jingleJamAccent,
        cardColor: dark && amoled ? Colors.black : null,
      );
    }
    switch (t) {
      case 'orange':
        return ThemeData(
          brightness: (!dark) ? Brightness.light : Brightness.dark,
          scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
          accentColor: YColors.primaryColor,
          primarySwatch: YColors.accentColor,
          cardColor: dark && amoled ? Colors.black : null,
        );
      case 'jj':
        return ThemeData(
          brightness: (!dark) ? Brightness.light : Brightness.dark,
          scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
          primarySwatch: YColors.jingleJamPrimary,
          accentColor: YColors.jingleJamAccent,
          cardColor: dark && amoled ? Colors.black : null,
        );
      default:
        return ThemeData(
          brightness: (!dark) ? Brightness.light : Brightness.dark,
          scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
          primarySwatch: YColors.primaryColor,
          accentColor: YColors.accentColor,
          cardColor: dark && amoled ? Colors.black : null,
        );
    }
  }

  Color get settingsHeaderColor {
    return darkModeOnce ? YColors.accentColor : YColors.primaryColor;
  }

  String get themeNameOnce => getOnce('theme', 'blue');

  bool get saveDataOnce => getOnce('saveData', true);

  bool get lowQualityImagesOnce => getOnce('lowQualityImages', false);

  bool get loadImagesOnce => getOnce('loadImages', true);

  bool get loadBannerOnce => getOnce('loadBanner', true);

  bool get loadProfileOnce => getOnce('loadProfile', true);

  bool get loadTwitchThumbnailOnce => getOnce('loadTwitchThumbnail', true);

  bool get loadYoutubeThumbnailOnce => getOnce('loadYoutubeThumbnail', true);

  bool get youtubeSmallThumbOnce => getOnce('youtubeSmallThumb', true);

  bool get twitchSmallThumbOnce => getOnce('twitchSmallThumb', false);

  bool get darkModeOnce => getOnce('darkMode', false);

  bool get vodIconsOnce => getOnce('vodIcons', true);

  bool get analyticsPermissionOnce => getOnce('analyticsPermission', false);

  bool get showNotificationIconOnce => getOnce('showNotificationIcon', true);

  bool get scheduleArtOnce => getOnce('scheduleArt', true);

  bool get showScheduleAnimationOnce => getOnce('showScheduleAnimation', true);

  bool get useMerchSubTitleOnce => getOnce('useMerchSubTitle', true);

  bool get useSideMenuDarkModeToggleOnce =>
      getOnce('useSideMenuDarkModeToggle', true);

  bool get showYcCountdownOnce => getOnce('showYcCountdown', true);

  bool get useNotificationSystemV2Once =>
      getOnce('useNotificationSystemV2', false);

  bool get amoledModeOnce => getOnce("amoledMode", false);

  bool get useCreatorThemeOnMainPageOnce =>
      getOnce('useCreatorThemeOnMainPage', false);

  bool get useCreatorThemeOnce => getOnce('useCreatorTheme', true);

  bool get useCreatorThemeDarkOnce => getOnce('useCreatorThemeDark', true);

  String get scheduleThemeOnce => getOnce('scheduleTheme', 'yogs');

  int get gridSizeOnce => getOnce('gridSize', 3);

  YoutubeQuality get youtubeQualityOnce {
    return YoutubeQuality.medium;
    /*
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
    }*/
  }

  Color get buttonColorOnce {
    return darkModeOnce ? YColors.accentColor : YColors.primaryColor;
  }

  Color get textColorOnce {
    return darkModeOnce ? Colors.white : Colors.black;
  }

  Color get headerColorOnce {
    return darkModeOnce ? YColors.accentColor : YColors.primaryColor;
  }

  TwitchQuality get twitchQualityOnce {
    return TwitchQuality.medium;
  }
}

extension StreamPrefs on YcAppPrefs {
  Stream<MaterialColor> get primaryColor {
    return themeName.map((event) {
      switch (event) {
        case 'orange':
          return YColors.accentColor;
        default:
          return YColors.primaryColor;
      }
    });
  }

  Stream<MaterialColor> get accentColor {
    return themeName.map((event) {
      switch (event) {
        case 'orange':
          return YColors.primaryColor;
        default:
          return YColors.accentColor;
      }
    });
  }

  Stream<ThemeData> get theme {
    return CombineLatestStream.list([
      themeName,
      darkMode,
      amoledMode,
    ]).map((list) {
      String t = list[0] as String;
      bool dark = list[1] as bool;
      bool amoled = list[2] as bool;
      if (YDates.useJJTheme) {
        if (dark) {
          return ThemeData(
            brightness: (!dark) ? Brightness.light : Brightness.dark,
            scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
            primarySwatch: YColors.jingleJamAccent,
            accentColor: YColors.jingleJamPrimary,
            cardColor: dark && amoled ? Colors.black : null,
            appBarTheme: AppBarTheme(
              brightness: Brightness.light,
              color: YColors.jingleJamPrimary,
            ),
          );
        }
        return ThemeData(
          brightness: (!dark) ? Brightness.light : Brightness.dark,
          scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
          primarySwatch: YColors.jingleJamPrimary,
          accentColor: YColors.jingleJamAccent,
          cardColor: dark && amoled ? Colors.black : null,
        );
      }
      switch (t) {
        case 'orange':
          return ThemeData(
            brightness: (!dark) ? Brightness.light : Brightness.dark,
            scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
            accentColor: YColors.primaryColor,
            primarySwatch: YColors.accentColor,
            cardColor: dark && amoled ? Colors.black : null,
          );
        case 'jj':
          if (dark) {
            return ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
              primarySwatch: YColors.jingleJamAccent,
              accentColor: YColors.jingleJamPrimary,
              cardColor: dark && amoled ? Colors.black : null,
              appBarTheme: AppBarTheme(
                brightness: Brightness.light,
                color: YColors.jingleJamPrimary,
              ),
            );
          }
          return ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
            primarySwatch: YColors.jingleJamPrimary,
            accentColor: YColors.jingleJamAccent,
            cardColor: dark && amoled ? Colors.black : null,
          );
        default:
          return ThemeData(
            brightness: (!dark) ? Brightness.light : Brightness.dark,
            scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
            primarySwatch: YColors.primaryColor,
            accentColor: YColors.accentColor,
            cardColor: dark && amoled ? Colors.black : null,
          );
      }
    });
  }

  Stream<Color> get settingsHeaderColor {
    return darkMode
        .map((event) => event ? YColors.accentColor : YColors.primaryColor);
  }

  Stream<String> get themeName => get('theme', 'blue');

  Stream<bool> get saveData => get('saveData', true);

  Stream<bool> get lowQualityImages => get('lowQualityImages', false);

  Stream<bool> get loadImages => get('loadImages', true);

  Stream<bool> get loadBanner => get('loadBanner', true);

  Stream<bool> get loadProfile => get('loadProfile', true);

  Stream<bool> get loadTwitchThumbnail => get('loadTwitchThumbnail', true);

  Stream<bool> get loadYoutubeThumbnail => get('loadYoutubeThumbnail', true);

  Stream<bool> get youtubeSmallThumb => get('youtubeSmallThumb', true);

  Stream<bool> get twitchSmallThumb => get('twitchSmallThumb', false);

  Stream<bool> get darkMode => get('darkMode', false);

  Stream<bool> get vodIcons => get('vodIcons', true);

  Stream<bool> get analyticsPermission => get('analyticsPermission', false);

  Stream<bool> get showNotificationIcon => get('showNotificationIcon', true);

  Stream<bool> get scheduleArt => get('scheduleArt', true);

  Stream<bool> get showScheduleAnimation => get('showScheduleAnimation', true);

  Stream<bool> get useMerchSubTitle => get('useMerchSubTitle', true);

  Stream<bool> get useSideMenuDarkModeToggle =>
      get('useSideMenuDarkModeToggle', true);

  Stream<bool> get showYcCountdown => get('showYcCountdown', true);

  Stream<bool> get useNotificationSystemV2 =>
      get('useNotificationSystemV2', false);

  Stream<bool> get amoledMode => get("amoledMode", false);

  Stream<bool> get useCreatorThemeOnMainPage =>
      get('useCreatorThemeOnMainPage', false);

  Stream<bool> get useCreatorTheme => get('useCreatorTheme', true);

  Stream<bool> get useCreatorThemeDark => get('useCreatorThemeDark', true);

  Stream<String> get scheduleTheme => get('scheduleTheme', 'yogs');

  Stream<int> get gridSize => get('gridSize', 3);

  Stream<Color> get buttonColor {
    return darkMode
        .map((event) => event ? YColors.accentColor : YColors.primaryColor);
  }

  Stream<Color> get textColor {
    return darkMode.map((event) => event ? Colors.white : Colors.black);
  }

  Stream<Color> get headerColor {
    return darkMode
        .map((event) => event ? YColors.accentColor : YColors.primaryColor);
  }
}
