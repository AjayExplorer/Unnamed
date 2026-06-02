
class RequestHistory {
  final String historyId;
  final String requestId;
  final String action; // 'Approved', 'Rejected', 'Forwarded'
  final String fromFacultyId;
  final String fromFacultyName;
  final String? toFacultyId;
  final String? toFacultyName;
  final DateTime actionDateTime;

  RequestHistory({
    required this.historyId,
    required this.requestId,
    required this.action,
    required this.fromFacultyId,
    required this.fromFacultyName,
    this.toFacultyId,
    this.toFacultyName,
    required this.actionDateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'historyId': historyId,
      'requestId': requestId,
      'action': action,
      'fromFacultyId': fromFacultyId,
      'fromFacultyName': fromFacultyName,
      'toFacultyId': toFacultyId,
      'toFacultyName': toFacultyName,
      'actionDateTime': actionDateTime.toIso8601String(),
    };
  }

  factory RequestHistory.fromMap(Map<String, dynamic> map) {
    return RequestHistory(
      historyId: map['historyId'] ?? '',
      requestId: map['requestId'] ?? '',
      action: map['action'] ?? '',
      fromFacultyId: map['fromFacultyId'] ?? '',
      fromFacultyName: map['fromFacultyName'] ?? '',
      toFacultyId: map['toFacultyId'],
      toFacultyName: map['toFacultyName'],
      actionDateTime: DateTime.parse(map['actionDateTime']),
    );
  }
}

class AvailabilityHistory {
  final String historyId;
  final String facultyId;
  final String oldStatus;
  final String newStatus;
  final String updatedByFacultyId;
  final String updatedByFacultyName;
  final DateTime updatedDateTime;

  AvailabilityHistory({
    required this.historyId,
    required this.facultyId,
    required this.oldStatus,
    required this.newStatus,
    required this.updatedByFacultyId,
    required this.updatedByFacultyName,
    required this.updatedDateTime,
  });

  Map<String, dynamic> toMap() {
    return {
      'historyId': historyId,
      'facultyId': facultyId,
      'oldStatus': oldStatus,
      'newStatus': newStatus,
      'updatedByFacultyId': updatedByFacultyId,
      'updatedByFacultyName': updatedByFacultyName,
      'updatedDateTime': updatedDateTime.toIso8601String(),
    };
  }

  factory AvailabilityHistory.fromMap(Map<String, dynamic> map) {
    return AvailabilityHistory(
      historyId: map['historyId'] ?? '',
      facultyId: map['facultyId'] ?? '',
      oldStatus: map['oldStatus'] ?? '',
      newStatus: map['newStatus'] ?? '',
      updatedByFacultyId: map['updatedByFacultyId'] ?? '',
      updatedByFacultyName: map['updatedByFacultyName'] ?? '',
      updatedDateTime: DateTime.parse(map['updatedDateTime']),
    );
  }
}
