import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:ycapp_bloc/bloc/data_blocs/channel_blocs/channel_bloc.dart';
import 'package:ycapp_foundation/model/channel/youtube_channel.dart';
import 'package:ycapp_foundation/model/creator/creator.dart';
import 'package:ycapp_foundation/sort/sort.dart';

class YoutubeBloc extends ChannelBloc<YoutubeChannel> {
  bool isSubscribedToAnyYoutubeChannelOfCreator(Creator creator) =>
      getSubList(creator).isNotEmpty;

  List<String> getSubList(Creator creator) =>
      creator.youtube.where((id) => isSubscribedTo(id)).toList();

  List<String> getNotSubList(Creator creator) =>
      creator.youtube.where((id) => !getSubList(creator).contains(id)).toList();

  //region videos
  Stream<List<Video>> getVideos(String youtubeId) {
    return FirebaseFirestore.instance
        .collection('YoutubeVideo')
        .where('youtubeId', isEqualTo: youtubeId)
        .snapshots()
        .map((query) =>
            query.docs.map((doc) => Video.fromMap(doc.data())).toList());
  }

  Stream<List<Video>> getLatestMainChannelVideo(String creatorId) {
    print(creatorId);
    return FirebaseFirestore.instance
        .collection('YoutubeVideo')
        .where('creator', arrayContains: creatorId)
        .orderBy('publisedAt', descending: true)
        .snapshots()
        .map((query) =>
            query.docs.map((doc) => Video.fromMap(doc.data())).toList());
  }

  Stream<List<Video>> getAllVideos(List<String> youtubeIds) {
    if (youtubeIds.isEmpty) {
      return Stream.fromFuture(Future(() {
        return [];
      }));
    }
    return CombineLatestStream.list<List<Video>>(
            youtubeIds.map((youtubeId) => getVideos(youtubeId)))
        .map((lists) => lists.where((list) => list != null).toList())
        .map((lists) => lists.expand((video) => video).toList());
  }

  Future<List<Video>> getVideosOnce(
    String youtubeId,
    String videoId, {
    int limit = 2,
  }) async {
    QuerySnapshot query = await FirebaseFirestore.instance
        .collection('YoutubeVideo')
        .where('youtubeId', isEqualTo: youtubeId)
        .orderBy('videoId', descending: true)
        .startAfter(<String>[videoId])
        .limit(limit)
        .orderBy('publishedAt', descending: true)
        .get();
    return query.docs.map((doc) => Video.fromMap(doc.data())).toList();
  }

  Future<Video> getVideo(String videoId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('YoutubeVideo')
        .doc(videoId)
        .get();
    return Video.fromMap(doc.data());
  }

  Stream<Video> getVideoStream(String videoId) {
    return FirebaseFirestore.instance
        .collection('YoutubeVideo')
        .doc(videoId)
        .snapshots()
        .map((doc) => Video.fromMap(doc.data()));
  }

  Stream<List<Video>> getSubscribedVideos() {
    return getAllVideos(subscriptionsList);
  }

  //endregion

  Future<http.Response> getYoutubeSubs(String auth) async {
    var resp = await http
        .get('https://europe-west1-yogscastapp-7e6f0.cloudfunctions.net/'
            'userAccessData/youtube/auth/$auth');
    return resp;
  }

  @override
  String inboxPrefName() => 'youtubeInbox';

  @override
  String notificationPrefName() => 'youtubeNotifications';

  @override
  String subscriptionPrefName() => 'youtubeSubscriptions';

  @override
  String collectionPath() => 'YoutubeChannel';

  @override
  YoutubeChannel fromMap(Map<String, dynamic> map) =>
      YoutubeChannel.fromMap(map);

  @override
  List<YoutubeChannel> sortByIds(List<YoutubeChannel> list) {
    list.sort(YSort.sortYoutubeChannelByName);
    return list;
  }

  Future<List<YoutubeChannel>> getAllChannelHttp() async {
    var resp = await http.get(
        'https://europe-west1-yogscastapp-7e6f0.cloudfunctions.net/userAccessData/data/youtube');
    List<Map<String, dynamic>> list =
        json.decode(resp.body) as List<Map<String, dynamic>>;
    return list.map((j) => YoutubeChannel.fromMap(j)).toList();
  }

  Future<List<YoutubeChannel>> getAllChannelByIdsHttp(List<String> ids) async {
    String s = ids
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(' ', '');
    print('s $s');
    var resp = await http.get(
        'https://europe-west1-yogscastapp-7e6f0.cloudfunctions.net/userAccessData/data/youtube'
        '?ids=$s');
    List<Map<String, dynamic>> list = (json.decode(resp.body) as List)
        .map((dynamic e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return list.map((j) => YoutubeChannel.fromMap(j)).toList();
  }

  Future<YoutubeChannel> getChannelHttp(String id) async {
    var resp = await http.get(
        'https://europe-west1-yogscastapp-7e6f0.cloudfunctions.net/userAccessData/data/youtube/$id');
    return YoutubeChannel.fromMap(
        json.decode(resp.body) as Map<String, dynamic>);
  }
}
