import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:ycapp_analytics/ycapp_analytics.dart';
import 'package:ycapp_bloc/misc/function_timer.dart';
import 'package:ycapp_foundation/prefs/prefs.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'data_blocs/changelog_bloc.dart';
import 'data_blocs/channel_blocs/podcast_bloc.dart';
import 'data_blocs/channel_blocs/twitch_bloc.dart';
import 'data_blocs/channel_blocs/youtube_bloc.dart';
import 'data_blocs/creator_bloc.dart';
import 'data_blocs/jj_schedule_bloc.dart';
import 'data_blocs/news_bloc.dart';
import 'data_blocs/poll_bloc.dart';
import 'data_blocs/schedule_bloc.dart';
import 'data_blocs/yogcon_bloc.dart';

class YBloc {
  CreatorBloc creator;
  TwitchBloc twitch;
  YoutubeBloc youtube;
  PollBloc poll;
  ChangelogBloc changelog;
  JJScheduleBloc jjSchedule;
  ScheduleBloc schedule;
  NewsBloc news;
  PodcastBloc podcast;
  YogconBloc yogcon;

  final bool logTime;

  YBloc({
    this.logTime = kDebugMode,
  }) {
    print('YBloc');
    creator = CreatorBloc();
    twitch = TwitchBloc();
    youtube = YoutubeBloc();
    poll = PollBloc();
    changelog = ChangelogBloc();
    schedule = ScheduleBloc();
    news = NewsBloc();
    podcast = PodcastBloc();
    yogcon = YogconBloc();
    jjSchedule = JJScheduleBloc();
  }

  Future<bool> init() async {
    await time('init()', logTime, () async {
      await Future.wait([
        time('main', logTime, () async {
          await time('FirebaseFirestore.instance.settings', logTime, () async {
            try {
              FirebaseFirestore.instance.settings = Settings(
                persistenceEnabled: true,
                cacheSizeBytes: 5 * 1000 * 1000,
              );
            } catch (e) {
              print('BaseYBloc FirebaseFirestore.instance.settings');
            }
          });
          await time('_init()', logTime, () async {
            await _init();
          });
          await time('_sub()', logTime, () async {
            await _sub();
          });
        }),
      ]);
    });
    return true;
  }

  Future<void> initAnalytics(bool enable) async {
    await time('analytics', logTime, () async {
      bool analytics = await Prefs.getBool('analyticsPermission', false);
      await YAnalytics.enable(analytics && enable);
    });
  }

  Future<void> _sub() async {
    bool fcmPermission = await Prefs.getBool('fcmPermission', false);

    if (!fcmPermission) {
      return null;
    }

    int lastSub = await Prefs.getInt('lastSub',
        DateTime
            .now()
            .subtract(Duration(days: 4))
            .millisecondsSinceEpoch);

    DateTime now = DateTime.now();
    DateTime lastSubDate = DateTime.fromMillisecondsSinceEpoch(lastSub);

    Duration duration = now.difference(lastSubDate);

    print(duration);
    print(duration.inHours);
    if (duration.inHours >= 24 * 14) {
      print('resub topics');
      await Prefs.setInt('lastSub', now.millisecondsSinceEpoch);
      await time('forceSub()', logTime, () async {
        await forceSub();
      });
    } else {
      print('all topics up to date');
    }
    return null;
  }

  Future<void> _init() async {
    await Future.wait([
      time('creator.initList', logTime, () async {
        await creator.initList();
      }),
      time('twitch.initList', logTime, () async {
        await twitch.initList();
      }),
      time('youtube.initList', logTime, () async {
        await youtube.initList();
      }),
      //notification.init(),
    ]);

    bool isFirstStart18 = await Prefs.getBool('isFirstSettingsStart18', true);

    if (isFirstStart18) {
      await Future.wait(youtube.subscriptionsList
          .map((id) => Prefs.remove('notificationFilterShowYoutube_$id')));
      await Prefs.remove('notificationFilterYoutube');
      await Prefs.remove('notificationFilterTwitch');
      await Prefs.setBool('isFirstSettingsStart18', false);
    }
  }

  Future<void> clearDatabase() async {
    await forceUnsub();
    await Future.wait([
      twitch.resetList(),
      youtube.resetList(),
      creator.resetList(),
    ]);
  }

  Future<void> forceSub() async {
    print('subscribe all topics');
    await FirebaseMessaging.instance.subscribeToTopic('all');
    print('FirebaseChannel.subscribeToTopic');
    await Future.wait([
      time('creator.subscribeAll', logTime, () async {
        await creator.subscribeAll();
      }),
      time('twitch.subscribeAll', logTime, () async {
        await twitch.subscribeAll();
      }),
      time('youtube.subscribeAll', logTime, () async {
        await youtube.subscribeAll();
      }),
    ]);
  }

  Future<void> forceUnsub() async {
    print('unsubscribe all topics');
    await FirebaseMessaging.instance.subscribeToTopic('all');
    Future.wait([
      creator.unsubscribeAll(),
      twitch.unsubscribeAll(),
      youtube.unsubscribeAll(),
    ]);
  }

  Future<void> unsubscribeFromTopic(String id) async {
    await FirebaseMessaging.instance.subscribeToTopic(id);
  }

  Future<void> resetSubs() async {
    await forceUnsub();
    await forceSub();
  }

  void dispose() {
    print('YBloc dispose');
    creator?.dispose();
    twitch?.dispose();
    youtube?.dispose();
  }
}
