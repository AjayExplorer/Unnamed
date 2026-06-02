import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/news_feed.dart';

class NewsService {
  static final NewsService _instance = NewsService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _newsCollection = 'news';

  NewsService._internal();

  factory NewsService() {
    return _instance;
  }

  Future<String> addNewsPost(NewsPost post) async {
    try {
      final docRef = await _firestore.collection(_newsCollection).add(post.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding news post: $e');
    }
  }

  Future<List<NewsPost>> getAllNewsPosts() async {
    try {
      final snapshot = await _firestore
          .collection(_newsCollection)
          .orderBy('postedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => NewsPost.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching news posts: $e');
    }
  }
}
