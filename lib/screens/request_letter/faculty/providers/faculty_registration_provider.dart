import 'package:flutter/material.dart';
import '../models/faculty_registration_request.dart';
import '../models/faculty_model.dart';
import '../repositories/faculty_registration_repository.dart';

class FacultyRegistrationProvider with ChangeNotifier {
  final FacultyRegistrationRepository _repository = FacultyRegistrationRepository();
  bool _isSubmitting = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> submitRegistrationRequest({
    required String name,
    required String designation,
    required String username,
    required String password,
    required String phone,
    required String email,
    required String role,
  }) async {
    _isSubmitting = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final request = FacultyRegistrationRequest(
        requestId: '',
        name: name,
        designation: designation,
        username: username,
        password: password,
        profilePhoto: null,
        phone: phone,
        email: email,
        role: FacultyRole.values.firstWhere(
          (e) => e.toString().split('.').last == role,
          orElse: () => FacultyRole.teacher,
        ),
        status: 'Pending',
        submittedDate: DateTime.now(),
      );

      await _repository.submitRequest(request);
      _successMessage = 'Faculty registration request submitted successfully.';
      _isSubmitting = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Submission failed: $e';
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }
}
