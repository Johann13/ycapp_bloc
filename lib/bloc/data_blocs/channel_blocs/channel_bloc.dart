import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ycapp_analytics/ycapp_analytics.dart';
import 'package:ycapp_bloc/bloc/firebase/firestore_bloc.dart';
import 'package:ycapp_foundation/model/channel/channel.dart';
import 'package:ycapp_foundation/prefs/prefs.dart';

// Subscribe to Channel
// => Subscribe Channel, Notification, Inbox

// Unsubscribe to Channel
// => Unsubscribe Channel, Notification, Inbox

// Subscribe to Notification
// => Subscribe to Channel

// Unsubscribe to Notification
// => Unsubscribe Notification

// Subscribe to Inbox
// => Subscribe to Channel

// Unsubscribe to Inbox
// => Unsubscribe Inbox

abstract class ChannelBloc<T extends Channel> extends FirestoreBloc<T> {
  String subscriptionPrefName();

  String notificationPrefName();

  String inboxPrefName();

  //region fields
  String get _subscriptionsPrefName => subscriptionPrefName();

  String get _notificationsPrefName => notificationPrefName();

  String get _inboxPrefName => inboxPrefName();

  final _subscriptionsSubject = BehaviorSubject<List<String>>();
  List<String> _subscriptionsList = [];

  Stream<List<String>> get subscriptions =>
      _subscriptionsSubject.stream.asBroadcastStream();

  List<String> get subscriptionsList => _subscriptionsList;

  set subscriptionsList(List<String> list) => _subscriptionsList;

  final _notificationsSubject = BehaviorSubject<List<String>>();
  List<String> _notificationsList = [];

  Stream<List<String>> get notifications =>
      _notificationsSubject.stream.asBroadcastStream();

  List<String> get notificationsList => _notificationsList;

  set notificationsList(List<String> list) => _notificationsList;

  final _inboxSubject = BehaviorSubject<List<String>>();
  List<String> _inboxList = [];

  Stream<List<String>> get inbox => _inboxSubject.asBroadcastStream();

  List<String> get inboxList => _inboxList;

  //set inboxList(List<String> list) => _inboxList;

  //endregion

  Future<void> initList() async {
    /*
    bool isFirstStart1_6 =
        await Prefs.getBool('isFirstSettingsStart1_6_${inboxPrefName()}', true);
    if (isFirstStart1_6) {
      List<String> notifications = await _getNotificationsPrefs();
      _setInboxPrefs(notifications);
      await Prefs.setBool('isFirstSettingsStart1_6_${inboxPrefName()}', false);
    }*/
    _print('$_subscriptionsPrefName initList start');
    DateTime now = DateTime.now();
    this._subscriptionsList = await _getSubscriptionPrefs();
    _print(
        '$_subscriptionsPrefName _subscriptionsList ${DateTime.now().difference(now)}');
    this._notificationsList = await _getNotificationsPrefs();
    _print(
        '$_subscriptionsPrefName _notificationsList ${DateTime.now().difference(now)}');
    this._inboxList = await _getInboxPrefs();
    _print(
        '$_subscriptionsPrefName _inboxList ${DateTime.now().difference(now)}');

    await _refreshList(setPrefs: false);
    _print(
        '$_subscriptionsPrefName initList done ${DateTime.now().difference(now)}');
  }

  //region getter and setter
  Future<List<String>> _getSubscriptionPrefs() =>
      Prefs.getStringList(_subscriptionsPrefName);

  Future<List<String>> _getNotificationsPrefs() =>
      Prefs.getStringList(_notificationsPrefName);

  Future<List<String>> _getInboxPrefs() => Prefs.getStringList(_inboxPrefName);

  Future<bool> _setSubscriptionPrefs(List<String> list) =>
      Prefs.setStringList(_subscriptionsPrefName, list);

  Future<bool> _setNotificationsPrefs(List<String> list) =>
      Prefs.setStringList(_notificationsPrefName, list);

  Future<bool> _setInboxPrefs(List<String> list) =>
      Prefs.setStringList(_inboxPrefName, list);

  bool isSubscribedTo(String id) => _subscriptionsList.contains(id);

  bool areAllSubscribedTo(List<String> ids) =>
      !_subscriptionsList.any((t) => !ids.contains(t));

  Stream<bool> isSubscribedToStream(String id) =>
      subscriptions.map((list) => list.contains(id)).asBroadcastStream();

  Stream<bool> getsNotificationsFromStream(String id) =>
      notifications.map((list) => list.contains(id)).asBroadcastStream();

  Stream<bool> getsInboxFromStream(String id) =>
      inbox.map((list) => list.contains(id)).asBroadcastStream();

  bool getsNotificationsFrom(String id) => _notificationsList.contains(id);

  bool getsAllNotificationsFrom(List<String> ids) =>
      !_notificationsList.any((t) => !ids.contains(t));

  bool getsInboxFrom(String id) => _inboxList.contains(id);

  bool getsAllInboxFrom(List<String> ids) =>
      !_inboxList.any((t) => !ids.contains(t));

  //endregion

  //region subscribe
  // Subscribe to Channel
  // => Subscribe Channel, Notification, Inbox
  // Unsubscribe to Channel
  // => Unsubscribe Channel, Notification, Inbox
  Future<bool> updateSubscription(String id) async {
    _print('updateSubscription $id');
    if (isSubscribedTo(id)) {
      await Future.wait([
        _unsubscribe(id),
        _unsubscribeFromNotification(id),
        _unsubscribeFromInbox(id)
      ]);
      await _refreshList();
      return false;
    } else {
      await Future.wait([
        _subscribe(id),
        _subscribeToNotification(id),
        _subscribeToInbox(id),
      ]);
      await _refreshList();
      return true;
    }
  }

  Future<bool> subscribe(String id) async {
    if (isSubscribedTo(id)) {
      return false;
    } else {
      await Future.wait([
        _subscribe(id),
        _subscribeToNotification(id),
        _subscribeToInbox(id),
      ]);
      await _refreshList();
      return true;
    }
  }

  Future<bool> unsubscribe(String id) async {
    if (isSubscribedTo(id)) {
      await Future.wait([
        _unsubscribe(id),
        _unsubscribeFromNotification(id),
        _unsubscribeFromInbox(id)
      ]);
      await _refreshList();
      return false;
    } else {
      return true;
    }
  }

  // Subscribe to Notification
  // => Subscribe to Channel
  // Unsubscribe from Notification
  // => Unsubscribe Notification
  Future<bool> updateNotification(String id) async {
    if (_notificationsList.contains(id)) {
      await _unsubscribeFromNotification(id);
      await _refreshList();
      return true;
    } else {
      await Future.wait([
        _subscribe(id),
        _subscribeToNotification(id),
      ]);
      await _refreshList();
      return false;
    }
  }

  Future<bool> subscribeToNotification(String id) async {
    if (getsNotificationsFrom(id)) {
      return false;
    } else {
      await Future.wait([
        _subscribe(id),
        _subscribeToNotification(id),
      ]);
      await _refreshList();
      return true;
    }
  }

  Future<bool> unsubscribeFromNotification(String id) async {
    if (getsNotificationsFrom(id)) {
      await _unsubscribeFromNotification(id);
      await _refreshList();
      return false;
    } else {
      return true;
    }
  }

  // Subscribe to Inbox
  // => Subscribe to Channel
  // Unsubscribe from Inbox
  // => Unsubscribe Inbox
  Future<bool> updateInbox(String id) async {
    if (_inboxList.contains(id)) {
      await _unsubscribeFromInbox(id);
      await _refreshList();
      return false;
    } else {
      await Future.wait([
        _subscribe(id),
        _subscribeToInbox(id),
      ]);
      await _refreshList();
      return true;
    }
  }

  Future<bool> subscribeToInbox(String id) async {
    if (getsInboxFrom(id)) {
      return false;
    } else {
      await Future.wait([
        _subscribe(id),
        _subscribeToInbox(id),
      ]);
      await _refreshList();
      return true;
    }
  }

  Future<bool> unsubscribeFromInbox(String id) async {
    if (getsInboxFrom(id)) {
      await _unsubscribeFromInbox(id);
      await _refreshList();
      return false;
    } else {
      return true;
    }
  }

  Future<void> _subscribe(String id) async {
    if (!_subscriptionsList.contains(id)) {
      _subscriptionsList.add(id);
      await _sub(id);
      await YAnalytics.log('subscribe',
          parameters: <String, dynamic>{'id': id});
      _print('_subscribe $id');
    } else {
      _print('not added sub');
    }
  }

  Future<void> subscribeToAll(List<String> ids) async {
    await Future.wait(ids.map((id) async {
      if (!isSubscribedTo(id)) {
        _subscriptionsList.add(id);
        await _subscribeToNotification(id);
        await _subscribeToInbox(id);
        return FirebaseMessaging.instance.subscribeToTopic(id);
      } else {
        return null;
      }
    }));

    await _refreshList();

    _print('_subscribe: $ids');
    await YAnalytics.log('subscribeAll');
  }

  Future<bool> _unsubscribe(String id) async {
    if (isSubscribedTo(id)) {
      _subscriptionsList.remove(id);
      await _unsub(id);
      _print('_unsubscribe: $id');
      await YAnalytics.log('unsubscribe',
          parameters: <String, dynamic>{'id': id});
      return true;
    } else {
      return false;
    }
  }

  Future<void> unsubscribeFromAll(List<String> ids) async {
    await Future.wait(ids.map((id) async {
      if (isSubscribedTo(id)) {
        _subscriptionsList.remove(id);
        await _unsubscribeFromNotification(id);
        await _unsubscribeFromInbox(id);
        return FirebaseMessaging.instance.subscribeToTopic(id);
      } else {
        return null;
      }
    }));
    _print('_unsubscribe: $ids');
    await _refreshList();
    await YAnalytics.log('unsubscribeAll');
  }

  Future<void> _subscribeToNotification(String id) async {
    if (!_notificationsList.contains(id)) {
      _notificationsList.add(id);
      await YAnalytics.log('subscribeNoti',
          parameters: <String, dynamic>{'id': id});
      _print('_subscribeToNotification $id');
    }
  }

  // ignore: unused_element
  Future<void> _subscribeAllToNotification(List<String> ids) async {
    ids.forEach((id) {
      if (!getsNotificationsFrom(id)) {
        _notificationsList.add(id);
      }
    });
    await _refreshList();
    await YAnalytics.log('subscribeNotiAll');
  }

  Future<void> _unsubscribeFromNotification(String id) async {
    if (_notificationsList.contains(id)) {
      _notificationsList.remove(id);
      await YAnalytics.log('unsubscribeNoti',
          parameters: <String, dynamic>{'id': id});
      _print('_unsubscribeFromNotification $id');
    }
  }

  // ignore: unused_element
  Future<void> _unsubscribeAllFromNotification(List<String> ids) async {
    ids.forEach((id) {
      if (getsNotificationsFrom(id)) {
        _notificationsList.remove(id);
      }
    });
    await _refreshList();
    await YAnalytics.log('unsubscribeNotiAll');
  }

  Future<void> _subscribeToInbox(String id) async {
    if (!_inboxList.contains(id)) {
      _inboxList.add(id);
      await YAnalytics.log('subscribeInbox',
          parameters: <String, dynamic>{'id': id});
      _print('_subscribeToInbox $id');
    }
  }

  // ignore: unused_element
  Future<bool> _subscribeAllToInbox(List<String> ids) async {
    if (getsAllInboxFrom(ids)) {
      return false;
    } else {
      ids.forEach((id) {
        if (!getsInboxFrom(id)) {
          _inboxList.add(id);
        }
      });
      await _refreshList();
      await YAnalytics.log('subscribeInboxAll');
      return true;
    }
  }

  Future<void> _unsubscribeFromInbox(String id) async {
    if (_inboxList.contains(id)) {
      _inboxList.remove(id);
      await YAnalytics.log('unsubscribeInbox',
          parameters: <String, dynamic>{'id': id});
      _print('_unsubscribeFromInbox $id');
    }
  }

  // ignore: unused_element
  Future<void> _unsubscribeAllFromInbox(List<String> ids) async {
    ids.forEach((id) {
      if (getsInboxFrom(id)) {
        _inboxList.remove(id);
      }
    });
    await _refreshList();
    await YAnalytics.log('unsubscribeInboxAll');
  }

  Future subscribeAll() async {
    return Future.wait(subscriptionsList
        .map((id) => FirebaseMessaging.instance.subscribeToTopic(id)));
  }

  Future<List<void>> unsubscribeAll() async {
    return Future.wait(subscriptionsList
        .map((id) => FirebaseMessaging.instance.subscribeToTopic(id)));
  }

  Future<void> _sub(String id) async {
    await FirebaseMessaging.instance.subscribeToTopic(id);
  }

  Future<void> _unsub(String id) async {
    await FirebaseMessaging.instance.subscribeToTopic(id);
  }

//endregion

  //region util
  Future<void> _refreshList({bool setPrefs = true}) async {
    _subscriptionsSubject.add(_subscriptionsList);
    _notificationsSubject.add(_notificationsList);
    _inboxSubject.add(_inboxList);
    if (setPrefs) {
      await _setSubscriptionPrefs(_subscriptionsList);
      await _setNotificationsPrefs(_notificationsList);
      await _setInboxPrefs(_inboxList);
    }
    _print('_refreshList');
  }

  Future<void> resetList() {
    _subscriptionsList.clear();
    _notificationsList.clear();
    _inboxList.clear();
    return _refreshList();
  }

  //endregion

  //region data

  Stream<List<T>> getAllChannel() => FirebaseFirestore.instance
      .collection(collectionPath())
      .where('visible', isEqualTo: true)
      .snapshots()
      .map((query) => query.docs.map((doc) => fromMap(doc.data())).toList())
      .asBroadcastStream();

  Stream<T> getChannel(String channelId) => getById(channelId);

  Stream<List<T>> getChannelByIds(List<String> channelIds) =>
      getByIds(channelIds)
          .map(
              (l) => l.where((v) => v != null).where((c) => c.visible).toList())
          .map(sortByIds);

  Future<T> getChannelOnce(String channelId) => getOnceById(channelId);

  Future<List<T>> getChannelByIdsOnce(List<String> channelIds) async {
    List<T> list = await getOnceByIds(channelIds);
    return sortByIds(list).where((c) => c.visible).toList();
  }

  Stream<List<T>> getSubscribedChannel() => getChannelByIds(subscriptionsList);

  List<T> sortByIds(List<T> list);

  Future<List<T>> getSubscribedChannelOnce() =>
      getChannelByIdsOnce(subscriptionsList);

  //endregion

  void dispose() {
    _subscriptionsSubject?.close();
    _notificationsSubject?.close();
    _inboxSubject?.close();
  }

  void _print(String s) {
    if (!kReleaseMode) {
      print(s);
    }
  }
}
