import 'dart:async';
import 'dart:core';

import 'package:rxdart/rxdart.dart';
import 'package:ycapp_foundation/prefs/prefs.dart';

abstract class Pref<T> {
  Map<String, BehaviorSubject<T>> subjectMap = {};
  Map<String, List<String>> multiStreamNames = {};
  Map<String, T> valueMap = {};

  Future<void> init();

  Stream<T> getPrefStream(String prefName, T defaultValue) {
    if (!subjectMap.containsKey(prefName)) {
      subjectMap[prefName] = BehaviorSubject();
      _setValue(prefName, defaultValue);
    }
    return subjectMap[prefName];
  }

  Future<void> setPref(String prefName, T value) async {
    await setPrefDirect(prefName, value);
    if (!subjectMap.containsKey(prefName)) {
      subjectMap[prefName] = BehaviorSubject<T>();
    }
    await _setValue(prefName, value);

    List<String> keys =
        multiStreamNames.keys.where((key) => key.contains(prefName)).toList();
    List<String> prefs = [];
    keys.forEach((key) => prefs.addAll(multiStreamNames[key]));
    if (prefs.isNotEmpty) {
      await Future.wait(prefs
          .where((pref) => pref != prefName)
          .map((pref) => _setValue(pref, valueMap[pref])));
    }
  }

  Stream<List<T>> getMultiplePrefsStream(
      List<String> prefNames, List<T> defaultValues) {
    List<Stream<T>> streams = [];
    if (!multiStreamNames.containsKey(prefNames.toString())) {
      multiStreamNames[prefNames.toString()] = prefNames;
    }
    for (int i = 0; i < prefNames.length; i++) {
      streams.add(getPrefStream(prefNames[i], defaultValues[i]));
    }
    return _combine(0, streams).asBroadcastStream();
  }

  Stream<List<T>> _combine(int i, List<Stream<T>> list) {
    return CombineLatestStream.list(list);
  }

  Future<void> setMultiplePrefs(List<String> prefNames, List<T> values) async {
    List<Future> futures = [];
    if (!multiStreamNames.containsKey(prefNames.toString())) {
      multiStreamNames[prefNames.toString()] = prefNames;
    }
    for (int i = 0; i < prefNames.length; i++) {
      futures.add(setPref(prefNames[i], values[i]));
    }
    await Future.value(futures);
  }

  Future<void> _setValue(String prefName, T defaultValue) async {
    T value = await getPrefDirect(prefName, defaultValue);
    subjectMap[prefName].add(value);
    valueMap[prefName] = value;
  }

  Future<List<T>> getMultiplePrefs(
      List<String> prefNames, List<T> defaultValues) async {
    List<Future<T>> futures = [];
    for (int i = 0; i < prefNames.length; i++) {
      futures.add(getPrefDirect(prefNames[i], defaultValues[i]));
    }
    return Future.wait(futures);
  }

  Future<T> getPrefDirect(String prefName, T defaultValue);

  Future<void> setPrefDirect(String prefName, T value);

  Future<T> getPref(String prefName, T defaultValue) {
    return getPrefDirect(prefName, defaultValue);
  }

  void dispose() {
    if (subjectMap != null) {
      subjectMap.forEach((key, subject) {
        subject.close();
      });
    }
  }
}

class IntPref extends Pref<int> {
  StreamSubscription _gridSizeSub;
  int _gridSize;

  @override
  Future<int> getPrefDirect(String prefName, int defaultValue) {
    return Prefs.getInt(prefName, defaultValue);
  }

  @override
  Future<void> setPrefDirect(String prefName, int value) async {
    await Prefs.setInt(prefName, value);
  }

  Future<void> init() async {
    _gridSizeSub = getPrefStream('gridSize', 3).listen((data) {
      _gridSize = data;
    });
    return null;
  }

  int get gridSize => _gridSize;

  void dispose() {
    super.dispose();
    _gridSizeSub?.cancel();
  }
}

class DoublePref extends Pref<double> {
  @override
  Future<double> getPrefDirect(String prefName, double defaultValue) {
    return Prefs.getDouble(prefName, defaultValue);
  }

  @override
  Future<void> setPrefDirect(String prefName, double value) async {
    await Prefs.setDouble(prefName, value);
  }

  @override
  Future<void> init() async {
    return null;
  }
}

class StringPref extends Pref<String> {
  String _scheduleTheme;
  StreamSubscription<String> _scheduleThemeSub;
  String _theme;
  StreamSubscription<String> _themeSub;

  @override
  Future<String> getPrefDirect(String prefName, String defaultValue) {
    return Prefs.getString(prefName, defaultValue);
  }

  @override
  Future<void> setPrefDirect(String prefName, String value) async {
    await Prefs.setString(prefName, value);
  }

  Future<void> init() async {
    _scheduleThemeSub = getPrefStream('scheduleTheme', 'yogs').listen((data) {
      _scheduleTheme = data;
    });
    _themeSub = getPrefStream('theme', 'blue').listen((data) {
      _theme = data;
    });
    return null;
  }

  String get scheduleTheme => _scheduleTheme;

  String get theme => _theme;

  void dispose() {
    super.dispose();
    _scheduleThemeSub?.cancel();
    _themeSub?.cancel();
  }
}

class StringListPref extends Pref<List<String>> {
  @override
  Future<List<String>> getPrefDirect(String prefName, List<String> defaultValue) {
    return Prefs.getStringList(prefName);
  }

  @override
  Future<void> setPrefDirect(String prefName, List<String> value) async {
    await Prefs.setStringList(prefName, value);
  }

  Future<void> addItem(String prefName, String value) async {
    List<String> list = await getPrefDirect(prefName, []);
    list.add(value);
    await setPref(prefName, list);
  }

  Future<void> removeItem(String prefName, String value) async {
    List<String> list = await getPrefDirect(prefName, []);
    list.remove(value);
    await setPref(prefName, list);
  }

  Future<void> removeAt(String prefName, int index) async {
    List<String> list = await getPrefDirect(prefName, []);
    list.removeAt(index);
    await setPref(prefName, list);
  }

  @override
  Future<void> init() async {
    List<String> order = [
      'news',
      'my_jj_schedule',
      'jj_schedule',
      'main_schedule',
      'creator',
      'twitch',
      'youtube',
      'notification_inbox',
      'menu',
    ];
    List<String> o = await getPref('homePagePagePosition', order);

    if (o.isEmpty) {
      await setPref('homePagePagePosition', order);
    }

    return null;
  }
}
