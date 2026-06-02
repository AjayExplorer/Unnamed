
import 'package:flutter/material.dart';
import '../models/faculty_model.dart';
import 'service_config.dart';

class AuthProvider with ChangeNotifier {
  Faculty? _currentFaculty;
  bool _isLoading = false;

  Faculty? get currentFaculty => _currentFaculty;
  bool get isLoading => _isLoading;

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final faculty = await ServiceConfig.facultyRepo.login(username, password);
      if (faculty != null) {
        _currentFaculty = faculty;
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentFaculty = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    if (_currentFaculty == null) return;
    
    await ServiceConfig.facultyRepo.updateProfile(_currentFaculty!.facultyId, data);
    
    // Refresh local state
    final allFaculty = await ServiceConfig.facultyRepo.getAllFaculty();
    _currentFaculty = allFaculty.firstWhere((f) => f.facultyId == _currentFaculty!.facultyId);
    notifyListeners();
  }

  Future<void> updateMyAvailability(String status) async {
    if (_currentFaculty == null) return;
    
    await ServiceConfig.facultyRepo.updateFacultyAvailability(
      _currentFaculty!.facultyId,
      status,
      _currentFaculty!.facultyId,
      _currentFaculty!.name,
    );

    // Refresh local state
    final allFaculty = await ServiceConfig.facultyRepo.getAllFaculty();
    _currentFaculty = allFaculty.firstWhere((f) => f.facultyId == _currentFaculty!.facultyId);
    notifyListeners();
  }
}
