
enum FacultyRole { teacher, hod, principal }

class Faculty {
  final String facultyId;
  final String name;
  final String designation;
  final String username;
  final String password;
  final String? profilePhoto;
  final String phone;
  final String email;
  final String availabilityStatus; // 'Present', 'On Leave'
  final FacultyRole role;

  Faculty({
    required this.facultyId,
    required this.name,
    required this.designation,
    required this.username,
    required this.password,
    this.profilePhoto,
    required this.phone,
    required this.email,
    required this.availabilityStatus,
    required this.role,
  });

  Map<String, dynamic> toMap() {
    return {
      'facultyId': facultyId,
      'name': name,
      'designation': designation,
      'username': username,
      'profilePhoto': profilePhoto,
      'phone': phone,
      'email': email,
      'availabilityStatus': availabilityStatus,
      'role': role.toString().split('.').last,
    };
  }

  factory Faculty.fromMap(Map<String, dynamic> map) {
    return Faculty(
      facultyId: map['facultyId'] ?? '',
      name: map['name'] ?? '',
      designation: map['designation'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      profilePhoto: map['profilePhoto'],
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      availabilityStatus: map['availabilityStatus'] ?? 'Present',
      role: FacultyRole.values.firstWhere(
        (e) => e.toString().split('.').last == (map['role'] ?? 'teacher'),
        orElse: () => FacultyRole.teacher,
      ),
    );
  }
}
