import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/food_post.dart';

class FoodSharingService {
  final CollectionReference _collection =
      FirebaseFirestore.instance.collection('food_sharing');

  /// Streams active food posts (sorted by creation date descending)
  /// Note: We filter expired posts on the client side or via query to ensure real-time accuracy,
  /// and we will also purge expired posts periodically.
  Stream<List<FoodPost>> streamActiveFoodPosts() {
    return _collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      final now = DateTime.now();
      return snapshot.docs.map((doc) => FoodPost.fromSnapshot(doc)).where((post) {
        // Only include posts whose pickupTimestamp is in the future
        return post.pickupTimestamp.isAfter(now);
      }).toList();
    });
  }

  /// Adds a new food sharing post to Firestore
  Future<void> addFoodPost(FoodPost post) async {
    await _collection.add(post.toMap());
  }

  /// Deletes a specific food sharing post
  Future<void> deleteFoodPost(String docId) async {
    await _collection.doc(docId).delete();
  }

  /// Automatically deletes expired food posts from Firestore.
  /// Queries all documents where pickupTimestamp is less than or equal to now,
  /// and deletes them in a batch.
  Future<void> deleteExpiredPosts() async {
    try {
      final now = Timestamp.fromDate(DateTime.now());
      final expiredSnapshot = await _collection
          .where('pickupTimestamp', isLessThanOrEqualTo: now)
          .get();

      if (expiredSnapshot.docs.isEmpty) return;

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in expiredSnapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
      debugPrint('Successfully deleted ${expiredSnapshot.docs.length} expired food posts.');
    } catch (e) {
      debugPrint('Error deleting expired food posts: $e');
    }
  }
}
