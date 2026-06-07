import 'package:cloud_firestore/cloud_firestore.dart';

class GreenCampusRequest {
  final String? id;
  final String studentId;
  final String studentName;
  final String studentAdmission;
  final String photoUrl;
  final DateTime submittedAt;

  GreenCampusRequest({
    this.id,
    required this.studentId,
    required this.studentName,
    required this.studentAdmission,
    required this.photoUrl,
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'studentAdmission': studentAdmission,
      'photoUrl': photoUrl,
      'submittedAt': Timestamp.fromDate(submittedAt),
    };
  }

  factory GreenCampusRequest.fromMap(Map<String, dynamic> map, String docId) {
    return GreenCampusRequest(
      id: docId,
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      studentAdmission: map['studentAdmission'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      submittedAt: (map['submittedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory GreenCampusRequest.fromSnapshot(DocumentSnapshot snapshot) {
    return GreenCampusRequest.fromMap(
      snapshot.data() as Map<String, dynamic>,
      snapshot.id,
    );
  }
}
