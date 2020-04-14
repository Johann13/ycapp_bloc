import 'dart:async';

import 'package:async/async.dart';
import 'package:ycapp_foundation/model/schedule/jj_schedule.dart';

abstract class JJScheduleBlocBase {
  Stream<JJSchedule> getSchedule();

  Future<List<JJSlot>> getRelatedSlots(String creatorId);

  Stream<JJSlot> getSlot(String id);

  Stream<List<JJSlot>> getSlotsByIds(List<String> ids) {
    if (ids.isEmpty) {
      return Stream.fromFuture(Future(() {
        return [];
      }));
    }
    List<Stream<JJSlot>> streamList = ids.map((id) => getSlot(id)).toList();
    return StreamZip(streamList).map((list) {
      list.sort((a, b) => a.start.compareTo(b.start));
      return list
          .where((v) => v != null)
          .where((slot) => !slot.isEnded)
          .toList();
    });
  }
}
