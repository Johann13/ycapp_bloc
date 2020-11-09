import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:ycapp_foundation/model/schedule/jj_schedule.dart';

abstract class JJScheduleBlocBase {
  Stream<JJSchedule> getSchedule(String year);

  Future<List<JJSlot>> getRelatedSlots(String year, String creatorId);

  Stream<JJSlot> getSlot(String year, String id);

  Stream<List<JJSlot>> getSlotsByIds(String year, List<String> ids) {
    if (ids.isEmpty) {
      return Stream.fromFuture(Future(() {
        return [];
      }));
    }
    List<Stream<JJSlot>> streamList = ids.map((id) => getSlot(year, id)).toList();
    return CombineLatestStream.list(streamList).map((list) {
      list.sort((a, b) => a.start.compareTo(b.start));
      return list
          .where((v) => v != null)
          .where((slot) => !slot.isEnded)
          .toList();
    });
  }
}
