import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';

import '../../request_letter/faculty/models/faculty_model.dart';

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

  Future<int> getFacultyCount() async {
    final snapshot = await _firestore.collection('faculty').get();
    return snapshot.size;
  }



  /// Add new faculty
  Future<void> addFaculty(Faculty faculty) async {
    try {
      await _firestore.collection('faculty').doc(faculty.facultyId).set(faculty.toMap());
    } catch (e) {
      throw Exception('Error adding faculty: $e');
    }
  }

  /// Update faculty
  Future<void> updateFaculty(Faculty faculty) async {
    try {
      await _firestore.collection('faculty').doc(faculty.facultyId).update(faculty.toMap());
    } catch (e) {
      throw Exception('Error updating faculty: $e');
    }
  }

  /// Delete faculty
  Future<void> deleteFaculty(String facultyId) async {
    try {
      await _firestore.collection('faculty').doc(facultyId).delete();
    } catch (e) {
      throw Exception('Error deleting faculty: $e');
    }
  }

  /// Get all faculty
  Future<List<Faculty>> getAllFaculty() async {
    try {
      final snapshot = await _firestore.collection('faculty').get();
      return snapshot.docs.map((doc) => Faculty.fromMap({...doc.data(), 'facultyId': doc.id})).toList();
    } catch (e) {
      throw Exception('Error fetching faculty: $e');
    }
  }

  /// Get all alerts
  Future<List<Map<String, dynamic>>> getAllAlerts() async {
    try {
      final snapshot = await _firestore
          .collection('news')
          .orderBy('postedAt', descending: true)
          .get();
      
      final now = DateTime.now();
      final validAlerts = <Map<String, dynamic>>[];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final createdAtValue = data['postedAt'];
        DateTime parsedCreatedAt;

        if (createdAtValue is Timestamp) {
          parsedCreatedAt = createdAtValue.toDate();
        } else if (createdAtValue is String) {
          parsedCreatedAt = DateTime.tryParse(createdAtValue)?.toLocal() ?? DateTime.now();
        } else {
          parsedCreatedAt = DateTime.now();
        }
        
        if (now.difference(parsedCreatedAt).inHours >= 72) {
          _firestore.collection('news').doc(doc.id).delete();
        } else {
          data['id'] = doc.id;
          validAlerts.add(data);
        }
      }

      return validAlerts;
    } catch (e) {
      throw Exception('Error fetching alerts: $e');
    }
  }

  /// Delete alert
  Future<void> deleteAlert(String alertId) async {
    try {
      await _firestore.collection('news').doc(alertId).delete();
    } catch (e) {
      throw Exception('Error deleting alert: $e');
    }
  }
}

