import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:timezone/timezone.dart';
import 'package:ycapp_bloc/bloc/y_bloc_mobile.dart';
import 'package:ycapp_bloc/misc/post_init.dart';
import 'package:ycapp_bloc/pref/settings_bloc_mobile.dart';
import 'package:ycapp_bloc/root/base_root.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';

class RootMobile extends StatelessWidget {
  final WidgetBuilder builder;
  final WidgetBuilder loading;
  final ErrorBuilder error;
  final PostInit postInit;
  final bool analytics;
  final InitTimeDB initTimeDB;

  const RootMobile({
    Key key,
    @required this.builder,
    @required this.loading,
    @required this.error,
    this.analytics = true,
    this.initTimeDB,
    this.postInit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseRoot(
      analytics: analytics,
      yBloc: YBlocMobile(),
      settingsBloc: SettingsBlocMobile(),
      initTimeDB: initTimeDB != null
          ? initTimeDB(context)
          : (context) async {
              var byteData = await rootBundle.load('assets/2019c.tzf');
              initializeDatabase(byteData.buffer.asUint8List());
            },
      loading: loading,
      error: error,
      builder: builder,
      postInit: postInit,
    );
  }
}
