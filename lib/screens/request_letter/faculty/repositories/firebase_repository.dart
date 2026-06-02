
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/faculty_model.dart';
import '../models/request_model.dart';
import '../models/history_model.dart';
import 'base_repository.dart';

class FirebaseRepository implements IFacultyRepository, IRequestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Faculty Methods
  @override
  Future<Faculty?> login(String username, String password) async {
    final snapshot = await _firestore
        .collection('faculty')
        .where('username', isEqualTo: username)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return Faculty.fromMap(snapshot.docs.first.data());
    }
    return null;
  }

  @override
  Future<List<Faculty>> getAllFaculty() async {
    final snapshot = await _firestore.collection('faculty').get();
    return snapshot.docs.map((doc) => Faculty.fromMap(doc.data())).toList();
  }

  @override
  Future<void> updateFacultyAvailability(String facultyId, String status, String updatedByUid, String updatedByUsername) async {
    final batch = _firestore.batch();
    
    final facultyRef = _firestore.collection('faculty').doc(facultyId);
    batch.update(facultyRef, {'availabilityStatus': status});

    final historyRef = _firestore.collection('availability_history').doc();
    final history = AvailabilityHistory(
      historyId: historyRef.id,
      facultyId: facultyId,
      oldStatus: 'Unknown', // Ideally fetch current status first
      newStatus: status,
      updatedByFacultyId: updatedByUid,
      updatedByFacultyName: updatedByUsername,
      updatedDateTime: DateTime.now(),
    );
    batch.set(historyRef, history.toMap());

    // Also update faculty_availability collection if separate as per requirement
    final availabilityRef = _firestore.collection('faculty_availability').doc(facultyId);
    batch.set(availabilityRef, {
      'facultyId': facultyId,
      'currentStatus': status,
      'updatedByFacultyId': updatedByUid,
      'updatedByFacultyName': updatedByUsername,
      'updatedDateTime': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  @override
  Future<List<AvailabilityHistory>> getAvailabilityHistory(String facultyId) async {
    final snapshot = await _firestore
        .collection('availability_history')
        .where('facultyId', isEqualTo: facultyId)
        .orderBy('updatedDateTime', descending: true)
        .get();
    return snapshot.docs.map((doc) => AvailabilityHistory.fromMap(doc.data())).toList();
  }

  @override
  Future<void> updateProfile(String facultyId, Map<String, dynamic> data) async {
    await _firestore.collection('faculty').doc(facultyId).update(data);
  }

  // Request Methods
  @override
  Future<List<RequestLetter>> getRequestsForFaculty(String facultyId) async {
    final snapshot = await _firestore
        .collection('requests')
        .where('currentHandlerId', isEqualTo: facultyId)
        .get();
    return snapshot.docs.map((doc) => RequestLetter.fromMap(doc.data())).toList();
  }

  @override
  Future<void> approveRequest(String requestId, String facultyId, String facultyName) async {
    final batch = _firestore.batch();
    final requestRef = _firestore.collection('requests').doc(requestId);
    
    batch.update(requestRef, {
      'status': 'Approved',
      'approvedBy': facultyName,
      'approvedDateTime': DateTime.now().toIso8601String(),
    });

    final historyRef = _firestore.collection('request_history').doc();
    final history = RequestHistory(
      historyId: historyRef.id,
      requestId: requestId,
      action: 'Approved',
      fromFacultyId: facultyId,
      fromFacultyName: facultyName,
      actionDateTime: DateTime.now(),
    );
    batch.set(historyRef, history.toMap());

    await batch.commit();
  }

  @override
  Future<void> rejectRequest(String requestId, String facultyId, String facultyName) async {
    final batch = _firestore.batch();
    final requestRef = _firestore.collection('requests').doc(requestId);
    
    batch.update(requestRef, {
      'status': 'Rejected',
      'rejectedBy': facultyName,
      'rejectedDateTime': DateTime.now().toIso8601String(),
    });

    final historyRef = _firestore.collection('request_history').doc();
    final history = RequestHistory(
      historyId: historyRef.id,
      requestId: requestId,
      action: 'Rejected',
      fromFacultyId: facultyId,
      fromFacultyName: facultyName,
      actionDateTime: DateTime.now(),
    );
    batch.set(historyRef, history.toMap());

    await batch.commit();
  }

  @override
  Future<void> forwardRequest(String requestId, String fromId, String fromName, String toId, String toName, String nextStatus) async {
    final batch = _firestore.batch();
    final requestRef = _firestore.collection('requests').doc(requestId);
    
    batch.update(requestRef, {
      'currentHandlerId': toId,
      'currentHandlerName': toName,
      'status': nextStatus,
    });

    final historyRef = _firestore.collection('request_history').doc();
    final history = RequestHistory(
      historyId: historyRef.id,
      requestId: requestId,
      action: 'Forwarded',
      fromFacultyId: fromId,
      fromFacultyName: fromName,
      toFacultyId: toId,
      toFacultyName: toName,
      actionDateTime: DateTime.now(),
    );
    batch.set(historyRef, history.toMap());

    await batch.commit();
  }

  @override
  Future<List<RequestHistory>> getRequestTimeline(String requestId) async {
    final snapshot = await _firestore
        .collection('request_history')
        .where('requestId', isEqualTo: requestId)
        .orderBy('actionDateTime', descending: false)
        .get();
    return snapshot.docs.map((doc) => RequestHistory.fromMap(doc.data())).toList();
  }
}
