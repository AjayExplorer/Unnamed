
class RequestLetter {
  final String requestId;
  final String studentId;
  final String studentName;
  final String recipientFacultyId;
  final String currentHandlerId;
  final String currentHandlerName;
  final String requestContent;
  final DateTime submissionDate;
  final String status; // 'Pending', 'Approved', 'Rejected', 'Forwarded to ...'
  final String? approvedBy;
  final DateTime? approvedDateTime;
  final String? rejectedBy;
  final DateTime? rejectedDateTime;

  RequestLetter({
    required this.requestId,
    required this.studentId,
    required this.studentName,
    required this.recipientFacultyId,
    required this.currentHandlerId,
    required this.currentHandlerName,
    required this.requestContent,
    required this.submissionDate,
    required this.status,
    this.approvedBy,
    this.approvedDateTime,
    this.rejectedBy,
    this.rejectedDateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'requestId': requestId,
      'studentId': studentId,
      'studentName': studentName,
      'recipientFacultyId': recipientFacultyId,
      'currentHandlerId': currentHandlerId,
      'currentHandlerName': currentHandlerName,
      'requestContent': requestContent,
      'submissionDate': submissionDate.toIso8601String(),
      'status': status,
      'approvedBy': approvedBy,
      'approvedDateTime': approvedDateTime?.toIso8601String(),
      'rejectedBy': rejectedBy,
      'rejectedDateTime': rejectedDateTime?.toIso8601String(),
    };
  }

  factory RequestLetter.fromMap(Map<String, dynamic> map) {
    return RequestLetter(
      requestId: map['requestId'] ?? '',
      studentId: map['studentId'] ?? '',
      studentName: map['studentName'] ?? '',
      recipientFacultyId: map['recipientFacultyId'] ?? '',
      currentHandlerId: map['currentHandlerId'] ?? '',
      currentHandlerName: map['currentHandlerName'] ?? '',
      requestContent: map['requestContent'] ?? '',
      submissionDate: DateTime.parse(map['submissionDate']),
      status: map['status'] ?? 'Pending',
      approvedBy: map['approvedBy'],
      approvedDateTime: map['approvedDateTime'] != null ? DateTime.parse(map['approvedDateTime']) : null,
      rejectedBy: map['rejectedBy'],
      rejectedDateTime: map['rejectedDateTime'] != null ? DateTime.parse(map['rejectedDateTime']) : null,
    );
  }
}
