import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ycapp_bloc/bloc/firebase/data_bloc_base.dart';

abstract class FirestoreBloc<T> extends DataBloc<T> {

  @override
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

  @override
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

  @override
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
}