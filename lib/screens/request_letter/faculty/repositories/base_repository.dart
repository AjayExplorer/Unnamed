
import '../models/faculty_model.dart';
import '../models/request_model.dart';
import '../models/history_model.dart';

abstract class IFacultyRepository {
  Future<Faculty?> login(String username, String password);
  Future<List<Faculty>> getAllFaculty();
  Future<void> updateFacultyAvailability(String facultyId, String status, String updatedByUid, String updatedByUsername);
  Future<List<AvailabilityHistory>> getAvailabilityHistory(String facultyId);
  Future<void> updateProfile(String facultyId, Map<String, dynamic> data);
}

abstract class IRequestRepository {
  Future<List<RequestLetter>> getRequestsForFaculty(String facultyId);
  Future<void> approveRequest(String requestId, String facultyId, String facultyName);
  Future<void> rejectRequest(String requestId, String facultyId, String facultyName, String reason);
  Future<void> forwardRequest(String requestId, String fromId, String fromName, String toId, String toName, String nextStatus);
  Future<List<RequestHistory>> getRequestTimeline(String requestId);
}
