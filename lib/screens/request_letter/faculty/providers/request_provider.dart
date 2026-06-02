
import 'package:flutter/material.dart';
import '../models/request_model.dart';
import '../models/history_model.dart';
import 'service_config.dart';

class RequestProvider with ChangeNotifier {
  List<RequestLetter> _requests = [];
  bool _isLoading = false;

  List<RequestLetter> get requests => _requests;
  bool get isLoading => _isLoading;

  Future<void> fetchRequests(String facultyId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _requests = await ServiceConfig.requestRepo.getRequestsForFaculty(facultyId);
    } catch (e) {
      debugPrint('Fetch requests error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<RequestHistory>> getTimeline(String requestId) async {
    return await ServiceConfig.requestRepo.getRequestTimeline(requestId);
  }

  Future<void> approve(String requestId, String facultyId, String facultyName) async {
    await ServiceConfig.requestRepo.approveRequest(requestId, facultyId, facultyName);
    await fetchRequests(facultyId);
  }

  Future<void> reject(String requestId, String facultyId, String facultyName) async {
    await ServiceConfig.requestRepo.rejectRequest(requestId, facultyId, facultyName);
    await fetchRequests(facultyId);
  }

  Future<void> forward(String requestId, String fromId, String fromName, String toId, String toName, String nextStatus) async {
    await ServiceConfig.requestRepo.forwardRequest(requestId, fromId, fromName, toId, toName, nextStatus);
    await fetchRequests(fromId);
  }
}
