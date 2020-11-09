import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:ycapp_foundation/model/schedule/jj_schedule.dart';

class JJScheduleBloc {
  Stream<JJSchedule> getSchedule(String year) {
    return FirebaseFirestore.instance
        .collection('JingleJam')
        .doc(year)
        .collection('Schedule')
        .snapshots()
        .map((query) {
      List<JJSlot> slots =
      query.docs.map((doc) => JJSlot.fromMap(year, doc.data())).toList();
      JJSchedule schedule = JJSchedule(year, slots);
      return schedule;
    });
  }

  Future<List<JJSlot>> getRelatedSlots(String year, String creatorId) async {
    return FirebaseFirestore.instance
        .collection('JingleJam')
        .doc(year)
        .collection('Schedule')
        .where('creator', arrayContains: creatorId)
        .get()
        .then((query) =>
        query.docs.map((doc) => JJSlot.fromMap(year, doc.data())).toList());
  }

  Stream<JJSlot> getSlot(String id,
      String year,) {
    return FirebaseFirestore.instance
        .collection('JingleJam')
        .doc(year)
        .collection('Schedule')
        .doc(id)
        .snapshots()
        .map((doc) => JJSlot.fromMap(year, doc.data()));
  }

  Stream<List<JJSlot>> getSlotsByIds(List<String> ids, String year) {
    if (ids.isEmpty) {
      return Stream.fromFuture(Future(() {
        return [];
      }));
    }
    List<Stream<JJSlot>> streamList = ids.map((id) => getSlot(id, year,))
        .toList();
    return CombineLatestStream.list(streamList).map((list) {
      list.sort((a, b) => a.start.compareTo(b.start));
      return list
          .where((v) => v != null)
          .where((slot) => !slot.isEnded)
          .toList();
    });
  }
}
