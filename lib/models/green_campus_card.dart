import 'package:cloud_firestore/cloud_firestore.dart';

class GreenCampusCard {
  final String id; // Student ID
  final String studentName;
  final String studentAdmission;
  final String studentPhone;
  final String studentDepartment;
  final String cardNumber;
  final int level;
  final String color;
  final DateTime acquiredAt;

  GreenCampusCard({
    required this.id,
    required this.studentName,
    required this.studentAdmission,
    required this.studentPhone,
    required this.studentDepartment,
    required this.cardNumber,
    required this.level,
    required this.color,
    required this.acquiredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentName': studentName,
      'studentAdmission': studentAdmission,
      'studentPhone': studentPhone,
      'studentDepartment': studentDepartment,
      'cardNumber': cardNumber,
      'level': level,
      'color': color,
      'acquiredAt': Timestamp.fromDate(acquiredAt),
    };
  }

  factory GreenCampusCard.fromMap(Map<String, dynamic> map) {
    return GreenCampusCard(
      id: map['id'] ?? '',
      studentName: map['studentName'] ?? '',
      studentAdmission: map['studentAdmission'] ?? '',
      studentPhone: map['studentPhone'] ?? '',
      studentDepartment: map['studentDepartment'] ?? '',
      cardNumber: map['cardNumber'] ?? '',
      level: map['level'] ?? 0,
      color: map['color'] ?? '',
      acquiredAt: (map['acquiredAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
