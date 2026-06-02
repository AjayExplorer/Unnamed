import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';
import '../../request_letter/faculty/models/faculty_registration_request.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Admin?> login(String username, String password) async {
    final snapshot = await _firestore
        .collection('admins')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      data['adminId'] = snapshot.docs.first.id;
      return Admin.fromMap(data);
    }

    return null;
  }

  Future<List<FacultyRegistrationRequest>> getPendingFacultyRegistrations() async {
    final snapshot = await _firestore
        .collection('faculty_registration_requests')
        .where('status', isEqualTo: 'Pending')
        .get();

    return snapshot.docs
        .map((doc) => FacultyRegistrationRequest.fromMap({...doc.data(), 'requestId': doc.id}))
        .toList();
  }

  Future<int> getFacultyCount() async {
    final snapshot = await _firestore.collection('faculty').get();
    return snapshot.size;
  }

  Future<void> approveFacultyRegistration(
    FacultyRegistrationRequest request,
    String adminId,
    String adminName,
  ) async {
    final batch = _firestore.batch();
    final requestRef = _firestore.collection('faculty_registration_requests').doc(request.requestId);
    final facultyRef = _firestore.collection('faculty').doc();

    batch.set(facultyRef, {
      'facultyId': facultyRef.id,
      'name': request.name,
      'designation': request.designation,
      'username': request.username,
      'password': request.password,
      'profilePhoto': request.profilePhoto,
      'phone': request.phone,
      'email': request.email,
      'availabilityStatus': 'Present',
      'role': request.role.toString().split('.').last,
    });

    batch.update(requestRef, {
      'status': 'Approved',
      'handledByAdminId': adminId,
      'handledByAdminName': adminName,
      'handledDateTime': DateTime.now().toIso8601String(),
    });

    await batch.commit();
  }

  Future<void> rejectFacultyRegistration(
    String requestId,
    String adminId,
    String adminName,
    String rejectionReason,
  ) async {
    final requestRef = _firestore.collection('faculty_registration_requests').doc(requestId);

    await requestRef.update({
      'status': 'Rejected',
      'handledByAdminId': adminId,
      'handledByAdminName': adminName,
      'handledDateTime': DateTime.now().toIso8601String(),
      'rejectionReason': rejectionReason,
    });
  }
}
