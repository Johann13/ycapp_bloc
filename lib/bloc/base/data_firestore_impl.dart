import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:webfeed/domain/rss_feed.dart';
import 'package:ycapp_bloc/bloc/base/jj_bloc_base.dart';
import 'package:ycapp_bloc/bloc/base/schedule_bloc_base.dart';
import 'package:ycapp_bloc/bloc/firebase/firestore_bloc.dart';
import 'package:ycapp_foundation/model/channel/podcast.dart';
import 'package:ycapp_foundation/model/channel/twitch_channel.dart';
import 'package:ycapp_foundation/model/channel/youtube_channel.dart';
import 'package:ycapp_foundation/model/creator/creator.dart';
import 'package:ycapp_foundation/model/news/news_item.dart';
import 'package:ycapp_foundation/model/poll.dart';
import 'package:ycapp_foundation/model/schedule/jj_schedule.dart';
import 'package:ycapp_foundation/model/schedule/schedule.dart';

class CreatorFirestoreBloc extends FirestoreBloc<Creator> {
  @override
  String collectionPath() => 'Creator';

  @override
  Creator fromMap(Map map) => Creator.fromMap(map);
}

class YoutubeFirestoreBloc extends FirestoreBloc<YoutubeChannel> {
  @override
  String collectionPath() => 'YoutubeChannel';

  @override
  YoutubeChannel fromMap(Map map) => YoutubeChannel.fromMap(map);
}

class TwitchFirestoreBloc extends FirestoreBloc<TwitchChannel> {
  @override
  String collectionPath() => 'TwitchChannel';

  @override
  TwitchChannel fromMap(Map map) => TwitchChannel.fromMap(map);
}

class PodcastFirestoreBloc extends FirestoreBloc<Podcast> {
  Map<String, RssFeed> cache = {};

  @override
  String collectionPath() => 'Podcast';

  @override
  Stream<List<Podcast>> getAll() {
    return super.getAll().asyncMap((list) async {
      await Future.wait(list.map((p) async {
        if (cache.containsKey(p.channelId)) {
          p.rssFeed = cache[p.channelId];
        } else {
          await p.loadRssFeed();
          cache[p.channelId] = p.rssFeed;
        }
        return p;
      }));
      return list;
    }).asBroadcastStream();
  }

  @override
  Stream<Podcast> getById(String docId) {
    return super.getById(docId).asyncMap((p) async {
      if (cache.containsKey(p.channelId)) {
        p.rssFeed = cache[p.channelId];
      } else {
        await p.loadRssFeed();
        cache[p.channelId] = p.rssFeed;
      }
      return p;
    });
  }

  @override
  Stream<List<Podcast>> getByIds(List<String> docIds) {
    return super.getByIds(docIds).asyncMap((list) {
      Future.wait(list.map((p) async {
        if (cache.containsKey(p.channelId)) {
          p.rssFeed = cache[p.channelId];
        } else {
          await p.loadRssFeed();
          cache[p.channelId] = p.rssFeed;
        }
        return p;
      }));
      return list;
    }).asBroadcastStream();
  }

  @override
  Future<Podcast> getOnceById(String docId) async {
    Podcast p = await super.getOnceById(docId);
    if (cache.containsKey(p.channelId)) {
      p.rssFeed = cache[p.channelId];
    } else {
      await p.loadRssFeed();
      cache[p.channelId] = p.rssFeed;
    }
    return p;
  }

  @override
  Future<List<Podcast>> getOnceByIds(List<String> docIds) async {
    List<Podcast> list = await super.getOnceByIds(docIds);
    await Future.wait(list.map((p) async {
      if (cache.containsKey(p.channelId)) {
        p.rssFeed = cache[p.channelId];
      } else {
        await p.loadRssFeed();
        cache[p.channelId] = p.rssFeed;
      }
      return p;
    }));
    return list;
  }

  @override
  Podcast fromMap(Map map) {
    return Podcast.fromMap(map);
  }
}

class NewsFirestoreBloc extends FirestoreBloc<News> {
  @override
  String collectionPath() => 'News';

  @override
  News fromMap(Map map) => News.fromMap(map);
}

class PollFirestoreBloc extends FirestoreBloc<Poll> {
  @override
  String collectionPath() => 'Poll';

  @override
  Poll fromMap(Map map) => Poll.fromMap(map);
}

class ScheduleFirestoreBloc extends ScheduleBlocBase {
  @override
  Future<List<ScheduleSlot>> getRelatedSlots(
      String creatorId, String twitchId) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('TwitchChannel')
        .doc(twitchId)
        .collection('Schedule')
        .where('creator', arrayContains: creatorId)
        .get();
    List<ScheduleSlot> slots = query.docs
        .map((change) => ScheduleSlot.fromMap(twitchId, change.data()))
        .toList();
    return slots;
  }

  @override
  Stream<ScheduleSlot> getSlot(String id, String twitchId) {
    return FirebaseFirestore.instance
        .collection('TwitchChannel')
        .doc(twitchId)
        .collection('Schedule')
        .doc(id)
        .snapshots()
        .map((doc) => ScheduleSlot.fromMap(twitchId, doc.data()));
  }

  @override
  Stream<List<ScheduleSlot>> getSlots(String twitchId) {
    return FirebaseFirestore.instance
        .collection('TwitchChannel')
        .doc(twitchId)
        .collection('Schedule')
        .orderBy('day', descending: false)
        .orderBy('slot', descending: false)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .where((v) => v.data() != null)
            .map((change) => ScheduleSlot.fromMap(twitchId, change.data()))
            .toList());
  }

  @override
  Future<List<ScheduleSlot>> getSlotsOnce(String twitchId) async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('TwitchChannel')
        .doc(twitchId)
        .collection('Schedule')
        .orderBy('day', descending: false)
        .orderBy('slot', descending: false)
        .get();
    return snapshot.docs
        .map((doc) => ScheduleSlot.fromMap(twitchId, doc.data()))
        .toList();
  }
}

class JJScheduleFirestoreBloc extends JJScheduleBlocBase {
  @override
  Stream<JJSchedule> getSchedule(String year) {
    return FirebaseFirestore.instance
        .collection('JingleJam')
        .doc(year)
        .collection('Schedule')
        .snapshots()
        .map((query) {
      List<JJSlot> slots =
          query.docs.map((doc) => JJSlot.fromMap(year, doc.data())).toList();
      JJSchedule schedule = JJSchedule(year, slots);
      return schedule;
    });
  }

  @override
  Future<List<JJSlot>> getRelatedSlots(String year, String creatorId) async {
    return FirebaseFirestore.instance
        .collection('JingleJam')
        .doc(year)
        .collection('Schedule')
        .where('creator', arrayContains: creatorId)
        .get()
        .then((query) =>
            query.docs.map((doc) => JJSlot.fromMap(year, doc.data())).toList());
  }

  @override
  Stream<JJSlot> getSlot(String year, String id) {
    return FirebaseFirestore.instance
        .collection('JingleJam')
        .doc(year)
        .collection('Schedule')
        .doc(id)
        .snapshots()
        .map((doc) => JJSlot.fromMap(year, doc.data()));
  }
}
