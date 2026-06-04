class Admin {
  final String adminId;
  final String name;
  final String username;
  final String password;
  final String email;

  Admin({
    required this.adminId,
    required this.name,
    required this.username,
    required this.password,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'adminId': adminId,
      'name': name,
      'username': username,
      'password': password,
      'email': email,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      adminId: map['adminId'] ?? '',
      name: map['name'] ?? '',
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
