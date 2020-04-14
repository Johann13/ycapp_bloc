import 'dart:async';

import 'package:rxdart/rxdart.dart';

abstract class DataBloc<T> {

  String collectionPath();

  Stream<T> getById(String docId);

  Stream<List<T>> getAll();

  Future<T> getOnceById(String docId);

  T fromMap(Map map);

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
    return CombineLatestStream.list(streamList)
        .map((l) => l.where((v) => v != null).toList())
        .asBroadcastStream();
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
}
