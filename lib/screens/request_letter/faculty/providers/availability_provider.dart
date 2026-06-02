
import 'package:flutter/material.dart';
import '../models/faculty_model.dart';
import '../models/history_model.dart';
import 'service_config.dart';

class AvailabilityProvider with ChangeNotifier {
  List<Faculty> _allFaculty = [];
  bool _isLoading = false;

  List<Faculty> get allFaculty => _allFaculty;
  bool get isLoading => _isLoading;

  Future<void> fetchAllFaculty() async {
    _isLoading = true;
    notifyListeners();

    try {
      _allFaculty = await ServiceConfig.facultyRepo.getAllFaculty();
    } catch (e) {
      debugPrint('Fetch faculty error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateStaffStatus(String targetFacultyId, String status, String updatedByUid, String updatedByUsername) async {
    await ServiceConfig.facultyRepo.updateFacultyAvailability(targetFacultyId, status, updatedByUid, updatedByUsername);
    await fetchAllFaculty();
  }

  Future<List<AvailabilityHistory>> getHistory(String facultyId) async {
    return await ServiceConfig.facultyRepo.getAvailabilityHistory(facultyId);
  }
}
