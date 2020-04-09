import 'package:flutter/material.dart';
import 'package:ycapp_bloc/bloc/y_bloc_mobile.dart';

class RepoProvider extends StatefulWidget {
  final Widget child;

  RepoProvider({Key key, @required this.child}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RepoProviderState();

  static YBlocMobile of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RepoProvider>().bloc;
}

class _RepoProviderState extends State<RepoProvider> {
  YBlocMobile _yBloc;

  @override
  void initState() {
    super.initState();
    _yBloc = new YBlocMobile();
  }

  @override
  Widget build(BuildContext context) {
    return _RepoProvider(
      bloc: _yBloc,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _yBloc?.dispose();
    super.dispose();
  }
}

class _RepoProvider extends InheritedWidget {
  final YBlocMobile bloc;

  _RepoProvider({Key key, @required Widget child, @required YBlocMobile bloc})
      : bloc = bloc,
        super(key: key, child: child);

  @override
  bool updateShouldNotify(_RepoProvider oldWidget) =>
      bloc != oldWidget.bloc; //true;
}
