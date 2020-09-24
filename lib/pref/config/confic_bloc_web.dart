import 'dart:async';

import 'package:firebase/firebase.dart' as fb;
import 'package:flutter/widgets.dart';
import 'package:flutter_async_builder/flutter_async_builder.dart';
import 'package:ycapp_bloc/pref/config/config_bloc.dart';

class ConfigBlocWeb extends ConfigBloc {
  fb.RemoteConfig remoteConfig;

  @override
  Future<void> init() async {
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

  static ConfigBlocWeb of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_RemoteConfigProviderInh>()
        .config;
  }

  @override
  Widget build(BuildContext context) {
    return SimpleFutureBuilder<ConfigBlocWeb>(
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

  Future<ConfigBlocWeb> _init() async {
    ConfigBlocWeb configBlocMobile = ConfigBlocWeb();
    await configBlocMobile.init();
    return configBlocMobile;
  }
}

class _RemoteConfigProviderInh extends InheritedWidget {
  final ConfigBlocWeb config;

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
