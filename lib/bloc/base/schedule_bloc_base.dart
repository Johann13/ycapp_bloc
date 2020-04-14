import 'package:rxdart/rxdart.dart';
import 'package:ycapp_foundation/model/schedule/combined_schedule.dart';
import 'package:ycapp_foundation/model/schedule/schedule.dart';

abstract class ScheduleBlocBase {
  Stream<List<ScheduleSlot>> getSlots(String twitchId);

  Future<List<ScheduleSlot>> getSlotsOnce(String twitchId);

  Stream<ScheduleSlot> getSlot(String id, String twitchId);

  Future<List<ScheduleSlot>> getRelatedSlots(String creatorId, String twitchId);

  Stream<Schedule> getSchedule(String twitchId) {
    return getSlots(twitchId).map((list) => Schedule(twitchId, list));
  }

  Future<Schedule> getScheduleOnce(String twitchId) {
    return getSlotsOnce(twitchId).then((value) => Schedule(twitchId, value));
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
    return CombineLatestStream.list(streamList)
        .map((list) => list.where((v) => v != null).toList())
        .map((list) => list.expand((l) => l).toList())
        .map((list) => CombinedSchedule.withList(list));
  }

  ScheduleSlot toSlot(String twitchId, Map map) {
    return ScheduleSlot.fromMap(twitchId, map);
  }
}
