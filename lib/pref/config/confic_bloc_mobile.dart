import 'dart:async';
import 'dart:math';

import 'package:connectivity/connectivity.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_async_builder/flutter_async_builder.dart';
import 'package:ycapp_bloc/pref/config/config_bloc.dart';

class ConfigBlocMobile extends ConfigBloc {
  RemoteConfig remoteConfig;

  @override
  Future<void> init() async {
    try {
      remoteConfig = await _getRemoteConfig();
    } catch (e) {
      print(e);
    }
  }

  Future<RemoteConfig> _getRemoteConfig() async {
    bool wifi =
        (await Connectivity().checkConnectivity()) == ConnectivityResult.wifi;
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
      return defaults[key] as String ?? '';
    }
    return remoteConfig.getString(key);
  }

  int getInt(String key) {
    if (remoteConfig == null) {
      return defaults[key] as int ?? 0;
    }
    return remoteConfig.getInt(key);
  }

  bool getBool(String key) {
    if (remoteConfig == null) {
      return defaults[key] as bool ?? true;
    }
    return remoteConfig.getBool(key);
  }

  List<String> _merchSubTitles = [];

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
    Random r = Random();
    var i = r.nextInt(_merchSubTitles.length);
    return _merchSubTitles[i];
  }

  List<String> get merchSubTitles => _merchSubTitles;
}

class RemoteConfigProvider extends StatelessWidget {
  final WidgetBuilder builder;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  const RemoteConfigProvider({
    Key key,
    @required this.builder,
    this.error,
    this.loading,
  }) : super(key: key);

  static ConfigBlocMobile of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_RemoteConfigProviderInh>()
        .config;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleFutureBuilder<ConfigBlocMobile>(
      future: _init(),
      loading: loading,
      error: error,
      builder: (_, config) {
        return _RemoteConfigProviderInh(
          config: config,
          child: builder(context),
        );
      },
    );
  }

  Future<ConfigBlocMobile> _init() async {
    ConfigBlocMobile configBlocMobile = ConfigBlocMobile();
    await configBlocMobile.init();
    return configBlocMobile;
  }
}

class _RemoteConfigProviderInh extends InheritedWidget {
  final ConfigBlocMobile config;

  const _RemoteConfigProviderInh({
    Key key,
    @required Widget child,
    @required this.config,
  })  : assert(child != null),
        super(key: key, child: child);

  @override
  bool updateShouldNotify(_RemoteConfigProviderInh old) {
    return true;
  }
}
