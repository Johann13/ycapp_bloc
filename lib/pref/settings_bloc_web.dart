import 'dart:async';
import 'dart:core';

import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:ycapp_bloc/pref/settings_bloc.dart';

import 'file:///C:/Projects/ycapp_bloc/lib/pref/bool/bool_pref_web.dart';
import 'file:///C:/Projects/ycapp_bloc/lib/pref/config/confic_bloc_web.dart';

class SettingsBlocWeb extends SettingsBloc<BoolPrefWeb, ConfigBlocWeb> {
  @override
  Future<void> logUser() async {
    Analytics a = analytics();
    List<String> homePagePagePosition =
        await stringListPref.getPref('homePagePagePosition', []);
    a.setUserProperties({
      'homePagePagePosition': '$homePagePagePosition',
      'darkMode': '${boolPref.darkMode}',
      'timeZone': '${DateTime.now().toLocal().timeZoneName}'
    });
  }
}
