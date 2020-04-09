import 'package:flutter/material.dart';
import 'package:ycapp_bloc/pref/settings_provider.dart';
import 'package:ycapp_bloc/ui/loader/pref_data_loader.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';
import 'package:ycapp_foundation/ui/loader/base/y_future_widgets.dart';
import 'package:ycapp_foundation/ui/loader/base/y_stream_widgets.dart';

typedef Widget YSettingsBuilder<T>(BuildContext context, T data);

typedef Widget YSettingsErrorBuilder(BuildContext context, Error error);

typedef Widget YSettingsLoadingBuilder(BuildContext context);

class PrefBoolFuture extends StatelessWidget {
  final String pref;
  final YSettingsBuilder<bool> builder;
  final bool defaultValue;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  PrefBoolFuture({
    @required this.pref,
    @required this.builder,
    this.defaultValue = false,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return YFutureBuilder<bool>(
      future: SettingsProvider.of(context).boolPref.getPref(pref, defaultValue),
      builder: builder,
      error: error,
      loading: loading,
    );
  }
}

class PrefBoolStream extends StatelessWidget {
  final String pref;
  final YSettingsBuilder<bool> builder;
  final bool defaultValue;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  PrefBoolStream({
    @required this.pref,
    @required this.builder,
    this.defaultValue = false,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return BoolStreamBuilder(
      stream: SettingsProvider.of(context)
          .boolPref
          .getPrefStream(pref, defaultValue),
      builder: builder,
      error: error,
      loading: loading,
    );
  }
}

class PrefBoolListStream extends StatelessWidget {
  final List<String> prefs;
  final YSettingsBuilder<List<bool>> builder;
  final List<bool> defaultValues;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  PrefBoolListStream({
    @required this.prefs,
    @required this.builder,
    @required this.defaultValues,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return BoolListStreamBuilder(
      stream: SettingsProvider.of(context)
          .boolPref
          .getMultiplePrefsStream(prefs, defaultValues),
      builder: builder,
      error: error,
      loading: loading,
    );
  }
}

class PrefStringStream extends StatelessWidget {
  final String pref;
  final YSettingsBuilder<String> builder;
  final String defaultValue;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  PrefStringStream({
    @required this.pref,
    @required this.builder,
    this.defaultValue = '',
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return YStreamBuilder<String>(
      stream: SettingsProvider.of(context)
          .stringPref
          .getPrefStream(pref, defaultValue),
      builder: builder,
      error: error,
      loading: loading,
    );
  }
}

class PrefIntStream extends StatelessWidget {
  final String pref;
  final YSettingsBuilder<int> builder;
  final int defaultValue;
  final ErrorBuilder error;
  final WidgetBuilder loading;

  PrefIntStream({
    @required this.pref,
    @required this.builder,
    @required this.defaultValue,
    this.error,
    this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return YStreamBuilder<int>(
      stream: SettingsProvider.of(context)
          .intPref
          .getPrefStream(pref, defaultValue),
      builder: builder,
      error: error,
      loading: loading,
    );
  }
}

class PrefDoubleStream extends PrefStream<double> {
  PrefDoubleStream({
    Key key,
    @required String pref,
    @required YSettingsBuilder<double> builder,
    @required double defaultValue,
    Widget error,
    Widget loading,
  }) : super(
          key: key,
          pref: pref,
          builder: builder,
          defaultValue: defaultValue,
          error: error,
          loading: loading,
        );
}

class PrefStream<T> extends StatelessWidget {
  final String pref;
  final YSettingsBuilder<T> builder;
  final T defaultValue;
  final Widget error;
  final Widget loading;

  const PrefStream({
    Key key,
    this.pref,
    this.builder,
    this.defaultValue,
    this.error,
    this.loading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _stream();
  }

  Widget _stream() {
    if (T is String) {
      return PrefStringStream(
        pref: pref,
        defaultValue: defaultValue as String,
        builder: builder as YSettingsBuilder<String>,
      );
    } else if (T is int) {
      return PrefIntStream(
        pref: pref,
        defaultValue: defaultValue as int,
        builder: builder as YSettingsBuilder<int>,
      );
    } else if (T is double) {
      return PrefDoubleStream(
        pref: pref,
        defaultValue: defaultValue as double,
        builder: builder as YSettingsBuilder<double>,
      );
    } else if (T is bool) {
      return PrefBoolStream(
        pref: pref,
        defaultValue: defaultValue as bool,
        builder: builder as YSettingsBuilder<bool>,
      );
    } else if (T is List) {
      return PrefBoolStream(
        pref: pref,
        defaultValue: defaultValue as bool,
        builder: builder as YSettingsBuilder<bool>,
      );
    }
    return Container();
  }
}
