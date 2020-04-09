import 'dart:async';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ycapp_foundation/model/schedule/combined_schedule.dart';
import 'package:ycapp_foundation/model/schedule/schedule.dart';

class ScheduleBloc {
  Stream<List<ScheduleSlot>> getSlots(String twitchId) {
    return Firestore.instance
        .collection('TwitchChannel')
        .document(twitchId)
        .collection('Schedule')
        .orderBy('day', descending: false)
        .orderBy('slot', descending: false)
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .where((v) => v.data != null)
            .map((change) => ScheduleSlot.fromMap(twitchId, change.data))
            .toList());
  }

  Stream<Schedule> getSchedule(String twitchId) {
    return getSlots(twitchId).map((list) => Schedule(twitchId, list));
  }

  Future<List<ScheduleSlot>> getSlotsOnce(String twitchId) async {
    QuerySnapshot snapshot = await Firestore.instance
        .collection('TwitchChannel')
        .document(twitchId)
        .collection('Schedule')
        .orderBy('day', descending: false)
        .orderBy('slot', descending: false)
        .getDocuments();
    return snapshot.documents
        .map((doc) => ScheduleSlot.fromMap(twitchId, doc.data))
        .toList();
  }

  Future<List<ScheduleSlot>> getMultipleSlotsOnce(
      List<String> twitchIds) async {
    List<Future<List<ScheduleSlot>>> futures = twitchIds.map((twitchId) {
      return getSlotsOnce(twitchId);
    }).toList();

    List<List<ScheduleSlot>> list = await Future.wait(futures);

    return list.expand((l) => l).toList();
  }

  Future<CombinedSchedule> getCombinedScheduleOnce(
      List<String> twitchIds) async {
    List<ScheduleSlot> slots = await getMultipleSlotsOnce(twitchIds);

    return CombinedSchedule.withList(slots);
  }

  Stream<CombinedSchedule> getCombinedSchedule(List<String> ids) {
    if (ids.isEmpty) {
      return Stream.fromFuture(Future(() {
        return null;
      }));
    }
    List<Stream<List<ScheduleSlot>>> streamList =
        ids.map((id) => getSlots(id)).toList();
    return StreamZip(streamList)
        .map((list) => list.where((v) => v != null).toList())
        .map((list) => list.expand((l) => l).toList())
        .map((list) => CombinedSchedule.withList(list));
  }

  Stream<ScheduleSlot> getSlot(String id, String twitchId) {
    return Firestore.instance
        .collection('TwitchChannel')
        .document(twitchId)
        .collection('Schedule')
        .document(id)
        .snapshots()
        .map((doc) => ScheduleSlot.fromMap(twitchId, doc.data));
  }

  Future<List<ScheduleSlot>> getRelatedSlots(
      String creatorId, String twitchId) async {
    var query = await Firestore.instance
        .collection('TwitchChannel')
        .document(twitchId)
        .collection('Schedule')
        .where('creator', arrayContains: creatorId)
        .getDocuments();

    //print('docs ${query.documents.length}');

    List<ScheduleSlot> slots = query.documents
        .map((change) => ScheduleSlot.fromMap(twitchId, change.data))
        .toList();
    //print('slots ${slots.length}');
    return slots;
  }
}
