import 'package:cloud_firestore/cloud_firestore.dart';

class NewsPost {
  const NewsPost({
    this.id,
    required this.title,
    required this.details,
    required this.category,
    required this.author,
    required this.authorId,
    required this.postedAt,
  });

  final String? id;
  final String title;
  final String details;
  final String category;
  final String author;
  final String authorId;
  final DateTime postedAt;

  String get timeLabel {
    final diff = DateTime.now().difference(postedAt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    }
    if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    }
    if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    }
    return '${diff.inDays}d ago';
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'details': details,
      'category': category,
      'author': author,
      'authorId': authorId,
      'postedAt': Timestamp.fromDate(postedAt),
    };
  }

  factory NewsPost.fromMap(Map<String, dynamic> map, String docId) {
    final postedAtValue = map['postedAt'];
    DateTime parsedPostedAt;

    if (postedAtValue is Timestamp) {
      parsedPostedAt = postedAtValue.toDate();
    } else if (postedAtValue is String) {
      parsedPostedAt = DateTime.tryParse(postedAtValue)?.toLocal() ?? DateTime.now();
    } else {
      parsedPostedAt = DateTime.now();
    }

    return NewsPost(
      id: docId,
      title: map['title'] ?? '',
      details: map['details'] ?? '',
      category: map['category'] ?? '',
      author: map['author'] ?? '',
      authorId: map['authorId'] ?? '',
      postedAt: parsedPostedAt,
    );
  }

  NewsPost copyWith({
    String? id,
    String? title,
    String? details,
    String? category,
    String? author,
    String? authorId,
    DateTime? postedAt,
  }) {
    return NewsPost(
      id: id ?? this.id,
      title: title ?? this.title,
      details: details ?? this.details,
      category: category ?? this.category,
      author: author ?? this.author,
      authorId: authorId ?? this.authorId,
      postedAt: postedAt ?? this.postedAt,
    );
  }
}
