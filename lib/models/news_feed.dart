import 'package:flutter/foundation.dart';

class NewsPost {
  const NewsPost({
    required this.title,
    required this.details,
    required this.category,
    required this.author,
    required this.postedAt,
  });

  final String title;
  final String details;
  final String category;
  final String author;
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
}

final ValueNotifier<List<NewsPost>>
newsFeedNotifier = ValueNotifier<List<NewsPost>>([
  NewsPost(
    title: 'Tech Fest starts this Friday',
    details:
        'Campus activities committee announced workshops and hackathon tracks.',
    category: 'Event',
    author: 'Activities Cell',
    postedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
  NewsPost(
    title: 'New bus route added for hostellers',
    details:
        'Morning and evening shuttle timings updated in transport office portal.',
    category: 'Transport',
    author: 'Transport Office',
    postedAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  NewsPost(
    title: 'Green campus clean-up campaign',
    details:
        'Volunteer slots are available for Saturday between 8 AM and 12 PM.',
    category: 'Activity',
    author: 'Eco Club',
    postedAt: DateTime.now().subtract(const Duration(days: 2)),
  ),
]);
