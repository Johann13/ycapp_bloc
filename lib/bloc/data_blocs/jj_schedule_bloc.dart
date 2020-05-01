import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ycapp_foundation/model/schedule/jj_schedule.dart';

class JJScheduleBloc {
  Stream<JJSchedule> getSchedule() {
    return Firestore.instance
        .collection('JingleJam')
        .document('2019')
        .collection('Schedule')
        .snapshots()
        .map((query) {
      List<JJSlot> slots =
          query.documents.map((doc) => JJSlot.fromMap(doc.data)).toList();
      JJSchedule schedule = JJSchedule(slots);
      return schedule;
    });
  }

  Future<List<JJSlot>> getRelatedSlots(String creatorId) async {
    return Firestore.instance
        .collection('JingleJam')
        .document('2019')
        .collection('Schedule')
        .where('creator', arrayContains: creatorId)
        .getDocuments()
        .then((query) =>
            query.documents.map((doc) => JJSlot.fromMap(doc.data)).toList());
  }

  Stream<JJSlot> getSlot(String id) {
    return Firestore.instance
        .collection('JingleJam')
        .document('2019')
        .collection('Schedule')
        .document(id)
        .snapshots()
        .map((doc) => JJSlot.fromMap(doc.data));
  }

  Stream<List<JJSlot>> getSlotsByIds(List<String> ids) {
    if (ids.isEmpty) {
      return Stream.fromFuture(Future(() {
        return [];
      }));
    }
    List<Stream<JJSlot>> streamList = ids.map((id) => getSlot(id)).toList();
    return CombineLatestStream.list(streamList).map((list) {
      list.sort((a, b) => a.start.compareTo(b.start));
      return list
          .where((v) => v != null)
          .where((slot) => !slot.isEnded)
          .toList();
    });
  }
}
