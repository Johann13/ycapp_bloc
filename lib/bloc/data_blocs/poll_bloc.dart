import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ycapp_foundation/model/poll.dart';

class PollBloc {
  Stream<List<Poll>> getPolls() {
    return FirebaseFirestore.instance
        .collection('Poll')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((change) => Poll.fromMap(change.data()))
            .toList());
  }
}
