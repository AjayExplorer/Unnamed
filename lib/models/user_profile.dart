import 'package:flutter/foundation.dart';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.place,
    required this.bloodGroup,
    required this.phoneNumber,
    required this.photoUrl,
    required this.department,
  });

  final String name;
  final String place;
  final String bloodGroup;
  final String phoneNumber;
  final String photoUrl;
  final String department;

  static const UserProfile initial = UserProfile(
    name: 'Sarah Joseph',
    place: 'Kochi',
    bloodGroup: 'O+',
    phoneNumber: '9876543210',
    photoUrl: 'https://i.pravatar.cc/300?img=5',
    department: 'Computer Science',
  );

  UserProfile copyWith({
    String? name,
    String? place,
    String? bloodGroup,
    String? phoneNumber,
    String? photoUrl,
    String? department,
  }) {
    return UserProfile(
      name: name ?? this.name,
      place: place ?? this.place,
      bloodGroup: bloodGroup ?? this.bloodGroup,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      department: department ?? this.department,
    );
  }
}

final ValueNotifier<UserProfile> userProfileNotifier =
    ValueNotifier<UserProfile>(UserProfile.initial);
