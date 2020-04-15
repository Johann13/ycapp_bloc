import 'package:flutter/widgets.dart';
import 'package:timezone/browser.dart' as tz;
import 'package:ycapp_bloc/bloc/y_bloc_mobile.dart';
import 'package:ycapp_bloc/misc/post_init.dart';
import 'package:ycapp_bloc/pref/settings_bloc_web.dart';
import 'package:ycapp_bloc/root/base_root.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';

class RootWeb extends StatelessWidget {
  final WidgetBuilder builder;
  final WidgetBuilder loading;
  final ErrorBuilder error;
  final PostInit postInit;
  final bool analytics;
  final InitTimeDB initTimeDB;

  const RootWeb({
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
      settingsBloc: SettingsBlocWeb(),
      initTimeDB: initTimeDB != null
          ? initTimeDB(context)
          : (context) async {
              try {
                await tz.initializeTimeZone('assets/2019c.tzf');
              } catch (e) {
                print('could not load assets/2019c.tzf');
                print('assets/2019c.tzf: $e');
                try {
                  await tz.initializeTimeZone('assets/assets/2019c.tzf');
                } catch (e1) {
                  print('could not load assets/assets/2019c.tzf');
                  print('assets/assets/2019c.tzf: $e1');
                  try {
                    await tz.initializeTimeZone();
                  } catch (e2) {
                    print('could not load default');
                    print('default: $e2');
                  }
                }
              }
            },
      loading: loading,
      error: error,
      builder: builder,
      postInit: postInit,
    );
  }
}
