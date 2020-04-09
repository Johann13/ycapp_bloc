import 'dart:async';

import 'package:async/async.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ycapp_foundation/model/schedule/jj_schedule_2018.dart';

class JJScheduleBloc2018 {
  Stream<List<JJScheduleSlot2018>> getSlots() {
    return Firestore.instance
        .collection('JJSchedule')
        .orderBy('day', descending: false)
        .orderBy('slot', descending: false)
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .map((change) => JJScheduleSlot2018.fromMap(change.data))
            .toList());
  }

  Stream<List<JJScheduleSlot2018>> getSlotsByIds(List<String> ids) {
    if (ids.isEmpty) {
      return Stream.fromFuture(Future(() {
        return [];
      }));
    }
    List<Stream<JJScheduleSlot2018>> streamList =
        ids.map((id) => getSlot(id)).toList();
    return StreamZip(streamList).map((list) {
      list.sort((a, b) => a.start.compareTo(b.start));
      return list
          .where((v) => v != null)
          .where((slot) => !slot.isEnded)
          .toList();
    });
  }

  Stream<JJScheduleDay2018> getDaySlots(int day) {
    return Firestore.instance
        .collection('JJSchedule')
        .where('day', isEqualTo: day)
        .orderBy('slot', descending: false)
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .map((change) => JJScheduleSlot2018.fromMap(change.data))
            .toList())
        .map((list) => JJScheduleDay2018(day, list));
  }

  Stream<JJScheduleSlot2018> getSlot(String id) {
    return Firestore.instance
        .collection('JJSchedule')
        .document(id)
        .snapshots()
        .map((doc) => JJScheduleSlot2018.fromMap(doc.data));
  }

  Future<List<JJScheduleSlot2018>> getSlotsOnce() async {
    var query = await Firestore.instance
        .collection('JJSchedule')
        .orderBy('day', descending: false)
        .orderBy('slot', descending: false)
        .getDocuments();
    return query.documents
        .map((change) => JJScheduleSlot2018.fromMap(change.data))
        .toList();
  }

  Future<JJScheduleDay2018> getDayOnce(int day) async {
    var query = await Firestore.instance
        .collection('JJSchedule')
        .where('day', isEqualTo: day)
        .orderBy('slot', descending: false)
        .getDocuments();

    List<JJScheduleSlot2018> slots = query.documents
        .map((change) => JJScheduleSlot2018.fromMap(change.data))
        .toList();
    JJScheduleDay2018 slotDay = JJScheduleDay2018(day - 1, []);
    for (int i = 0; i < slots.length; i++) {
      JJScheduleSlot2018 slot = slots[i];
      if (slot.slot == 1) {
        slot.showStart = true;
        slotDay.slots.add(slot);
      } else {
        if (slot.day != slots[i - 1].day) {
          slot.showStart = true;
          slotDay.slots.add(slot);
        } else if (slot.title == slots[i - 1].title) {
          slots[i - 1].length += 1;
          slot.id = slots[i - 1].id;
          slot.color = slots[i - 1].color;
          slot.desc = slots[i - 1].desc;
          slot.darkText = slots[i - 1].darkText;
          slot.length = slots[i - 1].length;
          slot.showStart = false;
          slotDay.slots.add(slot);
        } else {
          slot.showStart = true;
          slotDay.slots.add(slot);
        }
      }
    }
    return slotDay;
  }

  Future<JJScheduleWeek2018> getWeekOnce(int day) async {
    List<Future<JJScheduleDay2018>> dayFutures = [];
    for (int i = day; i <= day + 6; i++) {
      if (i <= 31) {
        dayFutures.add(getDayOnce(i));
      }
    }
    List<JJScheduleDay2018> result = await Future.wait(dayFutures);
    return JJScheduleWeek2018(0, result);
  }

  Future<List<JJScheduleSlot2018>> getRelatedSlots(String creatorId) async {
    var query = await Firestore.instance
        .collection('JJSchedule')
        .where('creator', arrayContains: creatorId)
        .orderBy('day', descending: false)
        .orderBy('slot', descending: false)
        .getDocuments();
    return query.documents
        .map((change) => JJScheduleSlot2018.fromMap(change.data))
        .toList();
  }
}
