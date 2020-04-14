import 'package:ycapp_bloc/bloc/firebase/data_bloc_base.dart';

class FirebaseBloc<T> extends DataBloc<T> {
  @override
  String collectionPath() {
    // TODO: implement collectionPath
    throw UnimplementedError();
  }

  @override
  T fromMap(Map map) {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  Stream<List<T>> getAll() {
    // TODO: implement fromMap
    throw UnimplementedError();
  }

  @override
  Stream<T> getById(String docId) {
    // TODO: implement getById
    throw UnimplementedError();
  }

  @override
  Future<T> getOnceById(String docId) {
    // TODO: implement getOnceById
    throw UnimplementedError();
  }
}
