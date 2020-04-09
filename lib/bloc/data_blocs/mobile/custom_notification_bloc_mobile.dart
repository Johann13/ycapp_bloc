import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sqflite/sqflite.dart';
import 'package:ycapp_foundation/model/notification.dart';
import 'package:ycapp_foundation/prefs/prefs.dart';
import 'package:ycapp_analytics/ycapp_analytics.dart';

class NotificationBloc {
  String table = 'Notification';
  String inboxTable = 'InboxNotification';

  List<InboxNotification> _inboxList = [];
  BehaviorSubject<List<InboxNotification>> _inboxSubject = BehaviorSubject();
  Timer _timer;

  Database db;
  bool isLoading = false;

  Future<void> init() async {
    await open();
    await _init();
    if (_timer == null) {
      _timer = Timer.periodic(Duration(seconds: 10), (t) {
        //print('NotificationBloc timer isLoading=$isLoading ${DateTime.now()}');
        if (!isLoading) {
          _init();
        }
      });
    }
  }

  Future<Null> open() async {
    print('open db');
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "custom_notification.db");
    if (db == null || !db.isOpen) {
      db = await openDatabase(path,
          version: 2, onCreate: _onCreate, onUpgrade: _onUpdate);
    }
  }

  Future<void> _init() async {
    print('NotificationBloc init ${DateTime.now()}');
    _inboxList = await _getInboxNotifications();
    _inboxSubject.add(_inboxList);
  }

  Stream<List<InboxNotification>> get inboxStream => _inboxSubject;

  void _onCreate(Database db, int version) async {
    await db.execute("CREATE TABLE $table"
        "(id INTEGER PRIMARY KEY, "
        "type INTEGER, "
        "interval INTEGER, "
        "title TEXT, "
        "body TEXT, "
        "date INTEGER, "
        "channelId TEXT "
        ")");

    await db.execute("CREATE TABLE $inboxTable"
        "(id TEXT PRIMARY KEY, "
        "type INTEGER, "
        "channelId TEXT, "
        "channelName TEXT, "
        "title TEXT, "
        "videoId TEXT, "
        "date INTEGER, "
        "published INTEGER "
        ")");
  }

  void _onUpdate(Database db, int oldVersion, int newVersion) async {
    if (newVersion == 2) {
      await db.execute("CREATE TABLE $inboxTable"
          "(id TEXT PRIMARY KEY, "
          "type INTEGER, "
          "channelId TEXT, "
          "channelName TEXT, "
          "title TEXT, "
          "videoId TEXT, "
          "date INTEGER, "
          "published INTEGER "
          ")");
    }
  }

  Future<CustomNotification> _insertCustom(
      CustomNotification customNotification) async {
    await db.insert(table, customNotification.toMap());
    return customNotification;
  }

  Future<InboxNotification> _insertInbox(
      InboxNotification yNotification) async {
    await db.insert(inboxTable, yNotification.toMap());
    return yNotification;
  }

  Future<int> _deleteCustom(int id) {
    return db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteInbox(String id) {
    _inboxList.removeWhere((n) => n.id == id);
    _inboxSubject.add(_inboxList);
    return db.delete(inboxTable, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteAllInbox() async {
    _inboxList.clear();
    _inboxSubject.add(_inboxList);
    return db.delete(inboxTable);
  }

  Future<CustomNotification> getCustomNotification(int id) async {
    List<Map> maps = await db.query(table, where: '$id = ?', whereArgs: [id]);
    if (maps.length > 0) {
      return CustomNotification.fromMap(maps.first);
    }
    return null;
  }

  Future<List<CustomNotification>> getCustomNotifications() async {
    try {
      List<Map> maps = await db.query(
        table,
        orderBy: 'date DESC',
      );
      List<CustomNotification> list =
          maps.map((value) => CustomNotification.fromMap(value)).toList();

      List<Future> futures = [];
      DateTime now = DateTime.now();

      list.forEach((n) {
        if (n.interval == NotificationInterval.Once) {
          if (now.isAfter(n.date)) {
            futures.add(_deleteCustom(n.id));
          }
        }
      });
      list.removeWhere((n) {
        return n.interval == NotificationInterval.Once && now.isAfter(n.date);
      });

      await Future.wait(futures);

      return list;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<bool> updateFromQueue() async {
    List<String> notificationInboxQueue =
        await Prefs.getStringList('notificationInboxQueue');
    if (notificationInboxQueue.isEmpty) {
      return false;
    }
    try {
      print('updateFromQueue');
      isLoading = true;
      await Future.wait(notificationInboxQueue.map((id) async {
        print(id);
        InboxNotification notification = await _getInboxNotification(id);
        print(notification.title);
        await _insertInbox(notification);
        return null;
      }));
    } catch (e) {
      print('updateFromQueue $e');
    } finally {
      //print('notificationInboxQueue done');
      await Prefs.setStringList('notificationInboxQueue', []);
      isLoading = false;
    }
    return true;
  }

  Future<InboxNotification> _getInboxNotification(String id) async {
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('Notification').document(id).get();
    return InboxNotification.fromMap(snapshot.data);
  }

  Future<List<InboxNotification>> _getInboxNotifications() async {
    if (db == null || !db.isOpen) {
      await open();
    }
    await updateFromQueue();
    print('is db null? ${db == null}');
    List<Map> maps = await db.query(
      inboxTable,
      orderBy: 'date DESC',
    );
    return maps.map((map) => InboxNotification.fromMap(map)).toList();
  }

  Future<void> scheduleNotification(
    CustomNotification customNotification, {
    Time time,
    Day day,
  }) async {
    //print('removeNotification ${customNotification.toMap()} ${customNotification.date}');
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_stat_y');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) async {
      //print(payload);
    });

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        customNotification.notificationChannel,
        customNotification.notificationChannelDesc,
        customNotification.notificationChannelDesc,
        importance: Importance.Max,
        priority: Priority.High);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    switch (customNotification.interval) {
      case NotificationInterval.Once:
        //print('Once');
        await flutterLocalNotificationsPlugin.schedule(
          customNotification.id,
          customNotification.title,
          customNotification.body,
          customNotification.date,
          platformChannelSpecifics,
        );
        break;
      case NotificationInterval.Daily:
        //print('Daily');
        await flutterLocalNotificationsPlugin.showDailyAtTime(
          customNotification.id,
          customNotification.title,
          customNotification.body,
          time,
          platformChannelSpecifics,
        );
        break;
      case NotificationInterval.Weekly:
        //print('Weekly');
        await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
          customNotification.id,
          customNotification.title,
          customNotification.body,
          day,
          time,
          platformChannelSpecifics,
        );
        break;
    }

    await _insertCustom(customNotification);

    bool analyticsPermission =
        await Prefs.getBool('analyticsPermission', false);

    if (analyticsPermission) {
      await YAnalytics.log('addCustomNotification',
          parameters: customNotification.toMap());
    }
  }

  Future<Null> removeNotification(CustomNotification customNotification) async {
    //print('removeNotification ${customNotification.toMap()} ${customNotification.date}');
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: (payload) {
      return null;
    });
    await flutterLocalNotificationsPlugin.cancel(customNotification.id);
    await _deleteCustom(customNotification.id);
  }

  void dispose() {
    _timer?.cancel();
    _inboxSubject?.close();
  }
}
