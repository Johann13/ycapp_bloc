import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';
import 'package:ycapp_foundation/ui/loader/base/y_stream_widgets.dart';

class BoolStreamBuilder extends YStreamBuilder<bool> {
  BoolStreamBuilder({
    @required Stream<bool> stream,
    @required YDataBuilder<bool> builder,
    ErrorBuilder error,
    WidgetBuilder loading,
    bool initialData,
  }) : super(
          stream: stream,
          builder: builder,
          error: error,
          loading: loading,
          initialData: initialData,
        );
}

class BoolListStreamBuilder extends YStreamListBuilder<bool> {
  BoolListStreamBuilder({
    @required Stream<List<bool>> stream,
    @required YDataBuilder<List<bool>> builder,
    ErrorBuilder error,
    WidgetBuilder loading,
    List<bool> initialData,
  }) : super(
          stream: stream,
          builder: builder,
          error: error,
          loading: loading,
          initialData: initialData,
        );
}
