import 'package:webfeed/domain/rss_feed.dart';
import 'package:ycapp_bloc/bloc/data_blocs/channel_blocs/channel_bloc.dart';
import 'package:ycapp_foundation/model/channel/podcast.dart';


class PodcastBloc extends ChannelBloc<Podcast> {
  Map<String, RssFeed> cache = {};

  @override
  String collectionPath() {
    return 'Podcast';
  }

  @override
  Stream<List<Podcast>> getAllChannel() {
    return super.getAllChannel().asyncMap((list) async {
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
  Podcast fromMap(Map<String,dynamic> map) {
    return Podcast.fromMap(map);
  }

  @override
  String inboxPrefName() {
    return 'podcastInbox';
  }

  @override
  String notificationPrefName() {
    return 'podcastNotifications';
  }

  @override
  String subscriptionPrefName() {
    return 'podcastSubscriptions';
  }

  @override
  List<Podcast> sortByIds(List<Podcast> list) {
    list.sort((a, b) => a.name.compareTo(b.name));
    return list;
  }
}
