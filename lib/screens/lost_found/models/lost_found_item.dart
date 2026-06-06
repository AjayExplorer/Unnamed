import 'package:cloud_firestore/cloud_firestore.dart';

class LostFoundItem {
  final String id;
  final String type; // 'lost' or 'found'
  final String keyword;
  final String description;
  final String imageUrl;
  final String createdBy; // Firebase Auth UID
  final String createdByName;
  final DateTime createdAt;

  LostFoundItem({
    required this.id,
    required this.type,
    required this.keyword,
    required this.description,
    this.imageUrl = '',
    required this.createdBy,
    required this.createdByName,
    required this.createdAt,
  });

  factory LostFoundItem.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return LostFoundItem(
      id: doc.id,
      type: data['type'] ?? 'lost',
      keyword: data['keyword'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      createdBy: data['createdBy'] ?? '',
      createdByName: data['createdByName'] ?? 'Unknown',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'keyword': keyword,
      'description': description,
      'imageUrl': imageUrl,
      'createdBy': createdBy,
      'createdByName': createdByName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
