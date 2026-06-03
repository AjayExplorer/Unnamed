
import '../models/faculty_model.dart';
import '../models/request_model.dart';
import '../models/history_model.dart';
import 'base_repository.dart';

class MockRepository implements IFacultyRepository, IRequestRepository {
  // Mock Data
  static final List<Faculty> _faculty = [
    Faculty(
      facultyId: 'F001',
      name: 'Dr. John Smith',
      designation: 'HOD CSE',
      department: 'Computer Science',
      username: 'hod1',
      password: 'hod123',
      phone: '9876543210',
      email: 'hod@college.edu',
      availabilityStatus: 'Present',
      role: FacultyRole.hod,
    ),
    Faculty(
      facultyId: 'F002',
      name: 'Prof. Sarah Wilson',
      designation: 'Assistant Professor',
      department: 'Computer Science',
      username: 'teacher1',
      password: 'teacher123',
      phone: '9876543211',
      email: 'teacher@college.edu',
      availabilityStatus: 'Present',
      role: FacultyRole.teacher,
    ),
    Faculty(
      facultyId: 'F003',
      name: 'Dr. Robert Brown',
      designation: 'Principal',
      department: 'Administration',
      username: 'principal1',
      password: 'principal123',
      phone: '9876543212',
      email: 'principal@college.edu',
      availabilityStatus: 'Present',
      role: FacultyRole.principal,
    ),
  ];

  static final List<RequestLetter> _requests = [
    RequestLetter(
      requestId: 'REQ101',
      studentId: 'S501',
      studentName: 'Alex Johnson',
      recipientFacultyId: 'F002',
      currentHandlerId: 'F002',
      currentHandlerName: 'Prof. Sarah Wilson',
      subject: 'Leave Request',
      requestContent: 'I am requesting a leave for 3 days due to my brother\'s wedding.',
      submissionDate: DateTime.now().subtract(const Duration(days: 1)),
      status: 'Pending',
    ),
    RequestLetter(
      requestId: 'REQ102',
      studentId: 'S505',
      studentName: 'Jessica White',
      recipientFacultyId: 'F001',
      currentHandlerId: 'F001',
      currentHandlerName: 'Dr. John Smith',
      subject: 'Event Permission',
      requestContent: 'Permission requested for organizing the annual cultural fest.',
      submissionDate: DateTime.now().subtract(const Duration(hours: 5)),
      status: 'Pending',
    ),
  ];

  static final List<RequestHistory> _requestHistory = [];
  static final List<AvailabilityHistory> _availabilityHistory = [];

  // Faculty Methods
  @override
  Future<Faculty?> login(String username, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    try {
      return _faculty.firstWhere(
        (f) => f.username == username && f.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Faculty>> getAllFaculty() async {
    return _faculty;
  }

  @override
  Future<void> updateFacultyAvailability(String facultyId, String status, String updatedByUid, String updatedByUsername) async {
    final index = _faculty.indexWhere((f) => f.facultyId == facultyId);
    if (index != -1) {
      final oldStatus = _faculty[index].availabilityStatus;
      _faculty[index] = Faculty(
        facultyId: _faculty[index].facultyId,
        name: _faculty[index].name,
        designation: _faculty[index].designation,
        department: _faculty[index].department,
        username: _faculty[index].username,
        password: _faculty[index].password,
        phone: _faculty[index].phone,
        email: _faculty[index].email,
        availabilityStatus: status,
        role: _faculty[index].role,
        profilePhoto: _faculty[index].profilePhoto,
      );

      _availabilityHistory.add(AvailabilityHistory(
        historyId: 'AH${_availabilityHistory.length + 1}',
        facultyId: facultyId,
        oldStatus: oldStatus,
        newStatus: status,
        updatedByFacultyId: updatedByUid,
        updatedByFacultyName: updatedByUsername,
        updatedDateTime: DateTime.now(),
      ));
    }
  }

  @override
  Future<List<AvailabilityHistory>> getAvailabilityHistory(String facultyId) async {
    return _availabilityHistory.where((h) => h.facultyId == facultyId).toList();
  }

  @override
  Future<void> updateProfile(String facultyId, Map<String, dynamic> data) async {
    final index = _faculty.indexWhere((f) => f.facultyId == facultyId);
    if (index != -1) {
      final f = _faculty[index];
      _faculty[index] = Faculty(
        facultyId: f.facultyId,
        name: f.name,
        designation: f.designation,
        department: data['department'] ?? f.department,
        username: f.username,
        password: data['password'] ?? f.password,
        phone: data['phone'] ?? f.phone,
        email: data['email'] ?? f.email,
        availabilityStatus: f.availabilityStatus,
        role: f.role,
        profilePhoto: data['profilePhoto'] ?? f.profilePhoto,
      );
    }
  }

  // Request Methods
  @override
  Future<List<RequestLetter>> getRequestsForFaculty(String facultyId) async {
    return _requests.where((r) => r.currentHandlerId == facultyId).toList();
  }

  @override
  Future<void> approveRequest(String requestId, String facultyId, String facultyName) async {
    final index = _requests.indexWhere((r) => r.requestId == requestId);
    if (index != -1) {
      final r = _requests[index];
      _requests[index] = RequestLetter(
        requestId: r.requestId,
        studentId: r.studentId,
        studentName: r.studentName,
        recipientFacultyId: r.recipientFacultyId,
        currentHandlerId: r.currentHandlerId,
        currentHandlerName: r.currentHandlerName,
        subject: r.subject,
        requestContent: r.requestContent,
        submissionDate: r.submissionDate,
        status: 'Approved',
        approvedBy: facultyName,
        approvedDateTime: DateTime.now(),
      );

      _requestHistory.add(RequestHistory(
        historyId: 'RH${_requestHistory.length + 1}',
        requestId: requestId,
        action: 'Approved',
        fromFacultyId: facultyId,
        fromFacultyName: facultyName,
        actionDateTime: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> rejectRequest(String requestId, String facultyId, String facultyName, String reason) async {
    final index = _requests.indexWhere((r) => r.requestId == requestId);
    if (index != -1) {
      final r = _requests[index];
      _requests[index] = RequestLetter(
        requestId: r.requestId,
        studentId: r.studentId,
        studentName: r.studentName,
        recipientFacultyId: r.recipientFacultyId,
        currentHandlerId: r.currentHandlerId,
        currentHandlerName: r.currentHandlerName,
        subject: r.subject,
        requestContent: r.requestContent,
        submissionDate: r.submissionDate,
        status: 'Rejected',
        rejectedBy: facultyName,
        rejectionReason: reason,
        rejectedDateTime: DateTime.now(),
      );

      _requestHistory.add(RequestHistory(
        historyId: 'RH${_requestHistory.length + 1}',
        requestId: requestId,
        action: 'Rejected',
        fromFacultyId: facultyId,
        fromFacultyName: facultyName,
        actionDateTime: DateTime.now(),
      ));
    }
  }

  @override
  Future<void> forwardRequest(String requestId, String fromId, String fromName, String toId, String toName, String nextStatus) async {
    final index = _requests.indexWhere((r) => r.requestId == requestId);
    if (index != -1) {
      final r = _requests[index];
      _requests[index] = RequestLetter(
        requestId: r.requestId,
        studentId: r.studentId,
        studentName: r.studentName,
        recipientFacultyId: r.recipientFacultyId,
        currentHandlerId: toId,
        currentHandlerName: toName,
        subject: r.subject,
        requestContent: r.requestContent,
        submissionDate: r.submissionDate,
        status: nextStatus,
      );

      _requestHistory.add(RequestHistory(
        historyId: 'RH${_requestHistory.length + 1}',
        requestId: requestId,
        action: 'Forwarded',
        fromFacultyId: fromId,
        fromFacultyName: fromName,
        toFacultyId: toId,
        toFacultyName: toName,
        actionDateTime: DateTime.now(),
      ));
    }
  }

  @override
  Future<List<RequestHistory>> getRequestTimeline(String requestId) async {
    return _requestHistory.where((h) => h.requestId == requestId).toList();
  }
}
