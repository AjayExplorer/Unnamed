import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faculty_registration_request.dart';

class FacultyRegistrationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitRequest(FacultyRegistrationRequest request) async {
    final requestRef = _firestore.collection('faculty_registration_requests').doc();

    await requestRef.set({
      ...request.toMap(),
      'requestId': requestRef.id,
      'submittedDate': request.submittedDate.toIso8601String(),
      'status': request.status,
    });
  }
}
