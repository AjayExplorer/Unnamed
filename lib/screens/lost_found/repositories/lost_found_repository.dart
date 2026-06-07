import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/lost_found_item.dart';

class LostFoundRepository {
  final CollectionReference _collection = FirebaseFirestore.instance.collection(
    'lost_found',
  );

  /// Adds a new lost/found post.
  Future<void> addItem(LostFoundItem item) async {
    await _collection.add(item.toMap());
  }

  /// Deletes a post only if the requesting user is the creator.
  Future<bool> deleteItem(String docId, String currentUserId) async {
    final doc = await _collection.doc(docId).get();
    if (!doc.exists) return false;
    final data = doc.data() as Map<String, dynamic>;
    if (data['createdBy'] != currentUserId) return false;
    await _collection.doc(docId).delete();
    return true;
  }

  /// Fetches items filtered by [type] ('lost'/'found'), optional [searchQuery],
  /// and sort order.
  Future<List<LostFoundItem>> fetchItems({
    required String type,
    String searchQuery = '',
    String sortBy = 'latest', // 'latest', 'oldest', 'alphabetical'
  }) async {
    Query query = _collection;

    // Firestore doesn't natively support substring search, so we
    // sort server-side by date and filter client-side for keywords.
    if (sortBy == 'oldest') {
      query = query.orderBy('createdAt', descending: false);
    } else {
      // For 'latest' and 'alphabetical', fetch by latest first then
      // re-sort alphabetically client-side if needed.
      query = query.orderBy('createdAt', descending: true);
    }

    final snapshot = await query.get();
    List<LostFoundItem> items = snapshot.docs
        .map((doc) => LostFoundItem.fromFirestore(doc))
        .toList();

    // Client-side type filter
    items = items.where((item) => item.type == type).toList();

    // Client-side search filter
    if (searchQuery.trim().isNotEmpty) {
      final q = searchQuery.trim().toLowerCase();
      items = items.where((item) {
        return item.keyword.toLowerCase().contains(q) ||
            item.description.toLowerCase().contains(q);
      }).toList();
    }

    // Client-side alphabetical sort
    if (sortBy == 'alphabetical') {
      items.sort(
        (a, b) => a.keyword.toLowerCase().compareTo(b.keyword.toLowerCase()),
      );
    }

    return items;
  }
}
