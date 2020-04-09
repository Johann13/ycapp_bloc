import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:ycapp_bloc/pref/config/config_bloc.dart';
import 'package:ycapp_connectivity/ycappconnectivity.dart';

class ConfigBlocMobile extends ConfigBloc {
  RemoteConfig remoteConfig;

  @override
  Future<Null> init() async {
    try {
      remoteConfig = await _getRemoteConfig();
    } catch (e) {
      print(e);
    }
  }

  Future<RemoteConfig> _getRemoteConfig() async {
    bool wifi = await YConnectivity().isConnectedWifi();
    if (!wifi) {
      return null;
    }
    final RemoteConfig remoteConfig = await RemoteConfig.instance;
    remoteConfig.setConfigSettings(RemoteConfigSettings(debugMode: false));
    remoteConfig.setDefaults(defaults);
    await remoteConfig.fetch(expiration: const Duration(hours: 12));

    await remoteConfig.activateFetched();

    return remoteConfig;
  }

  String getString(String key) {
    if (remoteConfig == null) {
      return defaults[key] ?? '';
    }
    return remoteConfig.getString(key);
  }

  int getInt(String key) {
    if (remoteConfig == null) {
      return defaults[key] ?? 0;
    }
    return remoteConfig.getInt(key);
  }

  bool getBool(String key) {
    if (remoteConfig == null) {
      return defaults[key] ?? true;
    }
    return remoteConfig.getBool(key);
  }
}
