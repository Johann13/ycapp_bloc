import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ycapp_foundation/model/news/news_item.dart';

class NewsBloc {
  Stream<List<News>> getAllNews() {
    return FirebaseFirestore.instance
        .collection('News')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((querySnapshot) => querySnapshot.documents
            .map((doc) => News.fromMap(doc.data()))
            .toList());
  }

  Stream<News> getNews(String id) {
    return FirebaseFirestore.instance
        .collection('News')
        .document(id)
        .snapshots()
        .map((doc) => News.fromMap(doc.data()));
  }
}
