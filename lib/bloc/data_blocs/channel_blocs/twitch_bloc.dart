import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:ycapp_bloc/bloc/data_blocs/channel_blocs/channel_bloc.dart';
import 'package:ycapp_foundation/model/channel/twitch_channel.dart';
import 'package:ycapp_foundation/model/creator/creator.dart';
import 'package:ycapp_foundation/sort/sort.dart';

class TwitchBloc extends ChannelBloc<TwitchChannel> {
  bool isSubscribedToAnyTwitchChannelOfCreator(Creator creator) =>
      getSubList(creator).isNotEmpty;

  List<String> getSubList(Creator creator) {
    List l =
        creator.twitch.where((id) => subscriptionsList.contains(id)).toList();
    return l;
  }

  Stream<List<String>> getSubStream(Creator creator) {
    return subscriptions.map((list) {
      return list.where((id) => creator.twitch.contains(id)).toList();
    });
  }

  List<String> getNotSubList(Creator creator) =>
      creator.twitch.where((id) => !getSubList(creator).contains(id)).toList();

  //region videos
  Stream<List<TwitchVideo>> getTwitchVideos(String twitchId, String type,
      [int last = 5]) {
    return Firestore.instance
        .collection('TwitchVideo')
        .where('twitchId', isEqualTo: twitchId)
        .where('type', isEqualTo: type)
        .orderBy('publishedAt', descending: true)
        .limit(last)
        .snapshots()
        .map((query) => query.documentChanges
            .map((changes) => TwitchVideo.fromMap(changes.document.data))
            .toList());
  }

  Stream<List<TwitchVideo>> getArchives(String twitchId) {
    return getTwitchVideos(twitchId, 'archive');
  }

  Stream<List<TwitchVideo>> getAllArchives(List<String> twitchIds) {
    if (twitchIds.isEmpty) {
      return Stream.fromFuture(Future(() {
        return [];
      }));
    }
    return StreamZip<List<TwitchVideo>>(
        twitchIds.map((twitchId) => getArchives(twitchId))).map((value) {
      List<TwitchVideo> list = value.expand((video) => video).toList();
      list.sort((v1, v2) => v1.publishedAt.compareTo(v2.publishedAt));
      return list;
    });
  }

  Stream<List<TwitchVideo>> getSubscribedArchives() {
    return getAllArchives(subscriptionsList);
  }

  Stream<List<TwitchVideo>> getHighlights(String twitchId) {
    return getTwitchVideos(twitchId, 'highlight');
  }

  Stream<List<TwitchVideo>> getAllHighlights(List<String> twitchIds) {
    if (twitchIds.isEmpty) {
      return Stream.fromFuture(Future(() {
        return [];
      }));
    }
    return StreamZip<List<TwitchVideo>>(
        twitchIds.map((twitchId) => getHighlights(twitchId))).map((value) {
      List<TwitchVideo> list = value.expand((video) => video).toList();
      list.sort((v1, v2) => v1.publishedAt.compareTo(v2.publishedAt));
      return list;
    });
  }

  Stream<List<TwitchVideo>> getSubscribedHighlights() {
    return getAllHighlights(subscriptionsList);
  }

  Stream<List<TwitchVideo>> getUploads(String twitchId) {
    return getTwitchVideos(twitchId, 'upload');
  }

  Stream<List<TwitchVideo>> getAllUploads(List<String> twitchIds) {
    if (twitchIds.isEmpty) {
      return Stream.fromFuture(Future(() {
        return [];
      }));
    }
    return StreamZip<List<TwitchVideo>>(
        twitchIds.map((twitchId) => getUploads(twitchId))).map((value) {
      List<TwitchVideo> list = value.expand((video) => video).toList();
      list.sort((v1, v2) => v1.publishedAt.compareTo(v2.publishedAt));
      return list;
    });
  }

  Stream<List<TwitchVideo>> getSubscribedUploads() {
    return getAllUploads(subscriptionsList);
  }

  //endregion

  Stream<List<TwitchClip>> getClips(String twitchId) {
    return Firestore.instance
        .collection('TwitchClips')
        .where('twitchId', isEqualTo: twitchId)
        .orderBy('publishedAt', descending: true)
        .limit(5)
        .snapshots()
        .map((query) => query.documentChanges
            .map((changes) => TwitchClip.fromMap(changes.document.data))
            .toList());
  }

  Future<http.Response> getTwitchFollows(String name) async {
    var resp = await http.get(
        'https://europe-west1-yogscastapp-7e6f0.cloudfunctions.net/userAccessData/twitch/$name');
    return resp;
  }

  @override
  String inboxPrefName() => 'twitchInbox';

  @override
  String notificationPrefName() => 'twitchNotifications';

  @override
  String subscriptionPrefName() => 'twitchSubscriptions';

  @override
  String collectionPath() => 'TwitchChannel';

  @override
  TwitchChannel fromMap(Map map) => TwitchChannel.fromMap(map);

  @override
  List<TwitchChannel> sortByIds(List<TwitchChannel> list) {
    list.sort(YSort.sortTwitchChannelByName);
    return list;
  }

  Future<List<TwitchChannel>> getAllChannelHttp() async {
    var resp = await http.get(
        'https://europe-west1-yogscastapp-7e6f0.cloudfunctions.net/userAccessData/data/twitch');
    List list = json.decode(resp.body);
    return list.map((j) => TwitchChannel.fromMap(j)).toList();
  }

  Future<List<TwitchChannel>> getAllChannelByIdsHttp(List<String> ids) async {
    String s = ids
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(' ', '');
    var resp = await http.get(
        'https://europe-west1-yogscastapp-7e6f0.cloudfunctions.net/userAccessData/data/twitch'
        '?ids=$s');
    List list = json.decode(resp.body);
    return list.map((j) => TwitchChannel.fromMap(j)).toList();
  }

  Future<TwitchChannel> getChannelHttp(String id) async {
    var resp = await http.get(
        'https://europe-west1-yogscastapp-7e6f0.cloudfunctions.net/userAccessData/data/twitch/$id');
    return TwitchChannel.fromMap(json.decode(resp.body));
  }
}
