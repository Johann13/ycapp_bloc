import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ycapp_analytics/ycapp_analytics.dart';
import 'package:ycapp_bloc/bloc/data_blocs/changelog_bloc.dart';
import 'package:ycapp_bloc/bloc/data_blocs/channel_blocs/podcast_bloc.dart';
import 'package:ycapp_bloc/bloc/data_blocs/channel_blocs/twitch_bloc.dart';
import 'package:ycapp_bloc/bloc/data_blocs/channel_blocs/youtube_bloc.dart';
import 'package:ycapp_bloc/bloc/data_blocs/creator_bloc.dart';
import 'package:ycapp_bloc/bloc/data_blocs/jj_schedule_bloc.dart';
import 'package:ycapp_bloc/bloc/data_blocs/news_bloc.dart';
import 'package:ycapp_bloc/bloc/data_blocs/poll_bloc.dart';
import 'package:ycapp_bloc/bloc/data_blocs/schedule.dart';
import 'package:ycapp_bloc/bloc/data_blocs/yogcon_bloc.dart';
import 'package:ycapp_foundation/prefs/prefs.dart';
import 'package:ycapp_messaging/ycapp_messaging.dart';

import 'file:///C:/Projects/ycapp_bloc/lib/misc/function_timer.dart';

class YBlocMobile {
  CreatorBloc creatorBloc;
  TwitchBloc twitchBloc;
  YoutubeBloc youtubeBloc;
  PollBloc pollBloc;
  ChangelogBloc changelogBloc;
  JJScheduleBloc jjScheduleBloc;
  ScheduleBloc scheduleBloc;
  NewsBloc newsBloc;
  PodcastBloc podcastBloc;
  YogconBloc yogconBloc;
  Firestore firestore;

  YBlocMobile() {
    print('YBloc');
    creatorBloc = CreatorBloc();
    twitchBloc = TwitchBloc();
    youtubeBloc = YoutubeBloc();
    pollBloc = PollBloc();
    changelogBloc = ChangelogBloc();
    scheduleBloc = ScheduleBloc();
    newsBloc = NewsBloc();
    podcastBloc = PodcastBloc();
    yogconBloc = YogconBloc();
    jjScheduleBloc = JJScheduleBloc();
  }

  Future<bool> init() async {
    await time('init()', () async {
      await Future.wait([
        time('main', () async {
          await time('Firestore.instance.settings', () async {
            await Firestore.instance.settings(
              persistenceEnabled: true,
              cacheSizeBytes: 5 * 1000 * 1000,
            );
          });
          await time('_init()', () async {
            await _init();
          });
          await time('_sub()', () async {
            await _sub();
          });
        }),
      ]);
    });

    return true;
  }

  Future<Null> initAnalytics() async {
    await time('analytics', () async {
      bool analytics = await Prefs.getBool('analyticsPermission', false);
      await YAnalytics.enable(analytics);
    });
  }

  Future<Null> _sub() async {
    bool fcmPermission = await Prefs.getBool('fcmPermission', false);

    if (!fcmPermission) {
      return null;
    }

    int lastSub = await Prefs.getInt('lastSub',
        DateTime.now().subtract(Duration(days: 4)).millisecondsSinceEpoch);

    DateTime now = DateTime.now();
    DateTime lastSubDate = DateTime.fromMillisecondsSinceEpoch(lastSub);

    Duration duration = now.difference(lastSubDate);

    print(duration);
    print(duration.inHours);
    if (duration.inHours >= 48) {
      print('resub topics');
      await Prefs.setInt('lastSub', now.millisecondsSinceEpoch);
      await time('forceSub()', () async {
        await forceSub();
      });
    } else {
      print('all topics up to date');
    }
    return null;
  }

  Future<Null> _init() async {
    await Future.wait([
      time('creatorBloc.initList', () async {
        await creatorBloc.initList();
      }),
      time('twitchBloc.initList', () async {
        await twitchBloc.initList();
      }),
      time('youtubeBloc.initList', () async {
        await youtubeBloc.initList();
      }),
      //notificationBloc.init(),
    ]);

    bool isFirstStart18 = await Prefs.getBool('isFirstSettingsStart18', true);

    if (isFirstStart18) {
      await Future.wait(youtubeBloc.subscriptionsList
          .map((id) => Prefs.remove('notificationFilterShowYoutube_$id')));
      await Prefs.remove('notificationFilterYoutube');
      await Prefs.remove('notificationFilterTwitch');
      await Prefs.setBool('isFirstSettingsStart18', false);
    }
  }

  Future<Null> clearDatabase() async {
    await forceUnsub();
    await Future.wait([
      twitchBloc.resetList(),
      youtubeBloc.resetList(),
      creatorBloc.resetList(),
    ]);
  }

  Future<void> forceSub() async {
    print('subscribe all topics');
    await YMessaging.subscribeToTopic('all');
    print('FirebaseChannel.subscribeToTopic');
    await Future.wait([
      time('creatorBloc.subscribeAll', () async {
        await creatorBloc.subscribeAll();
      }),
      time('twitchBloc.subscribeAll', () async {
        await twitchBloc.subscribeAll();
      }),
      time('youtubeBloc.subscribeAll', () async {
        await youtubeBloc.subscribeAll();
      }),
    ]);
  }

  Future<void> forceUnsub() async {
    print('unsubscribe all topics');
    await YMessaging.unsubscribeFromTopic('all');
    Future.wait([
      creatorBloc.unsubscribeAll(),
      twitchBloc.unsubscribeAll(),
      youtubeBloc.unsubscribeAll(),
    ]);
  }

  Future<void> unsubscribeFromTopic(String id) async {
    await YMessaging.unsubscribeFromTopic(id);
  }

  Future<Null> resetSubs() async {
    await forceUnsub();
    await forceSub();
  }

  void dispose() {
    print('YBloc dispose');
    creatorBloc?.dispose();
    twitchBloc?.dispose();
    youtubeBloc?.dispose();
  }
}
