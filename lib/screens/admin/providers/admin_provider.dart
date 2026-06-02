import 'package:flutter/material.dart';
import '../models/admin_model.dart';
import '../repositories/admin_repository.dart';
import '../../request_letter/faculty/models/faculty_registration_request.dart';

class AdminProvider with ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  Admin? _currentAdmin;
  List<FacultyRegistrationRequest> _pendingRequests = [];
  int _facultyCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  Admin? get currentAdmin => _currentAdmin;
  List<FacultyRegistrationRequest> get pendingRequests => _pendingRequests;
  int get facultyCount => _facultyCount;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final admin = await _repository.login(username, password);
      if (admin != null) {
        _currentAdmin = admin;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Invalid Admin username or password';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Admin login failed: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _pendingRequests = await _repository.getPendingFacultyRegistrations();
      _facultyCount = await _repository.getFacultyCount();
    } catch (e) {
      _errorMessage = 'Unable to load dashboard: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> approveRequest(FacultyRegistrationRequest request) async {
    if (_currentAdmin == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.approveFacultyRegistration(request, _currentAdmin!.adminId, _currentAdmin!.name);
      await loadDashboard();
    } catch (e) {
      _errorMessage = 'Failed to approve request: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectRequest(String requestId, String rejectionReason) async {
    if (_currentAdmin == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.rejectFacultyRegistration(requestId, _currentAdmin!.adminId, _currentAdmin!.name, rejectionReason);
      await loadDashboard();
    } catch (e) {
      _errorMessage = 'Failed to reject request: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _currentAdmin = null;
    _pendingRequests = [];
    _facultyCount = 0;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
