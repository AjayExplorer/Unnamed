import 'package:cloud_firestore/cloud_firestore.dart';

enum VehicleType { car, bike }

enum RideStatus { active, cancelled, expired }

class RideOffer {
  final String? id;
  final String creatorId;
  final String creatorName;
  final String creatorPhotoUrl;
  final String creatorPhone;
  final String source;
  final String destination;
  final DateTime rideDateTime; // Combined date + time
  final VehicleType vehicleType;
  final int totalSeats;
  final int availableSeats;
  final String additionalDetails;
  final RideStatus status;
  final DateTime createdAt;
  final List<String> participantIds; // approved student IDs

  const RideOffer({
    this.id,
    required this.creatorId,
    required this.creatorName,
    this.creatorPhotoUrl = '',
    this.creatorPhone = '',
    required this.source,
    required this.destination,
    required this.rideDateTime,
    required this.vehicleType,
    required this.totalSeats,
    required this.availableSeats,
    this.additionalDetails = '',
    this.status = RideStatus.active,
    required this.createdAt,
    this.participantIds = const [],
  });

  /// Whether the ride is still bookable (active + seats remaining + time not passed)
  bool get isExpired {
    return availableSeats <= 0 || rideDateTime.isBefore(DateTime.now());
  }

  bool get isActive => status == RideStatus.active && !isExpired;

  // ------------------------------------------------------------------
  // Firestore serialization
  // ------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'creatorName': creatorName,
      'creatorPhotoUrl': creatorPhotoUrl,
      'creatorPhone': creatorPhone,
      'source': source,
      'destination': destination,
      'rideDateTime': Timestamp.fromDate(rideDateTime),
      'vehicleType': vehicleType.name, // 'car' | 'bike'
      'totalSeats': totalSeats,
      'availableSeats': availableSeats,
      'additionalDetails': additionalDetails,
      'status': status.name, // 'active' | 'cancelled' | 'expired'
      'createdAt': Timestamp.fromDate(createdAt),
      'participantIds': participantIds,
    };
  }

  factory RideOffer.fromMap(Map<String, dynamic> map, String docId) {
    return RideOffer(
      id: docId,
      creatorId: map['creatorId'] as String? ?? '',
      creatorName: map['creatorName'] as String? ?? '',
      creatorPhotoUrl: map['creatorPhotoUrl'] as String? ?? '',
      creatorPhone: map['creatorPhone'] as String? ?? '',
      source: map['source'] as String? ?? '',
      destination: map['destination'] as String? ?? '',
      rideDateTime: (map['rideDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      vehicleType: _vehicleTypeFromString(map['vehicleType'] as String?),
      totalSeats: (map['totalSeats'] as num?)?.toInt() ?? 1,
      availableSeats: (map['availableSeats'] as num?)?.toInt() ?? 1,
      additionalDetails: map['additionalDetails'] as String? ?? '',
      status: _rideStatusFromString(map['status'] as String?),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      participantIds: List<String>.from(map['participantIds'] as List? ?? []),
    );
  }

  factory RideOffer.fromSnapshot(DocumentSnapshot doc) =>
      RideOffer.fromMap(doc.data() as Map<String, dynamic>, doc.id);

  RideOffer copyWith({
    String? id,
    String? creatorId,
    String? creatorName,
    String? creatorPhotoUrl,
    String? creatorPhone,
    String? source,
    String? destination,
    DateTime? rideDateTime,
    VehicleType? vehicleType,
    int? totalSeats,
    int? availableSeats,
    String? additionalDetails,
    RideStatus? status,
    DateTime? createdAt,
    List<String>? participantIds,
  }) {
    return RideOffer(
      id: id ?? this.id,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      creatorPhotoUrl: creatorPhotoUrl ?? this.creatorPhotoUrl,
      creatorPhone: creatorPhone ?? this.creatorPhone,
      source: source ?? this.source,
      destination: destination ?? this.destination,
      rideDateTime: rideDateTime ?? this.rideDateTime,
      vehicleType: vehicleType ?? this.vehicleType,
      totalSeats: totalSeats ?? this.totalSeats,
      availableSeats: availableSeats ?? this.availableSeats,
      additionalDetails: additionalDetails ?? this.additionalDetails,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      participantIds: participantIds ?? this.participantIds,
    );
  }

  // ------------------------------------------------------------------
  // Helpers
  // ------------------------------------------------------------------

  static VehicleType _vehicleTypeFromString(String? s) {
    switch (s) {
      case 'bike':
        return VehicleType.bike;
      default:
        return VehicleType.car;
    }
  }

  static RideStatus _rideStatusFromString(String? s) {
    switch (s) {
      case 'cancelled':
        return RideStatus.cancelled;
      case 'expired':
        return RideStatus.expired;
      default:
        return RideStatus.active;
    }
  }
}
