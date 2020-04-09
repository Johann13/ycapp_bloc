import 'dart:async';

import 'package:firebase/firebase.dart' as fb;
import 'package:ycapp_bloc/pref/config/config_bloc.dart';

class ConfigBlocWeb extends ConfigBloc {
  fb.RemoteConfig remoteConfig;

  @override
  Future<Null> init() async {
    try {
      remoteConfig = await _getRemoteConfig();
    } catch (e) {
      print(e);
    }
  }

  Future<fb.RemoteConfig> _getRemoteConfig() async {
    final fb.RemoteConfig remoteConfig = fb.remoteConfig();
    remoteConfig.defaultConfig = defaults;
    await remoteConfig.fetchAndActivate();
    return remoteConfig;
  }

  @override
  String getString(String key) {
    if (remoteConfig == null) {
      return defaults[key] ?? '';
    }
    return remoteConfig.getString(key);
  }

  @override
  int getInt(String key) {
    if (remoteConfig == null) {
      return defaults[key] ?? 0;
    }
    return remoteConfig.getNumber(key);
  }

  @override
  bool getBool(String key) {
    if (remoteConfig == null) {
      return defaults[key] ?? true;
    }
    return remoteConfig.getBoolean(key);
  }
}
