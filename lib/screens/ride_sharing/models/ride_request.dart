import 'package:cloud_firestore/cloud_firestore.dart';

enum RideRequestStatus { pending, approved, rejected, rideCancelled }

class RideRequest {
  final String? id;
  final String rideId;
  final String requesterId;
  final String requesterName;
  final String requesterPhotoUrl;
  final String requesterPhone;
  final RideRequestStatus status;
  final DateTime createdAt;
  final DateTime? approvedAt; // Set when status becomes 'approved'

  const RideRequest({
    this.id,
    required this.rideId,
    required this.requesterId,
    required this.requesterName,
    this.requesterPhotoUrl = '',
    this.requesterPhone = '',
    this.status = RideRequestStatus.pending,
    required this.createdAt,
    this.approvedAt,
  });

  /// True if 3 days have passed since approval
  bool get isExpiredApproval {
    if (status != RideRequestStatus.approved || approvedAt == null) return false;
    return DateTime.now().difference(approvedAt!).inDays >= 3;
  }

  /// Days remaining until auto-hide (from approved date)
  int get daysUntilExpiry {
    if (approvedAt == null) return 3;
    final remaining = 3 - DateTime.now().difference(approvedAt!).inDays;
    return remaining < 0 ? 0 : remaining;
  }

  String get statusLabel {
    switch (status) {
      case RideRequestStatus.pending:
        return 'Pending';
      case RideRequestStatus.approved:
        return 'Approved';
      case RideRequestStatus.rejected:
        return 'Rejected';
      case RideRequestStatus.rideCancelled:
        return 'Ride Cancelled';
    }
  }

  // ------------------------------------------------------------------
  // Firestore serialization
  // ------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterPhotoUrl': requesterPhotoUrl,
      'requesterPhone': requesterPhone,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      if (approvedAt != null) 'approvedAt': Timestamp.fromDate(approvedAt!),
    };
  }

  factory RideRequest.fromMap(Map<String, dynamic> map, String docId) {
    return RideRequest(
      id: docId,
      rideId: map['rideId'] as String? ?? '',
      requesterId: map['requesterId'] as String? ?? '',
      requesterName: map['requesterName'] as String? ?? '',
      requesterPhotoUrl: map['requesterPhotoUrl'] as String? ?? '',
      requesterPhone: map['requesterPhone'] as String? ?? '',
      status: _statusFromString(map['status'] as String?),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      approvedAt: (map['approvedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory RideRequest.fromSnapshot(DocumentSnapshot doc) =>
      RideRequest.fromMap(doc.data() as Map<String, dynamic>, doc.id);

  RideRequest copyWith({
    String? id,
    String? rideId,
    String? requesterId,
    String? requesterName,
    String? requesterPhotoUrl,
    String? requesterPhone,
    RideRequestStatus? status,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return RideRequest(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterPhotoUrl: requesterPhotoUrl ?? this.requesterPhotoUrl,
      requesterPhone: requesterPhone ?? this.requesterPhone,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  static RideRequestStatus _statusFromString(String? s) {
    switch (s) {
      case 'approved':
        return RideRequestStatus.approved;
      case 'rejected':
        return RideRequestStatus.rejected;
      case 'rideCancelled':
        return RideRequestStatus.rideCancelled;
      default:
        return RideRequestStatus.pending;
    }
  }
}
