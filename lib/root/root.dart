import 'package:flutter/widgets.dart';
import 'package:ycapp_analytics/ycapp_analytics.dart';
import 'package:ycapp_bloc/bloc/y_bloc.dart';
import 'package:ycapp_bloc/bloc/repo_provider.dart';
import 'package:ycapp_bloc/misc/function_timer.dart';
import 'package:ycapp_bloc/misc/post_init.dart';
import 'package:ycapp_bloc/pref/settings_bloc.dart';
import 'package:ycapp_bloc/pref/settings_provider.dart';
import 'package:ycapp_bloc/root/base_root.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';
import 'package:ycapp_foundation/ui/loader/base/y_future_widgets.dart';

class Root extends StatelessWidget {
  final WidgetBuilder builder;
  final WidgetBuilder loading;
  final ErrorBuilder error;
  final InitTimeDB initTimeDB;
  final YBloc yBloc;
  final SettingsBloc settingsBloc;
  final PostInit postInit;
  final bool analytics;
  final bool logTime;

  const Root({
    Key key,
    @required this.yBloc,
    @required this.settingsBloc,
    @required this.builder,
    @required this.loading,
    @required this.error,
    @required this.initTimeDB,
    this.analytics = true,
    this.logTime = false,
    this.postInit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsProvider(
      bloc: settingsBloc,
      child: RepoProvider(
        yBloc: yBloc,
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
    await RepoProvider.of(context).initAnalytics(analytics);
    await initTimeDB(context);
    Duration duration = await time('init', logTime, () async {
      try {
        await Future.wait([
          SettingsProvider.of(context).init(),
          RepoProvider.of(context).init(),
        ]);
      } catch (e) {
        print(e);
      }
    });
    if (duration != null) {
      print('init duration $duration');
    }
    await YAnalytics.log('init', parameters: {
      'duration': duration.inMilliseconds,
    });
    if (postInit != null) {
      await postInit();
    }
    return [true, true];
  }
}
