import 'dart:async';
import 'dart:core';
import 'dart:math';

import 'package:device_info/device_info.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:ycapp_analytics/ycapp_analytics.dart';
import 'package:ycapp_bloc/bloc/data_blocs/web/bool_pref_web.dart';
import 'package:ycapp_bloc/bloc/data_blocs/web/confic_bloc_web.dart';
import 'package:ycapp_bloc/misc/function_timer.dart';
import 'package:ycapp_bloc/pref/pref_repo.dart';
import 'package:ycapp_foundation/ui/y_colors.dart';


class SettingsBlocWeb {
  BoolPrefWeb boolPref;
  IntPref intPref;
  DoublePref doublePref;
  StringPref stringPref;
  StringListPref stringListPref;
  ConfigBlocWeb remoteConfig;

  DeviceInfoPlugin deviceInfo;
  AndroidDeviceInfo androidInfo;

  List<String> _merchSubTitles = [];

  //StreamSubscription<String> _scheduleThemeSub;

  SettingsBlocWeb() {
    remoteConfig = ConfigBlocWeb();
    boolPref = BoolPrefWeb();
    intPref = IntPref();
    doublePref = DoublePref();
    stringPref = StringPref();
    stringListPref = StringListPref();
  }

  Future<bool> init() async {
    await time('init()', () async {
      await time('pref init', () async {
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
        time('_init()', () async {
          await _init();
          return null;
        }),
        _initRemoteConfig(),
      ]);
    });
    return true;
  }

  Future<Null> _initRemoteConfig() async {
    await time('remoteConfig.init()', () async {
      await remoteConfig.init();
    });
    await time('initMerchSubTitles()', () async {
      initMerchSubTitles();
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
      Analytics a = analytics();
      List<String> homePagePagePosition =
          await stringListPref.getPref('homePagePagePosition', []);
      a.setUserProperties({
        'homePagePagePosition': '$homePagePagePosition',
        'darkMode': '${boolPref.darkMode}',
        'timeZone': '${DateTime.now().toLocal().timeZoneName}'
      });
      await intPref.setPref('lastLog', now.millisecondsSinceEpoch);
    } else {
      print('lastLog not requiered');
    }
  }

  void initMerchSubTitles() {
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

  /*
  Future<void> setUserProperty(String name, String value) async {
    if (boolPref.analytics) {
      await _firebaseAnalytics.setUserProperty(name: name, value: value);
    }
  }*/

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

class SettingsProviderWeb extends StatefulWidget {
  final Widget child;

  SettingsProviderWeb({Key key, @required this.child}) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();

  static SettingsBlocWeb of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SettingsProvider>().bloc;
  }
}

class _SettingsState extends State<SettingsProviderWeb> {
  SettingsBlocWeb bloc;

  @override
  void initState() {
    super.initState();
    bloc = SettingsBlocWeb();
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsProvider(child: widget.child, bloc: bloc);
  }

  @override
  void dispose() {
    bloc?.dispose();
    super.dispose();
  }
}

class _SettingsProvider extends InheritedWidget {
  final SettingsBlocWeb bloc;

  _SettingsProvider({Key key, @required Widget child, @required this.bloc})
      : super(key: key, child: child);

  @override
  bool updateShouldNotify(_SettingsProvider oldWidget) =>
      bloc != oldWidget.bloc;
}
