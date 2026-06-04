import 'faculty_model.dart';

class FacultyRegistrationRequest {
  final String requestId;
  final String name;
  final String designation;
  final String username;
  final String password;
  final String? profilePhoto;
  final String phone;
  final String email;
  final FacultyRole role;
  final String status;
  final DateTime submittedDate;
  final String? handledByAdminId;
  final String? handledByAdminName;
  final DateTime? handledDateTime;
  final String? rejectionReason;

  FacultyRegistrationRequest({
    required this.requestId,
    required this.name,
    required this.designation,
    required this.username,
    required this.password,
    this.profilePhoto,
    required this.phone,
    required this.email,
    required this.role,
    required this.status,
    required this.submittedDate,
    this.handledByAdminId,
    this.handledByAdminName,
    this.handledDateTime,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'name': name,
      'designation': designation,
      'username': username,
      'password': password,
      'profilePhoto': profilePhoto,
      'phone': phone,
      'email': email,
      'role': role.toString().split('.').last,
      'status': status,
      'submittedDate': submittedDate.toIso8601String(),
      'handledByAdminId': handledByAdminId,
      'handledByAdminName': handledByAdminName,
      'handledDateTime': handledDateTime?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  factory FacultyRegistrationRequest.fromMap(Map<String, dynamic> map) {
    return FacultyRegistrationRequest(
      requestId: map['requestId'] ?? '',
      name: map['name'] ?? '',
      designation: map['designation'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      profilePhoto: map['profilePhoto'],
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      role: FacultyRole.values.firstWhere(
        (e) => e.toString().split('.').last == (map['role'] ?? 'teacher'),
        orElse: () => FacultyRole.teacher,
      ),
      status: map['status'] ?? 'Pending',
      submittedDate: DateTime.parse(map['submittedDate'] ?? DateTime.now().toIso8601String()),
      handledByAdminId: map['handledByAdminId'],
      handledByAdminName: map['handledByAdminName'],
      handledDateTime: map['handledDateTime'] != null ? DateTime.parse(map['handledDateTime']) : null,
      rejectionReason: map['rejectionReason'],
    );
  }
}
