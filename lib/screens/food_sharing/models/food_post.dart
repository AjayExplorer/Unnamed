import 'package:cloud_firestore/cloud_firestore.dart';

class FoodPost {
  final String? id;
  final String foodType; // "Veg" or "Non-Veg"
  final String pickupTime; // e.g. "05:30 PM"
  final DateTime pickupTimestamp; // exact expiration/pickup date & time
  final String pickupPlace;
  final String phoneNumber;
  final String sharedBy;
  final DateTime createdAt;

  FoodPost({
    this.id,
    required this.foodType,
    required this.pickupTime,
    required this.pickupTimestamp,
    required this.pickupPlace,
    required this.phoneNumber,
    required this.sharedBy,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'foodType': foodType,
      'pickupTime': pickupTime,
      'pickupTimestamp': Timestamp.fromDate(pickupTimestamp),
      'pickupPlace': pickupPlace,
      'phoneNumber': phoneNumber,
      'sharedBy': sharedBy,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Map (Firestore DocumentSnapshot data)
  factory FoodPost.fromMap(Map<String, dynamic> map, String docId) {
    return FoodPost(
      id: docId,
      foodType: map['foodType'] ?? 'Veg',
      pickupTime: map['pickupTime'] ?? '',
      pickupTimestamp: (map['pickupTimestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      pickupPlace: map['pickupPlace'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      sharedBy: map['sharedBy'] ?? 'Anonymous',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Create from DocumentSnapshot
  factory FoodPost.fromSnapshot(DocumentSnapshot snapshot) {
    return FoodPost.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
    );
  }

  // Copy with method
  FoodPost copyWith({
    String? id,
    String? foodType,
    String? pickupTime,
    DateTime? pickupTimestamp,
    String? pickupPlace,
    String? phoneNumber,
    String? sharedBy,
    DateTime? createdAt,
  }) {
    return FoodPost(
      id: id ?? this.id,
      foodType: foodType ?? this.foodType,
      pickupTime: pickupTime ?? this.pickupTime,
      pickupTimestamp: pickupTimestamp ?? this.pickupTimestamp,
      pickupPlace: pickupPlace ?? this.pickupPlace,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      sharedBy: sharedBy ?? this.sharedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
