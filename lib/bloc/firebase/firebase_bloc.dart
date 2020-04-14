import 'package:ycapp_bloc/bloc/firebase/data_bloc_base.dart';
import 'package:firebase/firebase.dart';

abstract class FirebaseBloc<T> extends DataBloc<T> {
  @override
  Stream<List<T>> getAll() {
    return database().ref(collectionPath()).onValue.map((event) {
      List<T> list = [];
      event.snapshot.forEach((d) {
        list.add(fromMap(d.toJson()));
      });
      return list;
    });
  }

  @override
  Stream<T> getById(String docId) {
    return database()
        .ref('${collectionPath()}/$docId')
        .onValue
        .map((event) => fromMap(event.snapshot.toJson()));
  }

  @override
  Future<T> getOnceById(String docId) {
    return database()
        .ref('${collectionPath()}/$docId')
        .once('value')
        .then((value) => fromMap(value.snapshot.toJson()));
  }
}
