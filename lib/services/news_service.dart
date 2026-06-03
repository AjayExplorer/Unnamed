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

  Future<void> deleteNewsPost(String postId) async {
    try {
      await _firestore.collection(_newsCollection).doc(postId).delete();
    } catch (e) {
      throw Exception('Error deleting news post: $e');
    }
  }

  Future<List<NewsPost>> getAllNewsPosts() async {
    try {
      final snapshot = await _firestore
          .collection(_newsCollection)
          .orderBy('postedAt', descending: true)
          .get();
      
      final now = DateTime.now();
      final validDocs = <QueryDocumentSnapshot<Map<String, dynamic>>>[];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final postedAtValue = data['postedAt'];
        DateTime parsedPostedAt;

        if (postedAtValue is Timestamp) {
          parsedPostedAt = postedAtValue.toDate();
        } else if (postedAtValue is String) {
          parsedPostedAt = DateTime.tryParse(postedAtValue)?.toLocal() ?? DateTime.now();
        } else {
          parsedPostedAt = DateTime.now();
        }
        
        if (now.difference(parsedPostedAt).inHours >= 72) {
          _firestore.collection(_newsCollection).doc(doc.id).delete();
        } else {
          validDocs.add(doc);
        }
      }

      return validDocs
          .map((doc) => NewsPost.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error fetching news posts: $e');
    }
  }
}
