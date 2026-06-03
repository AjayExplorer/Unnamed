import 'package:flutter/material.dart';
import '../models/admin_model.dart';
import '../repositories/admin_repository.dart';

import '../../request_letter/faculty/models/faculty_model.dart';

class AdminProvider with ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  Admin? _currentAdmin;

  List<Faculty> _allFaculty = [];
  List<Map<String, dynamic>> _allAlerts = [];
  int _facultyCount = 0;
  bool _isLoading = false;
  String? _errorMessage;

  Admin? get currentAdmin => _currentAdmin;

  List<Faculty> get allFaculty => _allFaculty;
  List<Map<String, dynamic>> get allAlerts => _allAlerts;
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

      _facultyCount = await _repository.getFacultyCount();
      await loadAllFaculty();
      await loadAllAlerts();
    } catch (e) {
      _errorMessage = 'Unable to load dashboard: $e';
    }

    _isLoading = false;
    notifyListeners();
  }



  /// Add new faculty
  Future<bool> addFaculty(Faculty faculty) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.addFaculty(faculty);
      _facultyCount++;
      await loadAllFaculty();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to add faculty: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update existing faculty
  Future<bool> updateFaculty(Faculty faculty) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.updateFaculty(faculty);
      await loadAllFaculty();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to update faculty: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete faculty
  Future<bool> deleteFaculty(String facultyId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteFaculty(facultyId);
      _facultyCount = (_facultyCount - 1).clamp(0, double.infinity).toInt();
      await loadAllFaculty();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete faculty: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Load all faculty members
  Future<void> loadAllFaculty() async {
    try {
      _allFaculty = await _repository.getAllFaculty();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load faculty list: $e';
      notifyListeners();
    }
  }

  /// Load all alerts
  Future<void> loadAllAlerts() async {
    try {
      _allAlerts = await _repository.getAllAlerts();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load alerts: $e';
      notifyListeners();
    }
  }

  /// Delete an alert
  Future<bool> deleteAlert(String alertId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.deleteAlert(alertId);
      _allAlerts.removeWhere((alert) => alert['id'] == alertId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete alert: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentAdmin = null;

    _allFaculty = [];
    _allAlerts = [];
    _facultyCount = 0;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
