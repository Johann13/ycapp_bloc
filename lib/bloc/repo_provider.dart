import 'package:flutter/material.dart';
import 'package:ycapp_bloc/bloc/base_y_bloc.dart';

class RepoProvider extends StatefulWidget {
  final Widget child;
  final BaseYBloc yBloc;

  RepoProvider({
    Key key,
    @required this.child,
    @required this.yBloc,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _RepoProviderState();

  static BaseYBloc of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_RepoProvider>().bloc;
}

class _RepoProviderState extends State<RepoProvider> {
  BaseYBloc get _yBloc => widget.yBloc;

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
  final BaseYBloc bloc;

  _RepoProvider({Key key, @required Widget child, @required BaseYBloc bloc})
      : bloc = bloc,
        super(key: key, child: child);

  @override
  bool updateShouldNotify(_RepoProvider oldWidget) =>
      bloc != oldWidget.bloc; //true;
}
