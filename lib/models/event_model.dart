import 'package:cloud_firestore/cloud_firestore.dart';


class EventModel {
  final String id;
  final String eventName;
  final String description;
  final String hostedBy;
  final DateTime eventDate;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.eventName,
    required this.description,
    required this.hostedBy,
    required this.eventDate,
    required this.createdAt,
  });

  factory EventModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      eventName: data['eventName'] ?? '',
      description: data['description'] ?? '',
      hostedBy: data['hostedBy'] ?? '',
      eventDate: (data['eventDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'eventName': eventName,
      'description': description,
      'hostedBy': hostedBy,
      'eventDate': Timestamp.fromDate(eventDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Helper to compute days remaining
  int get daysRemaining => eventDate.difference(DateTime.now()).inDays;
}
