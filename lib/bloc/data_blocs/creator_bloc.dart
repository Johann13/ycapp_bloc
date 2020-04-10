import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:ycapp_bloc/bloc/data_blocs/firebase_bloc.dart';
import 'package:ycapp_foundation/model/creator/creator.dart';
import 'package:ycapp_messaging/ycapp_messaging.dart';
import 'package:ycapp_foundation/prefs/prefs.dart';
import 'package:ycapp_analytics/ycapp_analytics.dart';

typedef void AddListener(String id);
typedef void RemoveListener(String id);


class CreatorBloc extends FirestoreBloc<Creator> {
  String _creatorSubscriptionsPrefName = 'creatorSubscriptions';
  String _collaborationPrefName = 'collaboration';
  String _collaborationInboxPrefName = 'collaborationInbox';

  final _creatorIdsSubject = BehaviorSubject<List<String>>();
  List<String> _creatorIdList = [];

  final _collaborationSubject = BehaviorSubject<List<String>>();
  List<String> _collaborationList = [];

  Stream<List<String>> get collaboration => _collaborationSubject.asBroadcastStream();
  final _collaborationInboxSubject = BehaviorSubject<List<String>>();
  List<String> _collaborationInboxList = [];
  Stream<List<String>> get creatorIdsStream => _creatorIdsSubject.asBroadcastStream();

  List<String> get creatorIdList => _creatorIdList;

  CreatorBloc();

  Future<Null> initList() async {
    DateTime now = DateTime.now();
    print('creator initList start');
    this._creatorIdList = await _getCreatorSubscriptionPrefs();
    print('creator _creatorIdList ${DateTime.now().difference(now)}');
    this._collaborationList = await _getCollaborationPrefs();
    print('creator _collaborationList ${DateTime.now().difference(now)}');
    this._collaborationInboxList = await _getCollaborationInboxPrefs();
    print('creator _collaborationInboxList ${DateTime.now().difference(now)}');
    await _refreshList(setPref: false);
    print('creator initList done ${DateTime.now().difference(now)}');
  }


  Stream<List<Creator>> getAllCreator() {
    return Firestore.instance
        .collection('Creator')
        .where('visible', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .where((change) => change != null)
            .map((change) => fromMap(change.data))
            .where((v) => v != null)
            .toList())
        .asBroadcastStream();
  }

  Stream<List<Creator>> getAllYCreator() {
    return Firestore.instance
        .collection('Creator')
        .where('visible', isEqualTo: true)
        .orderBy('name')
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .map((change) => fromMap(change.data))
            .where((v) => v != null)
            .toList())
        .asBroadcastStream();
  }

  Future<List<Creator>> getAllYCreatorOnce() async {
    QuerySnapshot snap = await Firestore.instance
        .collection('Creator')
        .where('visible', isEqualTo: true)
        .orderBy('name')
        .getDocuments();
    return snap.documents
        .where((v) => v != null)
        .where((v) => v.data != null)
        .map((change) => fromMap(change.data))
        .toList();
  }

  Stream<List<Creator>> getAllFriendChannel() {
    return Firestore.instance
        .collection('Creator')
        .where('visible', isEqualTo: true)
        .where('type', isEqualTo: 4)
        .orderBy('name')
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .where((v) => v != null)
            .where((v) => v.data != null)
            .map((change) => fromMap(change.data))
            .toList())
        .asBroadcastStream();
  }

  Stream<List<Creator>> getAllFanChannel() {
    return Firestore.instance
        .collection('Creator')
        .where('visible', isEqualTo: true)
        .where('type', isEqualTo: 3)
        .orderBy('name')
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .where((v) => v != null)
            .where((v) => v.data != null)
            .map((change) => fromMap(change.data))
            .toList())
        .asBroadcastStream();
  }

  Stream<List<Creator>> getAllEditorChannel() {
    return Firestore.instance
        .collection('Creator')
        .where('visible', isEqualTo: true)
        .where('type', isEqualTo: 2)
        .orderBy('name')
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .where((v) => v != null)
            .where((v) => v.data != null)
            .map((change) => fromMap(change.data))
            .toList())
        .asBroadcastStream();
  }

  Stream<Creator> getCreator(String creatorId) => getById(creatorId);

  Stream<List<Creator>> getCreatorByIds(List<String> ids) =>
      getByIds(ids).map((list) => list.where((c) => c.visible).toList());

  Future<Creator> getCreatorOnce(String creatorId) => getOnceById(creatorId);

  Future<List<Creator>> getCreatorByIdsOnce(List<String> creatorIds) async {
    List<Creator> list = await getOnceByIds(creatorIds);
    return list.where((c) => c.visible).toList();
  }

  //region getter
  Stream<List<Creator>> getSubscribedCreator() =>
      getCreatorByIds(_creatorIdList);

  Future<List<String>> _getCreatorSubscriptionPrefs() =>
      Prefs.getStringList(_creatorSubscriptionsPrefName);

  Future<List<String>> _getCollaborationPrefs() =>
      Prefs.getStringList(_collaborationPrefName);

  Future<List<String>> _getCollaborationInboxPrefs() =>
      Prefs.getStringList(_collaborationInboxPrefName);

  Future<bool> _setCreatorSubscriptionPrefs(List<String> list) =>
      Prefs.setStringList(_creatorSubscriptionsPrefName, list);

  Future<bool> _setCollaborationPref(List<String> list) =>
      Prefs.setStringList(_collaborationPrefName, list);

  Future<bool> _setCollaborationInboxPref(List<String> list) =>
      Prefs.setStringList(_collaborationInboxPrefName, list);

  bool isSubscribedToCreator(String creatorId) =>
      _creatorIdList.contains(creatorId);

  bool getsCollaboration(String creatorId) =>
      _collaborationList.contains(creatorId);

  bool getsInboxCollaboration(String creatorId) =>
      _collaborationInboxList.contains(creatorId);

  Stream<bool> getsCollaborationStream(String creatorId) =>
      _collaborationSubject
          .map((list) => list.contains(creatorId))
          .asBroadcastStream();

  Stream<bool> getsCollaborationInboxStream(String creatorId) =>
      _collaborationInboxSubject
          .map((list) => list.contains(creatorId))
          .asBroadcastStream();

  //endregion

  //region subscriptions
  Future<Null> addCreator(String creatorId) async {
    if (!_creatorIdList.contains(creatorId)) {
      _creatorIdList.add(creatorId);
      await _refreshList();
      await YMessaging.subscribeToTopic(creatorId);
      await YAnalytics.log('subscribeCreator',
          parameters: {'creator_id': creatorId});
    }
  }

  Future<Null> addAllCreator(List<String> creatorIds) async {
    creatorIds.forEach((id) {
      if (!_creatorIdList.contains(id)) {
        _creatorIdList.add(id);
      }
    });

    await _refreshList();

    await Future.wait(creatorIds.map((id) {
      return YMessaging.subscribeToTopic(id);
    }));

    await YAnalytics.log('subscribeCreatorAll');
  }

  Future<Null> removeCreator(String creatorId) async {
    if (_creatorIdList.contains(creatorId)) {
      _creatorIdList.remove(creatorId);
      await _refreshList();
      await YMessaging.unsubscribeFromTopic(creatorId);
      await YAnalytics.log('unsubscribeCreator',
          parameters: {'creator_id': creatorId});
    }
  }

  Future<Null> addCollaboration(String creatorId) async {
    if (!_collaborationList.contains(creatorId)) {
      _collaborationList.add(creatorId);
      await YAnalytics.log('addCollab');
    }
  }

  Future<Null> removeCollaboration(String creatorId) async {
    if (_collaborationList.contains(creatorId)) {
      _collaborationList.remove(creatorId);
      await YAnalytics.log('removeCollab',
          parameters: {'creator_id': creatorId});
    }
  }

  Future<Null> updateCollaboration(String creatorId) async {
    if (_collaborationList.contains(creatorId)) {
      await removeCollaboration(creatorId);
    } else {
      await addCollaboration(creatorId);
    }
    await _refreshList();
  }

  Future<Null> addCollaborationInbox(String creatorId) async {
    if (!_collaborationInboxList.contains(creatorId)) {
      _collaborationInboxList.add(creatorId);
      await _refreshList();
      await YAnalytics.log('addCollabInbox',
          parameters: {'creator_id': creatorId});
    }
  }

  Future<Null> removeCollaborationInbox(String creatorId) async {
    if (_collaborationInboxList.contains(creatorId)) {
      _collaborationInboxList.remove(creatorId);
      await _refreshList();
      await YAnalytics.log('removeCollabInbox',
          parameters: {'creator_id': creatorId});
    }
  }

  Future<Null> updateCollaborationInbox(String creatorId) async {
    if (_collaborationInboxList.contains(creatorId)) {
      await removeCollaborationInbox(creatorId);
    } else {
      await addCollaborationInbox(creatorId);
    }
    await _refreshList();
  }

  //endregion

  //region other
  Future<Null> _refreshList({bool setPref = true}) async {
    _creatorIdsSubject.add(_creatorIdList);
    _collaborationSubject.add(_collaborationList);
    _collaborationInboxSubject.add(_collaborationInboxList);
    if (setPref) {
      await _setCreatorSubscriptionPrefs(_creatorIdList);
      await _setCollaborationPref(_collaborationList);
      await _setCollaborationInboxPref(_collaborationInboxList);
    }
  }

  Future<Null> resetList() {
    _creatorIdList.clear();
    _collaborationList.clear();
    _collaborationInboxList.clear();
    return _refreshList();
  }

  Future subscribeAll() async {
    print('subscribeAll creator');
    print('subscribeAll creator pushy done');
    return Future.wait(
        creatorIdList.map((id) => YMessaging.subscribeToTopic('all')));
  }

  Future unsubscribeAll() async {
    print('unsubscribeAll creator');
    return Future.wait(
        creatorIdList.map((id) => YMessaging.unsubscribeFromTopic(id)));
  }

  void dispose() {
    _creatorIdsSubject?.close();
    _collaborationSubject?.close();
    _collaborationInboxSubject?.close();
  }

  //endregion

  @override
  String collectionPath() => 'Creator';

  @override
  Creator fromMap(Map map) => Creator.fromMap(map);

  Future<List<Creator>> getCreatorHttp({
    String after,
    int limit,
    bool min,
    bool links,
    bool creator,
  }) async {
    String url =
        'https://europe-west1-yogscastapp-7e6f0.cloudfunctions.net/userAccessData/data/creator?'
        '${after != null ? '&after=$after' : ''}'
        '${min != null ? '&min=$min' : ''}'
        '${limit != null ? '&limit=$limit' : ''}'
        '${links != null ? '&links=$links' : ''}'
        '${creator != null ? '&creator=$creator' : ''}';
    print(url);
    var resp = await http.get(url);
    if (resp.body == 'Channel not found') {
      return [];
    }
    List list = json.decode(resp.body);
    return list.map((j) => Creator.fromMap(j)).toList();
  }

  Future<List<Creator>> getChannelByIdsHttp(
    List<String> ids,
  ) async {
    String s = ids
        .toString()
        .replaceAll('[', '')
        .replaceAll(']', '')
        .replaceAll(' ', '');
    var resp = await http.get(
        'https://europe-west1-yogscastapp-7e6f0.cloudfunctions.net/userAccessData/data/creator'
        '?ids=$s');
    List list = json.decode(resp.body);
    return list.map((j) => Creator.fromMap(j)).toList();
  }

  Future<Creator> getCreatorByIdHttp(String id) async {
    String url =
        'https://europe-west1-yogscastapp-7e6f0.cloudfunctions.net/userAccessData/data/creator/$id';
    print('getCreatorHttp $url');
    var resp = await http.get(url);
    return Creator.fromMap(json.decode(resp.body));
  }
}
