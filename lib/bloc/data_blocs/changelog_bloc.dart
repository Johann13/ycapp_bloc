import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ycapp_foundation/model/change_log.dart';

class ChangelogBloc {
  Stream<List<Changelog>> getChangeLogs() {
    return Firestore.instance
        .collection('Changelog')
        .orderBy('id', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .map((change) => Changelog.fromMap(change.data))
            .where((v) => v != null)
            .toList());
  }

  Stream<Changelog> getLastChangeLogs() {
    return Firestore.instance
        .collection('Changelog')
        .orderBy('id', descending: true)
        .limit(1)
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .map((change) => Changelog.fromMap(change.data))
            .where((v) => v != null)
            .toList()[0]);
  }
}