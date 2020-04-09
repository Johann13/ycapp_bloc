import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:timezone/timezone.dart';
import 'package:ycapp_analytics/ycapp_analytics.dart';
import 'package:ycapp_bloc/bloc/repo_provider.dart';
import 'package:ycapp_bloc/misc/function_timer.dart';
import 'package:ycapp_bloc/pref/settings_bloc_mobile.dart';
import 'package:ycapp_bloc/pref/settings_provider.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';
import 'package:ycapp_foundation/ui/loader/base/y_future_widgets.dart';

class RootMobile extends StatelessWidget {
  final WidgetBuilder builder;
  final WidgetBuilder loading;
  final ErrorBuilder error;

  const RootMobile({
    Key key,
    @required this.builder,
    @required this.loading,
    @required this.error,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsProvider(
      bloc: SettingsBlocMobile(),
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
    var byteData = await rootBundle.load('assets/2019c.tzf');
    initializeDatabase(byteData.buffer.asUint8List());

    Duration duration = await time('init', () async {
      try {
        await Future.wait([
          SettingsProvider.of(context).init(),
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
