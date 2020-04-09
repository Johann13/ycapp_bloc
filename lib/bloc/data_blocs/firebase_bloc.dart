import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';

abstract class FirestoreBloc<T> {
  String collectionPath();

  T fromMap(Map map);

  Stream<T> getById(String docId) {
    return Firestore.instance
        .collection(collectionPath())
        .document(docId)
        .snapshots()
        .map((snap) {
      if (snap == null) {
        return null;
      }
      if (snap.data == null) {
        return null;
      }
      return fromMap(snap.data);
    });
  }

  Stream<List<T>> getAll() {
    return Firestore.instance
        .collection(collectionPath())
        .snapshots()
        .map((query) => query.documents
            .where((doc) => doc != null)
            .map((doc) => fromMap(doc.data))
            .where((v) => v != null)
            .toList())
        .asBroadcastStream();
  }

  Stream<List<T>> getByIds(List<String> docIds) {
    if (docIds.isEmpty) {
      return Stream.fromFuture(Future(() {
        return [];
      }));
    }
    List<Stream<T>> streamList =
        docIds.map((id) => getById(id)).where((v) => v != null).map((v) {
      return v;
    }).toList();
    return _combine(0, streamList)
        .map((l) => l.where((v) => v != null).toList())
        .asBroadcastStream();
  }

  Future<T> getOnceById(String docId) async {
    DocumentSnapshot doc = await Firestore.instance
        .collection(collectionPath())
        .document(docId)
        .get();
    if (doc == null) {
      return null;
    }
    if (doc.data == null) {
      return null;
    }
    return fromMap(doc.data);
  }

  Future<List<T>> getOnceByIds(List<String> docIds) async {
    if (docIds.isEmpty) {
      return [];
    }
    List<Future<T>> futureList = docIds
        .map((twitchId) => getOnceById(twitchId))
        .where((v) => v != null)
        .toList();
    return Future.wait(futureList);
  }

  Stream<List<T>> _combine(int i, List<Stream<T>> list) {
    return ZipStream(list, (v) => v.toList());
  }
}
