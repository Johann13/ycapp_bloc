import 'dart:async';
import 'dart:core';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:ycapp_bloc/pref/settings_bloc.dart';

import 'file:///C:/Projects/ycapp_bloc/lib/pref/bool/boo_pref_mobile.dart';
import 'file:///C:/Projects/ycapp_bloc/lib/pref/config/confic_bloc_mobile.dart';

class SettingsBlocMobile
    extends SettingsBloc<BoolPrefMobile, ConfigBlocMobile> {
  @override
  Future<void> logUser() async {
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
  }
}
