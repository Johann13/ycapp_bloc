import 'dart:core';

import 'package:flutter/material.dart';
import 'package:ycapp_bloc/pref/settings_bloc.dart';

class SettingsProvider extends StatefulWidget {
  final Widget child;
  final SettingsBloc bloc;

  SettingsProvider({
    Key key,
    @required this.child,
    @required this.bloc,
  }) : super(key: key);

  @override
  _SettingsState createState() => _SettingsState();

  static SettingsBloc of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SettingsProvider>().bloc;
  }
}

class _SettingsState extends State<SettingsProvider> {
  @override
  Widget build(BuildContext context) {
    return _SettingsProvider(
      child: widget.child,
      bloc: widget.bloc,
    );
  }

  @override
  void dispose() {
    widget.bloc?.dispose();
    super.dispose();
  }
}

class _SettingsProvider extends InheritedWidget {
  final SettingsBloc bloc;

  _SettingsProvider({
    Key key,
    @required Widget child,
    @required this.bloc,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(_SettingsProvider oldWidget) =>
      bloc != oldWidget.bloc;
}
