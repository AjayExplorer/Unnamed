import 'package:cloud_firestore/cloud_firestore.dart';

class Student {
  final String? id;
  final String fullName;
  final String phoneNumber;
  final String admissionNumber;
  final String password;
  final String place;
  final String bloodGroup;
  final String photoUrl;
  final String department;
  final DateTime registrationDate;
  final int greenPoints;

  Student({
    this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.admissionNumber,
    required this.password,
    this.place = '',
    this.bloodGroup = '',
    this.photoUrl = '',
    this.department = '',
    DateTime? registrationDate,
    this.greenPoints = 0,
  }) : registrationDate = registrationDate ?? DateTime.now();

  // Convert Student to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'admissionNumber': admissionNumber.toUpperCase(),
      'password': password,
      'place': place,
      'bloodGroup': bloodGroup,
      'photoUrl': photoUrl,
      'department': department,
      'registrationDate': Timestamp.fromDate(registrationDate),
      'greenPoints': greenPoints,
    };
  }

  // Create Student from Firestore document
  factory Student.fromMap(Map<String, dynamic> map, String docId) {
    return Student(
      id: docId,
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      admissionNumber: map['admissionNumber'] ?? '',
      password: map['password'] ?? '',
      place: map['place'] ?? '',
      bloodGroup: map['bloodGroup'] ?? '',
      photoUrl: map['photoUrl'] ?? '',
      department: map['department'] ?? '',
      registrationDate: (map['registrationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      greenPoints: map['greenPoints'] ?? 0,
    );
  }

  // Create Student from Firestore DocumentSnapshot
  factory Student.fromSnapshot(DocumentSnapshot snapshot) {
    return Student.fromMap(snapshot.data() as Map<String, dynamic>, snapshot.id);
  }

  // Copy with method for updating fields
  Student copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? admissionNumber,
    String? password,
    String? place,
    String? bloodGroup,
    String? photoUrl,
    String? department,
    DateTime? registrationDate,
    int? greenPoints,
  }) {
    return Student(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      admissionNumber: admissionNumber ?? this.admissionNumber,
      password: password ?? this.password,
      place: place ?? this.place,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      photoUrl: photoUrl ?? this.photoUrl,
      department: department ?? this.department,
      registrationDate: registrationDate ?? this.registrationDate,
      greenPoints: greenPoints ?? this.greenPoints,
    );
  }

  @override
  String toString() {
    return 'Student(id: $id, fullName: $fullName, phoneNumber: $phoneNumber, '
        'admissionNumber: $admissionNumber, place: $place, bloodGroup: $bloodGroup, '
        'photoUrl: $photoUrl, department: $department, registrationDate: $registrationDate, greenPoints: $greenPoints)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Student &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          fullName == other.fullName &&
          phoneNumber == other.phoneNumber &&
          admissionNumber == other.admissionNumber &&
          place == other.place &&
          bloodGroup == other.bloodGroup &&
          photoUrl == other.photoUrl &&
          department == other.department &&
          greenPoints == other.greenPoints;

  @override
  int get hashCode =>
      id.hashCode ^
      fullName.hashCode ^
      phoneNumber.hashCode ^
      admissionNumber.hashCode ^
      place.hashCode ^
      bloodGroup.hashCode ^
      photoUrl.hashCode ^
      department.hashCode ^
      greenPoints.hashCode;
}
