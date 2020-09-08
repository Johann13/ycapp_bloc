import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ycapp_foundation/model/yogcon/signing.dart';
import 'package:ycapp_foundation/model/yogcon/yogcon_schedule.dart';

class YogconBloc {
  Stream<List<Signing>> getSignings() {
    return FirebaseFirestore.instance
        .collection('Yogcon')
        .document('signings')
        .collection('signings')
        .snapshots()
        .map((query) =>
            query.documents.map((doc) => Signing.fromMap(doc.data())).toList())
        .asBroadcastStream();
  }

  Stream<SigningDay> getSigningDay(int day) {
    return FirebaseFirestore.instance
        .collection('Yogcon')
        .document('signings')
        .collection('signings')
        .where('day', isEqualTo: day)
        .snapshots()
        .map((query) =>
            query.documents.map((doc) => Signing.fromMap(doc.data())).toList())
        .map((list) => SigningDay(list))
        .asBroadcastStream();
  }

  Stream<List<YCSlot>> getSlots() {
    return FirebaseFirestore.instance
        .collection('Yogcon')
        .document('schedule')
        .collection('schedule')
        .snapshots()
        .map((query) =>
            query.documents.map((doc) => YCSlot.fromMap(doc.data())).toList())
        .asBroadcastStream();
  }

  Stream<YCSlot> getSlot(String id) {
    return FirebaseFirestore.instance
        .collection('Yogcon')
        .document('schedule')
        .collection('schedule')
        .document(id)
        .snapshots()
        .map((doc) => YCSlot.fromMap(doc.data()))
        .asBroadcastStream();
  }

  Stream<List<YCSlot>> getSlotsByCreator(String creatorId) {
    return FirebaseFirestore.instance
        .collection('Yogcon')
        .document('schedule')
        .collection('schedule')
        .where('creator', arrayContains: creatorId)
        .snapshots()
        .map((query) =>
            query.documents.map((doc) => YCSlot.fromMap(doc.data())).toList())
        .asBroadcastStream();
  }

  Stream<YCDay> getScheduleDay(int day) {
    return FirebaseFirestore.instance
        .collection('Yogcon')
        .document('schedule')
        .collection('schedule')
        .where('day', isEqualTo: day)
        .snapshots()
        .map((query) =>
            query.documents.map((doc) => YCSlot.fromMap(doc.data())).toList())
        .map((list) => YCDay(list))
        .asBroadcastStream();
  }

  Stream<YCSchedule> getSchedule() {
    return getSlots().map((list) => YCSchedule(list)).asBroadcastStream();
  }

  Stream<Signing> getSigning(String id) {
    return FirebaseFirestore.instance
        .collection('Yogcon')
        .document('signings')
        .collection('signings')
        .document(id)
        .snapshots()
        .map((v) => Signing.fromMap(v.data()));
  }
}
