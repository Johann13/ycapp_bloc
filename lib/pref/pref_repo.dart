import 'dart:async';
import 'dart:core';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ycapp_foundation/model/channel/image_quality.dart';
import 'package:ycapp_foundation/ui/y_colors.dart';
import 'package:ycapp_connectivity/ycappconnectivity.dart';
import 'package:ycapp_foundation/prefs/prefs.dart';

abstract class Pref<T> {
  Map<String, BehaviorSubject<T>> subjectMap = {};
  Map<String, List<String>> multiStreamNames = {};
  Map<String, T> valueMap = {};

  Future<Null> init();

  Stream<T> getPrefStream(String prefName, T defaultValue) {
    if (!subjectMap.containsKey(prefName)) {
      subjectMap[prefName] = BehaviorSubject();
      _setValue(prefName, defaultValue);
    }
    return subjectMap[prefName];
  }

  Future<Null> setPref(String prefName, T value) async {
    await _setPref(prefName, value);
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
    return ZipStream(list, (v) => v.toList());
  }

  Future<Null> setMultiplePrefs(List<String> prefNames, List<T> values) async {
    List<Future> futures = [];
    if (!multiStreamNames.containsKey(prefNames.toString())) {
      multiStreamNames[prefNames.toString()] = prefNames;
    }
    for (int i = 0; i < prefNames.length; i++) {
      futures.add(setPref(prefNames[i], values[i]));
    }
    await Future.value(futures);
  }

  Future<Null> _setValue(String prefName, T defaultValue) async {
    T value = await _getPref(prefName, defaultValue);
    subjectMap[prefName].add(value);
    valueMap[prefName] = value;
  }

  Future<List<T>> getMultiplePrefs(
      List<String> prefNames, List<T> defaultValues) async {
    List<Future<T>> futures = [];
    for (int i = 0; i < prefNames.length; i++) {
      futures.add(_getPref(prefNames[i], defaultValues[i]));
    }
    return Future.wait(futures);
  }

  Future<T> _getPref(String prefName, T defaultValue);

  Future<Null> _setPref(String prefName, T value);

  Future<T> getPref(String prefName, T defaultValue) {
    return _getPref(prefName, defaultValue);
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
  Future<int> _getPref(String prefName, int defaultValue) {
    return Prefs.getInt(prefName, defaultValue);
  }

  @override
  Future<Null> _setPref(String prefName, int value) async {
    await Prefs.setInt(prefName, value);
  }

  Future<Null> init() async {
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
  Future<double> _getPref(String prefName, double defaultValue) {
    return Prefs.getDouble(prefName, defaultValue);
  }

  @override
  Future<Null> _setPref(String prefName, double value) async {
    await Prefs.setDouble(prefName, value);
  }

  @override
  Future<Null> init() async {
    return null;
  }
}

class StringPref extends Pref<String> {
  String _scheduleTheme;
  StreamSubscription<String> _scheduleThemeSub;
  String _theme;
  StreamSubscription<String> _themeSub;

  @override
  Future<String> _getPref(String prefName, String defaultValue) {
    return Prefs.getString(prefName, defaultValue);
  }

  @override
  Future<Null> _setPref(String prefName, String value) async {
    await Prefs.setString(prefName, value);
  }

  Future<Null> init() async {
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
  Future<List<String>> _getPref(String prefName, List<String> defaultValue) {
    return Prefs.getStringList(prefName);
  }

  @override
  Future<Null> _setPref(String prefName, List<String> value) async {
    await Prefs.setStringList(prefName, value);
  }

  Future<Null> addItem(String prefName, String value) async {
    List<String> list = await _getPref(prefName, []);
    list.add(value);
    await setPref(prefName, list);
  }

  Future<Null> removeItem(String prefName, String value) async {
    List<String> list = await _getPref(prefName, []);
    list.remove(value);
    await setPref(prefName, list);
  }

  Future<Null> removeAt(String prefName, int index) async {
    List<String> list = await _getPref(prefName, []);
    list.removeAt(index);
    await setPref(prefName, list);
  }

  @override
  Future<Null> init() async {
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
