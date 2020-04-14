import 'package:flutter/widgets.dart';
import 'package:ycapp_analytics/ycapp_analytics.dart';
import 'package:ycapp_bloc/bloc/base_y_bloc.dart';
import 'package:ycapp_bloc/bloc/repo_provider.dart';
import 'package:ycapp_bloc/misc/function_timer.dart';
import 'package:ycapp_bloc/misc/post_init.dart';
import 'package:ycapp_bloc/pref/settings_bloc.dart';
import 'package:ycapp_bloc/pref/settings_provider.dart';
import 'package:ycapp_foundation/ui/loader/base/y_builder.dart';
import 'package:ycapp_foundation/ui/loader/base/y_future_widgets.dart';

typedef Future<void> InitTimeDB(BuildContext context);

class BaseRoot extends StatelessWidget {
  final WidgetBuilder builder;
  final WidgetBuilder loading;
  final ErrorBuilder error;
  final InitTimeDB initTimeDB;
  final BaseYBloc yBloc;
  final SettingsBloc settingsBloc;
  final PostInit postInit;

  const BaseRoot({
    Key key,
    @required this.yBloc,
    @required this.settingsBloc,
    @required this.builder,
    @required this.loading,
    @required this.error,
    @required this.initTimeDB,
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
    await RepoProvider.of(context).initAnalytics();
    await initTimeDB(context);
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
    if (postInit != null) {
      await postInit();
    }
    return [true, true];
  }
}