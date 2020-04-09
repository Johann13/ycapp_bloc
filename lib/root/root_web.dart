import 'package:flutter/widgets.dart';
import 'package:timezone/browser.dart' as tz;
import 'package:ycapp_analytics/ycapp_analytics.dart';
import 'package:ycapp_bloc/bloc/repo_provider.dart';
import 'package:ycapp_bloc/misc/function_timer.dart';
import 'package:ycapp_bloc/pref/settings_bloc_web.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';
import 'package:ycapp_foundation/ui/loader/base/y_future_widgets.dart';

class RootWeb extends StatelessWidget {
  final WidgetBuilder builder;
  final WidgetBuilder loading;
  final ErrorBuilder error;

  const RootWeb({
    Key key,
    @required this.builder,
    @required this.loading,
    @required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsProviderWeb(
      child: RepoProvider(
        child: Builder(
          builder: (context) {
            return YFutureListBuilder<bool>(
              future: _init(context),
              errorBuilder: error,
              initialData: [false, false],
              loading: loading,
              builder: (context, list) {
                if ((!list[0] || !list[1])) {
                  return loading(context);
                }
                return builder(context);
              },
            );
          },
        ),
      ),
    );
  }

  Future<List<bool>> _init(BuildContext context) async {
    await RepoProvider.of(context).initAnalytics();

    //await initializeDateFormatting();
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

    Duration duration = await time('init', () async {
      try {
        await Future.wait([
          //_initTimezone(),
          SettingsProviderWeb.of(context).init(),
          RepoProvider.of(context).init(),
        ]);
      } catch (e) {
        print(e);
      }
    });
    print('init duration $duration');
    await YAnalytics.log('init', parameters: {
      'duration': duration.inMilliseconds,
    });
    return [true, true];
  }
}