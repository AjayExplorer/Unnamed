import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/student.dart';
import '../models/green_campus_request.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _studentsCollection = 'students';

  DatabaseService._internal();

  factory DatabaseService() {
    return _instance;
  }

  /// Add a new student to the database
  Future<String> addStudent(Student student) async {
    try {
      final docRef = await _firestore
          .collection(_studentsCollection)
          .add(student.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error adding student: $e');
    }
  }

  /// Update an existing student
  Future<void> updateStudent(Student student) async {
    try {
      await _firestore
          .collection(_studentsCollection)
          .doc(student.id)
          .update(student.toMap());
    } catch (e) {
      throw Exception('Error updating student: $e');
    }
  }

  /// Get a student by ID
  Future<Student?> getStudentById(String studentId) async {
    try {
      final doc =
          await _firestore.collection(_studentsCollection).doc(studentId).get();
      if (doc.exists) {
        return Student.fromSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching student: $e');
    }
  }

  /// Get all students
  Future<List<Student>> getAllStudents() async {
    try {
      final snapshot =
          await _firestore.collection(_studentsCollection).get();
      return snapshot.docs.map((doc) => Student.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching students: $e');
    }
  }

  /// Check if admission number already exists
  Future<bool> admissionNumberExists(String admissionNumber) async {
    try {
      final query = await _firestore
          .collection(_studentsCollection)
          .where('admissionNumber', isEqualTo: admissionNumber.toUpperCase())
          .limit(1)
          .get();
      return query.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Error checking admission number: $e');
    }
  }

  /// Get student by admission number
  Future<Student?> getStudentByAdmissionNumber(String admissionNumber) async {
    try {
      final query = await _firestore
          .collection(_studentsCollection)
          .where('admissionNumber', isEqualTo: admissionNumber.toUpperCase())
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return Student.fromSnapshot(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching student by admission number: $e');
    }
  }

  /// Get student by phone number
  Future<Student?> getStudentByPhoneNumber(String phoneNumber) async {
    try {
      final query = await _firestore
          .collection(_studentsCollection)
          .where('phoneNumber', isEqualTo: phoneNumber)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return Student.fromSnapshot(query.docs.first);
      }
      return null;
    } catch (e) {
      throw Exception('Error fetching student by phone number: $e');
    }
  }

  /// Delete a student
  Future<void> deleteStudent(String studentId) async {
    try {
      await _firestore
          .collection(_studentsCollection)
          .doc(studentId)
          .delete();
    } catch (e) {
      throw Exception('Error deleting student: $e');
    }
  }

  /// Search students by name
  Future<List<Student>> searchStudentsByName(String searchTerm) async {
    try {
      final snapshot = await _firestore
          .collection(_studentsCollection)
          .where('fullName', isGreaterThanOrEqualTo: searchTerm)
          .where('fullName', isLessThan: '${searchTerm}z')
          .get();
      return snapshot.docs.map((doc) => Student.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Error searching students: $e');
    }
  }

  /// Get recently registered students
  Future<List<Student>> getRecentStudents({int limit = 10}) async {
    try {
      final snapshot = await _firestore
          .collection(_studentsCollection)
          .orderBy('registrationDate', descending: true)
          .limit(limit)
          .get();
      return snapshot.docs.map((doc) => Student.fromSnapshot(doc)).toList();
    } catch (e) {
      throw Exception('Error fetching recent students: $e');
    }
  }

  /// Submit a new photo verification request
  Future<void> submitGreenCampusRequest(GreenCampusRequest request) async {
    try {
      await _firestore
          .collection('green_campus_requests')
          .add(request.toMap());
    } catch (e) {
      throw Exception('Error submitting photo verification request: $e');
    }
  }

  /// Approve a green campus request: add 5 green points to student and delete the request
  Future<void> approveGreenCampusRequest(String studentId, String requestId) async {
    try {
      final studentDoc = _firestore.collection(_studentsCollection).doc(studentId);
      final requestDoc = _firestore.collection('green_campus_requests').doc(requestId);

      await _firestore.runTransaction((transaction) async {
        final studentSnapshot = await transaction.get(studentDoc);
        if (studentSnapshot.exists) {
          final currentPoints = studentSnapshot.data()?['greenPoints'] ?? 0;
          transaction.update(studentDoc, {'greenPoints': currentPoints + 5});
        }
        transaction.delete(requestDoc);
      });
    } catch (e) {
      throw Exception('Error approving green campus request: $e');
    }
  }

  /// Reject/Delete a green campus request
  Future<void> rejectGreenCampusRequest(String requestId) async {
    try {
      await _firestore.collection('green_campus_requests').doc(requestId).delete();
    } catch (e) {
      throw Exception('Error rejecting green campus request: $e');
    }
  }
}
