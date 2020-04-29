import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ycapp_analytics/ycapp_analytics.dart';
import 'package:ycapp_bloc/misc/function_timer.dart';
import 'package:ycapp_bloc/pref/bool/bool_pref.dart';
import 'package:ycapp_bloc/pref/config/config_bloc.dart';
import 'package:ycapp_bloc/pref/pref_repo.dart';
import 'package:ycapp_foundation/ui/y_colors.dart';

abstract class SettingsBloc<B extends BoolPref, C extends ConfigBloc> {
  IntPref intPref;
  DoublePref doublePref;
  StringPref stringPref;
  StringListPref stringListPref;
  B boolPref;
  C remoteConfig;
  final bool logTime;

  List<String> _merchSubTitles = [];

  SettingsBloc({
    this.logTime = false,
  }) {
    intPref = IntPref();
    doublePref = DoublePref();
    stringPref = StringPref();
    stringListPref = StringListPref();
  }

  Future<bool> init() async {
    await time('init()', logTime, () async {
      await time('pref init', logTime, () async {
        await Future.wait([
          boolPref.init(),
          stringPref.init(),
          intPref.init(),
          stringListPref.init(),
          doublePref.init(),
        ]);
        return null;
      });
      await Future.wait([
        time('_init()', logTime, () async {
          await _init();
          return null;
        }),
        _initRemoteConfig(),
      ]);
    });
    return true;
  }

  Future<void> logUser();

  Future<void> _initRemoteConfig() async {
    await time('remoteConfig.init()', logTime, () async {
      await remoteConfig.init();
    });
    await time('initMerchSubTitles()', logTime, () async {
      _initMerchSubTitles();
    });
  }

  Future<bool> _init() async {
    await _logUserProperties();
    bool isFirstStart1042 =
        await boolPref.getPref('isFirstSettingsStart1042', true);
    if (isFirstStart1042) {
      List<String> list = await stringListPref.getPref(
        'homePagePagePosition',
        [
          'news',
          'my_jj_schedule',
          'jj_schedule',
          'main_schedule',
          'creator',
          'twitch',
          'youtube',
          'notification_inbox',
          'menu',
        ],
      );
      if (!list.contains('jj_schedule')) {
        list.add('jj_schedule');
      }
      await stringListPref.setPref(
        'homePagePagePosition',
        list,
      );
      await stringListPref.setPref('jjNotiIds', []);
      await boolPref.setPref('show_' + 'jj_schedule' + '_page', false);
      await boolPref.setPref('isFirstSettingsStart1042', false);
    }

    bool version109 = await boolPref.getPref('version109', true);
    if (version109) {
      await boolPref.setPref('useCreatorThemeOnMainPage', true);
      await boolPref.setPref('version109', false);
    }
    return true;
  }

  Future<void> _logUserProperties() async {
    print('_logUserProperties');
    bool analyticsPermission =
        await boolPref.getPref('analyticsPermission', false);

    if (!analyticsPermission) {
      return;
    }

    int lastLog = await intPref.getPref('lastLog',
        DateTime.now().subtract(Duration(days: 7)).millisecondsSinceEpoch);

    DateTime now = DateTime.now();
    DateTime lastLogDate = DateTime.fromMillisecondsSinceEpoch(lastLog);

    Duration duration = now.difference(lastLogDate);

    await YAnalytics.logUserSub(2 * 24);

    if (duration.inHours >= 7 * 24) {
      await logUser();
      /*
      FirebaseAnalytics analytics = FirebaseAnalytics();

      List<String> homePagePagePosition =
      await stringListPref.getPref('homePagePagePosition', []);
      await analytics.setUserProperty(
          name: 'homePagePagePosition', value: '$homePagePagePosition');
      await analytics.setUserProperty(
          name: 'darkMode', value: '${boolPref.darkMode}');

      await analytics.setUserProperty(
          name: 'timeZone', value: '${DateTime.now().toLocal().timeZoneName}');
      await analytics.setUserProperty(
          name: 'timeZone', value: '${DateTime.now().toLocal().timeZoneName}');
      */

      await intPref.setPref('lastLog', now.millisecondsSinceEpoch);
    } else {
      print('lastLog not requiered');
    }
  }

  void _initMerchSubTitles() {
    List<String> strings = remoteConfig.getString('merchSubTitles').split('|');
    for (var i = 0; i < strings.length; i++) {
      if (strings[i].contains(':')) {
        List<String> list = strings[i].split(':');
        if (list[0].isNotEmpty) {
          int change = int.tryParse(list[0]) ?? 1;
          for (int i = 0; i < change; i++) {
            _merchSubTitles.add(list[1]);
          }
        } else {
          _merchSubTitles.add(list[1]);
        }
      } else {
        _merchSubTitles.add(strings[i]);
      }
    }
    _merchSubTitles.shuffle();
  }

  String getMerchSubTitle() {
    if (!boolPref.useMerchSubTitle) {
      return null;
    }
    if (_merchSubTitles == null) {
      return null;
    }
    if (_merchSubTitles.isEmpty) {
      return null;
    }
    Random r = Random();
    var i = r.nextInt(_merchSubTitles.length);
    return _merchSubTitles[i];
  }

  List<String> get merchSubTitles => _merchSubTitles;

  MaterialColor get primaryColor {
    String t = stringPref.theme;
    switch (t) {
      case 'orange':
        return YColors.accentColorPallet;
      default:
        return YColors.primaryColorPallet;
    }
  }

  MaterialColor get accentColor {
    String t = stringPref.theme;
    switch (t) {
      case 'orange':
        return YColors.primaryColorPallet;
      default:
        return YColors.accentColorPallet;
    }
  }

  ThemeData get theme {
    String t = stringPref.theme;
    bool dark = boolPref.darkMode;
    bool amoled = boolPref.amoledMode;
    switch (t) {
      case 'orange':
        return ThemeData(
          brightness: (!dark) ? Brightness.light : Brightness.dark,
          scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
          accentColor: YColors.primaryColorPallet,
          primarySwatch: YColors.accentColorPallet,
          cardColor: dark && amoled ? Colors.black : null,
        );
      default:
        return ThemeData(
          brightness: (!dark) ? Brightness.light : Brightness.dark,
          scaffoldBackgroundColor: (dark && amoled) ? Colors.black : null,
          primarySwatch: YColors.primaryColorPallet,
          accentColor: YColors.accentColorPallet,
          cardColor: dark && amoled ? Colors.black : null,
        );
    }
  }

  Color get settingsHeaderColor {
    return boolPref.darkMode ? YColors.accentColor : YColors.primaryColor;
  }

  void dispose() {
    boolPref?.dispose();
    intPref?.dispose();
    doublePref?.dispose();
    stringPref?.dispose();
    stringListPref?.dispose();
  }
}
